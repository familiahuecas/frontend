// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recaudacionresponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recaudacionresponse _$RecaudacionresponseFromJson(Map<String, dynamic> json) =>
    Recaudacionresponse(
      entradaM1: (json['entradaM1'] as num?)?.toInt(),
      salidaM1: (json['salidaM1'] as num?)?.toInt(),
      entradaM2: (json['entradaM2'] as num?)?.toInt(),
      salidaM2: (json['salidaM2'] as num?)?.toInt(),
      lastEntradaM1: (json['lastEntradaM1'] as num?)?.toInt(),
      lastSalidaM1: (json['lastSalidaM1'] as num?)?.toInt(),
      lastEntradaM2: (json['lastEntradaM2'] as num?)?.toInt(),
      lastSalidaM2: (json['lastSalidaM2'] as num?)?.toInt(),
      restaEntradaM1: (json['restaEntradaM1'] as num?)?.toInt(),
      restaSalidaM1: (json['restaSalidaM1'] as num?)?.toInt(),
      restaEntradaM2: (json['restaEntradaM2'] as num?)?.toInt(),
      restaSalidaM2: (json['restaSalidaM2'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toDouble(),
      totalCadaUno: (json['totalcadauno'] as num?)?.toDouble(),
      totalm1: (json['totalm1'] as num?)?.toDouble(),
      totalm2: (json['totalm2'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecaudacionresponseToJson(
        Recaudacionresponse instance) =>
    <String, dynamic>{
      'entradaM1': instance.entradaM1,
      'salidaM1': instance.salidaM1,
      'entradaM2': instance.entradaM2,
      'salidaM2': instance.salidaM2,
      'lastEntradaM1': instance.lastEntradaM1,
      'lastSalidaM1': instance.lastSalidaM1,
      'lastEntradaM2': instance.lastEntradaM2,
      'lastSalidaM2': instance.lastSalidaM2,
      'restaEntradaM1': instance.restaEntradaM1,
      'restaSalidaM1': instance.restaSalidaM1,
      'restaEntradaM2': instance.restaEntradaM2,
      'restaSalidaM2': instance.restaSalidaM2,
      'total': instance.total,
      'totalcadauno': instance.totalCadaUno,
      'totalm1': instance.totalm1,
      'totalm2': instance.totalm2,
    };
