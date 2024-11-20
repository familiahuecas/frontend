// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recaudaciones.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recaudaciones _$RecaudacionesFromJson(Map<String, dynamic> json) =>
    Recaudaciones(
      id: (json['id'] as num).toInt(),
      maquina1: (json['maquina1'] as num).toInt(),
      maquina2: (json['maquina2'] as num).toInt(),
      recaudaciontotal: (json['recaudaciontotal'] as num).toInt(),
      recaudacionparcial: (json['recaudacionparcial'] as num).toInt(),
      bar: json['bar'] as String,
      fecha: json['fecha'] as String,
    );

Map<String, dynamic> _$RecaudacionesToJson(Recaudaciones instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maquina1': instance.maquina1,
      'maquina2': instance.maquina2,
      'recaudaciontotal': instance.recaudaciontotal,
      'recaudacionparcial': instance.recaudacionparcial,
      'bar': instance.bar,
      'fecha': instance.fecha,
    };

RecaudacionesPage _$RecaudacionesPageFromJson(Map<String, dynamic> json) =>
    RecaudacionesPage(
      content: (json['content'] as List<dynamic>)
          .map((e) => Recaudaciones.fromJson(e as Map<String, dynamic>))
          .toList(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      first: json['first'] as bool,
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$RecaudacionesPageToJson(RecaudacionesPage instance) =>
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
