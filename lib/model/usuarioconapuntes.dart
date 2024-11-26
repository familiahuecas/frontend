import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'usuarioconapuntes.g.dart';

@JsonSerializable()
class UsuarioConApuntes implements BaseModel {
  int idUsuario;
  String nombre;
  double cantidadAsignada;
  double cantidadRestante;
  int numeroDeApuntes;

  UsuarioConApuntes({
    required this.idUsuario,
    required this.nombre,
    required this.cantidadAsignada,
    required this.cantidadRestante,
    required this.numeroDeApuntes,
  });

  factory UsuarioConApuntes.fromJson(Map<String, dynamic> json) => _$UsuarioConApuntesFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioConApuntesToJson(this);
}

@JsonSerializable()
class UsuarioConApuntesPage extends Page<UsuarioConApuntes> implements BaseModel {
  @override
  List<UsuarioConApuntes> content;

  UsuarioConApuntesPage({
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

  factory UsuarioConApuntesPage.fromJson(Map<String, dynamic>? json) => _$UsuarioConApuntesPageFromJson(json!);
  @override
  Map<String, dynamic> toJson() => _$UsuarioConApuntesPageToJson(this);
}
