// To parse this JSON data, do
//
//     final clientLoanspayHistory = clientLoanspayHistoryFromJson(jsonString);

import 'dart:convert';

ClientLoanspayHistory clientLoanspayHistoryFromJson(String str) => ClientLoanspayHistory.fromJson(json.decode(str));

String clientLoanspayHistoryToJson(ClientLoanspayHistory data) => json.encode(data.toJson());

class ClientLoanspayHistory {
    String responseCode;
    String message;
    List<ClientContent> content;
    dynamic errors;

    ClientLoanspayHistory({
        required this.responseCode,
        required this.message,
        required this.content,
        required this.errors,
    });

    factory ClientLoanspayHistory.fromJson(Map<String, dynamic> json) => ClientLoanspayHistory(
        responseCode: json["response_code"],
        message: json["message"],
        content: List<ClientContent>.from(json["content"].map((x) => ClientContent.fromJson(x))),
        errors: json["errors"],
    );

    Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "message": message,
        "content": List<dynamic>.from(content.map((x) => x.toJson())),
        "errors": errors,
    };
}

class ClientContent {
    int id;
    int loanId;
    int clientId;
    int agentId;
    String amount;
    DateTime paymentDate;
    String? note;
    DateTime createdAt;
    DateTime updatedAt;

    ClientContent({
        required this.id,
        required this.loanId,
        required this.clientId,
        required this.agentId,
        required this.amount,
        required this.paymentDate,
        required this.note,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ClientContent.fromJson(Map<String, dynamic> json) => ClientContent(
        id: json["id"],
        loanId: json["loan_id"],
        clientId: json["client_id"],
        agentId: json["agent_id"],
        amount: json["amount"],
        paymentDate: DateTime.parse(json["payment_date"]),
        note: json["note"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "loan_id": loanId,
        "client_id": clientId,
        "agent_id": agentId,
        "amount": amount,
        "payment_date": "${paymentDate.year.toString().padLeft(4, '0')}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}",
        "note": note,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
