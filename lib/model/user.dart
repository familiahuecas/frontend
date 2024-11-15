import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int id;
  String name;
  String email;
  bool enabled;
  List<String> roles;
  String messaje;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.enabled,
    required this.roles,
    required this.messaje,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
