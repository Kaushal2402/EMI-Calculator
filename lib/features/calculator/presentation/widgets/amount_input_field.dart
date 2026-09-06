import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/core/utils/indian_number_input_formatter.dart';
import 'package:emi_calculator/core/utils/number_formatter.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/input_slider.dart';
import 'package:flutter/material.dart';

/// Principal-amount input: a `₹` [TextField] and a [Slider] kept in sync
/// (SOW §4.2, §5.2). Range ₹10,000 – ₹5,00,00,000, Indian numeral grouping.
///
/// Dumb widget: it owns only its [TextEditingController]. The current [value]
/// and every change flow through the parent, which is the single source of
/// truth (`loanInputProvider`).
class AmountInputField extends StatefulWidget {
  /// Creates an [AmountInputField].
  const AmountInputField({
    required this.value,
    required this.onChanged,
    this.min = kMinPrincipal,
    this.max = kMaxPrincipal,
    super.key,
  });

  /// Current principal in ₹.
  final double value;

  /// Lower bound (₹10,000 by default).
  final double min;

  /// Upper bound (₹5,00,00,000 by default).
  final double max;

  /// Called with the new, in-range principal on every text or slider change.
  final ValueChanged<double> onChanged;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  /// Slider granularity — SOW gives no step for principal, so snap drags to
  /// ₹1,000 for a usable track. The text field still accepts any exact ₹.
  static const double _sliderStep = 1000;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _grouped(widget.value));
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AmountInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      _controller.text = _grouped(widget.value);
      _errorText = null;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  static String _grouped(double value) =>
      NumberFormatter.grouped(value.round());

  double? _parse(String text) {
    final digits = text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return null;
    return double.tryParse(digits);
  }

  void _onTextChanged(String text) {
    final parsed = _parse(text);
    if (parsed == null) {
      setState(() => _errorText = 'Enter an amount');
      return;
    }
    if (parsed < widget.min || parsed > widget.max) {
      setState(
        () => _errorText =
            '${NumberFormatter.currency(widget.min)} – '
            '${NumberFormatter.currency(widget.max)}',
      );
      return;
    }
    setState(() => _errorText = null);
    widget.onChanged(parsed);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    // Commit on blur: clamp, normalise the text, propagate.
    final parsed = _parse(_controller.text) ?? widget.value;
    final clamped = parsed.clampTo(widget.min, widget.max);
    setState(() => _errorText = null);
    _controller.text = _grouped(clamped);
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  void _onSliderChanged(double raw) {
    final snapped = (raw / _sliderStep).round() * _sliderStep;
    final clamped = snapped.clampTo(widget.min, widget.max);
    if (!_focusNode.hasFocus) _controller.text = _grouped(clamped);
    setState(() => _errorText = null);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: const [IndianDigitsInputFormatter()],
          onChanged: _onTextChanged,
          onSubmitted: (_) => _focusNode.unfocus(),
          decoration: InputDecoration(
            prefixText: '₹ ',
            errorText: _errorText,
            helperText:
                '${NumberFormatter.currency(widget.min)} – '
                '${NumberFormatter.currency(widget.max)}',
          ),
        ),
        const SizedBox(height: kSpacingSM),
        InputSlider(
          value: widget.value,
          min: widget.min,
          max: widget.max,
          onChanged: _onSliderChanged,
          minLabel: '₹10K',
          maxLabel: '₹5Cr',
          semanticFormatterCallback: NumberFormatter.currency,
        ),
      ],
    );
  }
}
