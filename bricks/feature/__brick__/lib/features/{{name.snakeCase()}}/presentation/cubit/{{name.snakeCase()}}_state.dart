import 'package:equatable/equatable.dart';
import 'package:{{package_name}}/core/errors/app_failure.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_item.dart';

/// Feature data and the current loading operation.
class {{name.pascalCase()}}State extends Equatable {
  /// Creates state retaining previous items during a retry.
  const new({this.items = const [], this.isLoading = false, this.failure});

  /// Last successfully loaded items.
  final List<{{name.pascalCase()}}Item> items;

  /// Whether a request is in progress.
  final bool isLoading;

  /// Last operation failure.
  final FailureKind? failure;

  @override
  List<Object?> get props => [items, isLoading, failure];
}
