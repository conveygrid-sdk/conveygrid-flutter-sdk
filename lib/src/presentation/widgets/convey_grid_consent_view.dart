import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conveygrid_flutter_sdk/src/client/convey_grid_client.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_theme.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/bloc/consent_view_cubit.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/widgets/convey_grid_consent_actions.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/widgets/convey_grid_purpose_tile.dart';

class ConveyGridConsentView extends StatelessWidget {
  const ConveyGridConsentView({
    super.key,
    required this.notice,
    required this.client,
    this.subject,
    this.pageUrl,
    this.onCompleted,
    this.onCancelled,
  });

  final ConsentNotice notice;
  final ConveyGridClient client;
  final ConveyGridSubject? subject;
  final String? pageUrl;
  final ValueChanged<ConsentViewState>? onCompleted;
  final VoidCallback? onCancelled;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsentViewCubit(
        client: client,
        notice: notice,
        subject: subject,
        pageUrl: pageUrl,
      ),
      child: _ConsentViewBody(
        theme: client.config.theme,
        onCompleted: onCompleted,
        onCancelled: onCancelled,
      ),
    );
  }
}

class _ConsentViewBody extends StatelessWidget {
  const _ConsentViewBody({
    required this.theme,
    this.onCompleted,
    this.onCancelled,
  });

  final ConveyGridTheme theme;
  final ValueChanged<ConsentViewState>? onCompleted;
  final VoidCallback? onCancelled;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConsentViewCubit, ConsentViewState>(
      listener: (context, state) {
        if (state.result != null) {
          onCompleted?.call(state);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ConsentViewCubit>();
        return ListView(
          padding: EdgeInsets.all(theme.spacing),
          children: [
            Text(
              state.notice.noticeName,
              style: theme.titleTextStyle ??
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${state.notice.version}',
              style: theme.bodyTextStyle,
            ),
            const SizedBox(height: 12),
            Text(state.notice.introductionText, style: theme.bodyTextStyle),
            const SizedBox(height: 16),
            ...state.notice.purposes.map(
              (purpose) => ConveyGridPurposeTile(
                purpose: purpose,
                selected: purpose.isMandatory ||
                    state.grantedOptionalIds.contains(purpose.purposeId),
                onChanged: purpose.isMandatory
                    ? null
                    : (value) => cubit.toggleOptional(purpose.purposeId),
                theme: theme,
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ConveyGridConsentActions(
              theme: theme,
              isSubmitting: state.isSubmitting,
              isCustomizing: state.isCustomizing,
              onAcceptAll: cubit.acceptAll,
              onRejectOptional: cubit.rejectOptional,
              onCustomize: cubit.showCustomize,
              onSave: cubit.saveCustom,
              onCancel: onCancelled,
            ),
            const SizedBox(height: 16),
            Text(state.notice.footerText, style: theme.bodyTextStyle),
          ],
        );
      },
    );
  }
}
