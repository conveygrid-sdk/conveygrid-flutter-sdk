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
    final isOn = purpose.isMandatory || selected;
    final borderColor = isOn
        ? theme.primaryColor.withValues(alpha: 0.35)
        : theme.secondaryColor.withValues(alpha: 0.1);
    final fillColor =
        isOn ? theme.primaryColor.withValues(alpha: 0.06) : theme.surfaceColor;

    return Semantics(
      label:
          '${purpose.purposeName}. ${purpose.isMandatory ? ConveyGridUiStrings.mandatory : ConveyGridUiStrings.optional}',
      toggled: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: theme.spacing * 0.85),
        padding: EdgeInsets.all(theme.spacing),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(theme.borderRadius),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: theme.secondaryColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                        TextStyle(
                          color: theme.secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: purpose.isMandatory
                        ? theme.secondaryColor.withValues(alpha: 0.08)
                        : theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    purpose.isMandatory
                        ? ConveyGridUiStrings.mandatory
                        : ConveyGridUiStrings.optional,
                    style: TextStyle(
                      color: purpose.isMandatory
                          ? theme.secondaryColor.withValues(alpha: 0.8)
                          : theme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Switch.adaptive(
                  value: isOn,
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
                    color: theme.secondaryColor.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.4,
                  ),
            ),
            if (purpose.isMandatory) ...[
              const SizedBox(height: 8),
              Text(
                ConveyGridUiStrings.essentialLocked,
                style: TextStyle(
                  color: theme.secondaryColor.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (purpose.categories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: purpose.categories
                    .map(
                      (category) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: theme.secondaryColor.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          category.categoryName,
                          style: TextStyle(
                            color: theme.secondaryColor.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
