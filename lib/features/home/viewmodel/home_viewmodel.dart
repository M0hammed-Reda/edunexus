import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/announcement_model.dart';
import '../../../data/models/material_model.dart';
import '../../../data/repositories/announcement_repository_impl.dart';
import '../../../data/repositories/material_repository_impl.dart';
import '../../../domain/repositories/announcement_repository.dart';
import '../../../domain/repositories/material_repository.dart';

// ── Repository providers — wires interface to implementation ─────────────────
// (The ViewModel depends on the abstract interface, NOT the concrete class)
final announcementRepoProvider = Provider<AnnouncementRepository>(
  (_) => AnnouncementRepositoryImpl(),
);
final materialRepoProvider = Provider<MaterialRepository>(
  (_) => MaterialRepositoryImpl(),
);

// ── State class — what the Home screen displays ──────────────────────────────
class HomeState {
  final List<AnnouncementModel> announcements;
  final List<MaterialModel> materials;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.announcements = const [],
    this.materials = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<AnnouncementModel>? announcements,
    List<MaterialModel>? materials,
    bool? isLoading,
    String? error,
  }) =>
      HomeState(
        announcements: announcements ?? this.announcements,
        materials: materials ?? this.materials,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// ─── OBSERVER PATTERN (Riverpod) ────────────────────────────────────────────
/// HomeNotifier manages announcements & materials state.
/// The UI is a passive Observer — it just watches homeProvider and rebuilds.
/// ────────────────────────────────────────────────────────────────────────────
class HomeNotifier extends StateNotifier<HomeState> {
  final AnnouncementRepository _announcementRepo;
  final MaterialRepository _materialRepo;

  HomeNotifier(this._announcementRepo, this._materialRepo)
      : super(const HomeState(isLoading: true)) {
    _loadAll(); // Fetch on construction
  }

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      final announcements = await _announcementRepo.getAnnouncements();
      final materials = await _materialRepo.getMaterials();
      state = state.copyWith(
        announcements: announcements,
        materials: materials,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _loadAll();

  // ── Teacher actions ───────────────────────────────────────────────────────

  Future<void> postAnnouncement({
    required String title,
    required String content,
    required String teacherId,
  }) async {
    final newAnnouncement = AnnouncementModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdBy: teacherId,
      createdAt: DateTime.now(),
    );
    await _announcementRepo.postAnnouncement(newAnnouncement);
    await _loadAll(); // Reload to reflect the new record
  }

  Future<void> uploadMaterial({
    required String title,
    required String fileUrl,
    required String teacherId,
  }) async {
    final newMaterial = MaterialModel(
      id: const Uuid().v4(),
      title: title,
      fileUrl: fileUrl,
      uploadedBy: teacherId,
      createdAt: DateTime.now(),
    );
    await _materialRepo.uploadMaterial(newMaterial);
    await _loadAll();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(
    ref.watch(announcementRepoProvider),
    ref.watch(materialRepoProvider),
  );
});

