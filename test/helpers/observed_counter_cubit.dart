import 'package:flutter_boilerplate/features/counter/presentation/cubit/counter_cubit.dart';

class ObservedCounterCubit extends CounterCubit {
  void fail(Object error) => addError(error, StackTrace.current);
}
