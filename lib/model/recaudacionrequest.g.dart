// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recaudacionrequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recaudacionrequest _$RecaudacionrequestFromJson(Map<String, dynamic> json) =>
    Recaudacionrequest(
      bar: json['bar'] as String,
      entradaM1: (json['entradaM1'] as num).toInt(),
      salidaM1: (json['salidaM1'] as num).toInt(),
      entradaM2: (json['entradaM2'] as num).toInt(),
      salidaM2: (json['salidaM2'] as num).toInt(),
    );

Map<String, dynamic> _$RecaudacionrequestToJson(Recaudacionrequest instance) =>
    <String, dynamic>{
      'bar': instance.bar,
      'entradaM1': instance.entradaM1,
      'salidaM1': instance.salidaM1,
      'entradaM2': instance.entradaM2,
      'salidaM2': instance.salidaM2,
    };
