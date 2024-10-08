// To parse this JSON data, do
//
//     final ClientsLoansPageRunning = ClientsLoansPageRunningFromJson(jsonString);

import 'dart:convert';

ClientsLoansPageRunning ClientsLoansPageRunningFromJson(String str) => ClientsLoansPageRunning.fromJson(json.decode(str));

String ClientsLoansPageRunningToJson(ClientsLoansPageRunning data) => json.encode(data.toJson());

class ClientsLoansPageRunning {
    bool? status;
    List<ClientsDatumRunning>? data;
    int? totalClients;

    ClientsLoansPageRunning({
        this.status,
        this.data,
        this.totalClients,
    });

    factory ClientsLoansPageRunning.fromJson(Map<String, dynamic> json) => ClientsLoansPageRunning(
        status: json["status"],
        data: json["data"] == null ? [] : List<ClientsDatumRunning>.from(json["data"]!.map((x) => ClientsDatumRunning.fromJson(x))),
        totalClients: json["total_clients"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "total_clients": totalClients,
    };
}

class ClientsDatumRunning {
    int? id;
    String? name;
    String? email;
    String? phone;
    String? address;
    int? status;
    DateTime? kycVerifiedAt;
    dynamic dob;
    dynamic business;
    dynamic nin;
    dynamic recommenders;
    String? creditBalance;
    String? savingsBalance;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? addedBy;
    dynamic clientPhoto;
    dynamic nextOfKin;
    dynamic nationalIdPhoto;

    ClientsDatumRunning({
        this.id,
        this.name,
        this.email,
        this.phone,
        this.address,
        this.status,
        this.kycVerifiedAt,
        this.dob,
        this.business,
        this.nin,
        this.recommenders,
        this.creditBalance,
        this.savingsBalance,
        this.createdAt,
        this.updatedAt,
        this.addedBy,
        this.clientPhoto,
        this.nextOfKin,
        this.nationalIdPhoto,
    });

    factory ClientsDatumRunning.fromJson(Map<String, dynamic> json) => ClientsDatumRunning(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        status: json["status"],
        kycVerifiedAt: json["kyc_verified_at"] == null ? null : DateTime.parse(json["kyc_verified_at"]),
        dob: json["dob"],
        business: json["business"],
        nin: json["nin"],
        recommenders: json["recommenders"],
        creditBalance: json["credit_balance"],
        savingsBalance: json["savings_balance"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        addedBy: json["added_by"],
        clientPhoto: json["client_photo"],
        nextOfKin: json["next_of_kin"],
        nationalIdPhoto: json["national_id_photo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "status": status,
        "kyc_verified_at": kycVerifiedAt?.toIso8601String(),
        "dob": dob,
        "business": business,
        "nin": nin,
        "recommenders": recommenders,
        "credit_balance": creditBalance,
        "savings_balance": savingsBalance,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "added_by": addedBy,
        "client_photo": clientPhoto,
        "next_of_kin": nextOfKin,
        "national_id_photo": nationalIdPhoto,
    };
}