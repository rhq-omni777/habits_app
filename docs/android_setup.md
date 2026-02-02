# Guia rapida: clonar, debug e instalacion release en Android

## Requisitos previos
- Flutter SDK instalado (`flutter --version`).
- Android SDK y `platform-tools` disponibles (para usar `adb`) o, alternativamente, usar `flutter install` que no requiere `adb` en PATH.
- Dispositivo Android con modo desarrollador y depuracion USB habilitada.
- Java/JDK compatible con tu version de Flutter (Flutter trae su propio JDK en Windows; no hace falta instalar otro en la mayoria de casos).
- Si usas Windows, PowerShell o CMD.
- Asegura los archivos de Firebase: `android/app/google-services.json` y `lib/firebase_options.dart` (ya estan en el repo). Si cambias el proyecto de Firebase, vuelve a generar ambos con `flutterfire configure`.
- Permisos: la app usa ubicacion y notificaciones; concede permisos al abrirla.

## 1) Clonar el repo
```bash
git clone <URL_DEL_REPO>
cd habits_app
```

## 2) Obtener dependencias
```bash
flutter pub get
```

Si el cache de pub esta corrupto (errores de paquetes faltantes), puedes limpiar y re-instalar:
```bash
flutter pub cache clean
flutter pub get
```

### Restaurar dependencias desde cero (opcional)
Si quieres forzar una reinstalacion limpia:
```bash
flutter clean
rm -r .dart_tool        # en Windows: rmdir /s /q .dart_tool
rm pubspec.lock         # opcional: para recalcular versiones dentro de constraints
flutter pub cache clean # borra cache global
flutter pub get
```

## 3) Verificar dispositivo
```bash
flutter devices
```
Toma el ID del dispositivo Android (ejemplo: `R5CW609WYYF`).

## 4) Ejecutar en modo debug (con hot reload)
```bash
flutter run -d <DEVICE_ID> --debug
```
- Mantener la app en primer plano para no perder la conexion del `flutter run`.
- Atajos: `r` hot reload, `R` hot restart, `q` salir.

## 5) Construir APK de release
Este proyecto usa iconos creados en runtime, por lo que se debe desactivar el tree shaking de iconos:
```bash
flutter build apk --release --no-tree-shake-icons
```
El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

Para distribucion/Play Store, configura firma propia (keystore) en `android/app/build.gradle` y sube el .jks o usa Play App Signing. Esta guia asume la firma debug o la firma por defecto de Flutter para instalaciones locales.

## 6) Instalar APK de release en el dispositivo
Opcion A: con `flutter install` (no requiere `adb` en PATH):
```bash
flutter install -d <DEVICE_ID> --use-application-binary build/app/outputs/flutter-apk/app-release.apk
```

Opcion B: con `adb` (requiere platform-tools en PATH):
```bash
adb -s <DEVICE_ID> install -r build/app/outputs/flutter-apk/app-release.apk
```
Si `adb` no se encuentra, agrega la carpeta `platform-tools` del Android SDK a tu variable de entorno `PATH`.

## 7) Lanzar la app instalada (release)
En el dispositivo, abre el icono de la app. Si prefieres desde CLI con Flutter (sin hot reload):
```bash
flutter run -d <DEVICE_ID> --use-application-binary build/app/outputs/flutter-apk/app-release.apk
```

## 8) Debug rapido de dependencias y entorno
- `flutter doctor -v` para verificar SDKs y licencias.
- `where adb` (Windows) o `which adb` (Linux/macOS) para confirmar que `adb` esta en PATH; si no, usa `flutter install`.
- Si algo falla en compilacion de Android, limpia y reintenta: `flutter clean && flutter pub get`.

## Notas
- Advertencias de `source value 8 is obsolete` provienen del toolchain Java; no bloquean la compilacion actual.
- Si necesitas actualizar paquetes, revisa las restricciones en `pubspec.yaml` y usa `flutter pub outdated` para ver versiones.
- Para web/desktop, seguir las guias oficiales de Flutter; este doc se centra en Android.
