// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      enabled: json['enabled'] as bool,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      message: json['message'] as String?,
      secuencia: json['secuencia'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'enabled': instance.enabled,
      'roles': instance.roles,
      'message': instance.message,
      'secuencia': instance.secuencia,
    };

UserEditable _$UserEditableFromJson(Map<String, dynamic> json) => UserEditable(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      enabled: json['enabled'] as bool?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$UserEditableToJson(UserEditable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'enabled': instance.enabled,
      'roles': instance.roles,
      'message': instance.message,
    };

UserPage _$UserPageFromJson(Map<String, dynamic> json) => UserPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>?))
          .toList(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      first: json['first'] as bool,
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$UserPageToJson(UserPage instance) => <String, dynamic>{
      'content': instance.content,
      'last': instance.last,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'first': instance.first,
      'size': instance.size,
      'number': instance.number,
      'empty': instance.empty,
    };
