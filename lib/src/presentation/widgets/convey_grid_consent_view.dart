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
    this.compactHeader = false,
  });

  final ConsentNotice notice;
  final ConveyGridClient client;
  final ConveyGridSubject? subject;
  final String? pageUrl;
  final ValueChanged<ConsentViewState>? onCompleted;
  final VoidCallback? onCancelled;
  final bool compactHeader;

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
        compactHeader: compactHeader,
      ),
    );
  }
}

class _ConsentViewBody extends StatelessWidget {
  const _ConsentViewBody({
    required this.theme,
    required this.compactHeader,
    this.onCompleted,
    this.onCancelled,
  });

  final ConveyGridTheme theme;
  final bool compactHeader;
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
        final spacing = theme.spacing;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(spacing, 12, spacing, spacing),
                children: [
                  _ConsentHeader(
                    theme: theme,
                    title: state.notice.noticeName,
                    version: state.notice.version,
                    introduction: state.notice.introductionText,
                    compact: compactHeader,
                  ),
                  SizedBox(height: spacing),
                  Text(
                    'Purposes',
                    style: theme.titleTextStyle?.copyWith(fontSize: 15) ??
                        TextStyle(
                          color: theme.secondaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Required purposes stay on. Optional ones are off until you choose.',
                    style: theme.bodyTextStyle ??
                        TextStyle(
                          color: theme.secondaryColor.withValues(alpha: 0.65),
                          fontSize: 13,
                          height: 1.35,
                        ),
                  ),
                  SizedBox(height: spacing * 0.85),
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
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: spacing * 0.75),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(theme.borderRadius),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state.notice.footerText.trim().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: spacing * 0.25),
                      child: Text(
                        state.notice.footerText,
                        style: theme.bodyTextStyle ??
                            TextStyle(
                              color:
                                  theme.secondaryColor.withValues(alpha: 0.55),
                              fontSize: 12,
                              height: 1.4,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: theme.secondaryColor.withValues(alpha: 0.08),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.secondaryColor.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing, 12, spacing, 12),
                  child: ConveyGridConsentActions(
                    theme: theme,
                    isSubmitting: state.isSubmitting,
                    isCustomizing: state.isCustomizing,
                    onAcceptAll: cubit.acceptAll,
                    onRejectOptional: cubit.rejectOptional,
                    onCustomize: cubit.showCustomize,
                    onSave: cubit.saveCustom,
                    onCancel: onCancelled,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConsentHeader extends StatelessWidget {
  const _ConsentHeader({
    required this.theme,
    required this.title,
    required this.version,
    required this.introduction,
    required this.compact,
  });

  final ConveyGridTheme theme;
  final String title;
  final String version;
  final String introduction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.12),
            theme.primaryColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(theme.borderRadius + 4),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.titleTextStyle ??
                          TextStyle(
                            color: theme.secondaryColor,
                            fontSize: compact ? 20 : 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.secondaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        'Version $version',
                        style: TextStyle(
                          color: theme.secondaryColor.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (introduction.trim().isNotEmpty) ...[
            SizedBox(height: theme.spacing * 0.85),
            Text(
              introduction,
              style: theme.bodyTextStyle ??
                  TextStyle(
                    color: theme.secondaryColor.withValues(alpha: 0.78),
                    fontSize: 14,
                    height: 1.45,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
