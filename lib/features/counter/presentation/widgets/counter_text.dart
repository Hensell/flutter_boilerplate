import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/counter/presentation/cubit/counter_cubit.dart';

/// Displays the current counter value.
class CounterText extends StatelessWidget {
  /// Creates this widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CounterCubit, int>((cubit) => cubit.state);
    return AppText('$count', variant: AppTextStyle.display);
  }
}
