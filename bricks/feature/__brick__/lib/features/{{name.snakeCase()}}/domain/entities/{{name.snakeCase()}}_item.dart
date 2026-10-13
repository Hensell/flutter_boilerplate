import 'package:equatable/equatable.dart';

/// An immutable item for this feature.
class {{name.pascalCase()}}Item extends Equatable {
  /// Creates an item.
  const new({required this.id, required this.label});

  /// The item identity.
  final String id;

  /// The item label.
  final String label;

  @override
  List<Object> get props => [id, label];
}
