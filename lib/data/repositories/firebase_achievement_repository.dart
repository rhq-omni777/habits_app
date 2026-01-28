import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../models/achievement_model.dart';

class FirebaseAchievementRepository implements AchievementRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _db.collection('users').doc(userId).collection('achievements');

  @override
  Future<void> upsert(String userId, AchievementEntity achievement) async {
    final model = AchievementModel(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      threshold: achievement.threshold,
      unlocked: achievement.unlocked,
    );
    await _collection(userId).doc(achievement.id).set(model.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<AchievementEntity>> watchAchievements(String userId) {
    return _collection(userId).snapshots().map(
          (snap) => snap.docs
              .map((d) => AchievementModel.fromMap({...d.data(), 'id': d.id}))
              .toList(),
        );
  }
}
