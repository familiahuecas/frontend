import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'recaudacionresponse.g.dart';

@JsonSerializable()
class Recaudacionresponse implements BaseModel {
  @JsonKey(name: 'entradaM1')
  int? entradaM1;
  @JsonKey(name: 'salidaM1')
  int? salidaM1;
  @JsonKey(name: 'entradaM2')
  int? entradaM2;
  @JsonKey(name: 'salidaM2')
  int? salidaM2;

  @JsonKey(name: 'lastEntradaM1')
  int? lastEntradaM1;
  @JsonKey(name: 'lastSalidaM1')
  int? lastSalidaM1;
  @JsonKey(name: 'lastEntradaM2')
  int? lastEntradaM2;
  @JsonKey(name: 'lastSalidaM2')
  int? lastSalidaM2;

  @JsonKey(name: 'restaEntradaM1')
  int? restaEntradaM1;
  @JsonKey(name: 'restaSalidaM1')
  int? restaSalidaM1;
  @JsonKey(name: 'restaEntradaM2')
  int? restaEntradaM2;
  @JsonKey(name: 'restaSalidaM2')
  int? restaSalidaM2;

  double? total;
  @JsonKey(name: 'totalcadauno')
  double? totalCadaUno;
  double? totalm1;
  double? totalm2;

  Recaudacionresponse({
    this.entradaM1,
    this.salidaM1,
    this.entradaM2,
    this.salidaM2,
    this.lastEntradaM1,
    this.lastSalidaM1,
    this.lastEntradaM2,
    this.lastSalidaM2,
    this.restaEntradaM1,
    this.restaSalidaM1,
    this.restaEntradaM2,
    this.restaSalidaM2,
    this.total,
    this.totalCadaUno,
    this.totalm1,
    this.totalm2,
  });

  factory Recaudacionresponse.fromJson(Map<String, dynamic> json) => _$RecaudacionresponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecaudacionresponseToJson(this);
}
