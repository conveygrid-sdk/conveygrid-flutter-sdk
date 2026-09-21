import 'package:flutter/material.dart';
import 'package:conveygrid_flutter_sdk/src/client/convey_grid_client.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/widgets/convey_grid_consent_view.dart';

abstract final class ConveyGridConsentBottomSheet {
  static Future<ConsentSubmitResult?> show(
    BuildContext context, {
    required ConveyGridClient client,
    required ConsentNotice notice,
    ConveyGridSubject? subject,
    String? pageUrl,
  }) {
    final theme = client.config.theme;
    return showModalBottomSheet<ConsentSubmitResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: theme.secondaryColor.withValues(alpha: 0.45),
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.92;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(theme.borderRadius + 8),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.secondaryColor.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.secondaryColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Expanded(
                  child: ConveyGridConsentView(
                    client: client,
                    notice: notice,
                    subject: subject,
                    pageUrl: pageUrl,
                    compactHeader: true,
                    onCompleted: (state) {
                      Navigator.of(sheetContext).pop(state.result);
                    },
                    onCancelled: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
