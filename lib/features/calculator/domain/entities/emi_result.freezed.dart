// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emi_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmiResult {

/// Monthly instalment (exact, unrounded).
 double get monthlyEmi;/// Total interest payable over the full tenure (`EMI × n − P`).
 double get totalInterest;/// Total amount payable (`P + totalInterest`, i.e. `EMI × n`).
 double get totalPayable;/// Principal as a fraction of [totalPayable], `0.0`–`1.0`.
 double get principalRatio;/// Interest as a fraction of [totalPayable], `0.0`–`1.0`.
 double get interestRatio;/// Month-by-month amortization schedule (length == `tenureMonths`).
 List<AmortizationRow> get schedule;
/// Create a copy of EmiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmiResultCopyWith<EmiResult> get copyWith => _$EmiResultCopyWithImpl<EmiResult>(this as EmiResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmiResult&&(identical(other.monthlyEmi, monthlyEmi) || other.monthlyEmi == monthlyEmi)&&(identical(other.totalInterest, totalInterest) || other.totalInterest == totalInterest)&&(identical(other.totalPayable, totalPayable) || other.totalPayable == totalPayable)&&(identical(other.principalRatio, principalRatio) || other.principalRatio == principalRatio)&&(identical(other.interestRatio, interestRatio) || other.interestRatio == interestRatio)&&const DeepCollectionEquality().equals(other.schedule, schedule));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyEmi,totalInterest,totalPayable,principalRatio,interestRatio,const DeepCollectionEquality().hash(schedule));

@override
String toString() {
  return 'EmiResult(monthlyEmi: $monthlyEmi, totalInterest: $totalInterest, totalPayable: $totalPayable, principalRatio: $principalRatio, interestRatio: $interestRatio, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class $EmiResultCopyWith<$Res>  {
  factory $EmiResultCopyWith(EmiResult value, $Res Function(EmiResult) _then) = _$EmiResultCopyWithImpl;
@useResult
$Res call({
 double monthlyEmi, double totalInterest, double totalPayable, double principalRatio, double interestRatio, List<AmortizationRow> schedule
});




}
/// @nodoc
class _$EmiResultCopyWithImpl<$Res>
    implements $EmiResultCopyWith<$Res> {
  _$EmiResultCopyWithImpl(this._self, this._then);

  final EmiResult _self;
  final $Res Function(EmiResult) _then;

/// Create a copy of EmiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyEmi = null,Object? totalInterest = null,Object? totalPayable = null,Object? principalRatio = null,Object? interestRatio = null,Object? schedule = null,}) {
  return _then(_self.copyWith(
monthlyEmi: null == monthlyEmi ? _self.monthlyEmi : monthlyEmi // ignore: cast_nullable_to_non_nullable
as double,totalInterest: null == totalInterest ? _self.totalInterest : totalInterest // ignore: cast_nullable_to_non_nullable
as double,totalPayable: null == totalPayable ? _self.totalPayable : totalPayable // ignore: cast_nullable_to_non_nullable
as double,principalRatio: null == principalRatio ? _self.principalRatio : principalRatio // ignore: cast_nullable_to_non_nullable
as double,interestRatio: null == interestRatio ? _self.interestRatio : interestRatio // ignore: cast_nullable_to_non_nullable
as double,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<AmortizationRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [EmiResult].
extension EmiResultPatterns on EmiResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmiResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmiResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmiResult value)  $default,){
final _that = this;
switch (_that) {
case _EmiResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmiResult value)?  $default,){
final _that = this;
switch (_that) {
case _EmiResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double monthlyEmi,  double totalInterest,  double totalPayable,  double principalRatio,  double interestRatio,  List<AmortizationRow> schedule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmiResult() when $default != null:
return $default(_that.monthlyEmi,_that.totalInterest,_that.totalPayable,_that.principalRatio,_that.interestRatio,_that.schedule);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double monthlyEmi,  double totalInterest,  double totalPayable,  double principalRatio,  double interestRatio,  List<AmortizationRow> schedule)  $default,) {final _that = this;
switch (_that) {
case _EmiResult():
return $default(_that.monthlyEmi,_that.totalInterest,_that.totalPayable,_that.principalRatio,_that.interestRatio,_that.schedule);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double monthlyEmi,  double totalInterest,  double totalPayable,  double principalRatio,  double interestRatio,  List<AmortizationRow> schedule)?  $default,) {final _that = this;
switch (_that) {
case _EmiResult() when $default != null:
return $default(_that.monthlyEmi,_that.totalInterest,_that.totalPayable,_that.principalRatio,_that.interestRatio,_that.schedule);case _:
  return null;

}
}

}

