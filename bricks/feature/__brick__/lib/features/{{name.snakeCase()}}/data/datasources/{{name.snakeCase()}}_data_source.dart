import 'package:{{package_name}}/features/{{name.snakeCase()}}/data/models/{{name.snakeCase()}}_item_model.dart';

/// Example source; replace its internals with local or remote access.
class {{name.pascalCase()}}DataSource {
  /// Creates an empty source or one with injected initial items.
  const new({this._items = const []});

  final List<{{name.pascalCase()}}ItemModel> _items;

  /// Loads the source models without exposing infrastructure to the Cubit.
  Future<List<{{name.pascalCase()}}ItemModel>> fetchItems() async => _items;
}
