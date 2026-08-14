# CLAUDE.md

Este archivo da guía a Claude Code (claude.ai/code) al trabajar con código en este repositorio.

## Estado del proyecto

`medphe_app` es una app Flutter en etapa temprana de scaffold. `lib/main.dart` solo renderiza una pantalla placeholder `Hello World!`. La arquitectura prevista es una capa `presentation` con barrel files `screens/`, `pages/` y `providers/` (`lib/presentation/screens/screens.dart`, `lib/presentation/pages/pages.dart`, `lib/presentation/providers/providers.dart`), pero todos están vacíos — aún no hay código real. No existe carpeta de tests ni paquete de manejo de estado/navegación declarado en `pubspec.yaml`.

## Comandos

- Instalar deps: `flutter pub get`
- Correr app (con dispositivo/emulador conectado): `flutter run`
- Análisis estático / lint: `flutter analyze` (reglas de `package:flutter_lints/flutter.yaml` vía `analysis_options.yaml`)
- Correr todos los tests: `flutter test`
- Correr un solo archivo de test: `flutter test test/<archivo>_test.dart`
- Ver deps desactualizadas/incompatibles: `flutter pub outdated`

## Entorno

- Restricción de Dart SDK: `^3.10.7` (ver `pubspec.yaml`)
- Targets: Android e iOS (ambas carpetas de plataforma presentes); sin config web/desktop.

## Notas de arquitectura

- Punto de entrada es `MainApp` en `lib/main.dart`, un `StatelessWidget` que envuelve un `MaterialApp`.
- El patrón de barrel files `lib/presentation/{screens,pages,providers}/` está definido pero vacío — al agregar código de UI o estado, seguir esta división de carpetas existente (screens vs. pages vs. providers) en vez de introducir estructura nueva, y exportar archivos nuevos a través del barrel file correspondiente.

- El directorio /pages es para aquellas pantallas que sean push.

## Librerias

- dio: esta libreria va a manejar todas las peticiones rest de la app.
- flutter_dotenv: este paquete para manejar el archivo .env y las variables de entorno del proyecto.
- flutter_riverpod: este paquete manejará los estados de la aplicacion en los providers.
- go_router: este paquete manejará todas las rutas de la app,  statefulshellroutes, push, etc.
- wolt_modal_sheet: para manejar los modales y tenga una apariencia moderna.


# Colores

Por el momento el unico color oficial es #1D2EEC seguido por un violeta parecido al #6c1dec.

## Que NO hacer

- No agregues nuevos paquetes sin antes preguntar.
- No hagas commits, pull, push porque yo los haré manualmente.