import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the active Material [ThemeMode] across RITMA.
///
/// Defaults to [ThemeMode.dark] to showcase the Editorial Kinetic dark
/// surface, with instant toggle support for high-daylight studio reception
/// environments.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setMode(ThemeMode mode) {
    state = mode;
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Compact AppBar action to toggle Dark/Light theme on any screen.
class ThemeModeToggleButton extends ConsumerWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}
