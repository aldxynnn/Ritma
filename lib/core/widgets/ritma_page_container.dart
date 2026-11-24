import 'package:flutter/material.dart';

import '../theme/ritma_spacing.dart';

/// Centers page content on desktop/web viewports with consistent max width
/// and horizontal gutters while remaining full-width on phones and tablets.
class RitmaPageContainer extends StatelessWidget {
  const RitmaPageContainer({
    required this.child,
    super.key,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.all(RitmaSpacing.md),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
