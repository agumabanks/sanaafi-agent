// To parse this JSON data, do
//
//     final clientguarantorsList = clientguarantorsListFromJson(jsonString);

import 'dart:convert';

ClientguarantorsList clientguarantorsListFromJson(String str) => ClientguarantorsList.fromJson(json.decode(str));

String clientguarantorsListToJson(ClientguarantorsList data) => json.encode(data.toJson());

class ClientguarantorsList {
    String? responseCode;
    String? message;
    List<Content>? content;
    dynamic errors;

    ClientguarantorsList({
        this.responseCode,
        this.message,
        this.content,
        this.errors,
    });

    factory ClientguarantorsList.fromJson(Map<String, dynamic> json) => ClientguarantorsList(
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
    String? name;
    String? nin;
    String? photo;
    String? nationalIdPhoto;
    int? addedBy;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? clientId;

    Content({
        this.id,
        this.name,
        this.nin,
        this.photo,
        this.nationalIdPhoto,
        this.addedBy,
        this.createdAt,
        this.updatedAt,
        this.clientId,
    });

    factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        name: json["name"],
        nin: json["nin"],
        photo: json["photo"],
        nationalIdPhoto: json["national_id_photo"],
        addedBy: json["added_by"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        clientId: json["client_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "nin": nin,
        "photo": photo,
        "national_id_photo": nationalIdPhoto,
        "added_by": addedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "client_id": clientId,
    };
}
