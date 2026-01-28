/// Data backend toggles.
/// Para usar Firestore nativo (SDK Flutter), deja Firebase en true y Mongo en false.
const bool kUseFirebase = true;
const bool kUseMongo = false;

/// Mongo configuration.
/// Se puede definir vía --dart-define para no quemar credenciales en código:
/// flutter run --dart-define=MONGO_URI="mongodb+srv://user:pass@cluster0.mongodb.net/habits" \
///            --dart-define=MONGO_DB=habits
const String kMongoUri = String.fromEnvironment('MONGO_URI', defaultValue: '');
const String kMongoDbName = String.fromEnvironment('MONGO_DB', defaultValue: 'default');
