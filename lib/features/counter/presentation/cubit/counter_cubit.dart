import 'package:bloc/bloc.dart';

/// Manages the example counter state.
class CounterCubit extends Cubit<int> {
  /// Creates a counter starting at zero.
  new() : super(0);

  /// Increases the counter by one.
  void increment() => emit(state + 1);

  /// Decreases the counter by one.
  void decrement() => emit(state - 1);
}
