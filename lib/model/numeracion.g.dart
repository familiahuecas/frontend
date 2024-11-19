// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'numeracion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Numeracion _$NumeracionFromJson(Map<String, dynamic> json) => Numeracion(
      id: (json['id'] as num).toInt(),
      entrada_m1: (json['entrada_m1'] as num).toInt(),
      salida_m1: (json['salida_m1'] as num).toInt(),
      entrada_m2: (json['entrada_m2'] as num).toInt(),
      salida_m2: (json['salida_m2'] as num).toInt(),
      bar: json['bar'] as String,
      fecha: json['fecha'] as String,
    );

Map<String, dynamic> _$NumeracionToJson(Numeracion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entrada_m1': instance.entrada_m1,
      'salida_m1': instance.salida_m1,
      'entrada_m2': instance.entrada_m2,
      'salida_m2': instance.salida_m2,
      'bar': instance.bar,
      'fecha': instance.fecha,
    };

NumeracionPage _$NumeracionPageFromJson(Map<String, dynamic> json) =>
    NumeracionPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => Numeracion.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      first: json['first'],
      size: json['size'],
      number: json['number'],
      empty: json['empty'],
    );

Map<String, dynamic> _$NumeracionPageToJson(NumeracionPage instance) =>
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

Pageable _$PageableFromJson(Map<String, dynamic> json) => Pageable(
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      sort: Sort.fromJson(json['sort'] as Map<String, dynamic>),
      offset: (json['offset'] as num).toInt(),
      paged: json['paged'] as bool,
      unpaged: json['unpaged'] as bool,
    );

Map<String, dynamic> _$PageableToJson(Pageable instance) => <String, dynamic>{
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'sort': instance.sort,
      'offset': instance.offset,
      'paged': instance.paged,
      'unpaged': instance.unpaged,
    };

Sort _$SortFromJson(Map<String, dynamic> json) => Sort(
      empty: json['empty'] as bool,
      sorted: json['sorted'] as bool,
      unsorted: json['unsorted'] as bool,
    );

Map<String, dynamic> _$SortToJson(Sort instance) => <String, dynamic>{
      'empty': instance.empty,
      'sorted': instance.sorted,
      'unsorted': instance.unsorted,
    };
