import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const HowToPlayDialog(),
    );
  }

  static const _stepBrown = Color(0xFFB8956A);

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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'HOW TO PLAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Guess the historical figure in 6 tries!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _StepItem(
                    number: 1,
                    color: _stepBrown,
                    title: 'Pixelated portrait',
                    description:
                        'A heavily pixelated image of a historical figure is shown.',
                  ),
                  const SizedBox(height: 16),
                  const _StepItem(
                    number: 2,
                    color: _stepBrown,
                    title: 'Make your guess',
                    description:
                        'Type in the name of who you think it is. You have 6 attempts to guess correctly.',
                  ),
                  const SizedBox(height: 16),
                  const _StepItem(
                    number: 3,
                    color: _stepBrown,
                    title: 'Clearer each time',
                    description:
                        'With each wrong guess, the image becomes clearer and a new hint appears.',
                  ),
                  const SizedBox(height: 16),
                  const _StepItem(
                    number: 4,
                    color: _stepBrown,
                    title: 'Learn something new',
                    description:
                        'Win or lose, you\'ll discover a fun fact about the historical figure.',
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'FEEDBACK COLORS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _FeedbackLegendItem(
                    color: AppColors.progressDotCorrect,
                    label: 'CORRECT',
                  ),
                  const SizedBox(height: 10),
                  const _FeedbackLegendItem(
                    color: AppColors.progressDotWrong,
                    label: 'INCORRECT',
                  ),
                  const SizedBox(height: 10),
                  const _FeedbackLegendItem(
                    color: AppColors.progressDot,
                    label: 'REMAINING ATTEMPTS',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
                color: Colors.black45,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.color,
    required this.title,
    required this.description,
  });

  final int number;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackLegendItem extends StatelessWidget {
  const _FeedbackLegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
