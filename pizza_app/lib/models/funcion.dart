class Funcion {
  final int id;
  final String name;
  final String description;
  final bool state;

  Funcion({
    required this.id,
    required this.name,
    required this.description,
    required this.state,
  });

  factory Funcion.fromJson(Map<String, dynamic> json) {
    return Funcion(
      id: json['fun_id'] is int ? json['fun_id'] : int.parse(json['fun_id'].toString()),
      name: json['fun_name'],
      description: json['fun_description'],
      state: json['fun_state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fun_name': name,
      'fun_description': description,
      'fun_state': state,
    };
  }
}