import '../../data/models/material_model.dart';

/// ─── REPOSITORY PATTERN ─────────────────────────────────────────────────────
/// Contract for material upload/fetch operations.
/// ────────────────────────────────────────────────────────────────────────────
abstract class MaterialRepository {
  Future<List<MaterialModel>> getMaterials();
  Future<void> uploadMaterial(MaterialModel material);
}
