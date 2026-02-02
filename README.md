# Hábitos Saludables (Flutter)

App móvil para crear, seguir y cumplir hábitos diarios con recordatorios locales, estadísticas de rachas y autenticación Firebase. Arquitectura limpia (domain/data/presentation) con estado gestionado en Riverpod.

## Características
- Creación, edición y eliminación de hábitos con icono, descripción, frecuencia y horario de recordatorio.
- Recordatorios locales (flutter_local_notifications + timezone) y marcado automático si vienes desde una notificación.
- Rachas diarias y progreso por hábito; sección de estadísticas con gráficas (fl_chart).
- Biblioteca sugerida de hábitos y pantalla de perfil.
- Autenticación Firebase (email/contraseña y Google), datos en Firestore.
- Soporte de tema claro/oscuro y enrutamiento con go_router.

## Stack
- Flutter 3.x, Dart 3.
- Estado: flutter_riverpod.
- Routing: go_router.
- Backend: Firebase (Auth, Firestore), firebase_core.
- Notificaciones locales + timezone; permisos de ubicación (geolocator) para alinear zona horaria.
- UI: Material 3, fl_chart, google_fonts.

## Estructura rápida
- lib/core: config, router, theme, servicios (notificaciones, ubicación).
- lib/domain: entidades, casos de uso, contratos de repositorio.
- lib/data: datasources e implementaciones Firebase; mapeos a entidades.
- lib/presentation: pages (UI) y providers (estado Riverpod).

## Requisitos
- Flutter SDK instalado (`flutter --version`).
- Android SDK (`platform-tools` para adb) o usa `flutter install` sin adb.
- Archivos Firebase: android/app/google-services.json y lib/firebase_options.dart. Si cambias el proyecto de Firebase, genera de nuevo con `flutterfire configure`.
- Dispositivo/emulador con modo desarrollador y permisos de notificaciones/ubicación habilitados.

## Puesta en marcha
```bash
git clone <URL_DEL_REPO>
cd habits_app
flutter pub get
```

Si el caché de pub está corrupto:
```bash
flutter pub cache clean
flutter pub get
```

## Ejecutar en debug
```bash
flutter devices           # obtener ID
flutter run -d <DEVICE_ID> --debug
```
Mantén la app en primer plano para conservar la sesión de hot reload.

## Build e instalación en release (Android)
Necesario desactivar tree shaking de íconos (se crean dinámicamente):
```bash
flutter build apk --release --no-tree-shake-icons
```
Instalar en dispositivo:
```bash
flutter install -d <DEVICE_ID> --use-application-binary build/app/outputs/flutter-apk/app-release.apk
```
Si prefieres adb y lo tienes en PATH: `adb -s <DEVICE_ID> install -r build/app/outputs/flutter-apk/app-release.apk`.

Más detalles y soluciones rápidas: ver [docs/android_setup.md](docs/android_setup.md).

## Notas y permisos
- Android 13+: solicita permiso de notificaciones al abrir.
- Se pide ubicación una vez para ajustar zona horaria; no se guarda ubicación.
- Advertencias `source value 8 is obsolete` del toolchain Java no bloquean el build.

## Scripts útiles
- Limpiar y reinstalar dependencias: `flutter clean && rm -r .dart_tool && flutter pub cache clean && flutter pub get` (en Windows usar `rmdir /s /q .dart_tool`).
- Si modificas modelos Freezed/JSON, ejecuta: `flutter pub run build_runner build --delete-conflicting-outputs`.

## Testing
Por ahora solo está la plantilla de widget_test. Agrega tests en `test/` según los casos de uso (hábitos, progreso, notificaciones).

## Licencia
Privado / uso interno. Ajusta esta sección si se publica.
