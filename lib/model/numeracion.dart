import 'package:json_annotation/json_annotation.dart';


import 'base_model.dart';

part 'numeracion.g.dart';

@JsonSerializable()
class Numeracion implements BaseModel{
  int id;

  @JsonKey(name: 'entrada_m1')
  int entrada_m1;

  @JsonKey(name: 'salida_m1')
  int salida_m1;

  @JsonKey(name: 'entrada_m2')
  int entrada_m2;

 // @JsonKey(name: 'salida_m2')
  int salida_m2;

  String bar;
  DateTime fecha;

  Numeracion({
    required this.id,
    required this.entrada_m1,
    required this.salida_m1,
    required this.entrada_m2,
    required this.salida_m2,
    required this.bar,
    required this.fecha,
  });

  factory Numeracion.fromJson(Map<String, dynamic> json) => _$NumeracionFromJson(json);
  Map<String, dynamic> toJson() => _$NumeracionToJson(this);
}

@JsonSerializable()
class NumeracionPage extends Page<Numeracion> implements BaseModel{
  @override
  List<Numeracion> content;

  NumeracionPage({ required this.content, last, totalElements, totalPages, first, size, number, empty }) :
        super(last: last, totalElements: totalElements, totalPages: totalPages, first: first, size: size, number: number, empty: empty);

  factory NumeracionPage.fromJson(Map<String, dynamic>? json) => _$NumeracionPageFromJson(json!);
  @override Map<String, dynamic> toJson() => _$NumeracionPageToJson(this);
}

/*@JsonSerializable()
class NumeracionPage {
  List<Numeracion> content;
  Pageable pageable;
  bool last;
  int totalPages;
  int totalElements;
  bool first;
  int size;
  int number;
  bool empty;

  NumeracionPage({
    required this.content,
    required this.pageable,
    required this.last,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.size,
    required this.number,
    required this.empty,
  });

  factory NumeracionPage.fromJson(Map<String, dynamic> json) => _$NumeracionPageFromJson(json);
  Map<String, dynamic> toJson() => _$NumeracionPageToJson(this);
}*/

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
