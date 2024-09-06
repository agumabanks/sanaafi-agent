// To parse this JSON data, do
//
//     final agentTodaysLoans = agentTodaysLoansFromJson(jsonString);

import 'dart:convert';

AgentTodaysLoans agentTodaysLoansFromJson(String str) => AgentTodaysLoans.fromJson(json.decode(str));

String agentTodaysLoansToJson(AgentTodaysLoans data) => json.encode(data.toJson());

class AgentTodaysLoans {
    String? responseCode;
    String? message;
    List<DataContent>? dataContent;

    AgentTodaysLoans({
        this.responseCode,
        this.message,
        this.dataContent,
    });

    factory AgentTodaysLoans.fromJson(Map<String, dynamic> json) => AgentTodaysLoans(
        responseCode: json["response_code"],
        message: json["message"],
        dataContent: json["DataContent"] == null ? [] : List<DataContent>.from(json["DataContent"]!.map((x) => DataContent.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "message": message,
        "DataContent": dataContent == null ? [] : List<dynamic>.from(dataContent!.map((x) => x.toJson())),
    };
}

class DataContent {
    int? id;
    int? loanId;
    int? agentId;
    int? clientId;
    String? clientName;
    String? clientPhone;
    String? installAmount;
    DateTime? date;
    String? status;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataContent({
        this.id,
        this.loanId,
        this.agentId,
        this.clientId,
        this.clientName,
        this.clientPhone,
        this.installAmount,
        this.date,
        this.status,
        this.createdAt,
        this.updatedAt,
    });

    factory DataContent.fromJson(Map<String, dynamic> json) => DataContent(
        id: json["id"],
        loanId: json["loan_id"],
        agentId: json["agent_id"],
        clientId: json["client_id"],
        clientName: json["client_name"],
        clientPhone: json["client_phone"],
        installAmount: json["install_amount"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "loan_id": loanId,
        "agent_id": agentId,
        "client_id": clientId,
        "client_name": clientName,
        "client_phone": clientPhone,
        "install_amount": installAmount,
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
