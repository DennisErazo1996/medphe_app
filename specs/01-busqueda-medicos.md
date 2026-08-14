# SPEC 01 — Búsqueda de médicos por especialidad

**Estado:** aprobado
**Depende de:** ninguno
**Fecha:** 2026-08-14

**Objetivo:** Permitir a cualquier usuario, sin necesidad de login, buscar médicos por especialidad, ciudad o nombre, ver su perfil completo, y contactarlo por WhatsApp o redes sociales.

## Alcance

**Incluye:**
- Listado y búsqueda pública de médicos (sin autenticación).
- Filtro por especialidad médica (selector).
- Filtro por ciudad (selector).
- Búsqueda por nombre usando `SearchDelegate` de Flutter.
- Perfil de médico con: foto, nombre, especialidad(es), ciudad, "atiende en:", "servicios médicos:", "atención avanzada a pacientes con:".
- Botón de contacto por WhatsApp (deep link `wa.me` con el número del médico).
- Botones de redes sociales (Instagram, Facebook, TikTok) en el perfil, mostrados solo si el backend envía el valor correspondiente (no null).
- Datos de ejemplo (dummy) en memoria: médicos, especialidades y ciudades de prueba, con fotos de stock vía URL (`https://i.pravatar.cc/...`), ya que el backend Medphe todavía no está listo.
- `DoctorsRepository` con interfaz fija para que, cuando el backend exista, solo se cambie la implementación (de dummy a `dio` real) sin tocar providers ni UI.
- `dio` y `.env`/`flutter_dotenv` quedan agregados y configurados (dependencia + `API_BASE_URL` de placeholder), listos para conectarse cuando el backend esté disponible, pero no se usan todavía para traer datos reales.
- Rutas `/doctors` (listado) y `/doctors/:id` (perfil) con `go_router`.
- Manejo de estados: cargando, error (con reintentar), sin resultados, con resultados.

**No incluye (queda para specs futuros):**
- Agendar cita dentro de la app (reserva real con calendario/backend de citas) — el "agendar" de este spec es solo abrir WhatsApp.
- Búsqueda de hospitales, farmacias, clínicas o laboratorios (specs separados, mismo patrón).
- Login/autenticación de usuario.
- Calificaciones/reseñas de médicos.
- Tarifa de consulta visible.
- Geolocalización por GPS (el filtro de ciudad es por selección manual, no por posición del dispositivo).
- Paginación de resultados (fuera de este spec; el listado trae todos los resultados de la búsqueda de una sola vez).
- Panel de administración para que el médico cargue sus propios datos (los datos ya existen del lado del backend).

## Modelo de datos

Nueva capa `lib/domain/entities/` y `lib/data/` (no existía antes; el proyecto solo tenía `lib/presentation/`).

```dart
// lib/domain/entities/especialidad.dart
class Especialidad {
  final String id;
  final String nombre;
}

// lib/domain/entities/ciudad.dart
class Ciudad {
  final String id;
  final String nombre;
}

// lib/domain/entities/doctor.dart
class Doctor {
  final String id;
  final String nombre;
  final String? fotoUrl;
  final List<Especialidad> especialidades;
  final Ciudad ciudad;
  final String whatsappNumero;         // requerido, formato E.164
  final String? instagramUrl;          // null => botón oculto
  final String? facebookUrl;           // null => botón oculto
  final String? tiktokUrl;             // null => botón oculto
  final List<String> atiendeEn;
  final List<String> serviciosMedicos;
  final List<String> atencionAvanzadaPacientesCon;
}
```

Contrato futuro del backend Medphe (referencia para cuando exista; por ahora `DoctorsRepository` lo implementa con datos dummy en `lib/data/datasources/doctors_dummy_datasource.dart`):
- `GET /especialidades` → `Especialidad[]`
- `GET /ciudades` → `Ciudad[]`
- `GET /medicos?especialidadId=&ciudadId=&nombre=` → `Doctor[]` (todos los filtros opcionales y combinables)
- `GET /medicos/:id` → `Doctor`

Datos dummy: mínimo 8 médicos de ejemplo, cubriendo al menos 4 especialidades y 3 ciudades distintas, con `fotoUrl` apuntando a `https://i.pravatar.cc/300?img=N` (una por médico). Al menos un médico con `instagramUrl`/`facebookUrl`/`tiktokUrl` en null para poder verificar que los botones se ocultan.

## Plan de implementación

