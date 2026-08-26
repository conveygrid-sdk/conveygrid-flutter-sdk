import 'package:equatable/equatable.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_category.dart';

final class CookieBanner extends Equatable {
  const CookieBanner({
    required this.bannerConfigId,
    required this.configCode,
    required this.bannerTitle,
    required this.bannerDescription,
    required this.aboutContent,
    required this.version,
    required this.showAcceptAll,
    required this.showDeclineAll,
    required this.showCustomise,
    required this.preferenceExpiryDays,
    required this.categories,
  });

  final String bannerConfigId;
  final String configCode;
  final String bannerTitle;
  final String bannerDescription;
  final String aboutContent;
  final String version;
  final bool showAcceptAll;
  final bool showDeclineAll;
  final bool showCustomise;
  final int preferenceExpiryDays;
  final List<CookieCategory> categories;

  @override
  List<Object?> get props => [bannerConfigId, configCode, version, categories];
}
