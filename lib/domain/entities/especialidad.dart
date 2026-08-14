class Especialidad {
  const Especialidad({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
    );
  }
}
