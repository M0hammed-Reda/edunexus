import '../../data/models/submission_model.dart';
import '../../data/services/mock_data_service.dart';
import '../../domain/repositories/submission_repository.dart';

/// Concrete implementation of [SubmissionRepository].
class SubmissionRepositoryImpl implements SubmissionRepository {
  final _service = MockDataService();

  @override
  Future<List<SubmissionModel>> getSubmissions({String? studentId}) =>
      _service.fetchSubmissions(studentId: studentId);

  @override
  Future<void> submit(SubmissionModel submission) =>
      _service.addSubmission(submission);
}
