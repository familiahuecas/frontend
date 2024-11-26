// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuarioconapuntes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioConApuntes _$UsuarioConApuntesFromJson(Map<String, dynamic> json) =>
    UsuarioConApuntes(
      idUsuario: (json['idUsuario'] as num).toInt(),
      nombre: json['nombre'] as String,
      cantidadAsignada: (json['cantidadAsignada'] as num).toDouble(),
      cantidadRestante: (json['cantidadRestante'] as num).toDouble(),
      numeroDeApuntes: (json['numeroDeApuntes'] as num).toInt(),
    );

Map<String, dynamic> _$UsuarioConApuntesToJson(UsuarioConApuntes instance) =>
    <String, dynamic>{
      'idUsuario': instance.idUsuario,
      'nombre': instance.nombre,
      'cantidadAsignada': instance.cantidadAsignada,
      'cantidadRestante': instance.cantidadRestante,
      'numeroDeApuntes': instance.numeroDeApuntes,
    };

UsuarioConApuntesPage _$UsuarioConApuntesPageFromJson(
        Map<String, dynamic> json) =>
    UsuarioConApuntesPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => UsuarioConApuntes.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      first: json['first'] as bool,
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$UsuarioConApuntesPageToJson(
        UsuarioConApuntesPage instance) =>
    <String, dynamic>{
      'last': instance.last,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'first': instance.first,
      'size': instance.size,
      'number': instance.number,
      'empty': instance.empty,
      'content': instance.content,
    };
