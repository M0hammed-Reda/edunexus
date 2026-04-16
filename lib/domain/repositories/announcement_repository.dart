import '../../data/models/announcement_model.dart';

/// ─── REPOSITORY PATTERN ─────────────────────────────────────────────────────
/// This abstract class is the CONTRACT (interface) for announcement operations.
/// The UI and ViewModels depend on this abstraction, NOT on the concrete impl.
/// This makes it easy to swap MockRepository for a real SupabaseRepository.
/// ────────────────────────────────────────────────────────────────────────────
abstract class AnnouncementRepository {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<void> postAnnouncement(AnnouncementModel announcement);
}
