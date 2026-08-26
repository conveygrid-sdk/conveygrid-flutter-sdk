import 'package:equatable/equatable.dart';

final class CookieCategoryChoice extends Equatable {
  const CookieCategoryChoice({
    required this.categoryCode,
    required this.granted,
  });

  final String categoryCode;
  final bool granted;

  Map<String, dynamic> toJson() => {
        'category_code': categoryCode,
        'granted': granted,
      };

  @override
  List<Object?> get props => [categoryCode, granted];
}

final class CookiePreference extends Equatable {
  const CookiePreference({
    required this.choices,
    required this.version,
    this.preferenceToken,
    this.recordedAt,
  });

  final List<CookieCategoryChoice> choices;
  final String version;
  final String? preferenceToken;
  final DateTime? recordedAt;

  bool isGranted(String categoryCode) {
    for (final choice in choices) {
      if (choice.categoryCode == categoryCode) {
        return choice.granted;
      }
    }
    return false;
  }

  Map<String, bool> get asMap => {
        for (final choice in choices) choice.categoryCode: choice.granted,
      };

  @override
  List<Object?> get props => [choices, version, preferenceToken];
}
