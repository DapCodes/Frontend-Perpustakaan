import 'dart:convert';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  List<DataPost>? data;
  String? message;
  bool? success;

  PostModel({
    this.data,
    this.message,
    this.success,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        data: json["data"] == null
            ? []
            : List<DataPost>.from(
                json["data"]!.map((x) => DataPost.fromJson(x))),
        message: json["message"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "success": success,
      };
}

class DataPost {
  int? id;
  String? title;
  String? content;
  String? slug;
  int? status;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;

  DataPost({
    this.id,
    this.title,
    this.content,
    this.slug,
    this.status,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory DataPost.fromJson(Map<String, dynamic> json) => DataPost(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        slug: json["slug"],
        status: json["status"],
        image: json["image"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "slug": slug,
        "status": status,
        "image": image,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
