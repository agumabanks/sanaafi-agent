<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\LoanOffer;
use App\Models\LoanPlan;
use App\Models\UserLoan;

use App\Models\LoanPayment;
use Illuminate\Support\Str;


use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Brian2694\Toastr\Facades\Toastr;

use App\Models\User;
use App\Models\Client;
use App\Models\AgentLoan;
use App\Models\Guarantor;

use App\Models\PaymentTransaction;

use App\CentralLogics\Helpers;
use App\Models\LoanPaymentInstallment;

class LoanOfferController extends Controller
{
    
    // client loan payment history api
      public function clientLoanspayHistory(Request $request): JsonResponse
    {
        $clientloanspays = LoanPayment::where('client_id', $request ->id)->get();
        return response()->json(response_formatter(DEFAULT_200, $clientloanspays, null), 200);
        
    }
    
    // delete loan
    public function deleteLoan($id)
        {
            // Find the loan by ID
            $loan = UserLoan::findOrFail($id);
        
            // Delete all loan installments associated with this loan
            LoanPaymentInstallment::where('loan_id', $loan->id)->delete();
        
            // Delete the loan itself
            $loan->delete();
        
            // Redirect back with success message
            return back()->with('success', 'Loan and its installments deleted successfully.');
        }

    
    
    public function addClientLoan($id)
        {
            // Fetch the necessary data
            // $loan = UserLoan::find($id); // Assuming $id refers to a loan
            $client = Client::find($id); // Assuming $loan has a client_id
            
            $loanPlans = LoanPlan::all();
        
            // Check if loan, client, or loanPlan is null and handle appropriately
            if (!$client || !$loanPlans) {
                return redirect()->back()->withErrors(['message' => 'Invalid Loan, Client, or Plan ID']);
            }
            
            $agents = User::join('clients', 'users.id', '=', 'clients.added_by')
                    ->select('users.id', 'users.f_name', 'users.l_name', 
                             \DB::raw('COUNT(clients.id) as client_count'),
                             \DB::raw('SUM(clients.credit_balance) as total_money_out'))
                    ->groupBy('users.id', 'users.f_name', 'users.l_name')
                    ->get();
                    
        
            // Return the view with the data
            return view('admin-views.Loans.addClientLoan', compact( 'client', 'loanPlans', 'agents'));
        }
        

// pay admin loan
    public function adminPayingLoan($id)
    {
        // Fetch client details
        $client = Client::find($id);
    
        if (!$client) {
            return response()->json(['errors' => 'Client not found'], 404);
        }
    
        // Find the running loan associated with this client
        $loan = UserLoan::where('client_id', $id)
            ->where('status', '<>', 2) // Exclude fully paid loans
            ->first();
    
        if (!$loan) {
            return response()->json(['errors' => 'No running loans found for the client'], 404);
        }
    
        // Fetch the agent associated with the loan 
        $agent = User::find($loan->user_id);
    
        // Fetch all payment slots (installments) associated with this loan
        $loanInstallments = LoanPaymentInstallment::where('loan_id', $loan->id)->get();
    
        // Return the view with the fetched data admin-views.Loans.pay-loan?
        return view('admin-views.Loans.pay-loan', compact('client', 'loanInstallments', 'loan', 'agent'));
    }


// agent pay loan

    public function payLoanF(Request $request): JsonResponse
    {
        try {
            // Validate the request inputs
            $validator = Validator::make($request->all(), [
                'client_id' => 'required|exists:clients,id',
                'amount' => 'required|numeric|min:0',
            ]);
    
            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 403);
            }
    
            $clientId = $request->input('client_id');
            $amountPaid = $request->input('amount');
            $agentId = $request->input('agent_id'); // Optional
            $transactionId = $this->generateTransactionId();
            $paymentType = 'loan'; // Loan payment type
            $today = now()->toDateString();
    
            // Get running loans for the client
            $loans = UserLoan::where('client_id', $clientId)
                ->where('status', '<>', 2) // Exclude fully paid loans
                ->get();
    
            if ($loans->isEmpty()) {
                return response()->json(['errors' => 'No running loans found for the client'], 404);
            }
    
            $totalPaid = $amountPaid;
            
            
            
            // Update client's credit balance
            $client->credit_balance -= $totalPaid;
            $client->save();
                
                
             
    
            foreach ($loans as $loan) {
                // Get today's installments for the current loan
                $installments = LoanPaymentInstallment::where('loan_id', $loan->id)
                    ->where('date', $today)
                    ->where('status', 'pending')
                    ->get();
    
                if ($installments->isEmpty()) {
                    continue;
                }
    
                foreach ($installments as $installment) {
                    // Update the installment status to 'paid' and save the installment
                    $installment->status = 'paid';
                    $installment->save();
    
                    // Update the loan's paid amount
                    $loan->paid_amount += $installment->install_amount;
    
                    
                    // Create a record for the payment made
                        LoanPayment::create([
                            'loan_id'       => $loan->id,
                            'client_id'     => $loan->client_id,
                            'agent_id'      => $loan->user_id,
                            'credit_balance'=> $client->credit_balance,
                            'amount'        => $totalPaid, // Original payment amount
                            'payment_date'  => now(), // Current date/time as the payment record date
                            'note'          => $validatedData['note'] ?? null,
                        ]);
    
    
                    // If the total paid amount is equal to or exceeds the final amount, update the loan status
                    if ($loan->paid_amount >= $loan->final_amount) {
                        $loan->status = 2; // Status 2 indicates a fully paid loan
                    }
    
                    // Save the loan updates
                    $loan->save();
    
                    // Deduct the installment amount from the total amount paid
                    $totalPaid -= $installment->install_amount;
    
                    // If the total amount paid covers the current installment, continue to the next
                    if ($totalPaid <= 0) {
                        break;
                    }
                }
    
                // If the total amount paid covers all installments, break the loop
                if ($totalPaid <= 0) {
                    break;
                }
            }
    
           
    
