import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_item.dart';

/// Domain contract independent of storage and presentation.
abstract interface class {{name.pascalCase()}}Repository {
  /// Loads the feature items.
  Future<List<{{name.pascalCase()}}Item>> fetchItems();
}
