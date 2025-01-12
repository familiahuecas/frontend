import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'ubicacion.g.dart';

@JsonSerializable()
class Ubicacion implements BaseModel {
  int id;
  String nombre;
  String ubicacion;
  String? foto; // Nuevo campo opcional para la imagen

  Ubicacion({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    this.foto, // Inicialmente nulo, ya que puede no tener foto
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => _$UbicacionFromJson(json);
  Map<String, dynamic> toJson() => _$UbicacionToJson(this);
}

@JsonSerializable()
class UbicacionPage extends Page<Ubicacion> implements BaseModel {
  @override
  List<Ubicacion> content;

  UbicacionPage({
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

  factory UbicacionPage.fromJson(Map<String, dynamic>? json) =>
      _$UbicacionPageFromJson(json!);

  @override
  Map<String, dynamic> toJson() => _$UbicacionPageToJson(this);
}
