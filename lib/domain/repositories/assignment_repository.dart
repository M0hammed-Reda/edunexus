import '../../data/models/assignment_model.dart';

/// ─── REPOSITORY PATTERN ─────────────────────────────────────────────────────
/// Contract for assignment create/read operations.
/// ────────────────────────────────────────────────────────────────────────────
abstract class AssignmentRepository {
  Future<List<AssignmentModel>> getAssignments();
  Future<void> createAssignment(AssignmentModel assignment);
}
