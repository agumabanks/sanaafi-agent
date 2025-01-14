// lib/features/membership/domain/models/membership_model.dart

class MembershipModel {
  final int id;
  final int userId;
  final String membershipType;
  final bool isPaid;
  final int shares;
  final double shareValue;
  final double membershipFees;
  final int clientId;
  final bool isSharesPaid;
  final DateTime? membershipDate;
  final ClientModel? client;
  final List<ShareTransactionModel> transactionsList;

  // Optional fields for calculated dividend & interest
  final double? dividend;
  final double? interest;

  MembershipModel({
    required this.id,
    required this.userId,
    required this.membershipType,
    required this.isPaid,
    required this.shares,
    required this.shareValue,
    required this.membershipFees,
    required this.clientId,
    required this.isSharesPaid,
    required this.transactionsList,
    this.membershipDate,
    this.client,
    this.dividend,
    this.interest,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    // Parse "client"
    ClientModel? parsedClient;
    if (json['client'] != null) {
      parsedClient = ClientModel.fromJson(json['client']);
    }

    // Parse "transactions_list" if present
    final List txList = json['transactions_list'] ?? [];
    List<ShareTransactionModel> shareTx =
        txList.map((e) => ShareTransactionModel.fromJson(e)).toList();

    return MembershipModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      membershipType: json['membership_type'] ?? 'Unknown',
      isPaid: (json['is_paid'] == true),
      shares: json['shares'] ?? 0,
      shareValue: double.tryParse('${json['share_value']}') ?? 0.0,
      membershipFees: double.tryParse('${json['membership_fees']}') ?? 0.0,
      clientId: json['client_id'] as int,
      isSharesPaid: (json['is_shares_paid'] == true),
      membershipDate: json['membership_date'] != null
          ? DateTime.tryParse(json['membership_date'])
          : null,
      client: parsedClient,
      transactionsList: shareTx,
      dividend: json['dividend'] != null
          ? double.tryParse('${json['dividend']}')
          : null,
      interest: json['interest'] != null
          ? double.tryParse('${json['interest']}')
          : null,
    );
  }
}

class ClientModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  // Add any other fields you have in "client"

  ClientModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] ?? 'Unknown Client',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }
}

class ShareTransactionModel {
  final String createdAt;
  final String transactionType;
  final double amount;
  final String? description;

  ShareTransactionModel({
    required this.createdAt,
    required this.transactionType,
    required this.amount,
    this.description,
  });

  factory ShareTransactionModel.fromJson(Map<String, dynamic> json) {
    return ShareTransactionModel(
      createdAt: json['created_at'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      amount: double.tryParse('${json['amount']}') ?? 0.0,
      description: json['description'],
    );
  }
}
