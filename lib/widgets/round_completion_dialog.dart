import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_round.dart';
import '../theme/app_colors.dart';
import '../view_models/game_view_model.dart';

class RoundCompletionDialog extends StatelessWidget {
  const RoundCompletionDialog({
    super.key,
    required this.summary,
    required this.onPlayAgain,
  });

  final RoundSummary summary;
  final VoidCallback onPlayAgain;

  static Future<void> show(
    BuildContext context, {
    required GameViewModel viewModel,
    required RoundSummary summary,
    required VoidCallback onPlayAgain,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // Rebuild as the AI-generated fact arrives so the modal stays live.
        return AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            return RoundCompletionDialog(
              summary: viewModel.roundSummary ?? summary,
              onPlayAgain: onPlayAgain,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: maxDialogHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                summary.isWon ? 'Well done!' : 'Nice try!',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
              if (summary.imageUrl != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    summary.imageUrl!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 240,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 240,
                        child: ColoredBox(
                          color: AppColors.progressDot,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'The answer was',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary.answer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (summary.isWon) ...[
                const SizedBox(height: 8),
                Text(
                  'Guessed in ${summary.guesses.length} ${summary.guesses.length == 1 ? 'try' : 'tries'}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _FactSection(
                isLoading: summary.isFactLoading,
                fact: summary.fact,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your guesses',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(summary.guesses.length, (index) {
                final guess = summary.guesses[index];
                final isCorrect =
                    summary.isWon && index == summary.guesses.length - 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.progressDotCorrect
                              : AppColors.progressDotWrong,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          guess,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPlayAgain();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.guessButton,
                    ),
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactSection extends StatelessWidget {
  const _FactSection({
    required this.isLoading,
    required this.fact,
  });

  final bool isLoading;
  final String? fact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  'DID YOU KNOW?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black45,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Finding a fun fact...',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      );
    }

    return Text(
      fact ?? 'No fact available right now.',
      style: const TextStyle(
        fontSize: 15,
        height: 1.4,
        color: Colors.black87,
      ),
    );
  }
}
