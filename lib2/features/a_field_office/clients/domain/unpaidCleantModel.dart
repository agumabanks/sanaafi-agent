// To parse this JSON data, do
//
//     final clientsWithUnpaidLoan = clientsWithUnpaidLoanFromJson(jsonString);

import 'dart:convert';

ClientsWithUnpaidLoan clientsWithUnpaidLoanFromJson(String str) => ClientsWithUnpaidLoan.fromJson(json.decode(str));

String clientsWithUnpaidLoanToJson(ClientsWithUnpaidLoan data) => json.encode(data.toJson());

class ClientsWithUnpaidLoan {
    String? status;
    String? message;
    List<UPDatum>? data;
    int? currentPage;
    int? perPage;
    int? total;
    int? lastPage;

    ClientsWithUnpaidLoan({
        this.status,
        this.message,
        this.data,
        this.currentPage,
        this.perPage,
        this.total,
        this.lastPage,
    });

    factory ClientsWithUnpaidLoan.fromJson(Map<String, dynamic> json) => ClientsWithUnpaidLoan(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<UPDatum>.from(json["data"]!.map((x) => UPDatum.fromJson(x))),
        currentPage: json["current_page"],
        perPage: json["per_page"],
        total: json["total"],
        lastPage: json["last_page"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "current_page": currentPage,
        "per_page": perPage,
        "total": total,
        "last_page": lastPage,
    };
}

class UPDatum {
    int? id;
    dynamic branchId;
    String? name;
    String? email;
    String? phone;
    String? address;
    Status? status;
    dynamic kycVerifiedAt;
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

    UPDatum({
        this.id,
        this.branchId,
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

    factory UPDatum.fromJson(Map<String, dynamic> json) => UPDatum(
        id: json["id"],
        branchId: json["branch_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        status: statusValues.map[json["status"]]!,
        kycVerifiedAt: json["kyc_verified_at"],
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
        "branch_id": branchId,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "status": statusValues.reverse[status],
        "kyc_verified_at": kycVerifiedAt,
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

enum Status {
    ACTIVE,
    STATUS_ACTIVE
}

final statusValues = EnumValues({
    "active": Status.ACTIVE,
    "ACTIVE": Status.STATUS_ACTIVE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
