import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conveygrid_flutter_sdk/src/client/convey_grid_client.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/bloc/cookie_banner_cubit.dart';

class ConveyGridCookieBanner extends StatelessWidget {
  const ConveyGridCookieBanner({
    super.key,
    required this.client,
    required this.configCode,
    this.pageUrl,
    this.onCompleted,
  });

  final ConveyGridClient client;
  final String configCode;
  final String? pageUrl;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CookieBannerCubit(
          client: client,
          configCode: configCode,
          pageUrl: pageUrl,
        );
        // ignore: unawaited_futures
        cubit.load();
        return cubit;
      },
      child: _CookieBannerBody(onCompleted: onCompleted),
    );
  }
}

class _CookieBannerBody extends StatelessWidget {
  const _CookieBannerBody({this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<CookieBannerCubit>();
    return BlocConsumer<CookieBannerCubit, CookieBannerState>(
      listener: (context, state) {
        if (state.status == CookieBannerStatus.success) {
          onCompleted?.call();
        }
      },
      builder: (context, state) {
        if (state.status == CookieBannerStatus.success ||
            state.status == CookieBannerStatus.initial) {
          return const SizedBox.shrink();
        }
        if (state.status == CookieBannerStatus.loading) {
          return const SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(),
            ),
          );
        }
        final banner = state.banner;
        if (banner == null) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            elevation: 12,
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.bannerTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(banner.bannerDescription),
                    if (state.isCustomizing) ...[
                      const SizedBox(height: 12),
                      ...banner.categories.map(
                        (category) => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(category.categoryName),
                          subtitle: Text(
                            category.isEssential
                                ? ConveyGridUiStrings.essentialLocked
                                : category.description,
                          ),
                          value: category.isEssential ||
                              state.grantedCodes
                                  .contains(category.categoryCode),
                          onChanged: category.isEssential
                              ? null
                              : (_) => theme.toggle(
                                    category.categoryCode,
                                    essential: false,
                                  ),
                        ),
                      ),
                    ],
                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 12),
                    if (state.status == CookieBannerStatus.submitting)
                      const Center(child: CircularProgressIndicator())
                    else if (state.isCustomizing)
                      FilledButton(
                        onPressed: theme.saveCustom,
                        child: const Text(ConveyGridUiStrings.savePreferences),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (banner.showAcceptAll)
                            FilledButton(
                              onPressed: theme.acceptAll,
                              child: const Text(ConveyGridUiStrings.acceptAll),
                            ),
                          if (banner.showDeclineAll)
                            OutlinedButton(
                              onPressed: theme.rejectOptional,
                              child: const Text(
                                ConveyGridUiStrings.rejectOptional,
                              ),
                            ),
                          if (banner.showCustomise)
                            TextButton(
                              onPressed: theme.showCustomize,
                              child: const Text(ConveyGridUiStrings.customize),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
