import 'package:equatable/equatable.dart';

final class ConveyGridSubject extends Equatable {
  const ConveyGridSubject({
    this.sessionId,
    this.referenceId,
    this.email,
    this.mobile,
    this.fullName,
    this.language,
  });

  final String? sessionId;
  final String? referenceId;
  final String? email;
  final String? mobile;
  final String? fullName;
  final String? language;

  ConveyGridSubject copyWith({
    String? sessionId,
    String? referenceId,
    String? email,
    String? mobile,
    String? fullName,
    String? language,
  }) {
    return ConveyGridSubject(
      sessionId: sessionId ?? this.sessionId,
      referenceId: referenceId ?? this.referenceId,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      fullName: fullName ?? this.fullName,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        referenceId,
        email,
        mobile,
        fullName,
        language,
      ];
}
