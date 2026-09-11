import 'ciudad.dart';

class CentroMedico {
  const CentroMedico({
    required this.id,
    required this.nombre,
    required this.acronimo,
    required this.slug,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    this.googleMapsUrl,
    this.horario,
    this.telefonos,
    this.whatsapp,
    this.email,
    this.facebookUrl,
    this.instagramUrl,
    this.websiteUrl,
    this.citaUrl,
    this.serviciosMedicos = const [],
    this.especialidadesMedicas = const [],
    this.esActivo = true,
    this.esDestacado = false,
    this.logoUrl,
    this.fotoPortadaUrl,
  });

  final String id;
  final String nombre;
  final String acronimo;
  final String slug;
  final String direccion;
  final Ciudad ciudad;
  final String departamento;
  final String? googleMapsUrl;
  final String? horario;
  final String? telefonos;
  final String? whatsapp;
  final String? email;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? websiteUrl;
  final String? citaUrl;
  final List<String> serviciosMedicos;
  final List<String> especialidadesMedicas;
  final bool esActivo;
  final bool esDestacado;
  final String? logoUrl;
  final String? fotoPortadaUrl;

  bool get tieneWhatsapp => whatsapp != null && whatsapp!.trim().isNotEmpty;
  bool get tieneTelefonos => telefonos != null && telefonos!.trim().isNotEmpty;
  bool get tieneGoogleMaps =>
      googleMapsUrl != null && googleMapsUrl!.trim().isNotEmpty;
  bool get tieneEmail => email != null && email!.trim().isNotEmpty;
  bool get tieneWebsite => websiteUrl != null && websiteUrl!.trim().isNotEmpty;
  bool get tieneCitaUrl =>
      citaUrl != null && citaUrl!.trim().isNotEmpty;

  String get displayNombre =>
      acronimo.isNotEmpty && acronimo != nombre
          ? '$nombre ($acronimo)'
          : nombre;

  factory CentroMedico.fromJson(Map<String, dynamic> json) {
    return CentroMedico(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      acronimo: json['acronimo'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      ciudad: Ciudad.fromJson(json['ciudad'] as Map<String, dynamic>),
      departamento: json['departamento'] as String? ?? '',
      googleMapsUrl: json['googleMapsUrl'] as String?,
      horario: json['horario'] as String?,
      telefonos: json['telefonos'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      citaUrl: json['citaUrl'] as String?,
      serviciosMedicos: (json['serviciosMedicos'] as List?)?.cast<String>() ??
          const [],
      especialidadesMedicas:
          (json['especialidadesMedicas'] as List?)?.cast<String>() ?? const [],
      esActivo: json['esActivo'] as bool? ?? true,
      esDestacado: json['esDestacado'] as bool? ?? false,
      logoUrl: json['logoUrl'] as String?,
      fotoPortadaUrl: json['fotoPortadaUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'acronimo': acronimo,
    'slug': slug,
    'direccion': direccion,
    'ciudad': {'id': ciudad.id, 'nombre': ciudad.nombre, 'departamento': ciudad.departamento},
    'departamento': departamento,
    'googleMapsUrl': googleMapsUrl,
    'horario': horario,
    'telefonos': telefonos,
    'whatsapp': whatsapp,
    'email': email,
    'facebookUrl': facebookUrl,
    'instagramUrl': instagramUrl,
    'websiteUrl': websiteUrl,
    'citaUrl': citaUrl,
    'serviciosMedicos': serviciosMedicos,
    'especialidadesMedicas': especialidadesMedicas,
    'esActivo': esActivo,
    'esDestacado': esDestacado,
    'logoUrl': logoUrl,
    'fotoPortadaUrl': fotoPortadaUrl,
  };
}
