// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoanInput {

/// Principal loan amount, in ₹.
 double get principal;/// Annual interest rate as a percentage, e.g. `8.5` for 8.50% p.a.
 double get annualRate;/// Loan tenure, always expressed in months.
 int get tenureMonths;/// Selected loan product.
 LoanType get loanType;
/// Create a copy of LoanInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoanInputCopyWith<LoanInput> get copyWith => _$LoanInputCopyWithImpl<LoanInput>(this as LoanInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoanInput&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.annualRate, annualRate) || other.annualRate == annualRate)&&(identical(other.tenureMonths, tenureMonths) || other.tenureMonths == tenureMonths)&&(identical(other.loanType, loanType) || other.loanType == loanType));
}


@override
int get hashCode => Object.hash(runtimeType,principal,annualRate,tenureMonths,loanType);

@override
String toString() {
  return 'LoanInput(principal: $principal, annualRate: $annualRate, tenureMonths: $tenureMonths, loanType: $loanType)';
}


}

/// @nodoc
abstract mixin class $LoanInputCopyWith<$Res>  {
  factory $LoanInputCopyWith(LoanInput value, $Res Function(LoanInput) _then) = _$LoanInputCopyWithImpl;
@useResult
$Res call({
 double principal, double annualRate, int tenureMonths, LoanType loanType
});




}
/// @nodoc
class _$LoanInputCopyWithImpl<$Res>
    implements $LoanInputCopyWith<$Res> {
  _$LoanInputCopyWithImpl(this._self, this._then);

  final LoanInput _self;
  final $Res Function(LoanInput) _then;

/// Create a copy of LoanInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? principal = null,Object? annualRate = null,Object? tenureMonths = null,Object? loanType = null,}) {
  return _then(_self.copyWith(
principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,annualRate: null == annualRate ? _self.annualRate : annualRate // ignore: cast_nullable_to_non_nullable
as double,tenureMonths: null == tenureMonths ? _self.tenureMonths : tenureMonths // ignore: cast_nullable_to_non_nullable
as int,loanType: null == loanType ? _self.loanType : loanType // ignore: cast_nullable_to_non_nullable
as LoanType,
  ));
}

}


/// Adds pattern-matching-related methods to [LoanInput].
extension LoanInputPatterns on LoanInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoanInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoanInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoanInput value)  $default,){
final _that = this;
switch (_that) {
case _LoanInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoanInput value)?  $default,){
final _that = this;
switch (_that) {
case _LoanInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double principal,  double annualRate,  int tenureMonths,  LoanType loanType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoanInput() when $default != null:
return $default(_that.principal,_that.annualRate,_that.tenureMonths,_that.loanType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double principal,  double annualRate,  int tenureMonths,  LoanType loanType)  $default,) {final _that = this;
switch (_that) {
case _LoanInput():
return $default(_that.principal,_that.annualRate,_that.tenureMonths,_that.loanType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double principal,  double annualRate,  int tenureMonths,  LoanType loanType)?  $default,) {final _that = this;
switch (_that) {
case _LoanInput() when $default != null:
return $default(_that.principal,_that.annualRate,_that.tenureMonths,_that.loanType);case _:
  return null;

}
}

}

/// @nodoc


class _LoanInput implements LoanInput {
  const _LoanInput({required this.principal, required this.annualRate, required this.tenureMonths, required this.loanType});
  

/// Principal loan amount, in ₹.
@override final  double principal;
/// Annual interest rate as a percentage, e.g. `8.5` for 8.50% p.a.
@override final  double annualRate;
/// Loan tenure, always expressed in months.
@override final  int tenureMonths;
/// Selected loan product.
@override final  LoanType loanType;

/// Create a copy of LoanInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoanInputCopyWith<_LoanInput> get copyWith => __$LoanInputCopyWithImpl<_LoanInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoanInput&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.annualRate, annualRate) || other.annualRate == annualRate)&&(identical(other.tenureMonths, tenureMonths) || other.tenureMonths == tenureMonths)&&(identical(other.loanType, loanType) || other.loanType == loanType));
}


@override
int get hashCode => Object.hash(runtimeType,principal,annualRate,tenureMonths,loanType);

@override
String toString() {
  return 'LoanInput(principal: $principal, annualRate: $annualRate, tenureMonths: $tenureMonths, loanType: $loanType)';
}


}

/// @nodoc
abstract mixin class _$LoanInputCopyWith<$Res> implements $LoanInputCopyWith<$Res> {
  factory _$LoanInputCopyWith(_LoanInput value, $Res Function(_LoanInput) _then) = __$LoanInputCopyWithImpl;
@override @useResult
$Res call({
 double principal, double annualRate, int tenureMonths, LoanType loanType
});




}
/// @nodoc
class __$LoanInputCopyWithImpl<$Res>
    implements _$LoanInputCopyWith<$Res> {
  __$LoanInputCopyWithImpl(this._self, this._then);

  final _LoanInput _self;
  final $Res Function(_LoanInput) _then;

/// Create a copy of LoanInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? principal = null,Object? annualRate = null,Object? tenureMonths = null,Object? loanType = null,}) {
  return _then(_LoanInput(
principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,annualRate: null == annualRate ? _self.annualRate : annualRate // ignore: cast_nullable_to_non_nullable
as double,tenureMonths: null == tenureMonths ? _self.tenureMonths : tenureMonths // ignore: cast_nullable_to_non_nullable
as int,loanType: null == loanType ? _self.loanType : loanType // ignore: cast_nullable_to_non_nullable
as LoanType,
  ));
}


}

// dart format on
