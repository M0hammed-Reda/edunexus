import '../../data/models/submission_model.dart';

/// ─── REPOSITORY PATTERN ─────────────────────────────────────────────────────
/// Contract for submission create/read operations.
/// ────────────────────────────────────────────────────────────────────────────
abstract class SubmissionRepository {
  Future<List<SubmissionModel>> getSubmissions({String? studentId});
  Future<void> submit(SubmissionModel submission);
}