            // Return success response
            return response()->json([
                'response_code' => 'default_200',
                'message' => 'Loan installment(s) paid successfully'
            ], 200);
        } catch (\Exception $e) {
            // Log the error with all relevant details
            Log::error('Error processing loan payment', [
                'client_id' => $request->input('client_id'),
                'amount' => $request->input('amount'),
                'agent_id' => $request->input('agent_id'),
                'error' => $e->getMessage(),
                'stack_trace' => $e->getTraceAsString(),
            ]);
    
            // Return error response
            return response()->json([
                'response_code' => 'default_500',
                'message' => 'An error occurred while processing the loan payment. Please try again later.',
                'error' => $e->getMessage() // Optionally hide this in production for security reasons
            ], 500);
        }
    }

    public function payLoan(Request $request): JsonResponse
    {
        // Validate the request inputs
        $validatedData = $request->validate([
            'client_id' => 'required|exists:clients,id',
            'amount' => 'required|numeric|min:1',
            'note' => 'nullable|string|max:255',
        ]);
    
        $clientId = $validatedData['client_id'];
        $paymentAmount = $validatedData['amount'];
        $note = $validatedData['note'] ?? null;
        $paymentDate = now()->toDateString(); // Today's date
    
        // Retrieve the client and active loans
        $client = Client::findOrFail($clientId);
        $loans = UserLoan::where('client_id', $clientId)
            ->where('status', '<>', 2) // Exclude fully paid loans
            ->get();
    
        if ($loans->isEmpty()) {
            return response()->json(['errors' => 'No active loans found for this client'], 404);
        }
    
        $remainingPaymentAmount = $paymentAmount;
    
        foreach ($loans as $loan) {
            // Fetch installments due for today
            $installments = LoanPaymentInstallment::where('loan_id', $loan->id)
                ->where('date', $paymentDate)
                ->where('status', 'pending')
                ->get();
    
            foreach ($installments as $installment) {
                $installmentAmount = $installment->install_amount + $installment->installment_balance;
                
                if ($remainingPaymentAmount >= $installmentAmount) {
                    // Fully pay this installment
                    $installment->status = 'paid';
                    $installment->installment_balance = 0;
                    $remainingPaymentAmount -= $installmentAmount;
                } else {
                    // Partially pay this installment
                    $installment->status = 'withbalance';
                    $installment->installment_balance = $installmentAmount - $remainingPaymentAmount;
                    $remainingPaymentAmount = 0;
                }
    
                $installment->save();
    
                // Update loan's paid amount
                $loan->paid_amount += $installmentAmount - $installment->installment_balance;
                $loan->given_installment = $loan->given_installment + 1;
    
                // If loan is fully paid, update its status
                if ($loan->paid_amount >= $loan->final_amount) {
                    $loan->status = 2; // Fully Paid
                }
    
                $loan->save();
    
                // If no remaining payment amount, break out of the loop
                if ($remainingPaymentAmount <= 0) {
                    break;
                }
            }
    
            if ($remainingPaymentAmount <= 0) {
                break;
            }
        }
    
        // Deduct from client's credit balance
        $client->credit_balance -= $paymentAmount;
        $client->save();
    
        // Log the payment
        LoanPayment::create([
            'loan_id' => $loan->id,
            'client_id' => $clientId,
            'agent_id' => $loan->user_id, // Assuming the agent handling the loan
            'amount' => $paymentAmount,
            'credit_balance'=> $client->credit_balance,
            'payment_date' => now(),
            'note' => $note,
        ]);
    
        // Return a success response
        return response()->json([
            'response_code' => 'default_200',
            'message' => 'Loan payment processed successfully',
        ], 200);
    }
    


    public function updateLoanPayment(Request $request, $loanId)
    {
        // Validate the request inputs
        $validatedData = $request->validate([
            'payment_amount' => 'required|numeric|min:1',
            'payment_dates' => 'nullable|string', // Validate as a string
            'note' => 'nullable|string|max:255',
        ]);
    
        // If payment_dates is present, convert it to an array
        if ($request->has('payment_dates') && !empty($validatedData['payment_dates'])) {
            $validatedData['payment_dates'] = explode(',', $validatedData['payment_dates']);
            
            // Validate the dates after conversion
            foreach ($validatedData['payment_dates'] as $date) {
                if (!\Carbon\Carbon::createFromFormat('Y-m-d', trim($date))) {
                    return redirect()->back()->withErrors(['payment_dates' => 'Invalid date format.']);
                }
            }
        } else {
            $validatedData['payment_dates'] = [];
        }
    
        // Retrieve the loan and related details
        $loan = UserLoan::findOrFail($loanId);
        $client = Client::find($loan->client_id);
    
        // Calculate the new paid amount and remaining balance
        $newPaidAmount = $loan->paid_amount + $validatedData['payment_amount'];
        $remainingAmount = $loan->final_amount - $newPaidAmount;
    
        // Update the loan payment details
        $loan->paid_amount = $newPaidAmount;
    
        // If the loan is fully paid, update the status
        if ($remainingAmount <= 0) {
            $loan->status = 2; // Fully Paid
        }
    
        // Save the loan
        $loan->save();
    
        // Update client's credit balance
        $client->credit_balance -= $validatedData['payment_amount'];
        $client->save();
    
        // Check and log payment_dates
        if (!empty($validatedData['payment_dates'])) {
            \Log::info('Payment Dates:', $validatedData['payment_dates']);
            $paymentAmountRemaining = $validatedData['payment_amount'];
    
            foreach ($validatedData['payment_dates'] as $paymentDate) {
                $installment = LoanPaymentInstallment::where('loan_id', $loanId)
                    ->where('date', trim($paymentDate))
                    ->first();
    
                if ($installment) {
                    $installmentAmount = $installment->install_amount;
                    $installmentBalance = $installment->installment_balance;
    
                    $totalInstallmentAmount = $installmentAmount + $installmentBalance;
    
                    if ($paymentAmountRemaining >= $totalInstallmentAmount) {
                        $installment->status = 'paid';
                        $installment->installment_balance = 0;
                        $paymentAmountRemaining -= $totalInstallmentAmount;
                    } else {
                        $installment->status = 'withbalance';
                        $installment->installment_balance = $totalInstallmentAmount - $paymentAmountRemaining;
                        $paymentAmountRemaining = 0;
                    }
    
                    $installment->save();
                } else {
                    \Log::warning("Installment not found for loan_id: $loanId and date: $paymentDate");
                }
    
                if ($paymentAmountRemaining <= 0) {
                    break;
                }
            }
        } else {
            \Log::info('No payment dates provided.');
        }
    
        // Create a record for the payment made
        LoanPayment::create([
            'loan_id'       => $loan->id,
            'client_id'     => $loan->client_id,
            'agent_id'      => $loan->user_id,
            'credit_balance'=> $client->credit_balance,
            'amount'        => $validatedData['payment_amount'], // Original payment amount
            'payment_date'  => now(), // Current date/time as the payment record date
            'note'          => $validatedData['note'] ?? null,
        ]);
    
        // Provide feedback to the user
        Toastr::success('Loan payment updated successfully');
    
        // Redirect back to the loan details page
        return redirect()->route('admin.loans.show', $loanId)->with('success', 'Payment processed successfully!');
    }





    public function updateLoanPayment10(Request $request, $loanId)
    {
        // dd($request->all());
    
        // Validate the request inputs
        $validatedData = $request->validate([
            'payment_amount' => 'required|numeric|min:1',
            'payment_dates' => 'nullable|string', // Validate as a string
            'note' => 'nullable|string|max:255',
        ]);
    
        // If payment_dates is present, convert it to an array
        if ($request->has('payment_dates') && !empty($validatedData['payment_dates'])) {
            $validatedData['payment_dates'] = explode(',', $validatedData['payment_dates']);
            
            // Validate the dates after conversion
            foreach ($validatedData['payment_dates'] as $date) {
                if (!\Carbon\Carbon::createFromFormat('Y-m-d', trim($date))) {
                    return redirect()->back()->withErrors(['payment_dates' => 'Invalid date format.']);
                }
            }
        } else {
            $validatedData['payment_dates'] = [];
        }
    
        // Retrieve the loan and related details
        $loan = UserLoan::findOrFail($loanId);
        $client = Client::find($loan->client_id);
    
    
        // Calculate the new paid amount and remaining balance
        $newPaidAmount = $loan->paid_amount + $validatedData['payment_amount'];
        $remainingAmount = $loan->final_amount - $newPaidAmount;
    
        // Update the loan payment details
        $loan->paid_amount = $newPaidAmount;
    
        // If the loan is fully paid, update the status
        if ($remainingAmount <= 0) {
            $loan->status = 2; // Fully Paid
        }
    
        // Save the loan
        $loan->save();
        
        
         // Update client's credit balance
        $client->credit_balance -= $validatedData['payment_amount'];
        $client->save();
    
        // Check and log payment_dates
        if (!empty($validatedData['payment_dates'])) {
            \Log::info('Payment Dates:', $validatedData['payment_dates']);
            foreach ($validatedData['payment_dates'] as $paymentDate) {
                $installment = LoanPaymentInstallment::where('loan_id', $loanId)
                    ->where('date', trim($paymentDate))
                    ->first();
                if ($installment) {
                    $installment->status = 'paid';
                    $installment->save();
                } else {
                    \Log::warning("Installment not found for loan_id: $loanId and date: $paymentDate");
                }
            }
        } else {
            \Log::info('No payment dates provided.');
        }
    
        // Create a record for the payment made
        LoanPayment::create([
            'loan_id'       => $loan->id,
            'client_id'     => $loan->client_id,
            'agent_id'      => $loan->user_id,
            'amount'        => $validatedData['payment_amount'], // Original payment amount
            'payment_date'  => now(), // Current date/time as the payment record date
            'note'          => $validatedData['note'] ?? null,
            
        ]);
    
        // Provide feedback to the user
        Toastr::success('Loan payment updated successfully');
    
        // Redirect back to the loan details page
        // return redirect()->route('admin.loans.show', $loanId);
            return redirect()->route('admin.loans.show', $loanId)->with('success', 'Payment processed successfully!');
    
    }



    public function storeClientLoan(Request $request)
    {
        // Validate the request data
        $validatedData = $request->validate([
            'client_id' => 'required|exists:clients,id',
            'agent_id' => 'required|exists:users,id',
            'amount' => 'required|numeric|min:0',
            'installment_interval' => 'required|numeric|min:1',
            'paid_amount' => 'nullable|numeric|min:0',
            'next_installment_date' => 'nullable|date', // Ensure date validation if present
            'note' => 'nullable|string|max:255', // Adding note validation if provided
        ]);
    
        // Calculate per installment and final amount
        $per_installment = ($validatedData['amount'] * 1.2) / $validatedData['installment_interval'];
        $final_amount = $validatedData['amount'] * 1.2;
    
        // Calculate remaining amount
        $remaining_amount = $final_amount - ($validatedData['paid_amount'] ?? 0);
    
        // Create a new UserLoan instance
        $loan = new UserLoan();
        $loan->user_id = $validatedData['agent_id'];
        $loan->plan_id = 8; // Assuming plan_id is static or predefined
        $loan->trx = $this->generateUniqueTrx(); // Generate unique transaction ID
        $loan->amount = $validatedData['amount'];
        $loan->per_installment = $per_installment;
        $loan->installment_interval = $validatedData['installment_interval'];
        $loan->total_installment = $validatedData['installment_interval'];
        $loan->paid_amount = $validatedData['paid_amount'] ?? 0.00;
        $loan->final_amount = $final_amount;
        $loan->user_details = $request->user_details ?? null;
        $loan->admin_feedback = null; // Assuming this field is optional
        $loan->status = 0; // Assuming default status is 0
        $loan->next_installment_date = $validatedData['next_installment_date'] ?? null;
        $loan->client_id = $validatedData['client_id']; // Assign the client ID
        $loan->save(); // Save the loan to the database
    
        // Check if paid amount is greater than 0 to create a LoanPayment record
        if ($validatedData['paid_amount'] > 0) {
            // Create a record for the payment made
            LoanPayment::create([
                'loan_id' => $loan->id,
                'client_id' => $validatedData['client_id'],
                'agent_id' => $validatedData['agent_id'],
                'amount' => $validatedData['paid_amount'], // Use the correct paid amount
                'payment_date' => now(), // Current date/time as the payment record date
                'note' => $validatedData['note'] ?? null, // Include optional note if provided
            ]);
        }
    
        // Redirect back with success message
        return redirect()->route('admin.loan-pendingLoans')->with('success', 'Loan added successfully for client ');
    }
    
 
    
    public function createLoan(Request $request): JsonResponse
    {
        // Validate the request data
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'client_id' => 'required|exists:clients,id',
            'trx' => 'nullable|string|max:40',
            'amount' => 'required|numeric|min:0',
             
        ]);
    
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 403);
        }
    
        // Fetch the client and agent
        $client = Client::find($request->client_id);
        if (!$client) {
            return response()->json(['message' => 'Client not found'], 404);
        }
    
        $agent = User::findOrFail($request->user_id);
    
        // Calculate per installment and final amount
        $per_installment = ($request->amount * 1.2) / $request->installment_interval;
        $final_amount = $request->amount * 1.2;
    
        // Calculate remaining amount
        $remaining_amount = $final_amount - ($request->paid_amount ?? 0);
    
        // Create a new UserLoan instance
        $loan = new UserLoan();
        $loan->user_id = $request->user_id;
        $loan->plan_id = 8;  // Assuming plan_id is static or predefined
        $loan->trx = $request->trx; // Generate unique transaction ID
        $loan->amount = $request->amount;
        $loan->per_installment = $per_installment;
        $loan->installment_interval = $request->installment_interval;
        $loan->total_installment = $request->installment_interval;
        $loan->paid_amount = $request->paid_amount ?? 0.00;
        $loan->final_amount = $final_amount;
        $loan->user_details = $request->user_details ?? null;
        $loan->admin_feedback = null;  // Assuming this field is optional
        $loan->status = 0;  // Assuming default status is 0
        $loan->next_installment_date = $request->next_installment_date ?? null;
        $loan->client_id = $request->client_id; // Assign the client ID
        $loan->save();  // Save the loan to the database
    
        // Create a new agent loan record
        $agentLoan = new AgentLoan();
        $agentLoan->user_id = $request->user_id;
        $agentLoan->client_id = $request->client_id;
        $agentLoan->loan_amount = $request->amount;
        $agentLoan->final_loan_amount = $final_amount;
        $agentLoan->save();
        
        
         // Check if paid amount is greater than 0 to create a LoanPayment record
        if ($request->paid_amount > 0) {
            // Create a record for the payment made
            LoanPayment::create([
                'loan_id' => $loan->id,
                'client_id' => $request->client_id,
                'agent_id' => $request->agent_id,
                'amount' => $request->paid_amount, // Use the correct paid amount
                'payment_date' => now(), // Current date/time as the payment record date
                // 'note' => $validatedData['note'] ?? null, // Include optional note if provided
            ]);
        }
    
        return response()->json(response_formatter(DEFAULT_200, $loan, null), 200);
    }
        
        
    
    function generateUniqueTrx()
        {
            do {
                // Generate a random transaction ID
                $trx = 'TRX' . Str::random(8);
                
                // Check if the trx already exists in the UserLoan table
                $exists = UserLoan::where('trx', $trx)->exists();
            } while ($exists);
        
            return $trx;
        }
    
    public function editLoan($id) {
            // Find the loan by ID
            $loan = UserLoan::findOrFail($id);
        
            // Retrieve the related client and loan plan
            $client = Client::find($loan->client_id);
            $loanPlan = LoanPlan::find($loan->plan_id);
        
            // Pass the loan, client, and loan plan data to the view
            return view('admin-views.Loans.edit', compact('loan', 'client', 'loanPlan'));
        }

    public function editLoan2(Request $request){
        $loan = UserLoan::findOrFail($request->id);
        $client = Client::find($loan->client_id);
         $loanPlan = LoanPlan::find($loan->plan_id);
         return view('admin-views.Loans.edit', compact('loan', 'client', 'loanPlan'));
    }
    
    public function saveLoanEdit2(Request $request)
        {
            // Validate the request
            $request->validate([
                'id' => 'required|exists:user_loans,id', // Ensure the loan ID exists
                'amount' => 'required|numeric|min:0',
                'per_installment' => 'required|numeric|min:0',
                'installment_interval' => 'required|integer|min:1',
                'total_installment' => 'required|integer|min:1',
                // Add more validation rules as needed based on your loan fields
            ]);
            
            $loan = UserLoan::findOrFail($request->id);
        
            // Check if the loan is in a pending or running state (status 0 or 1)
            if ($loan->status != 0 && $loan->status != 1) {
                return response()->json([
                    'success' => false,
                    'message' => 'Loan cannot be edited in its current state.',
                ]);
            }
        
            // Update the loan details
            $loan->amount = $request->amount;
            $loan->per_installment = $request->per_installment;
            $loan->installment_interval = $request->installment_interval;
            $loan->total_installment = $request->installment_interval;
            // Update other loan fields as needed
        
            // Recalculate final_amount if necessary (based on your interest calculation logic)
        
            // Save the changes
            $loan->save();
        
            return this-> showLoan( $loan->id);
        }
        
        
        
        
        public function saveLoanEdit(Request $request)
            {
                
                $loan = UserLoan::findOrFail($request->id);
            
                // Check if the loan is in a pending or running state (status 0 or 1)
                if ($loan->status != 0 && $loan->status != 1) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Loan cannot be edited in its current state.',
                    ]);
                }
            
                // Update the loan details
                $loan->amount = $request->amount;
                $loan->per_installment = $request->per_installment;
                $loan->installment_interval = $request->installment_interval;
                $loan->total_installment = $request->installment_interval;
                $loan->final_amount = $loan->per_installment * $loan->total_installment;
                $loan->processing_fee = $request->processing_fee;

               
                // Save the changes
                $loan->save();
            
                // Redirect to the loan details view after saving the changes
                return $this->showLoan($loan->id);
            }

        
     public function showLoan($id)
    {
        // Fetch the loan by ID
        $loan = UserLoan::findOrFail($id);
    
        // Retrieve client details using the client_id
        $client = Client::find($loan->client_id);
        
        $agent = User::find($loan->user_id); 
    
        // Retrieve loan plan details using the plan_id
        $loanPlan = LoanPlan::find($loan->plan_id);
        
        // CLIENT guarantors
        $clientGuarantors =   Guarantor::where('client_id', $loan->client_id)->get();
        $loanSlots =  LoanPaymentInstallment::where('client_id', $loan->client_id)->get();


    
        // Pass the loan, client, and loan plan data to the view
        return view('admin-views.Loans.view', [
            'loan' => $loan,
            'client' => $client,
            'loanPlan' => $loanPlan,
            'agent' => $agent,
            'clientGuarantors' => $clientGuarantors,
            'loanSlots' => $loanSlots
        ]);
    }
    
    
    // on loan approval, create payment slots/plan
    public function approveLoan(Request $request)
        {
           
            $loan = UserLoan::findOrFail($request->id);
            $client = Client::find($loan->client_id);
            $clientGuarantors =   Guarantor::where('client_id', $loan->client_id)->get();
        
            // Check if the loan is in a pending state (status 0)
            if ($loan->status != 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Loan is not in a pending state.',
                ]);
            }
            
            
             // Check if the client has no guarantors 
            // if ($clientGuarantors->isEmpty()) {
            //         //   return response()->warning('Client has no guarantors.'); // Assuming you have a 'warning' response helper
            //         Toastr::error(translate('Client has no guarantors.'));
            //       return back();
            // }
        
            // Check if client credit balance is greater than 0 
            if ($client->credit_balance > 0) { // Assuming you have a 'credit_balance' column on your Client model
                
                
                Toastr::error(translate('Client has a positive credit balance.'));
                   return back();
            }
             
            if ($loan->status != 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Loan is not in a pending state.',
                ]);
            }
        
            // Update the loan status to 'Running' (status 1)
            $loan->status = 1;
            $loan->disbursed_at = now();
            $loan->due_date = now()->addDays($loan->installment_interval);
            
            // set the client credit balance to the add the loan
        
            // Set the next installment date (assuming today is the approval date)
            $loan->next_installment_date = now()->addDays($loan->installment_interval);
        
            // Save the changes
            $loan->save();
            
            
           // Set the next installment date (assuming today is the approval date)
            $loan->next_installment_date = now()->addDays($loan->installment_interval);
            $loan->save();
        
            // Update the client's credit balance by adding the loan amount
            $client->credit_balance = isset($client->credit_balance) ? $client->credit_balance + $loan->final_amount : $loan->final_amount;
            $client->save();

            
            // Generate payment installments
            $this->createPaymentInstallments($loan);
        
            return back();
        }
     
     
         
    // payment slots created after the loan is approved
    protected function createPaymentInsta(UserLoan $loan)
        {
            $installmentAmount = $loan->per_installment;
            $totalInstallments = $loan->total_installment;
        
            for ($i = 0; $i < $totalInstallments; $i++) {
                $installmentDate = now()->addDays($i); // Add days incrementally for daily installments
        
                LoanPaymentInstallment::create([
                    'loan_id' => $loan->id,
                    'agent_id' => $loan->user_id,
                    'client_id' => $loan->client_id,
                    'install_amount' => $installmentAmount,
                    'date' => $installmentDate,
                    'status' => 'pending', // Initially set status as 'pending'
                ]);
            }
        }


