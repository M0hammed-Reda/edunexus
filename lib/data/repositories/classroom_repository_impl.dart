
import '../../domain/repositories/classroom_repository.dart';
import '../models/classroom_model.dart';
import '../models/classroom_member_model.dart';
import '../services/api_service.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final ApiService _apiService;

  ClassroomRepositoryImpl(this._apiService);

  @override
  Future<List<ClassroomModel>> getMyClassrooms() async {
    final response = await _apiService.client.get('/classrooms');
    return (response.data as List).map((json) => ClassroomModel.fromJson(json)).toList();
  }

  @override
  Future<ClassroomModel> createClassroom(String name) async {
    final response = await _apiService.client.post('/classrooms', data: {'name': name});
    return ClassroomModel.fromJson(response.data);
  }

  @override
  Future<ClassroomMemberModel> joinClassroom(String uniqueCode) async {
    final response = await _apiService.client.post('/classrooms/join', data: {'unique_code': uniqueCode});
    return ClassroomMemberModel.fromJson(response.data);
  }

  @override
  Future<List<ClassroomMemberModel>> getPendingMembers(String classroomId) async {
    final response = await _apiService.client.get('/classrooms/$classroomId/members');
    final members = (response.data as List).map((json) => ClassroomMemberModel.fromJson(json)).toList();
    return members.where((m) => m.status == 'pending').toList();
  }

  @override
  Future<ClassroomMemberModel> approveMember(String classroomId, String userId, bool approve) async {
    final status = approve ? 'approved' : 'rejected';
    final response = await _apiService.client.put('/classrooms/$classroomId/members/$userId/approve', data: {'status': status});
    return ClassroomMemberModel.fromJson(response.data);
  }
}
