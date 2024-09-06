// To parse this JSON data, do
//
//     final clientLoans = clientLoansFromJson(jsonString);

import 'dart:convert';

ClientLoans clientLoansFromJson(String str) => ClientLoans.fromJson(json.decode(str));

String clientLoansToJson(ClientLoans data) => json.encode(data.toJson());

class ClientLoans {
    String? responseCode;
    String? message;
    List<Content>? content;
    dynamic errors;

    ClientLoans({
        this.responseCode,
        this.message,
        this.content,
        this.errors,
    });

    factory ClientLoans.fromJson(Map<String, dynamic> json) => ClientLoans(
        responseCode: json["response_code"],
        message: json["message"],
        content: json["content"] == null ? [] : List<Content>.from(json["content"]!.map((x) => Content.fromJson(x))),
        errors: json["errors"],
    );

    Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "message": message,
        "content": content == null ? [] : List<dynamic>.from(content!.map((x) => x.toJson())),
        "errors": errors,
    };
}

class Content {
    int? id;
    int? userId;
    int? clientId;
    int? planId;
    String? trx;
    String? amount;
    String? perInstallment;
    int? installmentInterval;
    int? totalInstallment;
    int? givenInstallment;
    String? paidAmount;
    String? finalAmount;
    dynamic? userDetails;
    dynamic? adminFeedback;
    int? status;
    DateTime? nextInstallmentDate;
    DateTime? createdAt;
    DateTime? updatedAt;

    Content({
        this.id,
        this.userId,
        this.clientId,
        this.planId,
        this.trx,
        this.amount,
        this.perInstallment,
        this.installmentInterval,
        this.totalInstallment,
        this.givenInstallment,
        this.paidAmount,
        this.finalAmount,
        this.userDetails,
        this.adminFeedback,
        this.status,
        this.nextInstallmentDate,
        this.createdAt,
        this.updatedAt,
    });

    factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        userId: json["user_id"],
        clientId: json["client_id"],
        planId: json["plan_id"],
        trx: json["trx"],
        amount: json["amount"],
        perInstallment: json["per_installment"],
        installmentInterval: json["installment_interval"],
        totalInstallment: json["total_installment"],
        givenInstallment: json["given_installment"],
        paidAmount: json["paid_amount"],
        finalAmount: json["final_amount"],
        userDetails: json["user_details"],
        adminFeedback: json["admin_feedback"],
        status: json["status"],
        nextInstallmentDate: json["next_installment_date"] == null ? null : DateTime.parse(json["next_installment_date"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "client_id": clientId,
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
        "admin_feedback": adminFeedback,
        "status": status,
        "next_installment_date": nextInstallmentDate?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
