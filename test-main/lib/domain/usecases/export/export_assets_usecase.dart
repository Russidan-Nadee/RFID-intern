import 'package:rfid_project/domain/repositories/asset_repository.dart';

class ExportAssetsUseCase {
  final AssetRepository repository;
  ExportAssetsUseCase(this.repository);

  Future<String?> execute(List<String> columns) async {
    final assets = await repository.getAssets();
    return await repository.exportAssetsToCSV(assets, columns);
  }
}
