import '../../domain/entities/ciudad.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';
import '../models/especialistas_response.dart';

/// Convierte el modelo del API (`EspecialistaModel`) a la entity `Doctor`
/// que consume la capa de presentación.
class EspecialistaMapper {
  /// Foto de stock temporal mientras el backend no envía fotos reales.
  static const _fotoStockUrl =
      'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&h=400&fit=crop&crop=faces';

  static Doctor toEntity(EspecialistaModel model) {
    final social = model.socialLinks ?? const {};

    return Doctor(
      id: model.id.toString(),
      nombre: model.displayNameWithTitle.isNotEmpty
          ? model.displayNameWithTitle
          : '${model.title} ${model.fullName}'.trim(),
      fotoUrl: model.photoUrl != null && model.photoUrl!.isNotEmpty
          ? model.photoUrl
          : _fotoStockUrl,
      especialidades: [
        Especialidad(id: model.specialty, nombre: model.specialty),
        ...model.subspecialties.map((s) => Especialidad(id: s, nombre: s)),
      ],
      ciudad: Ciudad(
        id: model.city,
        nombre: model.city,
        departamento: model.department,
      ),
      whatsappNumero: model.whatsapp ?? model.phone ?? '',
      instagramUrl: social['instagram'] as String?,
      facebookUrl: social['facebook'] as String?,
      tiktokUrl: social['tiktok'] as String?,
      atiendeEn: model.medicalCenters.map((c) => c.name).toList(),
      serviciosMedicos: model.medicalServices,
      atencionAvanzadaPacientesCon: model.treatedConditions,
      centrosMedicosIds:
          model.medicalCenters.map((c) => c.id.toString()).toList(),
    );
  }
}