protected function createPaymentInstallments(UserLoan $loan)
{
    $installmentAmount = $loan->per_installment;
    $installmentInterval = $loan->installment_interval;
    $totalInstallments = $loan->total_installment;

    for ($i = 1; $i <= $totalInstallments; $i++) {
        // Calculate the base installment date
        $installmentDate = now()->addDays($i);

        // Adjust the time to 11 AM to ensure it falls within the business day
        $installmentDate->setTime(11, 0);

        // Save the installment
        LoanPaymentInstallment::create([
            'loan_id' => $loan->id,
            'agent_id' => $loan->user_id,
            'client_id' => $loan->client_id,
            'install_amount' => $installmentAmount,
            'date' => $installmentDate,
            'status' => 'pending', // Initially set status as 'pending'
        ]);
    }
}

     
   
     
     
     
     
     
     
     
   
    
   public function getClientQr(Request $request): JsonResponse
{
    // Retrieve a single client record
    $customer = Client::where('id', $request->client_id)->first();
    
    // Check if the customer exists
    if ($customer) {
        $data = [];
        $data['name'] = $customer->name;
        $data['phone'] = $customer->phone;
        $data['clientid'] = $customer->id;
        $data['image'] = $customer->image;
        
        $qr = Helpers::get_qrcode_client($data); 
        
        

        // Return the response with customer data
        return response()->json([
            'qr_code' => strval($qr),
        ], 200);
    } else {
        // Handle case where the customer was not found
        return response()->json([
            'message' => 'Client not found',
        ], 404);
    }
}

    
    
    // pay loan 
  public function payLoan3(Request $request): JsonResponse
{
    $validator = Validator::make($request->all(), [
        'client_id' => 'required|exists:clients,id',
        'amount' => 'required|numeric|min:0',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 403);
    }

    $clientId = $request->input('client_id');
    $amountPaid = $request->input('amount');
    $today = now()->toDateString();

    // Get running loans for the client
    $loans = UserLoan::where('client_id', $clientId)
        ->where('status', '<>', 2) // Exclude fully paid loans
        ->get();

    if ($loans->isEmpty()) {
        return response()->json(['errors' => 'No running loans found for the client'], 404);
    }

    $totalPaid = $amountPaid;

    foreach ($loans as $loan) {
        // Get today's installments for the current loan
        $installments = LoanPaymentInstallment::where('loan_id', $loan->id)
            ->where('date', $today)
            ->where('status', 'pending')
            ->get();

        if ($installments->isEmpty()) {
            continue;
        }

        foreach ($installments as $installment) {
            // Update the installment status to 'paid' and the amount paid
            $installment->status = 'paid';
            $installment->save();

            // Update the loan's paid amount
            $loan->paid_amount += $installment->install_amount;

            // If the total paid amount is equal to or exceeds the final amount, update the loan status
            if ($loan->paid_amount >= $loan->final_amount) {
                $loan->status = 2; // Status 2 indicates a fully paid loan
            }

            $loan->save();

            // Deduct the installment amount from the total amount paid
            $totalPaid -= $installment->install_amount;

            // If the total amount paid covers the current installment, continue to the next
            if ($totalPaid <= 0) {
                break;
            }
        }

        // If the total amount paid covers all installments, break the loop
        if ($totalPaid <= 0) {
            break;
        }
    }

    return response()->json([
        'response_code' => 'default_200',
        'message' => 'Loan installment(s) paid successfully'], 200);
}


