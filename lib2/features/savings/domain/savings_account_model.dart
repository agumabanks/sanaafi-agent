// lib/features/savings/domain/models/savings_account_model.dart

import 'package:flutter/material.dart';

/// Model for each transaction
class SavingsTransactionModel {
  final int id;
  final int savingsAccountId;
  final String type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsTransactionModel({
    required this.id,
    required this.savingsAccountId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsTransactionModel.fromJson(Map<String, dynamic> json) {
    return SavingsTransactionModel(
      id: json['id'] as int,
      savingsAccountId: json['savings_account_id'] as int,
      type: json['type'] ?? '',
      amount: double.tryParse('${json['amount']}') ?? 0.0,
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Typed model for the `client` details
class ClientModel {
  final int id;
  final String branchId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String? kycVerifiedAt;
  final String? dob;
  final String business;
  final String nin;
  final String? recommenders;
  final double creditBalance;
  final double savingsBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String addedBy;
  final String? clientPhoto;
  final String nextOfKin;
  final String? nationalIdPhoto;
  final String? nextOfKinName;
  final String nextOfKinPhone;
  final String nextOfKinRelationship;

  ClientModel({
    required this.id,
    required this.branchId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    this.kycVerifiedAt,
    this.dob,
    required this.business,
    required this.nin,
    this.recommenders,
    required this.creditBalance,
    required this.savingsBalance,
    required this.createdAt,
    required this.updatedAt,
    required this.addedBy,
    this.clientPhoto,
    required this.nextOfKin,
    this.nationalIdPhoto,
    this.nextOfKinName,
    required this.nextOfKinPhone,
    required this.nextOfKinRelationship,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      branchId: json['branch_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      kycVerifiedAt: json['kyc_verified_at'],
      dob: json['dob'],
      business: json['business'] ?? '',
      nin: json['nin'] ?? '',
      recommenders: json['recommenders'],
      creditBalance: double.tryParse('${json['credit_balance']}') ?? 0.0,
      savingsBalance: double.tryParse('${json['savings_balance']}') ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      addedBy: json['added_by'] ?? '',
      clientPhoto: json['client_photo'],
      nextOfKin: json['next_of_kin'] ?? '',
      nationalIdPhoto: json['national_id_photo'],
      nextOfKinName: json['next_of_kin_name'],
      nextOfKinPhone: json['next_of_kin_phone'] ?? '',
      nextOfKinRelationship: json['next_of_kin_relationship'] ?? '',
    );
  }
}

/// Model for the savings account itself
class SavingsAccountModel {
  final int id;
  final int clientId;
  final int? agentId;
  final int accountTypeId;
  final String accountNumber;
  final double balance;
  final double interestRate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ClientModel? clientData; // Typed ClientModel
  final Map<String, dynamic>? agent;
  final Map<String, dynamic>? accountType;
  final List<SavingsTransactionModel> transactions;

  SavingsAccountModel({
    required this.id,
    required this.clientId,
    required this.accountTypeId,
    required this.accountNumber,
    required this.balance,
    required this.interestRate,
    required this.createdAt,
    required this.updatedAt,
    this.agentId,
    this.clientData, // Initialize ClientModel
    this.agent,
    this.accountType,
    required this.transactions,
  });

  factory SavingsAccountModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> txList = json['transactions'] ?? [];
    List<SavingsTransactionModel> transactions = txList
        .map((e) => SavingsTransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    ClientModel? clientModel;
    if (json['client'] != null) {
      clientModel = ClientModel.fromJson(json['client'] as Map<String, dynamic>);
    }

    return SavingsAccountModel(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      agentId: json['agent_id'] as int?,
      accountTypeId: json['account_type_id'] as int,
      accountNumber: json['account_number'] ?? '',
      balance: double.tryParse('${json['balance']}') ?? 0.0,
      interestRate: double.tryParse('${json['interest_rate']}') ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      clientData: clientModel, // Assign typed ClientModel
      agent: json['agent'] as Map<String, dynamic>?,
      accountType: json['account_type'] as Map<String, dynamic>?,
      transactions: transactions,
    );
  }
}
