import 'package:app_ui/src/tokens/app_tokens.dart';
import 'package:flutter/material.dart';

/// Standard screen chrome; callers provide content and actions.
class AppScreen extends StatelessWidget {
  /// Creates a screen with a localized title.
  const new({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  /// Screen title.
  final String title;

  /// Screen content.
  final Widget body;

  /// Optional toolbar controls.
  final List<Widget>? actions;

  /// Optional floating controls.
  final Widget? floatingActionButton;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: body,
    floatingActionButton: floatingActionButton,
  );
}

/// Scrollable content with shared padding and responsive width.
class AppContent extends StatelessWidget {
  /// Creates a content column.
  const new({
    required this.children,
    this.maxWidth = AppLayout.formWidth,
    super.key,
  });

  /// Composed sections.
  final List<Widget> children;

  /// Maximum content width.
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.section),
        children: children,
      ),
    ),
  );
}

/// A vertical gap from the shared spacing scale.
class AppGap extends StatelessWidget {
  /// Creates a vertical gap.
  const new(this.size, {super.key});

  /// Gap height.
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Typography roles supported by the design system.
enum AppTextStyle {
  /// Default body copy.
  body,

  /// Introductory copy.
  description,

  /// Section headings.
  heading,

  /// Secondary status copy.
  caption,

  /// Prominent numeric values.
  display,
}

/// Text styled through the active theme's semantic typography.
class AppText extends StatelessWidget {
  /// Creates semantic text.
  const new(
    this.text, {
    this.variant = AppTextStyle.body,
    this.semanticsLabel,
    super.key,
  });

  /// Localized content.
  final String text;

  /// Typography role.
  final AppTextStyle variant;

  /// Optional accessible description.
  final String? semanticsLabel;
  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    final style = switch (variant) {
      AppTextStyle.body => typography.bodyMedium,
      AppTextStyle.description => typography.bodyLarge,
      AppTextStyle.heading => typography.titleLarge,
      AppTextStyle.caption => typography.bodySmall,
      AppTextStyle.display => typography.displayLarge,
    };
    return Text(text, style: style, semanticsLabel: semanticsLabel);
  }
}

/// Emphasis levels for actions.
enum AppButtonStyle {
  /// Primary action.
  primary,

  /// Secondary action.
  secondary,

  /// Low-emphasis action.
  text,
}

/// A themed icon action with a localized label.
class AppButton extends StatelessWidget {
  /// Creates a button; a null callback disables it.
  const new({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = AppButtonStyle.primary,
    super.key,
  });

  /// Localized label.
  final String label;

  /// Action icon.
  final IconData icon;

  /// Action callback.
  final VoidCallback? onPressed;

  /// Visual emphasis.
  final AppButtonStyle variant;
  @override
  Widget build(BuildContext context) => switch (variant) {
    AppButtonStyle.primary => FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    ),
    AppButtonStyle.secondary => OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    ),
    AppButtonStyle.text => TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    ),
  };
}

/// Accessible toolbar or row action.
class AppIconButton extends StatelessWidget {
  /// Creates an icon action.
  const new({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  /// Accessible action label.
  final String tooltip;

  /// Action icon.
  final IconData icon;

  /// Action callback; null disables the control.
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon));
}

/// Shared progress feedback.
class AppProgress extends StatelessWidget {
  /// Creates progress feedback.
  const new({this.label, super.key});

  /// Optional localized progress label.
  final String? label;
  @override
  Widget build(BuildContext context) =>
      LinearProgressIndicator(semanticsLabel: label);
}

/// Section separator with consistent spacing.
class AppDivider extends StatelessWidget {
  /// Creates a section separator.
  const new({this.spacing = AppSpacing.section, super.key});

  /// Vertical padding around the divider.
  final double spacing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: spacing),
    child: const Divider(),
  );
}

/// Multiline text entry styled by the shared theme.
class AppTextField extends StatelessWidget {
  /// Creates a controlled text field.
  const new({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.maxLength,
    required this.onSubmitted,
    super.key,
  });

  /// Owner-managed input controller.
  final TextEditingController controller;

  /// Localized field label.
  final String label;

  /// Whether editing is enabled.
  final bool enabled;

  /// Maximum allowed characters.
  final int maxLength;

  /// Submission callback.
  final ValueChanged<String> onSubmitted;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    maxLength: maxLength,
    minLines: 1,
    maxLines: 4,
    textInputAction: TextInputAction.done,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(labelText: label),
  );
}

/// A selectable preference row inside a caller-owned RadioGroup.
class AppRadioTile<T> extends StatelessWidget {
  /// Creates a preference choice.
  const new({
    required this.value,
    required this.label,
    required this.enabled,
    this.icon,
    super.key,
  });

  /// Choice value.
  final T value;

  /// Localized label.
  final String label;

  /// Whether selection is enabled.
  final bool enabled;

  /// Optional leading symbol.
  final IconData? icon;
  @override
  Widget build(BuildContext context) => RadioListTile<T>(
    value: value,
    title: Text(label),
    enabled: enabled,
    contentPadding: EdgeInsets.zero,
    secondary: icon == null ? null : Icon(icon),
  );
}

/// A content row with an optional trailing action.
class AppListTile extends StatelessWidget {
  /// Creates a row without additional horizontal padding.
  const new({required this.title, this.trailing, super.key});

  /// Row content.
  final String title;

  /// Optional action.
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    trailing: trailing,
  );
}

/// A themed floating action, with ownership of its hero tag at the call site.
class AppFloatingAction extends StatelessWidget {
  /// Creates a floating action.
  const new({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  /// Unique hero identifier in this route.
  final String heroTag;

  /// Action symbol.
  final IconData icon;

  /// Action callback.
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FloatingActionButton(
    heroTag: heroTag,
    onPressed: onPressed,
    child: Icon(icon),
  );
}