public function payLoan33(Request $request): JsonResponse
{
    $validator = Validator::make($request->all(), [
        'client_id' => 'required|exists:clients,id',
        'amount' => 'required|numeric|min:0',
        'agent_id' => 'nullable|exists:agents,id', // Optional, only if there's an agent involved
        'transaction_id' => 'required|unique:payment_transactions,transaction_id',
        'payment_type' => 'required|string', // e.g., cash, card, mobile, etc.
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 403);
    }

    $clientId = $request->input('client_id');
    $amountPaid = $request->input('amount');
    $agentId = $request->input('agent_id');  // Optional
    $transactionId = $request->input('transaction_id');
    $paymentType = $request->input('payment_type');
    $today = now()->toDateString();

    // Get running loans for the client
    $loans = UserLoan::where('client_id', $clientId)
        ->where('status', '<>', 2) // Exclude fully paid loans
        ->get();

    if ($loans->isEmpty()) {
        return response()->json(['errors' => 'No running loans found for the client'], 404);
    }

    $totalPaid = $amountPaid;

    foreach ($loans as $loan) {
        // Get today's installments for the current loan
        $installments = LoanPaymentInstallment::where('loan_id', $loan->id)
            ->where('date', $today)
            ->where('status', 'pending')
            ->get();

        if ($installments->isEmpty()) {
            continue;
        }

        foreach ($installments as $installment) {
            // Update the installment status to 'paid' and the amount paid
            $installment->status = 'paid';
            $installment->save();

            // Update the loan's paid amount
            $loan->paid_amount += $installment->install_amount;

            // Create a new payment transaction record
            PaymentTransaction::create([
                'client_id' => $clientId,
                'loan_id' => $loan->id,
                'agent_id' => $agentId, // Optional
                'transaction_id' => $transactionId,
                'payment_type' => $paymentType,
                'amount' => $installment->install_amount,
                'status' => 'completed',
                'paid_at' => now(),
            ]);

            // If the total paid amount is equal to or exceeds the final amount, update the loan status
            if ($loan->paid_amount >= $loan->final_amount) {
                $loan->status = 2; // Status 2 indicates a fully paid loan
            }

            $loan->save();

            // Deduct the installment amount from the total amount paid
            $totalPaid -= $installment->install_amount;

            // If the total amount paid covers the current installment, continue to the next
            if ($totalPaid <= 0) {
                break;
            }
        }

        // If the total amount paid covers all installments, break the loop
        if ($totalPaid <= 0) {
            break;
        }
    }

    return response()->json([
        'response_code' => 'default_200',
        'message' => 'Loan installment(s) paid successfully'], 200);
}




    protected function generateTransactionId()
        {
            do {
                $transactionId = 'abROi' . mt_rand(1000000000, 9999999999);
            } while (PaymentTransaction::where('transaction_id', $transactionId)->exists());
        
            return $transactionId;
        }


