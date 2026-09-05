import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// Thin wrapper around [Scaffold] that applies the standard 16dp horizontal
/// screen padding (SOW §5.2 / §5.3) and a consistent AppBar.
class AppScaffold extends StatelessWidget {
  /// Creates an app scaffold.
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padBody = true,
    super.key,
  });

  /// AppBar title text.
  final String title;

  /// Screen content.
  final Widget body;

  /// Optional AppBar actions.
  final List<Widget>? actions;

  /// Optional AppBar leading widget.
  final Widget? leading;

  /// Optional bottom bar (e.g. AdMob banner on Results).
  final Widget? bottomNavigationBar;

  /// Optional FAB (e.g. Share on Results).
  final Widget? floatingActionButton;

  /// Whether to apply the standard horizontal screen padding to [body].
  final bool padBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: leading,
        actions: actions,
      ),
      body: padBody
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingLG),
              child: body,
            )
          : body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
