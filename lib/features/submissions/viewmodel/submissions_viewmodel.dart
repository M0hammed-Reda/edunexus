import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/submission_model.dart';
import '../../../data/repositories/submission_repository_impl.dart';
import '../../../domain/repositories/submission_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final submissionRepoProvider = Provider<SubmissionRepository>(
  (_) => SubmissionRepositoryImpl(),
);

// ── State ─────────────────────────────────────────────────────────────────────
class SubmissionState {
  final SubmissionModel? existingSubmission; // null means not yet submitted
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool submitted; // true once successfully submitted this session

  const SubmissionState({
    this.existingSubmission,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  SubmissionState copyWith({
    SubmissionModel? existingSubmission,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? submitted,
  }) =>
      SubmissionState(
        existingSubmission: existingSubmission ?? this.existingSubmission,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        submitted: submitted ?? this.submitted,
      );
}

/// ─── OBSERVER PATTERN (Riverpod) ────────────────────────────────────────────
class SubmissionNotifier extends StateNotifier<SubmissionState> {
  final SubmissionRepository _repo;
  final String assignmentId;
  final String studentId;

  SubmissionNotifier({
    required SubmissionRepository repo,
    required this.assignmentId,
    required this.studentId,
  })  : _repo = repo,
        super(const SubmissionState(isLoading: true)) {
    _checkExisting();
  }

  // Check if this student already submitted for this assignment
  Future<void> _checkExisting() async {
    state = state.copyWith(isLoading: true);
    try {
      final all = await _repo.getSubmissions(studentId: studentId);
      final existing = all.where((s) => s.assignmentId == assignmentId).firstOrNull;
      state = state.copyWith(existingSubmission: existing, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitAssignment(String fileUrl) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final submission = SubmissionModel(
        id: const Uuid().v4(),
        assignmentId: assignmentId,
        studentId: studentId,
        fileUrl: fileUrl,
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _repo.submit(submission);
      state = state.copyWith(
        isSubmitting: false,
        submitted: true,
        existingSubmission: submission,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

// ── Family provider — one instance per (assignmentId, studentId) pair ─────────
final submissionProvider = StateNotifierProvider.family<
    SubmissionNotifier, SubmissionState, ({String assignmentId, String studentId})>(
  (ref, params) => SubmissionNotifier(
    repo: ref.watch(submissionRepoProvider),
    assignmentId: params.assignmentId,
    studentId: params.studentId,
  ),
);
