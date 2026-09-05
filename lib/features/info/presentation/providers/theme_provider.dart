/// Barrel re-export so the Info feature (which owns the theme toggle UI, SOW
/// §5.4) can import the theme provider from its own layer while the single
/// source of truth stays in `core/theme/` (SOW §8 lists the file in both
/// places).
library;

export 'package:emi_calculator/core/theme/theme_provider.dart';
