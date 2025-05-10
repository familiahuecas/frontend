// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adelantorequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Adelantorequest _$AdelantorequestFromJson(Map<String, dynamic> json) =>
    Adelantorequest(
      idUsuario: (json['idUsuario'] as num).toInt(),
      cantidadSolicitada: (json['cantidadSolicitada'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
      fecha: json['fecha'] as String,
    );

Map<String, dynamic> _$AdelantorequestToJson(Adelantorequest instance) =>
    <String, dynamic>{
      'idUsuario': instance.idUsuario,
      'cantidadSolicitada': instance.cantidadSolicitada,
      'descripcion': instance.descripcion,
      'fecha': instance.fecha,
    };
