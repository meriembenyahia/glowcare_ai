import 'package:flutter/material.dart';

import 'app_logo.dart';

/// Compact page title that shows the GlowCare logo next to the page name.
/// Used in every standard AppBar so the brand is visible across the app.
class AppBarTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double logoSize;

  const AppBarTitle({
    super.key,
    required this.text,
    this.style,
    this.logoSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
