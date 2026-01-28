import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habit_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/habit_progress_model.dart';

class FirebaseProgressRepository implements ProgressRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _db.collection('users').doc(userId).collection('progress');

  @override
  Future<void> markDone(String userId, String habitId, DateTime day) async {
    final normalized = DateTime.utc(day.year, day.month, day.day);
    final id = '${normalized.toIso8601String()}_$habitId';
    final model = HabitProgressModel(habitId: habitId, date: normalized, completed: true);
    await _collection(userId).doc(id).set(model.toMap());
  }

  @override
  Future<void> unmark(String userId, String habitId, DateTime day) async {
    final normalized = DateTime.utc(day.year, day.month, day.day);
    final id = '${normalized.toIso8601String()}_$habitId';
    await _collection(userId).doc(id).delete();
  }

  @override
  Stream<List<HabitProgressEntity>> watchProgress(String userId) {
    return _collection(userId).snapshots().map(
          (snap) => snap.docs
              .map((d) => HabitProgressModel.fromMap({...d.data(), 'habitId': (d.data())['habitId'] ?? '', 'id': d.id}))
              .toList(),
        );
  }
}
