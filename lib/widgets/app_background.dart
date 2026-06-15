import 'package:flutter/material.dart';

abstract final class AppBackground {
  static const assetPath = 'assets/images/background.jpg';

  static const imageProvider = AssetImage(assetPath);

  static const decoration = BoxDecoration(
    image: DecorationImage(
      image: imageProvider,
      fit: BoxFit.cover,
    ),
  );

  static BoxDecoration dialogDecoration({double radius = 12}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      image: const DecorationImage(
        image: imageProvider,
        fit: BoxFit.cover,
      ),
    );
  }
}

class AppBackgroundScope extends StatelessWidget {
  const AppBackgroundScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppBackground.decoration,
      child: child,
    );
  }
}
