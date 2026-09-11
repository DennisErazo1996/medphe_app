import '../../domain/entities/ciudad.dart';
import '../../domain/entities/centro_medico.dart';
import '../models/centros_medicos_response.dart';

/// Convierte el modelo de respuesta (`Datum` / `CentroMedicoModel`) a la
/// entity `CentroMedico` que consume la capa de presentación.
class CentroMedicoMapper {
  /// Foto de stock por defecto cuando el centro no tiene cover photo cargada.
  static const _fotoPortadaStockUrl =
      'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=1200&h=600&fit=crop';

  static CentroMedico toEntity(Datum model) {
    return CentroMedico(
      id: model.id.toString(),
      nombre: model.name,
      acronimo: model.acronym,
      slug: model.slug,
      direccion: model.address,
      ciudad: Ciudad(
        id: model.city,
        nombre: model.city,
        departamento: model.department,
      ),
      departamento: model.department,
      googleMapsUrl: model.googleMapsUrl,
      horario: model.schedule,
      telefonos: model.phones,
      whatsapp: model.whatsapp,
      email: model.email,
      facebookUrl: model.facebookUrl,
      instagramUrl: model.instagramUrl,
      websiteUrl: model.websiteUrl,
      citaUrl: model.appointmentUrl,
      serviciosMedicos: model.medicalServices,
      especialidadesMedicas: model.medicalSpecialties,
      esActivo: model.isActive,
      esDestacado: model.isFeatured,
      logoUrl: model.logoUrl,
      fotoPortadaUrl:
          model.coverPhotoUrl != null && model.coverPhotoUrl!.isNotEmpty
              ? model.coverPhotoUrl
              : _fotoPortadaStockUrl,
    );
  }
}
