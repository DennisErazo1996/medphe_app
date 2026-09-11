/// Respuesta paginada (Laravel) del endpoint `/doctors`.
///
/// Parsing defensivo: los campos de paginación pueden venir null (última
/// página, lista vacía) y los catálogos del backend (especialidades,
/// servicios, horarios) son abiertos, por lo que se mapean como `String`
/// en lugar de enums.
class EspecialistasResponse {
  const EspecialistasResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  final int currentPage;
  final List<EspecialistaModel> data;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  factory EspecialistasResponse.fromJson(Map<String, dynamic> json) {
    return EspecialistasResponse(
      currentPage: json['current_page'] as int? ?? 1,
      data: ((json['data'] as List?) ?? const [])
          .map((e) => EspecialistaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }
}

class EspecialistaModel {
  const EspecialistaModel({
    required this.id,
    required this.title,
    required this.name,
    required this.fullName,
    required this.specialty,
    required this.subspecialties,
    required this.slug,
    required this.colegiacion,
    required this.department,
    required this.city,
    required this.rating,
    required this.reviewsCount,
    required this.isAvailable,
    required this.isActive,
    required this.isFeatured,
    required this.fullTitle,
    required this.displayNameWithTitle,
    required this.medicalCenters,
    this.photoUrl,
    this.coverPhotoUrl,
    this.address,
    this.googleMapsUrl,
    this.schedule,
    this.phone,
    this.whatsapp,
    this.email,
    this.appointmentUrl,
    this.socialLinks,
    this.education = const [],
    this.medicalServices = const [],
    this.treatedConditions = const [],
    this.specialProcedures = const [],
  });

  final int id;
  final String title;
  final String name;
  final String fullName;
  final String specialty;
  final List<String> subspecialties;
  final String slug;
  final String colegiacion;
  final String department;
  final String city;
  final double rating;
  final int reviewsCount;
  final bool isAvailable;
  final bool isActive;
  final bool isFeatured;
  final String fullTitle;
  final String displayNameWithTitle;
  final List<MedicalCenterModel> medicalCenters;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final String? address;
  final String? googleMapsUrl;
  final String? schedule;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? appointmentUrl;
  final Map<String, dynamic>? socialLinks;
  final List<String> education;
  final List<String> medicalServices;
  final List<String> treatedConditions;
  final List<String> specialProcedures;

  factory EspecialistaModel.fromJson(Map<String, dynamic> json) {
    return EspecialistaModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      subspecialties: _stringList(json['subspecialties']),
      slug: json['slug'] as String? ?? '',
      colegiacion: json['colegiacion'] as String? ?? '',
      department: json['department'] as String? ?? '',
      city: json['city'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      fullTitle: json['full_title'] as String? ?? '',
      displayNameWithTitle: json['display_name_with_title'] as String? ?? '',
      medicalCenters: ((json['medical_centers'] as List?) ?? const [])
          .map((e) => MedicalCenterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoUrl: json['photo_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      address: json['address'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      schedule: json['schedule'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      appointmentUrl: json['appointment_url'] as String?,
      socialLinks: json['social_links'] as Map<String, dynamic>?,
      education: _stringList(json['education']),
      medicalServices: _stringList(json['medical_services']),
      treatedConditions: _stringList(json['treated_conditions']),
      specialProcedures: _stringList(json['special_procedures']),
    );
  }
}

class MedicalCenterModel {
  const MedicalCenterModel({
    required this.id,
    required this.name,
    required this.acronym,
    required this.slug,
    required this.address,
    required this.department,
    required this.city,
    required this.medicalServices,
    required this.medicalSpecialties,
    required this.isActive,
    required this.isFeatured,
    this.schedule,
    this.phones,
    this.whatsapp,
    this.email,
    this.facebookUrl,
    this.instagramUrl,
    this.websiteUrl,
    this.appointmentUrl,
    this.googleMapsUrl,
    this.logoUrl,
    this.coverPhotoUrl,
    this.consultorio,
  });

  final int id;
  final String name;
  final String acronym;
  final String slug;
  final String address;
  final String department;
  final String city;
  final List<String> medicalServices;
  final List<String> medicalSpecialties;
  final bool isActive;
  final bool isFeatured;
  final String? schedule;
  final String? phones;
  final String? whatsapp;
  final String? email;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? websiteUrl;
  final String? appointmentUrl;
  final String? googleMapsUrl;
  final String? logoUrl;
  final String? coverPhotoUrl;

  /// Consultorio asignado al doctor dentro del centro (viene del pivot).
  final String? consultorio;

  factory MedicalCenterModel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>?;

    return MedicalCenterModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      acronym: json['acronym'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      address: json['address'] as String? ?? '',
      department: json['department'] as String? ?? '',
      city: json['city'] as String? ?? '',
      medicalServices: _stringList(json['medical_services']),
      medicalSpecialties: _stringList(json['medical_specialties']),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      schedule: json['schedule'] as String?,
      phones: json['phones'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      facebookUrl: json['facebook_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      appointmentUrl: json['appointment_url'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      consultorio: pivot?['consultorio'] as String?,
    );
  }
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}
