import 'package:{{package_name}}/features/{{name.snakeCase()}}/data/datasources/{{name.snakeCase()}}_data_source.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_item.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/repositories/{{name.snakeCase()}}_repository.dart';

/// Maps source models to immutable domain items.
class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  /// Creates a repository with an injected source.
  const new(this._source);

  final {{name.pascalCase()}}DataSource _source;

  @override
  Future<List<{{name.pascalCase()}}Item>> fetchItems() async => List.unmodifiable(
    (await _source.fetchItems()).map((model) => model.toEntity()),
  );
}
