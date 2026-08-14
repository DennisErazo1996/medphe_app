class Ciudad {
  const Ciudad({
    required this.id,
    required this.nombre,
    required this.departamento,
  });

  final String id;
  final String nombre;
  final String departamento;

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      departamento: json['departamento'] as String,
    );
  }
}