// pay loan tests





public function payLoanNew(Request $request): JsonResponse
{
    // Validate incoming request
    $validator = Validator::make($request->all(), [
        'client_id' => 'required|exists:clients,id',
        'amount' => 'required|numeric|min:0',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 403);
    }

    // Get input values
    $clientId = $request->input('client_id');
    $amountPaid = $request->input('amount');
    $agentId = $request->input('agent_id'); // Optional
    $transactionId = $this->generateTransactionId();
    $paymentType = 'loan'; // Default to loan
    $today = now()->toDateString();

    // Fetch client details
    $client = Client::find($clientId);
    if (!$client) {
        return response()->json(['errors' => 'Client not found'], 404);
    }

    // Find the running loan for the client
    $loan = UserLoan::where('client_id', $clientId)
        ->where('status', '<>', 2) // Exclude fully paid loans
        ->first();

    if (!$loan) {
        return response()->json(['errors' => 'No running loans found for the client'], 404);
    }

    // Fetch the agent associated with the loan
    $agent = User::find($loan->user_id);

    // Fetch all installments for the current loan
    $installments = LoanPaymentInstallment::where('loan_id', $loan->id)
        ->where('status', 'pending') // Only consider pending installments
        ->get();

    // If no installments are found, return an error
    if ($installments->isEmpty()) {
        return response()->json(['errors' => 'No pending installments found for the loan'], 404);
    }

    // Process payment for available installments
    $totalPaid = $amountPaid;

    foreach ($installments as $installment) {
        if ($totalPaid <= 0) {
            break;
        }

        // Mark the installment as paid and deduct from the total paid amount
        $installmentAmount = min($installment->install_amount, $totalPaid);
        $installment->status = 'paid';
        $installment->save();

        // Update the loan's paid amount
        $loan->paid_amount += $installmentAmount;

        // Create payment transaction record
        PaymentTransaction::create([
            'client_id' => $clientId,
            'loan_id' => $loan->id,
            'agent_id' => $agentId, // Optional
            'transaction_id' => $transactionId,
            'payment_type' => $paymentType,
            'amount' => $installmentAmount,
            'status' => 'completed',
            'paid_at' => now(),
        ]);

        // Deduct from the total paid amount
        $totalPaid -= $installmentAmount;

        // If the loan is fully paid, update the status
        if ($loan->paid_amount >= $loan->final_amount) {
            $loan->status = 2; // Fully paid loan
            $loan->save();
            break;
        }
    }

    // Return success response
    return response()->json([
        'response_code' => 'default_200',
        'message' => 'Loan installment(s) paid successfully',
    ], 200);
}






