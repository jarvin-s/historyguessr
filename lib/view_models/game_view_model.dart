import 'package:flutter/foundation.dart';

import '../data/historical_figures.dart';
import '../models/game_round.dart';
import '../services/gemini_fact_service.dart';
import '../services/image_storage_service.dart';

enum StageResult { pending, wrong, correct }

class GameViewModel extends ChangeNotifier {
  GameViewModel(
    this._imageStorageService, {
    GeminiFactService? factService,
  }) : _factService = factService ?? GeminiFactService();

  final ImageStorageService _imageStorageService;
  final GeminiFactService _factService;

  GameRound? currentRound;
  int currentStage = 1;
  List<StageResult> stageResults = List.filled(
    ImageStorageService.stageCount,
    StageResult.pending,
  );
  List<String> guesses = [];
  String? imageUrl;
  bool isLoadingImage = true;
  String? imageError;
  bool isWon = false;
  bool isGameOver = false;
  bool shouldShowCompletionModal = false;
  RoundSummary? roundSummary;

  bool get canGuess =>
      currentRound != null && !isLoadingImage && !isWon && !isGameOver;

  Future<void> startNewRound({String? excludeFolderKey}) async {
    isLoadingImage = true;
    imageError = null;
    currentRound = null;
    currentStage = 1;
    stageResults = List.filled(
      ImageStorageService.stageCount,
      StageResult.pending,
    );
    guesses = [];
    isWon = false;
    isGameOver = false;
    shouldShowCompletionModal = false;
    roundSummary = null;
    notifyListeners();

    try {
      final folderKey = await _imageStorageService.pickRandomFigureKey(
        exclude: excludeFolderKey,
      );
      final answer = HistoricalFigures.answerForFolderKey(folderKey);

      if (answer == null) {
        imageUrl = null;
        imageError = 'No matching figure for "$folderKey".';
        return;
      }

      currentRound = GameRound(folderKey: folderKey, answer: answer);
      imageUrl = await _imageStorageService.fetchRandomImageUrl(
        folderKey,
        currentStage,
      );
    } catch (error) {
      imageUrl = null;
      imageError = 'Failed to load figure.';
      debugPrint('Round load error: $error');
    } finally {
      isLoadingImage = false;
      notifyListeners();
    }
  }

  Future<void> refreshRound() {
    return startNewRound(excludeFolderKey: currentRound?.folderKey);
  }

  Future<void> submitGuess(String guess) async {
    if (!canGuess) {
      return;
    }

    final round = currentRound!;
    guesses.add(guess);

    if (round.matchesGuess(guess)) {
      stageResults[currentStage - 1] = StageResult.correct;
      isWon = true;
      await _showFinalImage(round);
      return;
    }

    stageResults[currentStage - 1] = StageResult.wrong;

    if (currentStage >= ImageStorageService.stageCount) {
      isGameOver = true;
      if (imageUrl != null && imageError == null) {
        _completeRound();
      } else {
        await _showFinalImage(round);
      }
      return;
    }

    currentStage++;
    isLoadingImage = true;
    notifyListeners();

    try {
      imageUrl = await _imageStorageService.fetchRandomImageUrl(
        round.folderKey,
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

  Future<void> _showFinalImage(GameRound round) async {
    isLoadingImage = true;
    notifyListeners();

    try {
      imageUrl = await _imageStorageService.fetchRandomImageUrl(
        round.folderKey,
        ImageStorageService.stageCount,
      );
      imageError = null;
    } catch (error) {
      imageError = 'Failed to load image.';
      debugPrint('Final image load error: $error');
    } finally {
      isLoadingImage = false;
      _completeRound();
    }
  }

  void _completeRound() {
    final answer = currentRound!.answer;
    roundSummary = RoundSummary(
      guesses: List<String>.from(guesses),
      isWon: isWon,
      answer: answer,
      imageUrl: imageUrl,
      isFactLoading: true,
    );
    shouldShowCompletionModal = true;
    notifyListeners();

    _loadFact(answer);
  }

  Future<void> _loadFact(String figureName) async {
    final fact = await _factService.fetchFact(figureName);

    // Ignore stale results if a new round started in the meantime.
    if (roundSummary == null || roundSummary!.answer != figureName) {
      return;
    }

    roundSummary = roundSummary!.copyWith(
      fact: fact,
      isFactLoading: false,
    );
    notifyListeners();
  }

  void clearCompletionModalFlag() {
    shouldShowCompletionModal = false;
    notifyListeners();
  }
}
