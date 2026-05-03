import '../../data/models/classroom_model.dart';
import '../../data/models/classroom_member_model.dart';

abstract class ClassroomRepository {
  Future<List<ClassroomModel>> getMyClassrooms();
  Future<ClassroomModel> createClassroom(String name);
  Future<ClassroomMemberModel> joinClassroom(String uniqueCode);
  Future<List<ClassroomMemberModel>> getPendingMembers(String classroomId);
  Future<ClassroomMemberModel> approveMember(String classroomId, String userId, bool approve);
}
