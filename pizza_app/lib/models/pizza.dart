class Pizza {
  final int id;
  final String name;
  final String origin;
  final bool state;

  Pizza({
    required this.id,
    required this.name,
    required this.origin,
    required this.state,
  });

  factory Pizza.fromJson(Map<String, dynamic> json) {
    return Pizza(
      id: json['piz_id'] is int ? json['piz_id'] : int.parse(json['piz_id'].toString()),
      name: json['piz_name'],
      origin: json['piz_origin'],
      state: json['piz_state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'piz_name': name,
      'piz_origin': origin,
      'piz_state': state,
    };
  }
}