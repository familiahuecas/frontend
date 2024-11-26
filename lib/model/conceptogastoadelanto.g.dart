// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conceptogastoadelanto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConceptoGastoAdelanto _$ConceptoGastoAdelantoFromJson(
        Map<String, dynamic> json) =>
    ConceptoGastoAdelanto(
      id: (json['id'] as num).toInt(),
      descripcion: json['descripcion'] as String,
      total: (json['total'] as num).toDouble(),
      fecha: json['fecha'] as String,
      usuario: json['usuario'] as String,
    );

Map<String, dynamic> _$ConceptoGastoAdelantoToJson(
        ConceptoGastoAdelanto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'descripcion': instance.descripcion,
      'total': instance.total,
      'fecha': instance.fecha,
      'usuario': instance.usuario,
    };

ConceptoGastoAdelantoPage _$ConceptoGastoAdelantoPageFromJson(
        Map<String, dynamic> json) =>
    ConceptoGastoAdelantoPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => ConceptoGastoAdelanto.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      first: json['first'] as bool,
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$ConceptoGastoAdelantoPageToJson(
        ConceptoGastoAdelantoPage instance) =>
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
