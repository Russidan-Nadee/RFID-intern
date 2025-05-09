import 'package:flutter/material.dart';
import 'package:rfid_project/core/navigation/app_routes.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';

class SearchAssetUseCase {
  final AssetRepository repository;

  SearchAssetUseCase(this.repository);

  Future<void> execute(String uid, BuildContext context) async {
    try {
      final asset = await repository.getAssetByUid(uid);
      if (asset != null) {
        Navigator.pushNamed(context, AppRoutes.found, arguments: {'uid': uid});
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.notFound,
          arguments: {'uid': uid},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
