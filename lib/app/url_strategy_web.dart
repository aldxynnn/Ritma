import 'package:flutter_web_plugins/url_strategy.dart';

/// Uses clean HTML5 History path URLs on Flutter Web (e.g. `/auth/sign-in`).
void configureAppUrlStrategy() {
  usePathUrlStrategy();
}
