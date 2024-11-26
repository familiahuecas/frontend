import 'dart:convert';

class UsuarioConAdelanto {
  int idUsuario;
  double cantidadSolicitada;

  UsuarioConAdelanto({
    required this.idUsuario,
    required this.cantidadSolicitada,
  });

  factory UsuarioConAdelanto.fromJson(Map<String, dynamic> json) {
    return UsuarioConAdelanto(
      idUsuario: json['idUsuario'],
      cantidadSolicitada: json['cantidadSolicitada'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'cantidadSolicitada': cantidadSolicitada,
    };
  }
}
