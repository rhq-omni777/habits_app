# Metodología y Desarrollo del Proyecto

Este documento está específicamente preparado para describir cómo está hecho el programa "Hábitos Saludables" y contiene toda la información técnica y metodológica necesaria para redactar la sección "Metodología y Desarrollo del Proyecto" de tu tesis. Está pensado para que otra IA o un revisor lo use como insumo: explica la arquitectura, tecnologías, decisiones de diseño, flujo de datos, pruebas, despliegue y pasos reproducibles.

Resumen rápido
- Proyecto: Aplicación móvil "Hábitos Saludables".
- Objetivo del documento: explicar cómo se desarrolló la aplicación; qué tecnologías, arquitecturas y decisiones se tomaron y cómo validar/reproducir el sistema.

Checklist de contenido (lo que contiene este documento)
- Resumen del sistema y funcionalidades clave
- Stack tecnológico y versiones (extraído de `pubspec.yaml`)
- Arquitectura y mapeo a archivos importantes
- Descripción de módulos y responsabilidades (servicios, providers, repositorios, UI)
- Integración con Firebase y configuración sensible
- Permisos y comportamiento nativo (Android/iOS)
- Estrategia de pruebas: unitarias, widget e integración + ejemplos de casos
- Instrumentación y recolección de datos (para evaluación)
- Proceso de build y despliegue (Android/iOS) y comandos
- Recomendaciones para la redacción de la sección Metodología y Desarrollo (texto reutilizable)
- Anexos: comandos reproducibles y lista de archivos que aportar como evidencia

---

1. Resumen del sistema y funcionalidades clave

La aplicación "Hábitos Saludables" permite a los usuarios crear, editar y eliminar hábitos; programar recordatorios diarios; marcar el progreso diario; visualizar rachas y estadísticas; y autenticarse mediante Firebase (email/password y Google). Los recordatorios son locales (no push server) y se programan en la zona horaria local del dispositivo.

Funcionalidades principales:
- CRUD de hábitos (título, descripción, frecuencia, icono, recordatorio horario).
- Recordatorios locales programados (zonedSchedule) con manejo de timezone.
- Visualización de rachas y estadísticas (gráficas con `fl_chart`).
- Autenticación y persistencia con Firebase Auth + Firestore (colecciones por usuario).
- Estado centralizado con Riverpod y navegación con `go_router`.

2. Stack tecnológico (extraído del proyecto)
- Lenguaje / Framework: Dart / Flutter (SDK definido en `pubspec.yaml`, environment sdk ^3.10.7).
- Gestión de estado: flutter_riverpod
- Routing: go_router
- Backend: Firebase (firebase_core, firebase_auth, cloud_firestore)
- Notificaciones: flutter_local_notifications + timezone
- Geolocalización: geolocator
- Persistencia local: shared_preferences (si aplica)
- UI / Gráficas: fl_chart, google_fonts
- Codegen y utilitarios: freezed, json_serializable, build_runner

(Para versiones exactas ver `pubspec.yaml` del repo.)

3. Arquitectura y organización del código

Patrón: Clean Architecture simplificado (capas):
- Presentation: `lib/presentation/` (páginas, widgets, providers) — UI y providers Riverpod.
- Domain: `lib/domain/` (entidades, usecases, contratos de repositorio) — lógica agnóstica de framework.
- Data: `lib/data/` (models, datasources, implementaciones de repositorios como Firebase/InMemory).
- Core: `lib/core/` (config, router, servicios transversales, theme).

Mapa rápido de archivos clave:
- `lib/main.dart` — bootstrapping: Widgets binding, Firebase.initializeApp(), init de `NotificationsService` y `LocationService`, runApp(ProviderScope).
- `lib/firebase_options.dart` & `android/app/google-services.json` — configuración de Firebase (IMPORTANTE: contienen info sensible).
- `lib/core/services/notifications_service.dart` — inicialización, timezone, scheduling y manejo de selección de notificación.
- `lib/core/services/location_service.dart` — comprobación/solicitud de permisos de ubicación para sincronizar timezone.
- `lib/core/router/app_router.dart` — provider que expone `GoRouter` y la lógica de redirección según `authState`.
- `lib/presentation/providers/` — `auth_providers.dart`, `habit_providers.dart`, `progress_providers.dart` — StateNotifier y controllers.
- `lib/data/repositories/` — `firebase_auth_repository.dart`, `firebase_habit_repository.dart`, `firebase_progress_repository.dart`.

