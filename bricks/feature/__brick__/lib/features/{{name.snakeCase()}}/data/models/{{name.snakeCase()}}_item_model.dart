import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_item.dart';

/// Maps source values into a domain entity.
class {{name.pascalCase()}}ItemModel {
  /// Creates a source model.
  const new({required this.id, required this.label});

  /// Source item identity.
  final String id;

  /// Source item label.
  final String label;

  /// Converts this model into the immutable domain representation.
  {{name.pascalCase()}}Item toEntity() => {{name.pascalCase()}}Item(id: id, label: label);
}
