import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/input_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Annual interest-rate input: a `%` [TextField] and a [Slider] kept in sync
/// (SOW §4.2, §5.2). Range 1.00 %–36.00 %, step 0.05 %, `XX.XX%` display.
class RateInputField extends StatefulWidget {
  /// Creates a [RateInputField].
  const RateInputField({
    required this.value,
    required this.onChanged,
    this.min = kMinAnnualRate,
    this.max = kMaxAnnualRate,
    this.step = kAnnualRateStep,
    super.key,
  });

  /// Current annual rate as a percentage (e.g. `8.5`).
  final double value;

  /// Lower bound (1.00 %).
  final double min;

  /// Upper bound (36.00 %).
  final double max;

  /// Slider / rounding step (0.05 %).
  final double step;

  /// Called with the new, in-range rate on every text or slider change.
  final ValueChanged<double> onChanged;

  @override
  State<RateInputField> createState() => _RateInputFieldState();
}

class _RateInputFieldState extends State<RateInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(RateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      _controller.text = _format(widget.value);
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

  static String _format(double value) => value.toStringAsFixed(2);

  double _snap(double raw) {
    final stepped = (raw / widget.step).round() * widget.step;
    final clamped = stepped.clampTo(widget.min, widget.max);
    return double.parse(clamped.toStringAsFixed(2));
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed == null) {
      setState(() => _errorText = 'Enter a rate');
      return;
    }
    if (parsed < widget.min || parsed > widget.max) {
      setState(
        () => _errorText = '${_format(widget.min)}% – ${_format(widget.max)}%',
      );
      return;
    }
    setState(() => _errorText = null);
    widget.onChanged(parsed);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    final parsed = double.tryParse(_controller.text) ?? widget.value;
    final clamped = parsed.clampTo(widget.min, widget.max);
    setState(() => _errorText = null);
    _controller.text = _format(clamped);
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  void _onSliderChanged(double raw) {
    final snapped = _snap(raw);
    if (!_focusNode.hasFocus) _controller.text = _format(snapped);
    setState(() => _errorText = null);
    widget.onChanged(snapped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
          ],
          onChanged: _onTextChanged,
          onSubmitted: (_) => _focusNode.unfocus(),
          decoration: InputDecoration(
            suffixText: ' %',
            errorText: _errorText,
            helperText:
                '${_format(widget.min)}% – ${_format(widget.max)}% p.a.',
          ),
        ),
        const SizedBox(height: kSpacingSM),
        InputSlider(
          value: widget.value,
          min: widget.min,
          max: widget.max,
          divisions: ((widget.max - widget.min) / widget.step).round(),
          onChanged: _onSliderChanged,
          minLabel: '1%',
          maxLabel: '36%',
          semanticFormatterCallback: (v) => '${_format(v)} percent',
        ),
      ],
    );
  }
}
