import 'package:flutter/material.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_theme.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_purpose.dart';

class ConveyGridPurposeTile extends StatelessWidget {
  const ConveyGridPurposeTile({
    super.key,
    required this.purpose,
    required this.selected,
    required this.onChanged,
    required this.theme,
  });

  final ConsentPurpose purpose;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final ConveyGridTheme theme;

  @override
  Widget build(BuildContext context) {
    final canToggle = !purpose.isMandatory && onChanged != null;
    return Semantics(
      label:
          '${purpose.purposeName}. ${purpose.isMandatory ? ConveyGridUiStrings.mandatory : ConveyGridUiStrings.optional}',
      toggled: selected,
      child: Container(
        margin: EdgeInsets.only(bottom: theme.spacing),
        padding: EdgeInsets.all(theme.spacing),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(theme.borderRadius),
          border:
              Border.all(color: theme.secondaryColor.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    purpose.purposeName,
                    style: theme.titleTextStyle ??
                        const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                    purpose.isMandatory
                        ? ConveyGridUiStrings.mandatory
                        : ConveyGridUiStrings.optional,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Switch(
                  value: purpose.isMandatory || selected,
                  onChanged: canToggle ? onChanged : null,
                  activeColor: theme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              purpose.purposeDescription,
              style: theme.bodyTextStyle ??
                  TextStyle(
                      color: theme.secondaryColor.withValues(alpha: 0.75)),
            ),
            if (purpose.categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: purpose.categories
                    .map(
                      (category) => Chip(
                        label: Text(category.categoryName),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
