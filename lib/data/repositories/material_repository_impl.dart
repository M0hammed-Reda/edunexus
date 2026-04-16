import '../../data/models/material_model.dart';
import '../../data/services/mock_data_service.dart';
import '../../domain/repositories/material_repository.dart';

/// Concrete implementation of [MaterialRepository].
class MaterialRepositoryImpl implements MaterialRepository {
  final _service = MockDataService();

  @override
  Future<List<MaterialModel>> getMaterials() => _service.fetchMaterials();

  @override
  Future<void> uploadMaterial(MaterialModel material) =>
      _service.addMaterial(material);
}
