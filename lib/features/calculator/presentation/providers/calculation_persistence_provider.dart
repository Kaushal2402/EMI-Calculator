import 'dart:async';

import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Side-effect provider: persists the current inputs after every **successful**
/// calculation (SOW §7.5, task 3.5).
///
/// This is deliberately separate from [emiResultProvider], which stays a pure
/// derivation. The write is done from a `ref.listen` callback — not buried in a
/// getter — and fires once per settled `AsyncData<EmiResult>` emission. Rapid
/// edits are already coalesced upstream by [emiResultProvider]'s debounce, so
/// one settled calculation ⇒ exactly one `saveLastInput`.
///
/// It has no value of its own; a long-lived consumer (the app root) must
/// `watch` it so the listener stays subscribed for the app's lifetime.
final Provider<void> calculationPersistenceProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<EmiResult>>(emiResultProvider, (previous, next) {
    if (next is! AsyncData<EmiResult>) return;
    // Ignore a no-op re-emission of an identical result.
    if (previous is AsyncData<EmiResult> && previous.value == next.value) {
      return;
    }
    final input = ref.read(loanInputProvider).value;
    if (input == null) return;
    // Fire and forget — persistence failure must not break calculation.
    unawaited(ref.read(loanRepositoryProvider).saveLastInput(input));
  });
});
