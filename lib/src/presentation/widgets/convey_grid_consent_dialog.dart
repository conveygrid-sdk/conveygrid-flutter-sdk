import 'package:flutter/material.dart';
import 'package:conveygrid_flutter_sdk/src/client/convey_grid_client.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/widgets/convey_grid_consent_view.dart';

abstract final class ConveyGridConsentDialog {
  static Future<ConsentSubmitResult?> show(
    BuildContext context, {
    required ConveyGridClient client,
    required ConsentNotice notice,
    ConveyGridSubject? subject,
    String? pageUrl,
  }) {
    return showDialog<ConsentSubmitResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 520,
            height: 640,
            child: ConveyGridConsentView(
              client: client,
              notice: notice,
              subject: subject,
              pageUrl: pageUrl,
              onCompleted: (state) {
                Navigator.of(dialogContext).pop(state.result);
              },
              onCancelled: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      },
    );
  }
}
