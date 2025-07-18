class RolFuncion {
  final int rolId;
  final int funId;

  RolFuncion({
    required this.rolId,
    required this.funId,
  });

  factory RolFuncion.fromJson(Map<String, dynamic> json) {
    return RolFuncion(
      rolId: json['rol_id'] is int ? json['rol_id'] : int.parse(json['rol_id'].toString()),
      funId: json['fun_id'] is int ? json['fun_id'] : int.parse(json['fun_id'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rol_id': rolId,
      'fun_id': funId,
    };
  }
}