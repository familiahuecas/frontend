import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'recaudacionrequest.g.dart';

@JsonSerializable()
class Recaudacionrequest implements BaseModel {
  String bar;
//  @JsonKey(name: 'entrada_m1')
  int entradaM1;
//  @JsonKey(name: 'salida_m1')
  int salidaM1;
//  @JsonKey(name: 'entrada_m2')
  int entradaM2;
//  @JsonKey(name: 'salida_m2')
  int salidaM2;

  Recaudacionrequest({
    required this.bar,
    required this.entradaM1,
    required this.salidaM1,
    required this.entradaM2,
    required this.salidaM2,
  });

  factory Recaudacionrequest.fromJson(Map<String, dynamic> json) => _$RecaudacionrequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecaudacionrequestToJson(this);
}
