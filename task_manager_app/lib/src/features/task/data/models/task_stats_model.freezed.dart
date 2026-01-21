// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskStatsModel {
  int get total;
  int get completed;
  int get pending;
  int get highPriority;
  int get overdue;

  /// Create a copy of TaskStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskStatsModelCopyWith<TaskStatsModel> get copyWith =>
      _$TaskStatsModelCopyWithImpl<TaskStatsModel>(
          this as TaskStatsModel, _$identity);

  /// Serializes this TaskStatsModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskStatsModel &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.highPriority, highPriority) ||
                other.highPriority == highPriority) &&
            (identical(other.overdue, overdue) || other.overdue == overdue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, total, completed, pending, highPriority, overdue);

  @override
  String toString() {
    return 'TaskStatsModel(total: $total, completed: $completed, pending: $pending, highPriority: $highPriority, overdue: $overdue)';
  }
}

/// @nodoc
abstract mixin class $TaskStatsModelCopyWith<$Res> {
  factory $TaskStatsModelCopyWith(
          TaskStatsModel value, $Res Function(TaskStatsModel) _then) =
      _$TaskStatsModelCopyWithImpl;
  @useResult
  $Res call(
      {int total, int completed, int pending, int highPriority, int overdue});
}

/// @nodoc
class _$TaskStatsModelCopyWithImpl<$Res>
    implements $TaskStatsModelCopyWith<$Res> {
  _$TaskStatsModelCopyWithImpl(this._self, this._then);

  final TaskStatsModel _self;
  final $Res Function(TaskStatsModel) _then;

  /// Create a copy of TaskStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? completed = null,
    Object? pending = null,
    Object? highPriority = null,
    Object? overdue = null,
  }) {
    return _then(_self.copyWith(
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as int,
      pending: null == pending
          ? _self.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as int,
      highPriority: null == highPriority
          ? _self.highPriority
          : highPriority // ignore: cast_nullable_to_non_nullable
              as int,
      overdue: null == overdue
          ? _self.overdue
          : overdue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [TaskStatsModel].
extension TaskStatsModelPatterns on TaskStatsModel {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskStatsModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskStatsModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskStatsModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskStatsModel():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskStatsModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskStatsModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int total, int completed, int pending, int highPriority,
            int overdue)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskStatsModel() when $default != null:
        return $default(_that.total, _that.completed, _that.pending,
            _that.highPriority, _that.overdue);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int total, int completed, int pending, int highPriority,
            int overdue)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskStatsModel():
        return $default(_that.total, _that.completed, _that.pending,
            _that.highPriority, _that.overdue);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int total, int completed, int pending, int highPriority,
            int overdue)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskStatsModel() when $default != null:
        return $default(_that.total, _that.completed, _that.pending,
            _that.highPriority, _that.overdue);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TaskStatsModel implements TaskStatsModel {
  const _TaskStatsModel(
      {this.total = 0,
      this.completed = 0,
      this.pending = 0,
      this.highPriority = 0,
      this.overdue = 0});
  factory _TaskStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TaskStatsModelFromJson(json);

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int completed;
  @override
  @JsonKey()
  final int pending;
  @override
  @JsonKey()
  final int highPriority;
  @override
  @JsonKey()
  final int overdue;

  /// Create a copy of TaskStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskStatsModelCopyWith<_TaskStatsModel> get copyWith =>
      __$TaskStatsModelCopyWithImpl<_TaskStatsModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TaskStatsModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskStatsModel &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.highPriority, highPriority) ||
                other.highPriority == highPriority) &&
            (identical(other.overdue, overdue) || other.overdue == overdue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, total, completed, pending, highPriority, overdue);

  @override
  String toString() {
    return 'TaskStatsModel(total: $total, completed: $completed, pending: $pending, highPriority: $highPriority, overdue: $overdue)';
  }
}

/// @nodoc
abstract mixin class _$TaskStatsModelCopyWith<$Res>
    implements $TaskStatsModelCopyWith<$Res> {
  factory _$TaskStatsModelCopyWith(
          _TaskStatsModel value, $Res Function(_TaskStatsModel) _then) =
      __$TaskStatsModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int total, int completed, int pending, int highPriority, int overdue});
}

/// @nodoc
class __$TaskStatsModelCopyWithImpl<$Res>
    implements _$TaskStatsModelCopyWith<$Res> {
  __$TaskStatsModelCopyWithImpl(this._self, this._then);

  final _TaskStatsModel _self;
  final $Res Function(_TaskStatsModel) _then;

  /// Create a copy of TaskStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? total = null,
    Object? completed = null,
    Object? pending = null,
    Object? highPriority = null,
    Object? overdue = null,
  }) {
    return _then(_TaskStatsModel(
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as int,
      pending: null == pending
          ? _self.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as int,
      highPriority: null == highPriority
          ? _self.highPriority
          : highPriority // ignore: cast_nullable_to_non_nullable
              as int,
      overdue: null == overdue
          ? _self.overdue
          : overdue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
