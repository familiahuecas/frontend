import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'conceptogastoadelanto.g.dart';

@JsonSerializable()
class ConceptoGastoAdelanto implements BaseModel {
  int id;
  String descripcion;
  double total;
  String fecha;
  String usuario;

  ConceptoGastoAdelanto({
    required this.id,
    required this.descripcion,
    required this.total,
    required this.fecha,
    required this.usuario,
  });

  factory ConceptoGastoAdelanto.fromJson(Map<String, dynamic> json) => _$ConceptoGastoAdelantoFromJson(json);
  Map<String, dynamic> toJson() => _$ConceptoGastoAdelantoToJson(this);
}
@JsonSerializable()
class ConceptoGastoAdelantoPage extends Page<ConceptoGastoAdelanto> implements BaseModel {
  @override
  List<ConceptoGastoAdelanto> content;

  ConceptoGastoAdelantoPage({
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

  factory ConceptoGastoAdelantoPage.fromJson(Map<String, dynamic>? json) =>
      _$ConceptoGastoAdelantoPageFromJson(json!);

  @override
  Map<String, dynamic> toJson() => _$ConceptoGastoAdelantoPageToJson(this);
}
