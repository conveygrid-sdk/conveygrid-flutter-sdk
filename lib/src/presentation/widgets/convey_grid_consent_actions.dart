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
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
    );
    if (isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isCustomizing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: onSave,
            style: buttonStyle,
            child: const Text(ConveyGridUiStrings.savePreferences),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onCancel,
            child: const Text(ConveyGridUiStrings.cancel),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onAcceptAll,
          style: buttonStyle,
          child: const Text(ConveyGridUiStrings.acceptAll),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onRejectOptional,
          child: const Text(ConveyGridUiStrings.rejectOptional),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onCustomize,
          child: const Text(ConveyGridUiStrings.customize),
        ),
      ],
    );
  }
}
