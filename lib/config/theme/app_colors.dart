import 'package:flutter/material.dart';

/// Colores oficiales de la marca Medphe y roles semánticos de la aplicación.
abstract final class AppColors {
  // ===========================================================================
  // COLORES PRINCIPALES (Marca Oficial)
  // ===========================================================================

  /// Azul Noche: `#02185d` | RGB(2, 24, 93) | CMYK(98%, 74%, 0%, 64%)
  static const Color azulNoche = Color(0xFF02185D);

  /// Azul Eléctrico: `#1d2eec` | RGB(29, 46, 236) | CMYK(88%, 81%, 0%, 7%)
  static const Color azulElectrico = Color(0xFF1D2EEC);

  /// Magenta: `#ce00ff` | RGB(206, 0, 255) | CMYK(19%, 100%, 0%, 0%)
  ///
  /// NOTA: Color oficial de la marca. Por decisión de diseño no se utiliza en
  /// los componentes activos del tema debido a su alta saturación ("chillane").
  static const Color magenta = Color(0xFFCE00FF);

  // ===========================================================================
  // COLORES SECUNDARIOS (Marca Oficial)
  // ===========================================================================

  /// Celeste Aqua: `#9fc4ed` | RGB(109, 205, 229) | CMYK(52%, 10%, 0%, 10%)
  static const Color celesteAqua = Color(0xFF9FC4ED);

  /// Lavanda Suave: `#dcb8ff` | RGB(220, 184, 255) | CMYK(14%, 28%, 0%, 0%)
  static const Color lavandaSuave = Color(0xFFDCB8FF);

  /// Gris Perla: `#ededed` | RGB(237, 237, 237) | CMYK(0%, 0%, 0%, 7%)
  static const Color grisPerla = Color(0xFFEDEDED);

  // ===========================================================================
  // ROLES SEMÁNTICOS (Tema de la App)
  // ===========================================================================

  /// Color primario de la aplicación (Azul Eléctrico)
  static const Color primary = azulElectrico;

  /// Color secundario y contraste elegante (Azul Noche)
  static const Color secondary = azulNoche;

  /// Color de acento fresco (Celeste Aqua)
  static const Color accent = celesteAqua;

  /// Tono lavanda para detalles suaves (Lavanda Suave)
  static const Color lavanda = lavandaSuave;

  /// Fondo y superficie general con un matiz limpio y moderno
  static const Color surface = Color(0xFFF5F7FB);

  /// Fondo o bordes neutros claros (Gris Perla)
  static const Color neutralLight = grisPerla;

  /// Color para favoritos / likes
  static const Color favorite = Color(0xFFE53E7A);

  /// Paleta rotativa para categorías y especialidades médicas
  static const List<Color> categoryPalette = [
    azulElectrico,
    azulNoche,
    Color(0xFF12A594),
    Color(0xFFF2994A),
  ];
}
