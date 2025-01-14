import 'dart:convert';

List<UserLoan> userLoanFromJson(String str) =>
    List<UserLoan>.from(json.decode(str).map((x) => UserLoan.fromJson(x)));
List<UserLoan> userLoanFromJsonList(List<dynamic> jsonList) =>
    List<UserLoan>.from(jsonList.map((x) => UserLoan.fromJson(x)));

String userLoanToJson(List<UserLoan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserLoan {
  UserLoan({
    required this.id,
    required this.userId,
    required this.planId,
    required this.trx,
    required this.amount,
    required this.perInstallment,
    required this.installmentInterval,
    required this.totalInstallment,
    required this.givenInstallment,
    required this.paidAmount,
    required this.finalAmount,
    this.userDetails,
    required this.status,
    this.nextInstallmentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userId;
  int planId;
  String trx;
  double amount;
  double perInstallment;
  int installmentInterval;
  int totalInstallment;
  int givenInstallment;
  double paidAmount;
  double finalAmount;
  String? userDetails;
  int status;
  DateTime? nextInstallmentDate;
  DateTime createdAt;
  DateTime updatedAt;

  factory UserLoan.fromRawJson(String str) => UserLoan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserLoan.fromJson(Map<String, dynamic> json) => UserLoan(
    id: json["id"],
    userId: json["user_id"],
    planId: json["plan_id"],
    trx: json["trx"],
    amount: double.parse(json["amount"].toString()),
    perInstallment: double.parse(json["per_installment"].toString()),
    installmentInterval: json["installment_interval"],
    totalInstallment: json["total_installment"],
    givenInstallment: json["given_installment"],
    paidAmount: double.parse(json["paid_amount"].toString()),
    finalAmount: double.parse(json["final_amount"].toString()),
    userDetails: json["user_details"],
    status: json["status"],
    nextInstallmentDate: json["next_installment_date"] != null
        ? DateTime.parse(json["next_installment_date"])
        : null,
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "plan_id": planId,
    "trx": trx,
    "amount": amount,
    "per_installment": perInstallment,
    "installment_interval": installmentInterval,
    "total_installment": totalInstallment,
    "given_installment": givenInstallment,
    "paid_amount": paidAmount,
    "final_amount": finalAmount,
    "user_details": userDetails,
    "status": status,
    "next_installment_date": nextInstallmentDate?.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
