import 'dart:convert';

// Function to parse JSON into a LoanTransaction object
LoanTransaction loanTransactionFromJson(String str) => LoanTransaction.fromJson(json.decode(str));

// Function to convert LoanTransaction object back to JSON
String loanTransactionToJson(LoanTransaction data) => json.encode(data.toJson());

class LoanTransaction {
  bool? status;
  String? message;
  List<Datum>? data;

  LoanTransaction({
    this.status,
    this.message,
    this.data,
  });

  // Factory constructor for creating a LoanTransaction from JSON
  factory LoanTransaction.fromJson(Map<String, dynamic> json) => LoanTransaction(
        status: json["status"] as bool?,
        message: json["message"] as String?,
        data: json["data"] == null
            ? null
            : List<Datum>.from((json["data"] as List<dynamic>).map((x) => Datum.fromJson(x))),
      );

  // Method to convert a LoanTransaction instance to JSON
  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? clientName;
  int? clientId;
  String? amountPaid;
  DateTime? paymentDate;
  bool? isReversed;

  Datum({
    this.clientName,
    this.clientId,
    this.amountPaid,
    this.paymentDate,
    this.isReversed,
  });

  // Factory constructor for creating a Datum from JSON
  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        clientName: json["client_name"] as String?,
        clientId: json["client_id"] as int?,
        amountPaid: json["amount_paid"] as String?,
        paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
        isReversed: json["is_reversed"] as bool?,
      );

  // Method to convert a Datum instance to JSON
  Map<String, dynamic> toJson() => {
        "client_name": clientName,
        "client_id": clientId,
        "amount_paid": amountPaid,
        "payment_date": paymentDate == null
            ? null
            : "${paymentDate!.year.toString().padLeft(4, '0')}-${paymentDate!.month.toString().padLeft(2, '0')}-${paymentDate!.day.toString().padLeft(2, '0')}",
        "is_reversed": isReversed,
      };
}
