// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      enabled: json['enabled'] as bool,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      messaje: json['messaje'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'enabled': instance.enabled,
      'roles': instance.roles,
      'messaje': instance.messaje,
    };
