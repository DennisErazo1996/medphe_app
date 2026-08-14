import 'ciudad.dart';
import 'especialidad.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.nombre,
    this.fotoUrl,
    required this.especialidades,
    required this.ciudad,
    required this.whatsappNumero,
    this.instagramUrl,
    this.facebookUrl,
    this.tiktokUrl,
    required this.atiendeEn,
    required this.serviciosMedicos,
    required this.atencionAvanzadaPacientesCon,
  });

  final String id;
  final String nombre;
  final String? fotoUrl;
  final List<Especialidad> especialidades;
  final Ciudad ciudad;
  final String whatsappNumero;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? tiktokUrl;
  final List<String> atiendeEn;
  final List<String> serviciosMedicos;
  final List<String> atencionAvanzadaPacientesCon;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      fotoUrl: json['fotoUrl'] as String?,
      especialidades: (json['especialidades'] as List)
          .map((e) => Especialidad.fromJson(e as Map<String, dynamic>))
          .toList(),
      ciudad: Ciudad.fromJson(json['ciudad'] as Map<String, dynamic>),
      whatsappNumero: json['whatsappNumero'] as String,
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      atiendeEn: (json['atiendeEn'] as List).cast<String>(),
      serviciosMedicos: (json['serviciosMedicos'] as List).cast<String>(),
      atencionAvanzadaPacientesCon:
          (json['atencionAvanzadaPacientesCon'] as List).cast<String>(),
    );
  }
}
