# Reporte Técnico para Tesis

## 1. Módulos e Interfaz de Usuario (Propuesta)

La aplicación Flutter "Hábitos Saludables" está estructurada en las siguientes pantallas principales. Para cada pantalla, se recomienda agregar una captura de pantalla en la sección de Propuesta de la tesis, numerada como Figura X, con su respectivo título descriptivo:

- **Splash**: Pantalla de carga inicial. Determina el estado de autenticación y redirige automáticamente a Login o Home.
  - *Agregar captura: Figura 1. Pantalla Splash (Carga inicial)*
- **Login**: Permite autenticación por email/contraseña y Google. Utiliza widgets de Material Design y validaciones de formulario.
  - *Agregar captura: Figura 2. Pantalla Login (Autenticación)*
- **Registro**: Similar a Login, permite crear una cuenta nueva. Incluye campos de email, nombre y contraseña.
  - *Agregar captura: Figura 3. Pantalla Registro (Crear cuenta)*
- **Home/Dashboard**: Muestra la lista de hábitos activos, progreso diario, rachas y acceso rápido a crear hábito, estadísticas, perfil y biblioteca. Usa chips, cards y botones de Material Design.
  - *Agregar captura: Figura 4. Pantalla Home/Dashboard (Lista de hábitos y progreso)*
- **Crear/Editar Hábito**: Formulario para definir título, descripción, frecuencia, icono y recordatorio horario. Permite activar notificaciones locales.
  - *Agregar captura: Figura 5. Pantalla Crear/Editar Hábito (Formulario de hábito)*
- **Estadísticas**: Visualiza rachas y progreso mediante gráficas (fl_chart). Permite filtrar por día y hábito.
  - *Agregar captura: Figura 6. Pantalla Estadísticas (Gráficas de rachas y progreso)*
- **Perfil**: Muestra datos del usuario, opciones de logout y gestión de cuenta.
  - *Agregar captura: Figura 7. Pantalla Perfil (Datos de usuario)*
- **Biblioteca de hábitos**: Lista sugerida de hábitos saludables con atajos para crear nuevos.
  - *Agregar captura: Figura 8. Pantalla Biblioteca de hábitos (Sugerencias y atajos)*
- **Legal/Privacidad**: Expone principios de protección de datos y términos de uso.
  - *Agregar captura: Figura 9. Pantalla Legal/Privacidad (Términos y protección de datos)*

El flujo de usuario es: Splash → Login/Registro → Home → Crear/Editar Hábito → Estadísticas/Perfil/Biblioteca. La navegación se gestiona con go_router y el estado con Riverpod.

## 2. Estructura de Datos Final (Firestore)

- **users/{uid}**: Documento principal por usuario.
  - **habits** (subcolección): Cada documento representa un hábito con campos: id, título, descripción, frecuencia, icono, recordatorio, notificaciones.
  - **progress** (subcolección): Registra el avance diario por hábito (fecha, completado, racha).
  - **achievements** (subcolección): Logros alcanzados por el usuario.

La estructura es modular y permite consultas eficientes por usuario y hábito.

## 3. Implementaciones Clave y Desafíos

- **Notificaciones locales con timezone**: Programación de recordatorios diarios usando flutter_local_notifications y timezone. Los IDs de notificación se generan de forma determinística para permitir cancelaciones/reprogramaciones idempotentes.
- **Gestión de estado y autenticación**: Riverpod centraliza el estado global (auth, hábitos, progreso). go_router implementa lógica de redirección según sesión y rutas protegidas.
- **Generación de gráficas**: fl_chart se usa para mostrar rachas y progreso. El cálculo de datos normalizados y la visualización semanal requieren lógica adicional.

## 4. Pruebas y Validaciones

- **Pruebas unitarias**: Validan casos de uso críticos (AddHabit, UpdateHabit, MarkDone), mapeos modelo→entidad y lógica de notificaciones.
- **Pruebas widget**: Cubren pantallas principales (Login, Home, HabitForm) y flujos básicos de interacción.
- **Cobertura**: El directorio /test incluye pruebas para carga inicial, navegación y persistencia. Se instrumenta Firestore para recopilar métricas de uso.

## 5. Limitaciones Actuales / Deuda Técnica (Conclusiones)

- Comentarios TODO y áreas de mejora detectadas:
  - Manejo de errores en autenticación y persistencia es básico; falta feedback detallado al usuario.
  - No hay pruebas de integración completas para flujos multi-pantalla.
  - La lógica de notificaciones no contempla casos de múltiples dispositivos o sincronización avanzada.
  - Algunos widgets tienen lógica de UI y negocio mezclada, lo que dificulta el testing.

## 6. Oportunidades de Mejora (Recomendaciones)

1. **Sincronización multi-dispositivo y backups automáticos**: Implementar sincronización en tiempo real y backups en la nube para restaurar hábitos y progreso.
2. **Sistema de logros gamificados y retos**: Añadir logros avanzados, retos semanales y notificaciones push para aumentar la motivación.
3. **Panel de configuración avanzada**: Permitir personalización de recordatorios, temas, y exportación de datos (CSV/PDF) para análisis personal.

---

Este reporte resume la arquitectura, módulos, datos, pruebas, limitaciones y oportunidades técnicas de la app, sirviendo como insumo para las secciones de propuesta, conclusiones y recomendaciones de la tesis.