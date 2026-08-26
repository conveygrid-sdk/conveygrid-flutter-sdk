import 'package:equatable/equatable.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_purpose.dart';

final class ConsentNoticeTheme extends Equatable {
  const ConsentNoticeTheme({
    required this.themeId,
    required this.themeName,
    required this.primaryColor,
    required this.secondaryColor,
    this.fontFamily,
  });

  final String themeId;
  final String themeName;
  final String primaryColor;
  final String secondaryColor;
  final String? fontFamily;

  @override
  List<Object?> get props => [themeId, primaryColor, secondaryColor];
}

final class ConsentNotice extends Equatable {
  const ConsentNotice({
    required this.noticeId,
    required this.noticeCode,
    required this.noticeName,
    required this.version,
    required this.status,
    required this.introductionText,
    required this.rightsText,
    required this.contactInformation,
    required this.footerText,
    required this.supportsMinors,
    required this.showNotice,
    required this.purposes,
    this.theme,
    this.alreadyGrantedPurposeIds = const [],
  });

  final String noticeId;
  final String noticeCode;
  final String noticeName;
  final String version;
  final String status;
  final String introductionText;
  final String rightsText;
  final String contactInformation;
  final String footerText;
  final bool supportsMinors;
  final bool showNotice;
  final List<ConsentPurpose> purposes;
  final ConsentNoticeTheme? theme;
  final List<String> alreadyGrantedPurposeIds;

  List<ConsentPurpose> get mandatoryPurposes =>
      purposes.where((p) => p.isMandatory).toList();

  List<ConsentPurpose> get optionalPurposes =>
      purposes.where((p) => !p.isMandatory).toList();

  @override
  List<Object?> get props => [noticeId, noticeCode, version, purposes];
}
