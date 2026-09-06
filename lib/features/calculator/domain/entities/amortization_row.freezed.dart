// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'amortization_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AmortizationRow {

/// 1-based period index (month number, or year number in the yearly view).
 int get period;/// EMI paid in this period (sum of the monthly EMIs in the yearly view).
 double get emi;/// Portion of [emi] that reduced the principal.
 double get principalComponent;/// Portion of [emi] that went to interest.
 double get interestComponent;/// Principal still outstanding at the end of this period.
 double get outstandingBalance;
/// Create a copy of AmortizationRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmortizationRowCopyWith<AmortizationRow> get copyWith => _$AmortizationRowCopyWithImpl<AmortizationRow>(this as AmortizationRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmortizationRow&&(identical(other.period, period) || other.period == period)&&(identical(other.emi, emi) || other.emi == emi)&&(identical(other.principalComponent, principalComponent) || other.principalComponent == principalComponent)&&(identical(other.interestComponent, interestComponent) || other.interestComponent == interestComponent)&&(identical(other.outstandingBalance, outstandingBalance) || other.outstandingBalance == outstandingBalance));
}


@override
int get hashCode => Object.hash(runtimeType,period,emi,principalComponent,interestComponent,outstandingBalance);

@override
String toString() {
  return 'AmortizationRow(period: $period, emi: $emi, principalComponent: $principalComponent, interestComponent: $interestComponent, outstandingBalance: $outstandingBalance)';
}


}

/// @nodoc
abstract mixin class $AmortizationRowCopyWith<$Res>  {
  factory $AmortizationRowCopyWith(AmortizationRow value, $Res Function(AmortizationRow) _then) = _$AmortizationRowCopyWithImpl;
@useResult
$Res call({
 int period, double emi, double principalComponent, double interestComponent, double outstandingBalance
});




}
/// @nodoc
class _$AmortizationRowCopyWithImpl<$Res>
    implements $AmortizationRowCopyWith<$Res> {
  _$AmortizationRowCopyWithImpl(this._self, this._then);

  final AmortizationRow _self;
  final $Res Function(AmortizationRow) _then;

/// Create a copy of AmortizationRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? emi = null,Object? principalComponent = null,Object? interestComponent = null,Object? outstandingBalance = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,emi: null == emi ? _self.emi : emi // ignore: cast_nullable_to_non_nullable
as double,principalComponent: null == principalComponent ? _self.principalComponent : principalComponent // ignore: cast_nullable_to_non_nullable
as double,interestComponent: null == interestComponent ? _self.interestComponent : interestComponent // ignore: cast_nullable_to_non_nullable
as double,outstandingBalance: null == outstandingBalance ? _self.outstandingBalance : outstandingBalance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AmortizationRow].
extension AmortizationRowPatterns on AmortizationRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmortizationRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmortizationRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmortizationRow value)  $default,){
final _that = this;
switch (_that) {
case _AmortizationRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmortizationRow value)?  $default,){
final _that = this;
switch (_that) {
case _AmortizationRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int period,  double emi,  double principalComponent,  double interestComponent,  double outstandingBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmortizationRow() when $default != null:
return $default(_that.period,_that.emi,_that.principalComponent,_that.interestComponent,_that.outstandingBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int period,  double emi,  double principalComponent,  double interestComponent,  double outstandingBalance)  $default,) {final _that = this;
switch (_that) {
case _AmortizationRow():
return $default(_that.period,_that.emi,_that.principalComponent,_that.interestComponent,_that.outstandingBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int period,  double emi,  double principalComponent,  double interestComponent,  double outstandingBalance)?  $default,) {final _that = this;
switch (_that) {
case _AmortizationRow() when $default != null:
return $default(_that.period,_that.emi,_that.principalComponent,_that.interestComponent,_that.outstandingBalance);case _:
  return null;

}
}

}

/// @nodoc


class _AmortizationRow implements AmortizationRow {
  const _AmortizationRow({required this.period, required this.emi, required this.principalComponent, required this.interestComponent, required this.outstandingBalance});
  

/// 1-based period index (month number, or year number in the yearly view).
@override final  int period;
/// EMI paid in this period (sum of the monthly EMIs in the yearly view).
@override final  double emi;
/// Portion of [emi] that reduced the principal.
@override final  double principalComponent;
/// Portion of [emi] that went to interest.
@override final  double interestComponent;
/// Principal still outstanding at the end of this period.
@override final  double outstandingBalance;

/// Create a copy of AmortizationRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmortizationRowCopyWith<_AmortizationRow> get copyWith => __$AmortizationRowCopyWithImpl<_AmortizationRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmortizationRow&&(identical(other.period, period) || other.period == period)&&(identical(other.emi, emi) || other.emi == emi)&&(identical(other.principalComponent, principalComponent) || other.principalComponent == principalComponent)&&(identical(other.interestComponent, interestComponent) || other.interestComponent == interestComponent)&&(identical(other.outstandingBalance, outstandingBalance) || other.outstandingBalance == outstandingBalance));
}


@override
int get hashCode => Object.hash(runtimeType,period,emi,principalComponent,interestComponent,outstandingBalance);

@override
String toString() {
  return 'AmortizationRow(period: $period, emi: $emi, principalComponent: $principalComponent, interestComponent: $interestComponent, outstandingBalance: $outstandingBalance)';
}


}

/// @nodoc
abstract mixin class _$AmortizationRowCopyWith<$Res> implements $AmortizationRowCopyWith<$Res> {
  factory _$AmortizationRowCopyWith(_AmortizationRow value, $Res Function(_AmortizationRow) _then) = __$AmortizationRowCopyWithImpl;
@override @useResult
$Res call({
 int period, double emi, double principalComponent, double interestComponent, double outstandingBalance
});




}
/// @nodoc
class __$AmortizationRowCopyWithImpl<$Res>
    implements _$AmortizationRowCopyWith<$Res> {
  __$AmortizationRowCopyWithImpl(this._self, this._then);

  final _AmortizationRow _self;
  final $Res Function(_AmortizationRow) _then;

/// Create a copy of AmortizationRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? emi = null,Object? principalComponent = null,Object? interestComponent = null,Object? outstandingBalance = null,}) {
  return _then(_AmortizationRow(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,emi: null == emi ? _self.emi : emi // ignore: cast_nullable_to_non_nullable
as double,principalComponent: null == principalComponent ? _self.principalComponent : principalComponent // ignore: cast_nullable_to_non_nullable
as double,interestComponent: null == interestComponent ? _self.interestComponent : interestComponent // ignore: cast_nullable_to_non_nullable
as double,outstandingBalance: null == outstandingBalance ? _self.outstandingBalance : outstandingBalance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
