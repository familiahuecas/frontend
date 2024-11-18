import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth.g.dart';

@JsonSerializable()
class Auth {
  String token;
  User user;

  Auth({
    required this.token,
    required this.user,
  });

  factory Auth.fromJson(Map<String, dynamic> json) =>
      _$AuthFromJson(json);
  Map<String, dynamic> toJson() => _$AuthToJson(this);
}