4. Flujo de datos y responsabilidades

- UI (pages) dispara acciones a través de Providers / Controllers.
- Los Controllers ejecutan UseCases (en `lib/domain/usecases`) que llaman a Repositories.
- Repositories (Firebase o InMemory) traducen entidades <-> modelos y persisten en Firestore o memoria.
- `NotificationsService` agenda y cancela notificaciones cuando un hábito se crea/edita/elimina.
- `LocationService` puede solicitar permisos para ajustar timezone, que `NotificationsService` usa.

5. Integración con Firebase y configuración sensible

- Inicialización: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` (en `main.dart`) si `kUseFirebase==true`.
- Archivos detectados: `lib/firebase_options.dart` y `android/app/google-services.json`. Contienen claves y deben manejarse como secretos: no subir a repo público.
- Recomendación: usar `flutterfire_cli` en entornos seguros y/o variables de entorno en CI; añadir `android/app/google-services.json` y `lib/firebase_options.dart` a `.gitignore` si no quieres compartirlos.

6. Permisos y comportamiento nativo

- AndroidManifest declara originalmente: POST_NOTIFICATIONS, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION. En la versión profesional actualizada se ha eliminado la solicitud de permisos de ubicación porque la funcionalidad principal de seguimiento de hábitos no requiere GPS.
- iOS Info.plist originalmente incluía `NSLocationWhenInUseUsageDescription`. Esta clave se ha removido para evitar pedir permisos innecesarios.
- Justificación técnica: la app utiliza la hora y zona horaria del sistema operativo y `flutter_local_notifications` para programar recordatorios; el uso de GPS no aporta ventajas significativas para el caso de uso y añade fricción de permisos y preocupaciones de privacidad.
- Nota de diseño: si en el futuro se decide usar ubicación (por ejemplo, recordatorios basados en localización), volver a añadir `geolocator` y manejar todos los estados de permiso (`denied`, `deniedForever`, `granted`) con UX que guíe al usuario a ajustes.

7. Estrategia de pruebas y validación técnica

Recomendación general:
- Unit tests: usecases (AddHabit, UpdateHabit, MarkDone), mapeos modelo->entity, validaciones.
- Widget tests: pantallas críticas (Login, Home, HabitForm), interacciones básicas.
- Integration tests (opcional): flujo completo con emulador que cubra login -> crear hábito -> notificación.

Comandos:
```bash
flutter analyze
flutter test
```

Ejemplos de casos de prueba prioritarios:
- UseCase AddHabit: al agregar un hábito con recordatorio activo, el `NotificationsService` recibe llamada para agendar.
- HabitRepository (Firebase): al añadir hábito, la colección `users/{uid}/habits` recibe documento con campos esperados.
- NotificationsService: cálculo de `notificationId` es determinístico y único por `habit.id`.

8. Instrumentación y recolección de datos para evaluación

- Instrumenta eventos importantes: `habit_created`, `habit_completed`, `habit_deleted`, `notification_shown`, `notification_tapped`, `app_open`.
- Almacenar eventos con timestamp y metadata (userId, habitId, source) en Firestore en subcolección `users/{uid}/events` o en sistema de analytics.
- Garantizar consentimiento previo a recopilar datos y mantener anonimización para exportación.

9. Build y despliegue

Android:
```bash
# debug
flutter run
# release apk
flutter build apk --release
# app bundle para Play Store
flutter build appbundle --release
```

iOS (en Mac):
```bash
flutter build ios --release
# luego abrir Xcode para firmar y subir
```

Notas:
- Preparar keystore para firma Android (documentar en tesis) y configurar signingConfigs en `android/app/build.gradle`.
- Revisar ProGuard/R8 rules si expones librerías nativas.

10. Consideraciones de seguridad y privacidad (críticas)

- Evitar incluir `google-services.json` y `firebase_options.dart` en repos públicos.
- Revisar Firestore Rules: asegurar que solo `users/{uid}` puede leer/escribir su propia colección.
- Logs: evitar imprimir PII en debugPrint en builds release; usar `logger` con niveles y configuración por entorno.

11. Cómo redactar la sección "Metodología y Desarrollo" de tu tesis (texto reutilizable)

Incluye estos apartados y copia/ajusta los párrafos siguientes en tu tesis:

- Descripción general del software (1 párrafo):

> El sistema desarrollado es una aplicación móvil multiplataforma (Android/iOS) construida con Flutter y Dart. Sigue una arquitectura de capas inspirada en Clean Architecture: las capas Presentation, Domain y Data separan responsabilidades para facilitar el mantenimiento y las pruebas. El estado se maneja con Riverpod y la navegación con GoRouter. El backend es Firebase (Auth y Firestore) y las notificaciones locales se implementaron con `flutter_local_notifications` junto con la librería `timezone` para asegurar programaciones coherentes con la zona local del dispositivo.

- Diseño e implementación (2–3 párrafos):

> El proyecto se organizó en módulos: UI y providers en `lib/presentation`, entidades y casos de uso en `lib/domain`, repositorios y mapeos de datos en `lib/data`, y servicios transversales en `lib/core`. El punto de entrada (`main.dart`) inicializa los servicios críticos (Firebase, notificaciones y ubicación) antes de arrancar el árbol de widgets. Las interacciones de usuario producen eventos que son manejados por controladores (StateNotifiers) que delegan la persistencia a los repositorios; estos repositorios empacan y desempaquetan modelos para Firestore. Las notificaciones son programadas con ids determinísticos derivados del id del hábito para permitir cancelaciones y reprogramaciones idempotentes.

- Pruebas y validación (1–2 párrafos):

> Se implementaron pruebas unitarias para las unidades de negocio críticas y pruebas widget para las pantallas principales. La instrumentación de eventos en Firestore permite recopilar métricas de uso (tasa de cumplimiento, rachas, retención) que se analizaron estadísticamente para validar la hipótesis de mejora en adherencia. Se documentaron protocolos de prueba manuales para smoke testing de notificaciones y persistencia.

- Reproducibilidad y despliegue (1 párrafo):

> El repositorio incluye instrucciones para obtener dependencias (`flutter pub get`), ejecutar la app en modo debug (`flutter run`), y generar builds de release. Los artefactos sensibles (configuración Firebase) deben gestionarse fuera del repositorio o a través de variables en CI. Para reproducir los experimentos con usuarios, se proporcionó un esquema de instrumentación de eventos y scripts de exportación para análisis.

12. Archivos y evidencias a entregar junto a la parte de Metodología y Desarrollo

- Código fuente completo (repo con tag o release).
- `docs/metodologia_desarrollo.md` (este archivo).
- README con pasos de instalación y configuración de Firebase (si usas credenciales privadas, indicar cómo obtenerlas).
- Export CSV/JSON de eventos (anonimizado) y scripts de análisis (Python/R).
- Capturas de pantalla de pantallas clave y diagramas de arquitectura.

13. Pasos reproducibles (comandos)

```bash
cd C:\projects\habits_app
flutter pub get
# debug
flutter run
# correr tests
flutter test
# analizar
flutter analyze
# build release Android
flutter build apk --release
```

14. Entrega a otra IA: qué proporcionarle para que genere la sección

Si vas a pasar esto a otra IA para que redacte la sección metodológica, dale:
- Este `docs/metodologia_desarrollo.md` (resumen técnico).
- `README.md` del repo.
- Lista de archivos clave: `lib/main.dart`, `lib/core/services/notifications_service.dart`, `lib/core/router/app_router.dart`, `lib/presentation/providers/*`, `lib/data/repositories/*`, `lib/firebase_options.dart` (o un resumen de la configuración si no se comparten claves).
- Resultados (si ya hay datos): CSV anónimo de eventos y resumen estadístico.
- Instrucciones sobre el estilo (longitud, voz académica, formato APA u otro requerido).

---

Si quieres que adapte el documento a un formato concreto (por ejemplo: apartados listos para pegar en Word o LaTeX), que genere diapositivas de defensa (Markdown/PDF/PPTX), o que añada scripts de análisis (notebook Jupyter en Python), dime cuál de las siguientes prefieres y lo agrego:

- A) Plantilla de slides (Markdown + PDF/PPTX prep).
- B) Notebook Jupyter con ejemplo de análisis (pandas + scipy) listo para ejecutar.
- C) Tests unitarios de ejemplo y GitHub Actions workflow que ejecute `flutter analyze` + `flutter test`.
- D) Limpiar repo: editar `.gitignore` y remover `build/` y archivos sensibles del índice git.

He creado `docs/metodologia_desarrollo.md` en el repositorio. ¿Qué extra quieres que agregue ahora?  
