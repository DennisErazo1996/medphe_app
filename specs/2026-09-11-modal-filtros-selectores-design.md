# Especificación de Diseño: Selectores con Buscador en Modal de Filtros

## 1. Contexto y Problema
En el modal de filtros (`showDoctorsFilterModal`) de la pantalla de inicio, las opciones de **Especialidad** y **Ciudad** se renderizaban como una nube masiva de *chips/pills* (`Wrap`). Al haber decenas de especialidades obtenidas del backend, el modal quedaba saturado verticalmente, degradando la usabilidad y dificultando encontrar una opción concreta.

## 2. Solución Propuesta
Transformar los filtros de Especialidad y Ciudad en **selectores interactivos compactos** con navegación multi-página nativa mediante `WoltModalSheet` y búsqueda en tiempo real:

1. **Página Principal del Modal (Índice 0):**
   - Tarjetas de selección estilizadas (`_SelectorTile`) para Especialidad y Ciudad.
   - Si no hay filtro seleccionado: indica "Todas las especialidades" / "Todas las ciudades" con icono y chevron.
   - Si hay filtro seleccionado: muestra el nombre de la opción elegida, estilizado con el color primario (`kMedphePrimary`) y un botón de deselección rápida `(X)`.
   - Mantiene la barra fija inferior (`_FilterActionBar`) con botones "Limpiar" y "Aplicar filtros".

2. **Páginas Secundarias de Selección (Índices 1 y 2):**
   - Página 1: Selección de Especialidad.
   - Página 2: Selección de Ciudad.
   - Cada página contiene:
     - Barra de navegación superior con botón atrás (`Icons.arrow_back_rounded`) y título descriptivo.
     - Campo de búsqueda interactivo en tiempo real con icono de lupa y botón para limpiar texto.
     - Opción superior "Todas" para seleccionar opción general.
     - Lista vertical scrolleable con radio/check estilizado en la opción actualmente seleccionada.
     - Al tocar un ítem: actualiza el filtro en `doctorsSearchFilterProvider` y hace transición animada de vuelta a la página principal (índice 0).

## 3. Arquitectura y Componentes
- **Control de Navegación:** `pageIndexNotifier: ValueNotifier<int>(0)` suministrado a `WoltModalSheet.show`.
- **Estado de Búsqueda:** `StatefulWidget` local para la vista de selección para gestionar el query de búsqueda sin contaminar providers globales.
- **Filtrado:** Normalización insensible a mayúsculas y acentos (`toLowerCase()`).
