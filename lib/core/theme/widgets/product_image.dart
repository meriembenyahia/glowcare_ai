import 'package:flutter/material.dart';
import 'app_colors.dart';

class ProductImage extends StatelessWidget {
  final String path;
  final double size;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.path,
    this.size = 90,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.sanitizer_outlined,
      size: size * 0.5,
      color: AppColors.sageGreen,
    );

    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: size,
        width: size,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: size,
            width: size,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.deepGreen,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    if (path.isNotEmpty) {
      return Image.asset(
        path,
        height: size,
        width: size,
        fit: fit,
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    return fallback;
  }
}