public function payLoan111e(Request $request): JsonResponse
{
    $validator = Validator::make($request->all(), [
        'client_id' => 'required|exists:clients,id',
        'amount' => 'required|numeric|min:0',
        'agent_id' => 'nullable|exists:agents,id', // Optional, only if there's an agent involved
        'transaction_id' => 'required|unique:payment_transactions,transaction_id',
        'payment_type' => 'required|string', // e.g., cash, card, mobile, etc.
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 403);
    }

    $clientId = $request->input('client_id');
    $amountPaid = $request->input('amount');
    $agentId = $request->input('agent_id');
    $transactionId = $request->input('transaction_id');
    $paymentType = $request->input('payment_type');
    $today = now()->toDateString();

    // Record the payment transaction
    $paymentTransaction = PaymentTransaction::create([
        'client_id' => $clientId,
        'amount' => $amountPaid,
        'agent_id' => $agentId,
        'transaction_id' => $transactionId,
        'payment_type' => $paymentType,
        'status' => 'completed',
        'paid_at' => now(),
    ]);

    // The rest of the payLoan logic remains the same
    // Get running loans for the client
    $loans = UserLoan::where('client_id', $clientId)
        ->where('status', '<>', 2) // Exclude fully paid loans
        ->get();

    if ($loans->isEmpty()) {
        return response()->json(['errors' => 'No running loans found for the client'], 404);
    }

    $totalPaid = $amountPaid;

    foreach ($loans as $loan) {
        // Get today's installments for the current loan
        $installments = LoanPaymentInstallment::where('loan_id', $loan->id)
            ->where('date', $today)
            ->where('status', 'pending')
            ->get();

        if ($installments->isEmpty()) {
            continue;
        }

        foreach ($installments as $installment) {
            // Update the installment status to 'paid' and the amount paid
            $installment->status = 'paid';
            $installment->save();

            // Update the loan's paid amount
            $loan->paid_amount += $installment->install_amount;

            // Associate the payment transaction with the loan
            $paymentTransaction->loan_id = $loan->id;
            $paymentTransaction->save();

            // If the total paid amount is equal to or exceeds the final amount, update the loan status
            if ($loan->paid_amount >= $loan->final_amount) {
                $loan->status = 2; // Status 2 indicates a fully paid loan
            }

            $loan->save();

            // Deduct the installment amount from the total amount paid
            $totalPaid -= $installment->install_amount;

            // If the total amount paid covers the current installment, continue to the next
            if ($totalPaid <= 0) {
                break;
            }
        }

        // If the total amount paid covers all installments, break the loop
        if ($totalPaid <= 0) {
            break;
        }
    }

    return response()->json([
        'response_code' => 'default_200',
        'message' => 'Loan installment(s) paid successfully'], 200);
}

    
    
    
   public function todaysLoanInstallments(): JsonResponse
    {
        // Get today's date in Y-m-d format
        $today = now()->toDateString();
        
        // Query LoanPaymentInstallment for today's date and pending status todaysLoanInstallments
    $installments = LoanPaymentInstallment::where('date', $today)
        ->where('status', 'pending')
        ->get();
        
        // Check if there are any installments for today
        if ($installments->isEmpty()) {
            return response()->json(['message' => 'No installments due today'], 404);
        }
    
        // Return the installments
        return response()->json(response_formatter(DEFAULT_200, $installments, null), 200);
        
        
        
    }
    
    
    // today schedule
    public function todaysSchedule(Request $request): JsonResponse
    {
        // Get today's date in Y-m-d format
        $today = now()->toDateString();
        
        $agentId = $request->input('agent_id');
        
        // Query LoanPaymentInstallment for today's date and pending status todaysLoanInstallments
        $installments = LoanPaymentInstallment::where('agent_id', $agentId)
            ->where('date', $today)
            ->get();
    
    
    // $totalAmount = LoanPaymentInstallment::where('agent_id', $agentId)
    //                 ->where('date', $today)
    //                 ->sum('install_amount');
                    
                    
            // Prepare the response data with client details
    $responseData = [];

    foreach ($installments as $installment) {
        // Get client details for each installment
        $client = Client::find($installment->client_id);

        $responseData[] = [
            'id' => $installment->id,
            'loan_id' => $installment->loan_id,
            'agent_id' => $installment->agent_id,
            'client_id' => $installment->client_id,
            'client_name' => $client ? $client->name : null, // Assuming 'name' is a field in the clients table
            'client_phone' => $client ? $client->phone : null, // Assuming 'phone' is a field in the clients table
            'install_amount' => $installment->install_amount,
            'date' => $installment->date,
            'status' => $installment->status,
            'created_at' => $installment->created_at,
            'updated_at' => $installment->updated_at,
        ];
    }
    
     return response()->json([
        'response_code' => 'default_200',
        'message' => 'Successfully fetched data',
        'DataContent' => $responseData
    ], 200);
    
     // Return the installments with client details
    // return response()->json(response_formatter(DEFAULT_200, $responseData, null), 200);
    }
    
    
    // collected 
    
    
    // daily total for agent for today
  public function totalAmountForAgentOnDate(Request $request): JsonResponse
{
    // Get today's date and time at 11 am
    $startOfBusinessDay = now()->setTime(11, 0, 0);
    
    // Get the agent_id from the request
    $agentId = $request->input('agent_id');

    // Query the installments for the given agent from 11 am today
    $totalAmount = LoanPaymentInstallment::where('agent_id', $agentId)
                    ->whereDate('date', now()->toDateString()) // Ensure only the date part is considered
                    ->sum('install_amount');
                    
    $totalAmountCollected = LoanPaymentInstallment::where('agent_id', $agentId)
                    ->whereDate('date', now()->toDateString()) // Ensure only the date part is considered
                    ->where('status', 'paid')
                    ->sum('install_amount');

    // Return the total amount the agent needs to collect
    return response()->json([
        'response_code' => 'default_200',
        'message' => 'Successfully fetched data',
        'total_amount' => $totalAmount,
        'collected' => $totalAmountCollected
    ], 200);
}


    
    public function totalAmountForAgentOnDate1000(Request $request): JsonResponse
    {
        // Get today's date in Y-m-d format
        $today = now()->toDateString();
        
   

    // Get the agent_id and date from the request
    $agentId = $request->input('agent_id');
    // $date = $request->input('date');

    // Query the installments for the given agent and date
    $totalAmount = LoanPaymentInstallment::where('agent_id', $agentId)
                    ->where('date', $today)
                    ->sum('install_amount');
                    
    $totalAmountCollected = LoanPaymentInstallment::where('agent_id', $agentId)
                    ->where('date', $today)
                    ->where('status', 'paid')
                    ->sum('install_amount');

    // Return the total amount the agent needs to collect
    return response()->json([
        'response_code' => 'default_200',
        'message' => 'Successfully fetched data',
        'total_amount' => $totalAmount,
        'collected' => $totalAmountCollected
    ], 200);
}


    
     // loan Plans
     public function allplans(){
        //  get all the available plans
        $loanPlans = LoanPlan::all();
        
         return view('admin-views.Loans.plan.index', compact('loanPlans'));
     }
    // add 
    public function addplan(){
         return view('admin-views.Loans.plan.create');
    }
    
     // create 
    public function createplan(Request $request){
        $request->validate([
            'plan_name' => 'required|string|max:255',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|min:0',
            'installment_value' => 'required|numeric|min:0',
            'installment_interval' => 'required|numeric|min:0',
            'total_installments' => 'required|integer|min:1',
            'instructions' => 'nullable|string',
        ]);

        LoanPlan::create($request->all());
        
        return view('admin-views.Loans.plan.create');
    }
    
    
    // edit 
       public function editplan($id){
         $loanPlan = LoanPlan::findOrFail($id);
         return view('admin-views.Loans.plan.edit',compact('loanPlan'));
    }
     
     
    //  delet paln 
    public function destroyNow($id)
    {
         
        $loanPlan = LoanPlan::findOrFail($id);
        $loanPlan->delete();

        return redirect()->route('admin.loan-plans')->with('success', 'Loan Plan deleted successfully');
    }
    
    
    
    
     public function updateNow(Request $request, $id)
    {
        $request->validate([
            'plan_name' => 'required|string|max:255',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|min:0',
            'installment_value' => 'required|numeric|min:0',
            'installment_interval' => 'required|numeric|min:0',
            'total_installments' => 'required|integer|min:1',
            'instructions' => 'nullable|string',
        ]);

        $loanPlan = LoanPlan::findOrFail($id);
        $loanPlan->update($request->all());

        return redirect()->route('admin.loan-plans')->with('success', 'Loan Plan updated successfully');
    }
     
     
     // all loans
     public function all_loans(){
        //  get all the available plans
        // $loanPlans = LoanPlan::all();
        $pageTitle      = 'All Loans';

        if(request()->search){
            $query          = UserLoan::where('trx', request()->search);
            $emptyMessage   = 'No Data Found';
        }else{
            $query          = UserLoan::latest();
            $emptyMessage   = 'No Loan Yet';
        }

        $loans = $query->paginate(20);
        
         return view('admin-views.Loans.index', compact('pageTitle', 'emptyMessage', 'loans'));
     }
     
        
        
        
    // paid Loans
        
    public function paidLoans()
     {
                $pageTitle      = 'Paid Loans';
        
        
                if(request()->search){
                    $query          = UserLoan::paid()->where('trx', request()->search);
                    $emptyMessage   = 'No Data Found';
                }else{
                    $query          = UserLoan::paid()->latest();
                    $emptyMessage   = 'No Paid Loan Yet';
                }
        
                $loans = $query->paginate(20);
        
                return view('admin-views.Loans.index', compact('pageTitle', 'emptyMessage', 'loans'));
            }
     
     
     
     
            
    // pending loans
    public function pendingLoans()
    {
                $pageTitle      = 'Pending Loans';
        
                if(request()->search){
                    $query          = UserLoan::pending()->where('trx', request()->search);
                    $emptyMessage   = 'No Data Found';
                }else{
                    $query          = UserLoan::pending()->latest();
                    $emptyMessage   = 'No Pending Loan Yet';
                }
        
                $loans = $query->paginate(20);
        
        
                return view('admin-views.Loans.index', compact('pageTitle', 'emptyMessage', 'loans'));
            }

        
    public function pendingLoans10()
{
    $pageTitle = 'Pending Loans';

    if (request()->search) {
        $query = UserLoan::pending()
            ->where('trx', request()->search)
            ->with('client') // Load client data based on client_id
            ->latest();
        $emptyMessage = 'No Data Found';
    } else {
        $query = UserLoan::pending()
            ->with('client') // Load client data based on client_id
            ->latest();
        $emptyMessage = 'No Pending Loan Yet';
    }

    $loans = $query->paginate(20);

    return view('admin-views.Loans.index', compact('pageTitle', 'emptyMessage', 'loans'));
}

    
    
    
    // rejected loans
    public function rejectedLoans()
            {
                $pageTitle      = 'Rejected Loans';
        
                if(request()->search){
                    $query          = UserLoan::rejected()->where('trx', request()->search);
                    $emptyMessage   = 'No Data Found';
                }else{
                    $query          = UserLoan::rejected()->latest();
                    $emptyMessage   = 'No Rejected Loan Yet';
                }
        
                $loans = $query->paginate(20);
        
                return view('admin-views.Loans.index', compact('pageTitle', 'emptyMessage', 'loans'));
            }

    
    
    
    // running loans 
    public function runningLoans()
    {
                $pageTitle      = 'Running Loans';
        
                if(request()->search){
                    $query          = UserLoan::running()->where('trx', request()->search);
                    $emptyMessage   = 'No Data Found';
                }else{
                    $query          = UserLoan::running()->latest();
                    $emptyMessage   = 'No Running Loan Yet';
                }
        
                $loans = $query->paginate(20);
        
                return view('admin-views.Loans.index', compact('pageTitle', 'emptyMessage', 'loans'));
            }

    
    
    
    public function loanplansindex()
    {
        
        $loanPlans = LoanPlan::all();
        return response()->json($loanPlans);
    }

    
    
    




