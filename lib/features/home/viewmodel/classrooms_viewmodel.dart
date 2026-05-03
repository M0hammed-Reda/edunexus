import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/models/classroom_member_model.dart';
import '../../../data/repositories/classroom_repository_impl.dart';
import '../../../domain/repositories/classroom_repository.dart';
import '../../../data/services/api_service.dart';

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  return ClassroomRepositoryImpl(ref.watch(apiServiceProvider));
});

class ClassroomsState {
  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final String? error;

  const ClassroomsState({
    this.classrooms = const [],
    this.isLoading = false,
    this.error,
  });

  ClassroomsState copyWith({List<ClassroomModel>? classrooms, bool? isLoading, String? error}) {
    return ClassroomsState(
      classrooms: classrooms ?? this.classrooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ClassroomsNotifier extends StateNotifier<ClassroomsState> {
  final ClassroomRepository _repo;

  ClassroomsNotifier(this._repo) : super(const ClassroomsState(isLoading: true)) {
    loadClassrooms();
  }

  Future<void> loadClassrooms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getMyClassrooms();
      state = ClassroomsState(classrooms: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createClassroom(String name) async {
    try {
      await _repo.createClassroom(name);
      await loadClassrooms();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> joinClassroom(String uniqueCode) async {
    try {
      await _repo.joinClassroom(uniqueCode);
      // It will be pending, so we might not show it or show it as pending. Let's just reload.
      await loadClassrooms();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final classroomsProvider = StateNotifierProvider<ClassroomsNotifier, ClassroomsState>(
  (ref) => ClassroomsNotifier(ref.watch(classroomRepositoryProvider)),
);

// We can add another provider for pending members for managers
final pendingMembersProvider = FutureProvider.family<List<ClassroomMemberModel>, String>((ref, classroomId) async {
  return ref.watch(classroomRepositoryProvider).getPendingMembers(classroomId);
});
