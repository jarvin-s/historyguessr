import 'package:flutter/foundation.dart';

import '../models/daily_challenge.dart';
import '../services/daily_challenge_service.dart';
import '../services/image_storage_service.dart';

enum StageResult { pending, wrong, correct }

class GameViewModel extends ChangeNotifier {
  GameViewModel(
    this._dailyChallengeService,
    this._imageStorageService,
  );

  final DailyChallengeService _dailyChallengeService;
  final ImageStorageService _imageStorageService;

  DailyChallenge? dailyChallenge;
  int currentStage = 1;
  List<StageResult> stageResults = List.filled(
    ImageStorageService.stageCount,
    StageResult.pending,
  );
  String? imageUrl;
  bool isLoadingImage = true;
  String? imageError;
  bool isWon = false;
  bool isGameOver = false;

  bool get canGuess =>
      dailyChallenge != null && !isLoadingImage && !isWon && !isGameOver;

  Future<void> loadDaily() async {
    isLoadingImage = true;
    imageError = null;
    dailyChallenge = null;
    currentStage = 1;
    stageResults = List.filled(
      ImageStorageService.stageCount,
      StageResult.pending,
    );
    isWon = false;
    isGameOver = false;
    notifyListeners();

    try {
      dailyChallenge = await _dailyChallengeService.fetchToday();

      if (dailyChallenge == null) {
        imageUrl = null;
        imageError = 'No daily challenge available today.';
        return;
      }

      imageUrl = await _imageStorageService.fetchDailyImageUrl(
        dailyChallenge!.challengeDate,
        currentStage,
      );
    } catch (error) {
      imageUrl = null;
      imageError = 'Failed to load daily challenge.';
      debugPrint('Daily load error: $error');
    } finally {
      isLoadingImage = false;
      notifyListeners();
    }
  }

  Future<void> submitGuess(String guess) async {
    if (!canGuess) {
      return;
    }

    final challenge = dailyChallenge!;

    if (challenge.matchesGuess(guess)) {
      stageResults[currentStage - 1] = StageResult.correct;
      isWon = true;
      notifyListeners();
      return;
    }

    stageResults[currentStage - 1] = StageResult.wrong;

    if (currentStage >= ImageStorageService.stageCount) {
      isGameOver = true;
      notifyListeners();
      return;
    }

    currentStage++;
    isLoadingImage = true;
    notifyListeners();

    try {
      imageUrl = await _imageStorageService.fetchDailyImageUrl(
        challenge.challengeDate,
        currentStage,
      );
    } catch (error) {
      imageError = 'Failed to load image.';
      debugPrint('Stage image load error: $error');
    } finally {
      isLoadingImage = false;
      notifyListeners();
    }
  }
}
