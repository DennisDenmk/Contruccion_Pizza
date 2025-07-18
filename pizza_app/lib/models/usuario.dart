class Usuario {
  final int id;
  final String name;
  final bool? state;
  String? password;

  Usuario({
    required this.id,
    required this.name,
    required this.state,
    this.password,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['usu_id'] is int ? json['usu_id'] : int.parse(json['usu_id'].toString()),
      name: json['usu_name'],
      state: json['usu_state'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': name,
    };
    
    // Solo incluir estado si no es nulo
    if (state != null) {
      map['estado'] = state;
    }
    
    // Solo incluir contraseña si no es nula o vacía
    if (password != null && password!.isNotEmpty) {
      map['contrasenia'] = password!;
    }
    
    return map;
  }
}