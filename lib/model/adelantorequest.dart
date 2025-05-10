import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'adelantorequest.g.dart';

@JsonSerializable()
class Adelantorequest implements BaseModel {
  int idUsuario;
  double cantidadSolicitada;
  String descripcion;
  String fecha;

  Adelantorequest({
    required this.idUsuario,
    required this.cantidadSolicitada,
    required this.descripcion,
    required this.fecha,
  });

  factory Adelantorequest.fromJson(Map<String, dynamic> json) =>
      _$AdelantorequestFromJson(json);
  Map<String, dynamic> toJson() => _$AdelantorequestToJson(this);
}
