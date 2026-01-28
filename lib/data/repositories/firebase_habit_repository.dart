import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_model.dart';

class FirebaseHabitRepository implements HabitRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _db.collection('users').doc(userId).collection('habits');

  @override
  Future<void> addHabit(String userId, HabitEntity habit) async {
    final model = HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      weekDays: habit.weekDays,
      reminderMinutes: habit.reminderMinutes,
      notificationsEnabled: habit.notificationsEnabled,
      createdAt: habit.createdAt,
      iconCodePoint: habit.iconCodePoint,
      iconFontFamily: habit.iconFontFamily,
      iconFontPackage: habit.iconFontPackage,
    );
    await _collection(userId).doc(habit.id).set(model.toMap());
  }

  @override
  Future<void> deleteHabit(String userId, String habitId) async {
    await _collection(userId).doc(habitId).delete();
  }

  @override
  Future<void> updateHabit(String userId, HabitEntity habit) async {
    final model = HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      weekDays: habit.weekDays,
      reminderMinutes: habit.reminderMinutes,
      notificationsEnabled: habit.notificationsEnabled,
      createdAt: habit.createdAt,
      iconCodePoint: habit.iconCodePoint,
      iconFontFamily: habit.iconFontFamily,
      iconFontPackage: habit.iconFontPackage,
    );
    await _collection(userId).doc(habit.id).update(model.toMap());
  }

  @override
  Stream<List<HabitEntity>> watchHabits(String userId) {
    return _collection(userId).orderBy('createdAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((d) => HabitModel.fromMap({...d.data(), 'id': d.id}))
              .toList(),
        );
  }
}
