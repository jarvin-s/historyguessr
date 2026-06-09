import 'package:flutter/foundation.dart';

import '../services/image_storage_service.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel(this._imageStorageService);

  final ImageStorageService _imageStorageService;

  String? imageUrl;
  bool isLoadingImage = true;
  String? imageError;

  Future<void> loadImage() async {
    isLoadingImage = true;
    imageError = null;
    notifyListeners();

    try {
      imageUrl = await _imageStorageService.fetchImageUrl();
    } catch (error) {
      imageUrl = null;
      imageError = 'Failed to load image.';
      debugPrint('Image load error: $error');
    } finally {
      isLoadingImage = false;
      notifyListeners();
    }
  }
}
