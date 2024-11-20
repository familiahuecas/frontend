import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'recaudaciones.g.dart';

@JsonSerializable()
class Recaudaciones implements BaseModel {
  int id;
  int maquina1;
  int maquina2;
  int recaudaciontotal;
  int recaudacionparcial;
  String bar;
  String fecha;

  Recaudaciones({
    required this.id,
    required this.maquina1,
    required this.maquina2,
    required this.recaudaciontotal,
    required this.recaudacionparcial,
    required this.bar,
    required this.fecha,
  });

  factory Recaudaciones.fromJson(Map<String, dynamic> json) => _$RecaudacionesFromJson(json);
  Map<String, dynamic> toJson() => _$RecaudacionesToJson(this);
}

@JsonSerializable()
class RecaudacionesPage extends Page<Recaudaciones> implements BaseModel {
  @override
  List<Recaudaciones> content;

  RecaudacionesPage({
    required this.content,
    required bool last,
    required int totalElements,
    required int totalPages,
    required bool first,
    required int size,
    required int number,
    required bool empty,
  }) : super(
    last: last,
    totalElements: totalElements,
    totalPages: totalPages,
    first: first,
    size: size,
    number: number,
    empty: empty,
  );

  factory RecaudacionesPage.fromJson(Map<String, dynamic>? json) => _$RecaudacionesPageFromJson(json!);
  @override
  Map<String, dynamic> toJson() => _$RecaudacionesPageToJson(this);
}

@JsonSerializable()
class Pageable {
  int pageNumber;
  int pageSize;
  Sort sort;
  int offset;
  bool paged;
  bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) => _$PageableFromJson(json);
  Map<String, dynamic> toJson() => _$PageableToJson(this);
}

@JsonSerializable()
class Sort {
  bool empty;
  bool sorted;
  bool unsorted;

  Sort({
    required this.empty,
    required this.sorted,
    required this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => _$SortFromJson(json);
  Map<String, dynamic> toJson() => _$SortToJson(this);
}
