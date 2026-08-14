class Ciudad {
  const Ciudad({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
    );
  }
}
