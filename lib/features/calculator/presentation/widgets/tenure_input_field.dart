import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/input_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Loan-tenure input: a [TextField] + [Slider] + a Years / Months
/// [ToggleButtons] (SOW §4.2, §5.2).
///
/// The tenure is *always* held in months by the parent ([onMonthsChanged]); the
/// [unit] only changes how the number is shown and entered. 1–30 years /
/// 12–360 months.
class TenureInputField extends StatefulWidget {
  /// Creates a [TenureInputField].
  const TenureInputField({
    required this.months,
    required this.unit,
    required this.onMonthsChanged,
    required this.onUnitChanged,
    super.key,
  });

  /// Current tenure in months (canonical).
  final int months;

  /// Whether the field currently shows Years or Months.
  final TenureUnit unit;

  /// Called with the new tenure in months.
  final ValueChanged<int> onMonthsChanged;

  /// Called when the Yr / Mo toggle changes.
  final ValueChanged<TenureUnit> onUnitChanged;

  @override
  State<TenureInputField> createState() => _TenureInputFieldState();
}

class _TenureInputFieldState extends State<TenureInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  bool get _inYears => widget.unit == TenureUnit.years;

  double get _min => (_inYears ? kMinTenureYears : kMinTenureMonths).toDouble();
  double get _max => (_inYears ? kMaxTenureYears : kMaxTenureMonths).toDouble();

  int get _displayValue => _inYears ? widget.months ~/ 12 : widget.months;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '$_displayValue');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(TenureInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        widget.months != oldWidget.months || widget.unit != oldWidget.unit;
    if (changed && !_focusNode.hasFocus) {
      _controller.text = '$_displayValue';
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

  int _toMonths(int display) => _inYears ? display * 12 : display;

  void _onTextChanged(String text) {
    final parsed = int.tryParse(text);
    if (parsed == null) {
      setState(() => _errorText = 'Enter a tenure');
      return;
    }
    if (parsed < _min || parsed > _max) {
      setState(
        () => _errorText = _inYears
            ? '$kMinTenureYears – $kMaxTenureYears years'
            : '$kMinTenureMonths – $kMaxTenureMonths months',
      );
      return;
    }
    setState(() => _errorText = null);
    widget.onMonthsChanged(_toMonths(parsed));
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    final parsed = int.tryParse(_controller.text) ?? _displayValue;
    final clamped = parsed.clamp(_min.toInt(), _max.toInt());
    setState(() => _errorText = null);
    _controller.text = '$clamped';
    final months = _toMonths(clamped);
    if (months != widget.months) widget.onMonthsChanged(months);
  }

  void _onSliderChanged(double raw) {
    final display = raw.round().clamp(_min.toInt(), _max.toInt());
    if (!_focusNode.hasFocus) _controller.text = '$display';
    setState(() => _errorText = null);
    widget.onMonthsChanged(_toMonths(display));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onTextChanged,
                onSubmitted: (_) => _focusNode.unfocus(),
                decoration: InputDecoration(
                  errorText: _errorText,
                  helperText: _inYears
                      ? '$kMinTenureYears – $kMaxTenureYears years'
                      : '$kMinTenureMonths – $kMaxTenureMonths months',
                ),
              ),
            ),
            const SizedBox(width: kSpacingMD),
            _UnitToggle(
              unit: widget.unit,
              onChanged: widget.onUnitChanged,
            ),
          ],
        ),
        const SizedBox(height: kSpacingSM),
        InputSlider(
          value: _displayValue.toDouble(),
          min: _min,
          max: _max,
          divisions: (_max - _min).round(),
          onChanged: _onSliderChanged,
          minLabel: _inYears ? '$kMinTenureYears Yr' : '$kMinTenureMonths Mo',
          maxLabel: _inYears ? '$kMaxTenureYears Yr' : '$kMaxTenureMonths Mo',
          semanticFormatterCallback: (v) =>
              _inYears ? '${v.round()} years' : '${v.round()} months',
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onChanged});

  final TenureUnit unit;
  final ValueChanged<TenureUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    const values = TenureUnit.values;
    return SizedBox(
      height: AppSizes.textFieldHeight,
      child: Center(
        child: ToggleButtons(
          constraints: const BoxConstraints(
            minHeight: AppSizes.toggleButtonHeight,
            maxHeight: AppSizes.toggleButtonHeight,
            minWidth: 48,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          isSelected: [for (final v in values) v == unit],
          onPressed: (index) => onChanged(values[index]),
          children: const [Text('Yr'), Text('Mo')],
        ),
      ),
    );
  }
}
