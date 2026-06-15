import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/supabase_config.dart';
import '../data/historical_figures.dart';
import '../services/completed_figures_service.dart';
import '../services/image_storage_service.dart';
import '../theme/app_colors.dart';
import '../view_models/game_view_model.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/round_completion_dialog.dart';
import 'all_figures_completed_screen.dart';

bool get _usesMobileKeyboardLayout =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _guessController = TextEditingController();
  final _guessFocusNode = FocusNode();
  late final GameViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final client = SupabaseConfig.client;
    _viewModel = GameViewModel(
      ImageStorageService(client),
      completedFiguresService: CompletedFiguresService(),
    )..addListener(_onViewModelChanged);
    _guessFocusNode.addListener(_onGuessFocusChanged);
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _viewModel.initialize();
    await _startRound();
  }

  void _onGuessFocusChanged() {
    setState(() {});
  }

  Future<void> _startRound() async {
    await _viewModel.startNewRound();
    _maybeShowCompletionModal();
  }

  Future<void> _playNextRound() async {
    _guessController.clear();
    await _startRound();
  }

  void _onViewModelChanged() {
    setState(() {});
    _maybeShowCompletionModal();
  }

  void _maybeShowCompletionModal() {
    if (!_viewModel.shouldShowCompletionModal ||
        _viewModel.roundSummary == null) {
      return;
    }

    final summary = _viewModel.roundSummary!;
    _viewModel.clearCompletionModalFlag();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      RoundCompletionDialog.show(
        context,
        viewModel: _viewModel,
        summary: summary,
        onPlayAgain: _playNextRound,
      );
    });
  }

  void _submitGuess() {
    final guess = HistoricalFigures.resolveExact(_guessController.text);
    if (guess == null ||
        !_viewModel.canGuess ||
        !HistoricalFigures.canSubmit(guess, exclude: _viewModel.guesses)) {
      return;
    }

    _viewModel.submitGuess(guess);
    _guessController.clear();
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    _guessController.dispose();
    _guessFocusNode
      ..removeListener(_onGuessFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.allFiguresCompleted) {
      return AllFiguresCompletedScreen(
        completedCount: _viewModel.totalFigureCount,
        onStartOver: () async {
          _guessController.clear();
          await _viewModel.resetProgress();
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, viewport) {
                      // On mobile, add invisible filler while the input is
                      // focused so the page can scroll the input to the top
                      // and leave room for the dropdown above the keyboard.
                      final fillerHeight =
                          _usesMobileKeyboardLayout && _guessFocusNode.hasFocus
                          ? (viewport.maxHeight - 120).clamp(
                              0.0,
                              double.infinity,
                            )
                          : 0.0;

                      return SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                32,
                                24,
                                32,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: _GameImage(
                                      imageUrl: _viewModel.imageUrl,
                                      isLoading: _viewModel.isLoadingImage,
                                      error: _viewModel.imageError,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Center(
                                    child: _ProgressDots(
                                      stageResults: _viewModel.stageResults,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _GuessInputRow(
                                    controller: _guessController,
                                    focusNode: _guessFocusNode,
                                    enabled: _viewModel.canGuess,
                                    showNext:
                                        _viewModel.isRoundComplete &&
                                        !_viewModel.isLoadingImage,
                                    guessedFigures: _viewModel.guesses,
                                    onGuess: _submitGuess,
                                    onNext: _playNextRound,
                                  ),
                                  if (_viewModel.guesses.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _SubmittedGuesses(
                                      guesses: _viewModel.guesses,
                                      answer: _viewModel.currentRound?.answer,
                                    ),
                                  ],
                                  SizedBox(height: fillerHeight),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 14,
              right: 20,
              child: _HeaderIconButton(
                icon: Icons.help_outline,
                onPressed: () => HowToPlayDialog.show(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameImage extends StatelessWidget {
  const _GameImage({
    required this.imageUrl,
    required this.isLoading,
    required this.error,
  });

  final String? imageUrl;
  final bool isLoading;
  final String? error;

  static const _size = 280.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: _size, height: _size, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const ColoredBox(
        color: AppColors.progressDot,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.black54,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (error != null || imageUrl == null) {
      return ColoredBox(
        color: AppColors.progressDot,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.black.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const ColoredBox(
          color: AppColors.progressDot,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.black54,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: AppColors.progressDot,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'HistoryGuessr',
            style: GoogleFonts.pressStart2p(
              fontSize: 18,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: onPressed != null ? Colors.black : Colors.black26,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.stageResults});

  final List<StageResult> stageResults;

  Color _colorForStage(StageResult result) {
    return switch (result) {
      StageResult.wrong => AppColors.progressDotWrong,
      StageResult.correct => AppColors.progressDotCorrect,
      StageResult.pending => AppColors.progressDot,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        stageResults.length,
        (index) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: _colorForStage(stageResults[index]),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _SubmittedGuesses extends StatelessWidget {
  const _SubmittedGuesses({required this.guesses, required this.answer});

  final List<String> guesses;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: guesses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final guess = guesses[index];
        final isCorrect =
            answer != null &&
            answer!.trim().toLowerCase() == guess.trim().toLowerCase();

        return _GuessResultBar(guess: guess, isCorrect: isCorrect);
      },
    );
  }
}

class _GuessResultBar extends StatelessWidget {
  const _GuessResultBar({required this.guess, required this.isCorrect});

  final String guess;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.guessCorrectBackground
            : AppColors.guessWrongBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? AppColors.guessCorrectBorder
              : AppColors.guessWrongBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.progressDotCorrect
                    : AppColors.progressDotWrong,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isCorrect ? Icons.check : Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(guess)),
          ],
        ),
      ),
    );
  }
}

class _GuessInputRow extends StatefulWidget {
  const _GuessInputRow({
    required this.controller,
    required this.focusNode,
    required this.onGuess,
    required this.enabled,
    required this.guessedFigures,
    this.showNext = false,
    this.onNext,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onGuess;
  final bool enabled;
  final List<String> guessedFigures;
  final bool showNext;
  final VoidCallback? onNext;

  @override
  State<_GuessInputRow> createState() => _GuessInputRowState();
}

class _GuessInputRowState extends State<_GuessInputRow> {
  static const _dropdownMaxHeight = 240.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus || !_usesMobileKeyboardLayout) {
      return;
    }

    // Wait for the keyboard animation before scrolling, so the input lands
    // at the top of the viewport and leaves room for the dropdown below.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !widget.focusNode.hasFocus) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        alignment: 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  bool get _canSubmit => HistoricalFigures.canSubmit(
    widget.controller.text,
    exclude: widget.guessedFigures,
  );

  void _pickOption(String option, AutocompleteOnSelected<String> onSelected) {
    widget.controller.value = TextEditingValue(
      text: option,
      selection: TextSelection.collapsed(offset: option.length),
    );
    onSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    final showNextButton = widget.showNext && widget.onNext != null;
    final canSubmit = !showNextButton && widget.enabled && _canSubmit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return RawAutocomplete<String>(
                textEditingController: widget.controller,
                focusNode: widget.focusNode,
                onSelected: (option) {
                  widget.controller.value = TextEditingValue(
                    text: option,
                    selection: TextSelection.collapsed(offset: option.length),
                  );
                },
                optionsBuilder: (textEditingValue) {
                  if (!widget.enabled) {
                    return const Iterable<String>.empty();
                  }
                  return HistoricalFigures.search(
                    textEditingValue.text,
                    exclude: widget.guessedFigures,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      color: AppColors.dropdownBackground,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: constraints.maxWidth,
                        constraints: const BoxConstraints(
                          maxHeight: _dropdownMaxHeight,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.dropdownBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () => _pickOption(option, onSelected),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        cursorColor: AppColors.guessButton,
                        enabled: widget.enabled,
                        scrollPadding: _usesMobileKeyboardLayout
                            ? const EdgeInsets.only(
                                bottom: _dropdownMaxHeight + 40,
                              )
                            : EdgeInsets.zero,
                        onSubmitted: (_) {
                          if (canSubmit) {
                            widget.onGuess();
                          }
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.enabled ? 'Type a name...' : null,
                          filled: true,
                          fillColor: AppColors.inputFill,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                        ),
                      );
                    },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: showNextButton || canSubmit
              ? AppColors.guessButton
              : const Color.fromARGB(255, 186, 179, 177),
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: showNextButton
                ? widget.onNext
                : canSubmit
                ? widget.onGuess
                : null,
            customBorder: const StadiumBorder(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Text(
                showNextButton ? 'NEXT' : 'GUESS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: showNextButton || canSubmit
                      ? Colors.white
                      : Colors.black38,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
