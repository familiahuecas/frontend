// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuarioconadelanto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioConAdelanto _$UsuarioConAdelantoFromJson(Map<String, dynamic> json) =>
    UsuarioConAdelanto(
      idUsuario: (json['id'] as num).toInt(),
      cantidadSolicitada: (json['cantidadSolicitada'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
      fecha: json['fecha'] as String,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$UsuarioConAdelantoToJson(UsuarioConAdelanto instance) =>
    <String, dynamic>{
      'id': instance.idUsuario,
      'cantidadSolicitada': instance.cantidadSolicitada,
      'descripcion': instance.descripcion,
      'fecha': instance.fecha,
      'name': instance.name,
    };

UsuarioConAdelantoPage _$UsuarioConAdelantoPageFromJson(
        Map<String, dynamic> json) =>
    UsuarioConAdelantoPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => UsuarioConAdelanto.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      first: json['first'] as bool,
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$UsuarioConAdelantoPageToJson(
        UsuarioConAdelantoPage instance) =>
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