// create loan.
    public function createLoan10(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            
            'trx' => 'nullable|string|max:40',
            'amount' => 'required|numeric|min:0',
            'per_installment' => 'required|numeric|min:0',
            'installment_interval' => 'required|integer|min:1',
            'total_installment' => 'required|integer|min:1',
            'given_installment' => 'nullable|integer|min:0',
            'paid_amount' => 'nullable|numeric|min:0',
            'final_amount' => 'required|numeric|min:0',
            'user_details' => 'nullable|string',
            'next_installment_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 403);
        }

        $user = User::find($request->user_id);
        $plan = LoanPlan::find($request->plan_id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

      

        $loan = new UserLoan();
        $loan->user_id = $request->user_id;
        $loan->plan_id = $request->plan_id;
        $loan->trx = $request->trx;
        $loan->amount = $request->amount;
        $loan->per_installment = $request->per_installment;
        $loan->installment_interval = $request->installment_interval;
        $loan->total_installment = $request->total_installment;
        $loan->given_installment = $request->given_installment ?? 0;
        $loan->paid_amount = $request->paid_amount ?? 0.00;
        $loan->final_amount = $request->final_amount;
        $loan->user_details = $request->user_details ?? null;
        $loan->admin_feedback = null;
        $loan->status = 0;
        $loan->next_installment_date = $request->next_installment_date ?? null;
        $loan->client_id = $request->client_id;
        $loan->save();
        
        
        // Create a new agent loan record
                $agentLoan = new AgentLoan();
                $agentLoan->user_id = $request->user_id;
                $agentLoan->client_id = $request->client_id;
                $agentLoan->loan_amount = $request->amount;
                $agentLoan->final_loan_amount = $request->final_amount;
                $agentLoan->save();
        
        // $client = Client::where('client_id', $request->client_id)
        
        
        
      

        
        return response()->json(response_formatter(DEFAULT_200, $loan, null), 200);
    }
    
    
    
    
    
   

    
    // client loans
    public function clientLoans(Request $request): JsonResponse
    {
        $loans = UserLoan::where('client_id', $request -> id)->get();
        return response()->json(response_formatter(DEFAULT_200, $loans, null), 200);
    }