1. Agregar dependencias a `pubspec.yaml`: `dio`, `flutter_dotenv`, `flutter_riverpod`, `go_router`, `wolt_modal_sheet`. Crear `.env` con `API_BASE_URL` (placeholder, sin uso real todavía) y agregarlo a `.gitignore`.
2. Crear `lib/domain/entities/` con `Especialidad`, `Ciudad`, `Doctor` (incluye `fromJson`).
3. Crear `lib/data/` con `DoctorsRepository` (interfaz abstracta) y `DummyDoctorsRepository` como única implementación por ahora, con métodos `getEspecialidades()`, `getCiudades()`, `searchDoctors({especialidadId, ciudadId, nombre})`, `getDoctorById(id)`, leyendo de `doctors_dummy_datasource.dart` (lista en memoria, simulando latencia con `Future.delayed`). El cliente `dio` queda instanciado y configurado con `API_BASE_URL` pero sin conectarse a esta repository todavía.
4. Crear providers Riverpod en `lib/presentation/providers/` (exportados vía `providers.dart`): provider de especialidades, provider de ciudades, provider de resultados de búsqueda (parámetros: especialidad/ciudad/nombre), provider de perfil de médico por id.
5. Crear pantalla de listado en `lib/presentation/screens/` (exportada vía `screens.dart`): filtros de especialidad/ciudad (modal con `wolt_modal_sheet`), acceso a búsqueda por nombre (`SearchDelegate`), grid/lista de resultados, estados de carga/error/vacío.
6. Crear pantalla de perfil de médico: foto, nombre, especialidades, ciudad, las tres listas de texto, botón WhatsApp (`wa.me/<numero>`), botones de redes sociales condicionados a no-null.
7. Registrar rutas `/doctors` y `/doctors/:id` en `go_router`, y conectar `MainApp` (`lib/main.dart`) para usar `MaterialApp.router` en vez del `Scaffold` placeholder actual.
8. Verificar manualmente: `flutter run`, probar búsqueda con cada filtro combinado y solo, caso sin resultados, caso de error de red (apagar backend/API_BASE_URL inválida), navegación a perfil y apertura de WhatsApp/redes.

## Criterios de aceptación

- [ ] `flutter analyze` no reporta errores ni warnings nuevos.
- [ ] `/doctors` carga sin login y muestra el listado de médicos desde la API.
- [ ] Filtrar por especialidad devuelve solo médicos de esa especialidad.
- [ ] Filtrar por ciudad devuelve solo médicos de esa ciudad.
- [ ] Combinar especialidad + ciudad + nombre aplica los tres filtros a la vez.
- [ ] Una búsqueda sin resultados muestra el estado "sin resultados", no una lista vacía silenciosa ni un error.
- [ ] Un fallo de red muestra el estado de error con opción de reintentar.
- [ ] `/doctors/:id` muestra foto, nombre, especialidad(es), ciudad, "atiende en:", "servicios médicos:" y "atención avanzada a pacientes con:".
- [ ] El botón de WhatsApp abre `wa.me` con el número correcto del médico mostrado.
- [ ] Los botones de Instagram/Facebook/TikTok solo aparecen cuando el campo correspondiente no es null en la respuesta del backend.
- [ ] `API_BASE_URL` se lee desde `.env` y no está hardcodeada en el código (aunque no se use todavía para pedir datos reales).
- [ ] Los datos mostrados (médicos, especialidades, ciudades, fotos) son todos dummy/stock, sin llamadas reales al backend Medphe.
- [ ] Cambiar de datos dummy a datos reales en el futuro solo requiere una nueva implementación de `DoctorsRepository`, sin tocar providers ni pantallas.

## Decisiones tomadas

- **Spec por entidad:** se decidió dividir médicos/hospitales/farmacias/clínicas/laboratorios en specs separados en vez de uno solo, para mantener cada plan de implementación verificable. Este es el primero y define el patrón (capas `domain`/`data`/`presentation`) que reutilizarán los siguientes.
- **"Agendar cita" = WhatsApp, no reserva real:** evita construir un sistema de citas/calendario en este spec; se puede agregar como spec futuro si se requiere reserva real dentro de la app.
- **Ciudad por selector, no GPS:** más simple, sin pedir permisos de ubicación, y consistente con que la ciudad ya es un catálogo que viene del backend.
- **Campos de perfil como listas de texto libre:** "atiende en", "servicios médicos" y "atención avanzada a pacientes con" no usan catálogos fijos; el backend controla el contenido, la app solo los renderiza.
- **Sin paginación en esta versión:** simplifica el provider y la UI inicial; se puede agregar después si el volumen de médicos lo justifica.
- **Búsqueda por nombre con `SearchDelegate` nativo de Flutter:** en vez de un campo de texto custom, para reusar el patrón estándar de Flutter.
- **Nuevas carpetas `lib/domain/entities/` y `lib/data/`:** el proyecto solo tenía `lib/presentation/` vacío; este spec introduce las capas de modelo y acceso a datos necesarias para consumir la API.
- **Datos dummy en vez de API real:** el backend Medphe aún no está listo. Se implementa `DoctorsRepository` como interfaz desde el inicio para que solo haya que agregar una implementación con `dio` más adelante, sin cambios en providers/UI. Fotos de stock vía `i.pravatar.cc` (servicio público de avatares placeholder) en vez de assets locales, para no cargar imágenes al bundle de la app.

## Riesgos identificados

- El contrato exacto de la API (`/medicos`, `/especialidades`, `/ciudades`) es una suposición razonable basada en las respuestas del usuario, no un contrato ya publicado por el backend — puede requerir ajuste de nombres de campos/endpoints al integrar, y por lo tanto también ajustes en `fromJson` de las entidades cuando se conecte el backend real.
- Números de WhatsApp mal formateados (sin código de país) romperían el deep link `wa.me`; no se definió validación de formato en este spec.
- Dependencia de un servicio externo (`i.pravatar.cc`) para las fotos dummy: si no hay conexión o el servicio cae, las imágenes de perfil no cargan en desarrollo/demo (se recomienda manejar `errorBuilder` en las imágenes para no romper la UI).
