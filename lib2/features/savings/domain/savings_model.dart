// To parse this JSON data, do
//
//     final savingsAcct = savingsAcctFromJson(jsonString);

import 'dart:convert';

SavingsAcct savingsAcctFromJson(String str) => SavingsAcct.fromJson(json.decode(str));

String savingsAcctToJson(SavingsAcct data) => json.encode(data.toJson());

class SavingsAcct {
    int? id;
    int? clientId;
    int? agentId;
    int? accountTypeId;
    String? accountNumber;
    String? balance;
    String? interestRate;
    DateTime? createdAt;
    DateTime? updatedAt;
    Client? client;
    Agent? agent;
    AccountType? accountType;
    List<Transaction>? transactions;

    SavingsAcct({
        this.id,
        this.clientId,
        this.agentId,
        this.accountTypeId,
        this.accountNumber,
        this.balance,
        this.interestRate,
        this.createdAt,
        this.updatedAt,
        this.client,
        this.agent,
        this.accountType,
        this.transactions,
    });

    factory SavingsAcct.fromJson(Map<String, dynamic> json) => SavingsAcct(
        id: json["id"],
        clientId: json["client_id"],
        agentId: json["agent_id"],
        accountTypeId: json["account_type_id"],
        accountNumber: json["account_number"],
        balance: json["balance"],
        interestRate: json["interest_rate"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        client: json["client"] == null ? null : Client.fromJson(json["client"]),
        agent: json["agent"] == null ? null : Agent.fromJson(json["agent"]),
        accountType: json["account_type"] == null ? null : AccountType.fromJson(json["account_type"]),
        transactions: json["transactions"] == null ? [] : List<Transaction>.from(json["transactions"]!.map((x) => Transaction.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "client_id": clientId,
        "agent_id": agentId,
        "account_type_id": accountTypeId,
        "account_number": accountNumber,
        "balance": balance,
        "interest_rate": interestRate,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "client": client?.toJson(),
        "agent": agent?.toJson(),
        "account_type": accountType?.toJson(),
        "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
    };
}

class AccountType {
    int? id;
    String? name;
    String? description;
    String? interestRate;
    String? compoundingFrequency;
    DateTime? createdAt;
    DateTime? updatedAt;

    AccountType({
        this.id,
        this.name,
        this.description,
        this.interestRate,
        this.compoundingFrequency,
        this.createdAt,
        this.updatedAt,
    });

    factory AccountType.fromJson(Map<String, dynamic> json) => AccountType(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        interestRate: json["interest_rate"],
        compoundingFrequency: json["compounding_frequency"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "interest_rate": interestRate,
        "compounding_frequency": compoundingFrequency,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class Agent {
    int? id;
    dynamic branchId;
    String? fName;
    String? lName;
    String? dialCountryCode;
    String? phone;
    dynamic email;
    String? image;
    int? type;
    dynamic role;
    int? isPhoneVerified;
    int? isEmailVerified;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? lastActiveAt;
    String? uniqueId;
    dynamic referralId;
    String? gender;
    String? occupation;
    int? twoFactor;
    String? fcmToken;
    int? isActive;
    dynamic identificationType;
    dynamic identificationNumber;
    String? identificationImage;
    int? isKycVerified;
    int? loginHitCount;
    int? isTempBlocked;
    dynamic tempBlockTime;
    dynamic deletedAt;
    String? imageFullpath;
    List<dynamic>? identificationImageFullpath;
    List<dynamic>? merchantIdentificationImageFullpath;

    Agent({
        this.id,
        this.branchId,
        this.fName,
        this.lName,
        this.dialCountryCode,
        this.phone,
        this.email,
        this.image,
        this.type,
        this.role,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.createdAt,
        this.updatedAt,
        this.lastActiveAt,
        this.uniqueId,
        this.referralId,
        this.gender,
        this.occupation,
        this.twoFactor,
        this.fcmToken,
        this.isActive,
        this.identificationType,
        this.identificationNumber,
        this.identificationImage,
        this.isKycVerified,
        this.loginHitCount,
        this.isTempBlocked,
        this.tempBlockTime,
        this.deletedAt,
        this.imageFullpath,
        this.identificationImageFullpath,
        this.merchantIdentificationImageFullpath,
    });

    factory Agent.fromJson(Map<String, dynamic> json) => Agent(
        id: json["id"],
        branchId: json["branch_id"],
        fName: json["f_name"],
        lName: json["l_name"],
        dialCountryCode: json["dial_country_code"],
        phone: json["phone"],
        email: json["email"],
        image: json["image"],
        type: json["type"],
        role: json["role"],
        isPhoneVerified: json["is_phone_verified"],
        isEmailVerified: json["is_email_verified"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        lastActiveAt: json["last_active_at"] == null ? null : DateTime.parse(json["last_active_at"]),
        uniqueId: json["unique_id"],
        referralId: json["referral_id"],
        gender: json["gender"],
        occupation: json["occupation"],
        twoFactor: json["two_factor"],
        fcmToken: json["fcm_token"],
        isActive: json["is_active"],
        identificationType: json["identification_type"],
        identificationNumber: json["identification_number"],
        identificationImage: json["identification_image"],
        isKycVerified: json["is_kyc_verified"],
        loginHitCount: json["login_hit_count"],
        isTempBlocked: json["is_temp_blocked"],
        tempBlockTime: json["temp_block_time"],
        deletedAt: json["deleted_at"],
        imageFullpath: json["image_fullpath"],
        identificationImageFullpath: json["identification_image_fullpath"] == null ? [] : List<dynamic>.from(json["identification_image_fullpath"]!.map((x) => x)),
        merchantIdentificationImageFullpath: json["merchant_identification_image_fullpath"] == null ? [] : List<dynamic>.from(json["merchant_identification_image_fullpath"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "branch_id": branchId,
        "f_name": fName,
        "l_name": lName,
        "dial_country_code": dialCountryCode,
        "phone": phone,
        "email": email,
        "image": image,
        "type": type,
        "role": role,
        "is_phone_verified": isPhoneVerified,
        "is_email_verified": isEmailVerified,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "last_active_at": lastActiveAt?.toIso8601String(),
        "unique_id": uniqueId,
        "referral_id": referralId,
        "gender": gender,
        "occupation": occupation,
        "two_factor": twoFactor,
        "fcm_token": fcmToken,
        "is_active": isActive,
        "identification_type": identificationType,
        "identification_number": identificationNumber,
        "identification_image": identificationImage,
        "is_kyc_verified": isKycVerified,
        "login_hit_count": loginHitCount,
        "is_temp_blocked": isTempBlocked,
        "temp_block_time": tempBlockTime,
        "deleted_at": deletedAt,
        "image_fullpath": imageFullpath,
        "identification_image_fullpath": identificationImageFullpath == null ? [] : List<dynamic>.from(identificationImageFullpath!.map((x) => x)),
        "merchant_identification_image_fullpath": merchantIdentificationImageFullpath == null ? [] : List<dynamic>.from(merchantIdentificationImageFullpath!.map((x) => x)),
    };
}

class Client {
    int? id;
    String? branchId;
    String? name;
    String? email;
    String? phone;
    String? address;
    String? status;
    dynamic kycVerifiedAt;
    dynamic dob;
    String? business;
    String? nin;
    dynamic recommenders;
    String? creditBalance;
    String? savingsBalance;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? addedBy;
    dynamic clientPhoto;
    String? nextOfKin;
    dynamic nationalIdPhoto;
    dynamic nextOfKinName;
    String? nextOfKinPhone;
    String? nextOfKinRelationship;

    Client({
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
        this.nextOfKinName,
        this.nextOfKinPhone,
        this.nextOfKinRelationship,
    });

    factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json["id"],
        branchId: json["branch_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        status: json["status"],
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
        nextOfKinName: json["next_of_kin_name"],
        nextOfKinPhone: json["next_of_kin_phone"],
        nextOfKinRelationship: json["next_of_kin_relationship"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "branch_id": branchId,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "status": status,
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
        "next_of_kin_name": nextOfKinName,
        "next_of_kin_phone": nextOfKinPhone,
        "next_of_kin_relationship": nextOfKinRelationship,
    };
}

class Transaction {
    int? id;
    int? savingsAccountId;
    String? type;
    String? amount;
    String? description;
    DateTime? createdAt;
    DateTime? updatedAt;

    Transaction({
        this.id,
        this.savingsAccountId,
        this.type,
        this.amount,
        this.description,
        this.createdAt,
        this.updatedAt,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        savingsAccountId: json["savings_account_id"],
        type: json["type"],
        amount: json["amount"],
        description: json["description"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "savings_account_id": savingsAccountId,
        "type": type,
        "amount": amount,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
