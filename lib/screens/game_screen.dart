import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/supabase_config.dart';
import '../data/historical_figures.dart';
import '../services/daily_challenge_service.dart';
import '../services/image_storage_service.dart';
import '../theme/app_colors.dart';
import '../view_models/game_view_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _guessController = TextEditingController();
  late final GameViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final client = SupabaseConfig.client;
    _viewModel = GameViewModel(
      DailyChallengeService(client),
      ImageStorageService(client),
    )..addListener(_onViewModelChanged);
    _viewModel.loadDaily();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _submitGuess() {
    final guess = _guessController.text;
    if (guess.trim().isEmpty || !_viewModel.canGuess) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(),
                const Divider(height: 1, thickness: 1, color: AppColors.divider),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _GameImage(
                              imageUrl: _viewModel.imageUrl,
                              isLoading: _viewModel.isLoadingImage,
                              error: _viewModel.imageError,
                            ),
                            const SizedBox(height: 28),
                            _ProgressDots(stageResults: _viewModel.stageResults),
                            const SizedBox(height: 28),
                            _GuessInputRow(
                              controller: _guessController,
                              enabled: _viewModel.canGuess,
                              onGuess: _submitGuess,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 14,
              right: 20,
              child: _HelpButton(onPressed: () {}),
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
      child: SizedBox(
        width: _size,
        height: _size,
        child: _buildContent(),
      ),
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
        child: Text(
          'HistoryGuessr',
          style: GoogleFonts.pressStart2p(
            fontSize: 18,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
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

class _GuessInputRow extends StatefulWidget {
  const _GuessInputRow({
    required this.controller,
    required this.onGuess,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback onGuess;
  final bool enabled;

  @override
  State<_GuessInputRow> createState() => _GuessInputRowState();
}

class _GuessInputRowState extends State<_GuessInputRow> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RawAutocomplete<String>(
            textEditingController: widget.controller,
            focusNode: _focusNode,
            optionsBuilder: (textEditingValue) {
              return HistoricalFigures.search(textEditingValue.text);
            },
            displayStringForOption: (option) => option,
            onSelected: (option) {
              widget.controller.text = option;
              widget.controller.selection = TextSelection.collapsed(
                offset: option.length,
              );
            },
            fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: fieldController,
                focusNode: focusNode,
                enabled: widget.enabled,
                onSubmitted: (_) {
                  widget.onGuess();
                },
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              if (options.isEmpty) {
                return const SizedBox.shrink();
              }

              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.dropdownBackground,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.dropdownBorder,
                      ),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
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
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: widget.enabled ? AppColors.guessButton : AppColors.progressDot,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: widget.enabled ? widget.onGuess : null,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Text(
                'GUESS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: widget.enabled ? Colors.white : Colors.black38,
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
