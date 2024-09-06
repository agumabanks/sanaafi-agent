import 'dart:convert';

List<Clients> clientsFromJson(String str) {
  final jsonData = json.decode(str)['content'];
  return List<Clients>.from(jsonData.map((x) => Clients.fromJson(x)));
}

String clientsToJson(List<Clients> data) {
  final jsonData = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(jsonData);
}

class Clients {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  Status? status;
  DateTime? kycVerifiedAt;
  DateTime? dob;
  String? business;
  String? nin;
  List<String>? recommenders;
  double? creditBalance;
  double? savingsBalance;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? addedBy; // New field
  String? nextOfKin;
  String? nationalIdPhotoUrl;

  Clients({
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
    this.addedBy, // Added new field
    this.nextOfKin, // Added new field
    this.nationalIdPhotoUrl, // Added new field
  });

  factory Clients.fromJson(Map<String, dynamic> json) => Clients(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    status: json["status"] == null ? null : statusValues.map[json["status"]],
    kycVerifiedAt: json["kyc_verified_at"] == null ? null : DateTime.parse(json["kyc_verified_at"]),
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    business: json["business"],
    nin: json["nin"],
    recommenders: json["recommenders"] == null ? null : List<String>.from(json["recommenders"].map((x) => x)),
    creditBalance: json["credit_balance"] == null ? null : double.parse(json["credit_balance"]),
    savingsBalance: json["savings_balance"] == null ? null : double.parse(json["savings_balance"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    addedBy: json["added_by"], // Added new field
    nextOfKin: json["next_of_kin"], // Added new field
    nationalIdPhotoUrl: json["national_id_photo_url"], // Added new field
    
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "status": status == null ? null : statusValues.reverse[status],
    "kyc_verified_at": kycVerifiedAt?.toIso8601String(),
    "dob": dob?.toIso8601String(),
    "business": business,
    "nin": nin,
    "recommenders": recommenders == null ? null : List<dynamic>.from(recommenders!.map((x) => x)),
    "credit_balance": creditBalance,
    "savings_balance": savingsBalance,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "added_by": addedBy, // Added new field
    "next_of_kin": nextOfKin, // Added new field
    "national_id_photo_url": nationalIdPhotoUrl, // Added new field
  };
}

enum Status { ACTIVE }

final statusValues = EnumValues({
  "active": Status.ACTIVE,
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
