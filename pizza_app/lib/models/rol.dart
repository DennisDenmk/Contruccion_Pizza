class Rol {
  final int id;
  final String name;
  final String description;
  final bool state;

  Rol({
    required this.id,
    required this.name,
    required this.description,
    required this.state,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['rol_id'] is int ? json['rol_id'] : int.parse(json['rol_id'].toString()),
      name: json['rol_name'],
      description: json['rol_description'],
      state: json['rol_state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rol_name': name,
      'rol_description': description,
      'rol_state': state,
    };
  }
}