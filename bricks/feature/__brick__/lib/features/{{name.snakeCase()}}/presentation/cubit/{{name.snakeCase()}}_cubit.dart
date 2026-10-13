import 'package:bloc/bloc.dart';
import 'package:{{package_name}}/core/errors/app_failure.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/repositories/{{name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/presentation/cubit/{{name.snakeCase()}}_state.dart';

/// Coordinates feature operations through a domain contract.
class {{name.pascalCase()}}Cubit extends Cubit<{{name.pascalCase()}}State> {
  /// Creates a route-scoped Cubit.
  new(this._repository) : super(const {{name.pascalCase()}}State());

  final {{name.pascalCase()}}Repository _repository;

  /// Loads items and prevents overlapping requests.
  Future<void> load() async {
    if (isClosed || state.isLoading) return;
    final previous = state.items;
    emit({{name.pascalCase()}}State(items: previous, isLoading: true));
    try {
      final items = await _repository.fetchItems();
      if (isClosed) return;
      emit({{name.pascalCase()}}State(items: items));
    } on AppFailure catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit({{name.pascalCase()}}State(items: previous, failure: error.kind));
    }
  }
}
