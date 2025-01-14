import 'dart:convert';

List<ClientProfile> clientProfileFromJson(String str) => List<ClientProfile>.from(json.decode(str).map((x) => ClientProfile.fromJson(x)));

String clientProfileToJson(List<ClientProfile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientProfile {
    String? responseCode;
    String? message;
    List<Content>? content;
    dynamic errors;

    ClientProfile({
        this.responseCode,
        this.message,
        this.content,
        this.errors,
    });

    factory ClientProfile.fromJson(Map<String, dynamic> json) => ClientProfile(
        responseCode: json["response_code"],
        message: json["message"],
        content: json["content"] == null ? [] : List<Content>.from(json["content"].map((x) => Content.fromJson(x))),
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
    String? name;
    String? email;
    String? phone;
    String? address;
    String? status;
    String? client_photo;
    dynamic kycVerifiedAt;
    DateTime? dob;
    String? business;
    String? nin;
    List<String>? recommenders;
    String? creditBalance;
    String? savingsBalance;
    DateTime? createdAt;
    DateTime? updatedAt;

    Content({
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
        this.client_photo,
        this.recommenders,
        this.creditBalance,
        this.savingsBalance,
        this.createdAt,
        this.updatedAt,
    });

    factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        status: json["status"],
        kycVerifiedAt: json["kyc_verified_at"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        business: json["business"],
        nin: json["nin"], 
        client_photo: json["client_photo"],
        recommenders: json["recommenders"] == null ? [] : List<String>.from(json["recommenders"].map((x) => x)),
        creditBalance: json["credit_balance"],
        savingsBalance: json["savings_balance"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "status": status,
        "kyc_verified_at": kycVerifiedAt,
        "dob": dob?.toIso8601String(),
        "business": business,
        "nin": nin,
        "recommenders": recommenders == null ? [] : List<dynamic>.from(recommenders!.map((x) => x)),
        "credit_balance": creditBalance,
        "savings_balance": savingsBalance,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
