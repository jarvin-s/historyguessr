import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/supabase_config.dart';
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

  static const _progressDotCount = 6;

  @override
  void initState() {
    super.initState();
    _viewModel = GameViewModel(
      ImageStorageService(SupabaseConfig.client),
    )..addListener(_onViewModelChanged);
    _viewModel.loadImage();
  }

  void _onViewModelChanged() {
    setState(() {});
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
                            _ProgressDots(count: _progressDotCount),
                            const SizedBox(height: 28),
                            _GuessInputRow(
                              controller: _guessController,
                              onGuess: () {},
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
  const _ProgressDots({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (_) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: AppColors.progressDot,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _GuessInputRow extends StatelessWidget {
  const _GuessInputRow({
    required this.controller,
    required this.onGuess,
  });

  final TextEditingController controller;
  final VoidCallback onGuess;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
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
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.guessButton,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onGuess,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: const Text(
                'GUESS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
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
