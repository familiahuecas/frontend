// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ubicacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ubicacion _$UbicacionFromJson(Map<String, dynamic> json) => Ubicacion(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      ubicacion: json['ubicacion'] as String,
      foto: json['foto'] as String?,
    );

Map<String, dynamic> _$UbicacionToJson(Ubicacion instance) => <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'ubicacion': instance.ubicacion,
      'foto': instance.foto,
    };

UbicacionPage _$UbicacionPageFromJson(Map<String, dynamic> json) =>
    UbicacionPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => Ubicacion.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      first: json['first'] as bool,
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$UbicacionPageToJson(UbicacionPage instance) =>
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
