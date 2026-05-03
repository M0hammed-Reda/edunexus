import '../models/announcement_model.dart';
import '../models/assignment_model.dart';
import '../models/material_model.dart';
import '../models/submission_model.dart';

/// ─── SINGLETON PATTERN ──────────────────────────────────────────────────────
/// MockDataService is the single shared data source for the entire app.
/// It simulates what a real database / Supabase client would do.
///
/// Pattern: The private constructor + static instance guarantee that only
/// ONE object ever exists (like a DB connection pool).
/// ────────────────────────────────────────────────────────────────────────────
class MockDataService {
  // Static instance — created once and reused everywhere
  static final MockDataService _instance = MockDataService._internal();

  // Private constructor — prevents external instantiation
  MockDataService._internal();

  // Public factory — always returns the same instance
  factory MockDataService() => _instance;

  // ── In-memory "database" tables ──────────────────────────────────────────

  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 'a1',
      'classroom_id': 'dummy_classroom_id',
      'title': 'Welcome to SWE2!',
      'content': 'This course covers software architecture & design patterns.',
      'created_by': '11111111-1111-1111-1111-111111111111',
      'created_at': '2026-04-10T08:00:00.000Z',
    },
    {
      'id': 'a2',
      'classroom_id': 'dummy_classroom_id',
      'title': 'Midterm Date Announced',
      'content': 'The midterm exam will be held on May 5th, 2026.',
      'created_by': '11111111-1111-1111-1111-111111111111',
      'created_at': '2026-04-12T10:30:00.000Z',
    },
  ];

  final List<Map<String, dynamic>> _materials = [
    {
      'id': 'm1',
      'classroom_id': 'dummy_classroom_id',
      'title': 'Lecture 1 — Clean Architecture.pdf',
      'file_url': 'https://example.com/files/lecture1.pdf',
      'uploaded_by': '11111111-1111-1111-1111-111111111111',
      'created_at': '2026-04-10T09:00:00.000Z',
    },
    {
      'id': 'm2',
      'classroom_id': 'dummy_classroom_id',
      'title': 'Lecture 2 — Design Patterns.pdf',
      'file_url': 'https://example.com/files/lecture2.pdf',
      'uploaded_by': '11111111-1111-1111-1111-111111111111',
      'created_at': '2026-04-14T09:00:00.000Z',
    },
  ];

  final List<Map<String, dynamic>> _assignments = [
    {
      'id': 'hw1',
      'classroom_id': 'dummy_classroom_id',
      'title': 'Assignment 1 — UML Diagrams',
      'description': 'Draw class & sequence diagrams for the EduNexus app.',
      'deadline': '2026-04-25T23:59:00.000Z',
      'created_by': '11111111-1111-1111-1111-111111111111',
      'created_at': '2026-04-10T08:00:00.000Z',
    },
    {
      'id': 'hw2',
      'classroom_id': 'dummy_classroom_id',
      'title': 'Assignment 2 — Repository Pattern',
      'description':
          'Implement the Repository pattern for a simple CRUD feature.',
      'deadline': '2026-05-05T23:59:00.000Z',
      'created_by': '11111111-1111-1111-1111-111111111111',
      'created_at': '2026-04-15T08:00:00.000Z',
    },
  ];

  final List<Map<String, dynamic>> _submissions = [];

  // ── Simulated async operations (mimic real API calls) ─────────────────────

  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Factory pattern: fromJson converts each raw map into a typed model
    return _announcements
        .map(AnnouncementModel.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
  }

  Future<void> addAnnouncement(AnnouncementModel a) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _announcements.add(a.toJson());
  }

  Future<List<MaterialModel>> fetchMaterials() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _materials
        .map(MaterialModel.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addMaterial(MaterialModel m) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _materials.add(m.toJson());
  }

  Future<List<AssignmentModel>> fetchAssignments() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _assignments
        .map(AssignmentModel.fromJson)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline)); // earliest deadline first
  }

  Future<void> addAssignment(AssignmentModel a) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _assignments.add(a.toJson());
  }

  Future<List<SubmissionModel>> fetchSubmissions({String? studentId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final all = _submissions.map(SubmissionModel.fromJson).toList();
    if (studentId != null) {
      return all.where((s) => s.studentId == studentId).toList();
    }
    return all;
  }

  Future<void> addSubmission(SubmissionModel s) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _submissions.add(s.toJson());
  }
}
