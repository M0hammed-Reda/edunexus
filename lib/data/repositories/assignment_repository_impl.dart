import '../../data/models/assignment_model.dart';
import '../../data/services/mock_data_service.dart';
import '../../domain/repositories/assignment_repository.dart';

/// Concrete implementation of [AssignmentRepository].
class AssignmentRepositoryImpl implements AssignmentRepository {
  final _service = MockDataService();

  @override
  Future<List<AssignmentModel>> getAssignments() =>
      _service.fetchAssignments();

  @override
  Future<void> createAssignment(AssignmentModel assignment) =>
      _service.addAssignment(assignment);
}
