/// Respuesta paginada (Laravel) del endpoint `/medical-centers`.
///
/// Parsing defensivo: los campos de paginación pueden venir null y los
/// catálogos del backend (servicios, especialidades, horarios) son abiertos,
/// por lo que se mapean como `String` en lugar de enums fijos.
class CentrosMedicosResponse {
  const CentrosMedicosResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.firstPageUrl,
    this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    this.path,
    this.from,
    this.to,
  });

  final int currentPage;
  final List<Datum> data;
  final int lastPage;
  final int perPage;
  final int total;
  final String? firstPageUrl;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final String? path;
  final int? from;
  final int? to;

  factory CentrosMedicosResponse.fromJson(Map<String, dynamic> json) =>
      CentrosMedicosResponse(
        currentPage: json["current_page"] as int? ?? 1,
        data: ((json["data"] as List?) ?? const [])
            .map((x) => Datum.fromJson(x as Map<String, dynamic>))
            .toList(),
        firstPageUrl: json["first_page_url"] as String?,
        from: json["from"] as int?,
        lastPage: json["last_page"] as int? ?? 1,
        lastPageUrl: json["last_page_url"] as String?,
        nextPageUrl: json["next_page_url"] as String?,
        path: json["path"] as String?,
        perPage: json["per_page"] as int? ?? 0,
        prevPageUrl: json["prev_page_url"] as String?,
        to: json["to"] as int?,
        total: json["total"] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data.map((x) => x.toJson()).toList(),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

typedef CentroMedicoModel = Datum;

class Datum {
  final int id;
  final String name;
  final String acronym;
  final String slug;
  final String? logoPath;
  final String? coverPhotoPath;
  final String address;
  final String department;
  final String city;
  final String? googleMapsUrl;
  final String? schedule;
  final String? phones;
  final String? whatsapp;
  final String? email;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? websiteUrl;
  final String? appointmentUrl;
  final List<String> medicalServices;
  final List<String> medicalSpecialties;
  final bool isActive;
  final bool isFeatured;
  final String? logoUrl;
  final String? coverPhotoUrl;

  const Datum({
    required this.id,
    required this.name,
    required this.acronym,
    required this.slug,
    this.logoPath,
    this.coverPhotoPath,
    required this.address,
    required this.department,
    required this.city,
    this.googleMapsUrl,
    this.schedule,
    this.phones,
    this.whatsapp,
    this.email,
    this.facebookUrl,
    this.instagramUrl,
    this.websiteUrl,
    this.appointmentUrl,
    this.medicalServices = const [],
    this.medicalSpecialties = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.logoUrl,
    this.coverPhotoUrl,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] as int? ?? 0,
    name: json["name"] as String? ?? '',
    acronym: json["acronym"] as String? ?? '',
    slug: json["slug"] as String? ?? '',
    logoPath: json["logo_path"] as String?,
    coverPhotoPath: json["cover_photo_path"] as String?,
    address: json["address"] as String? ?? '',
    department: json["department"] as String? ?? '',
    city: json["city"] as String? ?? '',
    googleMapsUrl: json["google_maps_url"] as String?,
    schedule: json["schedule"] as String?,
    phones: json["phones"] as String?,
    whatsapp: json["whatsapp"] as String?,
    email: json["email"] as String?,
    facebookUrl: json["facebook_url"] as String?,
    instagramUrl: json["instagram_url"] as String?,
    websiteUrl: json["website_url"] as String?,
    appointmentUrl: json["appointment_url"] as String?,
    medicalServices: _stringList(json["medical_services"]),
    medicalSpecialties: _stringList(json["medical_specialties"]),
    isActive: json["is_active"] as bool? ?? true,
    isFeatured: json["is_featured"] as bool? ?? false,
    logoUrl: json["logo_url"] as String?,
    coverPhotoUrl: json["cover_photo_url"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "acronym": acronym,
    "slug": slug,
    "logo_path": logoPath,
    "cover_photo_path": coverPhotoPath,
    "address": address,
    "department": department,
    "city": city,
    "google_maps_url": googleMapsUrl,
    "schedule": schedule,
    "phones": phones,
    "whatsapp": whatsapp,
    "email": email,
    "facebook_url": facebookUrl,
    "instagram_url": instagramUrl,
    "website_url": websiteUrl,
    "appointment_url": appointmentUrl,
    "medical_services": medicalServices,
    "medical_specialties": medicalSpecialties,
    "is_active": isActive,
    "is_featured": isFeatured,
    "logo_url": logoUrl,
    "cover_photo_url": coverPhotoUrl,
  };
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}
