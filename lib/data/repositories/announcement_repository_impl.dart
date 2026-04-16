import '../../data/models/announcement_model.dart';
import '../../data/services/mock_data_service.dart';
import '../../domain/repositories/announcement_repository.dart';

/// Concrete implementation of [AnnouncementRepository].
/// Delegates all operations to the [MockDataService] singleton.
///
/// To switch to Supabase, create SupabaseAnnouncementRepositoryImpl and
/// change the provider binding — ViewModels never need to change.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  // The Singleton is injected (could also be passed via constructor)
  final _service = MockDataService();

  @override
  Future<List<AnnouncementModel>> getAnnouncements() =>
      _service.fetchAnnouncements();

  @override
  Future<void> postAnnouncement(AnnouncementModel announcement) =>
      _service.addAnnouncement(announcement);
}
