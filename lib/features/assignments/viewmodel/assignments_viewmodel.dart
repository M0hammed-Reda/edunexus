import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/assignment_model.dart';
import '../../../data/repositories/assignment_repository_impl.dart';
import '../../../domain/repositories/assignment_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final assignmentRepoProvider = Provider<AssignmentRepository>(
  (_) => AssignmentRepositoryImpl(),
);

// ── State ─────────────────────────────────────────────────────────────────────
class AssignmentsState {
  final List<AssignmentModel> assignments;
  final bool isLoading;
  final String? error;

  const AssignmentsState({
    this.assignments = const [],
    this.isLoading = false,
    this.error,
  });

  AssignmentsState copyWith({
    List<AssignmentModel>? assignments,
    bool? isLoading,
    String? error,
  }) =>
      AssignmentsState(
        assignments: assignments ?? this.assignments,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// ─── OBSERVER PATTERN (Riverpod) ────────────────────────────────────────────
class AssignmentsNotifier extends StateNotifier<AssignmentsState> {
  final AssignmentRepository _repo;

  AssignmentsNotifier(this._repo) : super(const AssignmentsState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repo.getAssignments();
      state = state.copyWith(assignments: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> createAssignment({
    required String title,
    required String description,
    required DateTime deadline,
    required String createdBy,
  }) async {
    final assignment = AssignmentModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      deadline: deadline,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    await _repo.createAssignment(assignment);
    await _load();
  }
}

final assignmentsProvider =
    StateNotifierProvider<AssignmentsNotifier, AssignmentsState>(
  (ref) => AssignmentsNotifier(ref.watch(assignmentRepoProvider)),
);
