import '../../domain/entities/ciudad.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';

const especialidadesDummy = [
  Especialidad(id: 'esp-1', nombre: 'Cardiología'),
  Especialidad(id: 'esp-2', nombre: 'Pediatría'),
  Especialidad(id: 'esp-3', nombre: 'Dermatología'),
  Especialidad(id: 'esp-4', nombre: 'Ginecología'),
];

const ciudadesDummy = [
  Ciudad(id: 'ciu-1', nombre: 'Quito'),
  Ciudad(id: 'ciu-2', nombre: 'Guayaquil'),
  Ciudad(id: 'ciu-3', nombre: 'Cuenca'),
];

final doctoresDummy = <Doctor>[
  Doctor(
    id: 'doc-1',
    nombre: 'Dra. María Fernanda López',
    fotoUrl:
        'https://images.unsplash.com/photo-1685688739798-bce206ab6b42?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[0]],
    ciudad: ciudadesDummy[0],
    whatsappNumero: '593987654321',
    instagramUrl: 'https://instagram.com/dra.lopez',
    facebookUrl: 'https://facebook.com/dra.lopez',
    tiktokUrl: null,
    atiendeEn: ['Hospital Metropolitano', 'Clínica del Corazón'],
    serviciosMedicos: ['Ecocardiograma', 'Prueba de esfuerzo'],
    atencionAvanzadaPacientesCon: ['Hipertensión', 'Arritmias'],
  ),
  Doctor(
    id: 'doc-2',
    nombre: 'Dr. Carlos Andrade',
    fotoUrl:
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[1]],
    ciudad: ciudadesDummy[1],
    whatsappNumero: '593987654322',
    instagramUrl: null,
    facebookUrl: null,
    tiktokUrl: null,
    atiendeEn: ['Hospital de Niños'],
    serviciosMedicos: ['Control de niño sano', 'Vacunación'],
    atencionAvanzadaPacientesCon: ['Asma infantil'],
  ),
  Doctor(
    id: 'doc-3',
    nombre: 'Dra. Paola Vintimilla',
    fotoUrl:
        'https://images.unsplash.com/photo-1721674098745-7d1b76e0fc02?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[2]],
    ciudad: ciudadesDummy[2],
    whatsappNumero: '593987654323',
    instagramUrl: 'https://instagram.com/dra.vintimilla',
    facebookUrl: null,
    tiktokUrl: 'https://tiktok.com/@dra.vintimilla',
    atiendeEn: ['Clínica Dermatológica Cuenca'],
    serviciosMedicos: ['Biopsia de piel', 'Tratamiento de acné'],
    atencionAvanzadaPacientesCon: ['Psoriasis', 'Melanoma'],
  ),
  Doctor(
    id: 'doc-4',
    nombre: 'Dr. Jorge Salazar',
    fotoUrl:
        'https://images.unsplash.com/photo-1612531385446-f7e6d131e1d0?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[0], especialidadesDummy[3]],
    ciudad: ciudadesDummy[0],
    whatsappNumero: '593987654324',
    instagramUrl: 'https://instagram.com/dr.salazar',
    facebookUrl: 'https://facebook.com/dr.salazar',
    tiktokUrl: 'https://tiktok.com/@dr.salazar',
    atiendeEn: ['Hospital Metropolitano'],
    serviciosMedicos: ['Electrocardiograma', 'Consulta prenatal'],
    atencionAvanzadaPacientesCon: ['Insuficiencia cardíaca'],
  ),
  Doctor(
    id: 'doc-5',
    nombre: 'Dra. Ana Belén Torres',
    fotoUrl:
        'https://images.unsplash.com/photo-1712744626457-3ffa4ba32c8c?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[3]],
    ciudad: ciudadesDummy[1],
    whatsappNumero: '593987654325',
    instagramUrl: 'https://instagram.com/dra.torres',
    facebookUrl: null,
    tiktokUrl: null,
    atiendeEn: ['Hospital Materno Infantil'],
    serviciosMedicos: ['Control prenatal', 'Colposcopia'],
    atencionAvanzadaPacientesCon: ['Embarazo de alto riesgo'],
  ),
  Doctor(
    id: 'doc-6',
    nombre: 'Dr. Luis Chamorro',
    fotoUrl:
        'https://images.unsplash.com/photo-1612349316228-5942a9b489c2?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[1]],
    ciudad: ciudadesDummy[2],
    whatsappNumero: '593987654326',
    instagramUrl: null,
    facebookUrl: 'https://facebook.com/dr.chamorro',
    tiktokUrl: null,
    atiendeEn: ['Clínica Pediátrica Cuenca'],
    serviciosMedicos: ['Consulta pediátrica general'],
    atencionAvanzadaPacientesCon: ['Alergias alimentarias'],
  ),
  Doctor(
    id: 'doc-7',
    nombre: 'Dra. Verónica Peralta',
    fotoUrl:
        'https://images.unsplash.com/photo-1758600587839-56ba05596c69?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[2]],
    ciudad: ciudadesDummy[1],
    whatsappNumero: '593987654327',
    instagramUrl: 'https://instagram.com/dra.peralta',
    facebookUrl: 'https://facebook.com/dra.peralta',
    tiktokUrl: null,
    atiendeEn: ['Hospital Alcívar'],
    serviciosMedicos: ['Dermatoscopia', 'Cirugía menor de piel'],
    atencionAvanzadaPacientesCon: ['Cáncer de piel'],
  ),
  Doctor(
    id: 'doc-8',
    nombre: 'Dr. Esteban Ríos',
    fotoUrl:
        'https://images.unsplash.com/photo-1612523138351-4643808db8f3?auto=format&fit=crop&w=400&q=80',
    especialidades: [especialidadesDummy[0]],
    ciudad: ciudadesDummy[2],
    whatsappNumero: '593987654328',
    instagramUrl: null,
    facebookUrl: null,
    tiktokUrl: null,
    atiendeEn: ['Hospital Vicente Corral Moscoso'],
    serviciosMedicos: ['Holter', 'Monitoreo de presión arterial'],
    atencionAvanzadaPacientesCon: ['Fibrilación auricular'],
  ),
];
