import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'usuarioconadelanto.g.dart';

@JsonSerializable()
class UsuarioConAdelanto implements BaseModel {
  @JsonKey(name: 'id') // ← porque el backend devuelve "id"
  int idUsuario;

  double cantidadSolicitada;
  String descripcion;
  String fecha;

  String? name; 

  UsuarioConAdelanto({
    required this.idUsuario,
    required this.cantidadSolicitada,
    required this.descripcion,
    required this.fecha,
    this.name,
  });

  factory UsuarioConAdelanto.fromJson(Map<String, dynamic> json) =>
      _$UsuarioConAdelantoFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioConAdelantoToJson(this);
}

@JsonSerializable()
class UsuarioConAdelantoPage extends Page<UsuarioConAdelanto>
    implements BaseModel {
  @override
  List<UsuarioConAdelanto> content;

  UsuarioConAdelantoPage({
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

  factory UsuarioConAdelantoPage.fromJson(Map<String, dynamic> json) =>
      _$UsuarioConAdelantoPageFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UsuarioConAdelantoPageToJson(this);
}