// user loans 
   public function userLoansList(Request $request): JsonResponse
    {
        $loans = UserLoan::where('user_id', $request -> id)->get();
        return response()->json(response_formatter(DEFAULT_200, $loans, null), 200);
        
    }



 public function withdrawalMethods(Request $request): JsonResponse
    {
        $withdrawalMethods = $this->withdrawalMethod->latest()->get();
        return response()->json(response_formatter(DEFAULT_200, $withdrawalMethods, null), 200);
    }



    public function show($id)
    {
        $loanOffer = LoanOffer::findOrFail($id);
        return response()->json($loanOffer);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'interest_rate' => 'sometimes|required|numeric',
            'min_amount' => 'sometimes|required|integer|min:0',
            'max_amount' => 'sometimes|required|integer|min:0',
            'min_term' => 'sometimes|required|integer|min:0',
            'max_term' => 'sometimes|required|integer|min:0',
        ]);

        $loanOffer = LoanOffer::findOrFail($id);
        $loanOffer->update($request->all());
        return response()->json($loanOffer);
    }

    public function destroy2($id)
    {
        $loanOffer = LoanOffer::findOrFail($id);
        $loanOffer->delete();
        return response()->json(['message' => 'Loan offer deleted successfully']);
    }
    
    
    // 
}

