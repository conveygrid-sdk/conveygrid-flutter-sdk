import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conveygrid_flutter_sdk/src/client/convey_grid_client.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';

enum CookieBannerStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure
}

final class CookieBannerState extends Equatable {
  const CookieBannerState({
    this.status = CookieBannerStatus.initial,
    this.banner,
    this.grantedCodes = const {},
    this.isCustomizing = false,
    this.errorMessage,
    this.preference,
  });

  final CookieBannerStatus status;
  final CookieBanner? banner;
  final Set<String> grantedCodes;
  final bool isCustomizing;
  final String? errorMessage;
  final CookiePreference? preference;

  CookieBannerState copyWith({
    CookieBannerStatus? status,
    CookieBanner? banner,
    Set<String>? grantedCodes,
    bool? isCustomizing,
    String? errorMessage,
    CookiePreference? preference,
    bool clearError = false,
  }) {
    return CookieBannerState(
      status: status ?? this.status,
      banner: banner ?? this.banner,
      grantedCodes: grantedCodes ?? this.grantedCodes,
      isCustomizing: isCustomizing ?? this.isCustomizing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      preference: preference ?? this.preference,
    );
  }

  @override
  List<Object?> get props => [
        status,
        banner,
        grantedCodes,
        isCustomizing,
        errorMessage,
        preference,
      ];
}

final class CookieBannerCubit extends Cubit<CookieBannerState> {
  CookieBannerCubit({
    required ConveyGridClient client,
    required this.configCode,
    this.pageUrl,
  })  : _client = client,
        super(const CookieBannerState());

  final ConveyGridClient _client;
  final String configCode;
  final String? pageUrl;

  Future<void> load() async {
    emit(state.copyWith(status: CookieBannerStatus.loading, clearError: true));
    final cached = _client.cookiePreference;
    final result = await _client.getCookieBanner(configCode: configCode);
    result.fold(
      onSuccess: (banner) {
        final cacheMatches = cached != null && cached.version == banner.version;
        emit(
          state.copyWith(
            status: cacheMatches
                ? CookieBannerStatus.success
                : CookieBannerStatus.ready,
            banner: banner,
            grantedCodes: cacheMatches
                ? cached.asMap.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toSet()
                : {
                    for (final category in banner.categories)
                      if (category.isEssential) category.categoryCode,
                  },
            preference: cacheMatches ? cached : null,
          ),
        );
      },
      onFailure: (failure) => emit(
        state.copyWith(
          status: CookieBannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void toggle(String categoryCode, {required bool essential}) {
    if (essential) {
      return;
    }
    final next = Set<String>.from(state.grantedCodes);
    if (next.contains(categoryCode)) {
      next.remove(categoryCode);
    } else {
      next.add(categoryCode);
    }
    emit(state.copyWith(grantedCodes: next, clearError: true));
  }

  void showCustomize() {
    emit(state.copyWith(isCustomizing: true));
  }

  Future<void> acceptAll() {
    final banner = state.banner;
    if (banner == null) {
      return Future.value();
    }
    return _submit({
      for (final category in banner.categories) category.categoryCode,
    });
  }

  Future<void> rejectOptional() {
    final banner = state.banner;
    if (banner == null) {
      return Future.value();
    }
    return _submit({
      for (final category in banner.categories)
        if (category.isEssential) category.categoryCode,
    });
  }

  Future<void> saveCustom() {
    return _submit(state.grantedCodes);
  }

  Future<void> _submit(Set<String> granted) async {
    final banner = state.banner;
    if (banner == null) {
      return;
    }
    emit(state.copyWith(
        status: CookieBannerStatus.submitting, clearError: true));
    final result = await _client.submitCookiePreferences(
      banner: banner,
      grantedCategoryCodes: granted,
      pageUrl: pageUrl,
    );
    result.fold(
      onSuccess: (preference) => emit(
        state.copyWith(
          status: CookieBannerStatus.success,
          preference: preference,
          grantedCodes: granted,
        ),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          status: CookieBannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
