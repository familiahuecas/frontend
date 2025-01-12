//import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';

part 'user.g.dart';

@JsonSerializable()
class User implements BaseModel {
  int id;
  String? name;
  String? email;
  String? password; // Nuevo campo para la contraseña
  bool enabled;
  List<String>? roles;
  String? message;
  String? secuencia;

  @JsonKey(ignore: true)
  String? _fullName;
  @JsonKey(ignore: true)
  String? get fullName => _fullName ??= name;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password, // Contraseña opcional para mantener flexibilidad
    required this.enabled,
    required this.roles,
    required this.message,
    required this.secuencia
  });

  UserEditable editableWith({
    int? id,
    String? name,
    String? email,
    String? password, // Contraseña editable
    bool? enabled,
    List<String>? roles,
    String? message,
  }) =>
      UserEditable(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        enabled: enabled ?? this.enabled,
        roles: roles ?? this.roles,
        message: message ?? this.message,
      );

  factory User.fromJson(Map<String, dynamic>? json) => _$UserFromJson(json!);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(Object other) => other is User && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class UserEditable {
  int? id;
  String? name;
  String? email;
  String? password; // Contraseña editable
  bool? enabled;
  List<String>? roles;
  String? message;

  UserEditable({
    this.id,
    this.name,
    this.email,
    this.password,
    this.enabled,
    this.roles,
    this.message,
  });

  factory UserEditable.fromJson(Map<String, dynamic>? json) =>
      _$UserEditableFromJson(json!);
  Map<String, dynamic> toJson() => _$UserEditableToJson(this);
}

@JsonSerializable()
class UserPage {
  List<User> content;
  bool last;
  int totalElements;
  int totalPages;
  bool first;
  int size;
  int number;
  bool empty;

  UserPage({
    required this.content,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.size,
    required this.number,
    required this.empty,
  });

  factory UserPage.fromJson(Map<String, dynamic>? json) =>
      _$UserPageFromJson(json!);
  Map<String, dynamic> toJson() => _$UserPageToJson(this);
}