/// @nodoc


class _EmiResult implements EmiResult {
  const _EmiResult({required this.monthlyEmi, required this.totalInterest, required this.totalPayable, required this.principalRatio, required this.interestRatio, required final  List<AmortizationRow> schedule}): _schedule = schedule;
  

/// Monthly instalment (exact, unrounded).
@override final  double monthlyEmi;
/// Total interest payable over the full tenure (`EMI × n − P`).
@override final  double totalInterest;
/// Total amount payable (`P + totalInterest`, i.e. `EMI × n`).
@override final  double totalPayable;
/// Principal as a fraction of [totalPayable], `0.0`–`1.0`.
@override final  double principalRatio;
/// Interest as a fraction of [totalPayable], `0.0`–`1.0`.
@override final  double interestRatio;
/// Month-by-month amortization schedule (length == `tenureMonths`).
 final  List<AmortizationRow> _schedule;
/// Month-by-month amortization schedule (length == `tenureMonths`).
@override List<AmortizationRow> get schedule {
  if (_schedule is EqualUnmodifiableListView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedule);
}


/// Create a copy of EmiResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmiResultCopyWith<_EmiResult> get copyWith => __$EmiResultCopyWithImpl<_EmiResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmiResult&&(identical(other.monthlyEmi, monthlyEmi) || other.monthlyEmi == monthlyEmi)&&(identical(other.totalInterest, totalInterest) || other.totalInterest == totalInterest)&&(identical(other.totalPayable, totalPayable) || other.totalPayable == totalPayable)&&(identical(other.principalRatio, principalRatio) || other.principalRatio == principalRatio)&&(identical(other.interestRatio, interestRatio) || other.interestRatio == interestRatio)&&const DeepCollectionEquality().equals(other._schedule, _schedule));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyEmi,totalInterest,totalPayable,principalRatio,interestRatio,const DeepCollectionEquality().hash(_schedule));

@override
String toString() {
  return 'EmiResult(monthlyEmi: $monthlyEmi, totalInterest: $totalInterest, totalPayable: $totalPayable, principalRatio: $principalRatio, interestRatio: $interestRatio, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class _$EmiResultCopyWith<$Res> implements $EmiResultCopyWith<$Res> {
  factory _$EmiResultCopyWith(_EmiResult value, $Res Function(_EmiResult) _then) = __$EmiResultCopyWithImpl;
@override @useResult
$Res call({
 double monthlyEmi, double totalInterest, double totalPayable, double principalRatio, double interestRatio, List<AmortizationRow> schedule
});




}
/// @nodoc
class __$EmiResultCopyWithImpl<$Res>
    implements _$EmiResultCopyWith<$Res> {
  __$EmiResultCopyWithImpl(this._self, this._then);

  final _EmiResult _self;
  final $Res Function(_EmiResult) _then;

/// Create a copy of EmiResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyEmi = null,Object? totalInterest = null,Object? totalPayable = null,Object? principalRatio = null,Object? interestRatio = null,Object? schedule = null,}) {
  return _then(_EmiResult(
monthlyEmi: null == monthlyEmi ? _self.monthlyEmi : monthlyEmi // ignore: cast_nullable_to_non_nullable
as double,totalInterest: null == totalInterest ? _self.totalInterest : totalInterest // ignore: cast_nullable_to_non_nullable
as double,totalPayable: null == totalPayable ? _self.totalPayable : totalPayable // ignore: cast_nullable_to_non_nullable
as double,principalRatio: null == principalRatio ? _self.principalRatio : principalRatio // ignore: cast_nullable_to_non_nullable
as double,interestRatio: null == interestRatio ? _self.interestRatio : interestRatio // ignore: cast_nullable_to_non_nullable
as double,schedule: null == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<AmortizationRow>,
  ));
}


}

// dart format on
