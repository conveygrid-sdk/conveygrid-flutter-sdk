import 'package:flutter/material.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_theme.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';

class ConveyGridConsentActions extends StatelessWidget {
  const ConveyGridConsentActions({
    super.key,
    required this.theme,
    required this.isSubmitting,
    required this.isCustomizing,
    required this.onAcceptAll,
    required this.onRejectOptional,
    required this.onCustomize,
    required this.onSave,
    this.onCancel,
  });

  final ConveyGridTheme theme;
  final bool isSubmitting;
  final bool isCustomizing;
  final VoidCallback onAcceptAll;
  final VoidCallback onRejectOptional;
  final VoidCallback onCustomize;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(theme.borderRadius);
    final primaryStyle = FilledButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: radius),
      textStyle: theme.buttonTextStyle ??
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
    final outlineStyle = OutlinedButton.styleFrom(
      foregroundColor: theme.secondaryColor,
      minimumSize: const Size.fromHeight(48),
      side: BorderSide(color: theme.secondaryColor.withValues(alpha: 0.18)),
      shape: RoundedRectangleBorder(borderRadius: radius),
      textStyle: theme.buttonTextStyle ??
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );

    if (isSubmitting) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.primaryColor,
            ),
          ),
        ),
      );
    }

    if (isCustomizing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: onSave,
            style: primaryStyle,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text(ConveyGridUiStrings.savePreferences),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onCancel,
            style: outlineStyle,
            child: const Text(ConveyGridUiStrings.cancel),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAcceptAll,
          style: primaryStyle,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text(ConveyGridUiStrings.acceptAll),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRejectOptional,
          style: outlineStyle,
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
          label: const Text(ConveyGridUiStrings.rejectOptional),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onCustomize,
          style: TextButton.styleFrom(
            foregroundColor: theme.primaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          child: const Text(ConveyGridUiStrings.customize),
        ),
      ],
    );
  }
}
