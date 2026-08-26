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
    return showModalBottomSheet<ConsentSubmitResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.9,
          child: ConveyGridConsentView(
            client: client,
            notice: notice,
            subject: subject,
            pageUrl: pageUrl,
            onCompleted: (state) {
              Navigator.of(sheetContext).pop(state.result);
            },
            onCancelled: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }
}
