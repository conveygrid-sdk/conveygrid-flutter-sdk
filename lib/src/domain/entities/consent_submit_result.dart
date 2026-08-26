import 'package:equatable/equatable.dart';

final class ConsentSubmitResult extends Equatable {
  const ConsentSubmitResult({
    required this.allMandatoryGranted,
    required this.linkRequired,
    this.artifactId,
    this.subjectId,
    this.preferenceToken,
    this.status,
    this.linkExpiresAt,
  });

  final bool allMandatoryGranted;
  final bool linkRequired;
  final String? artifactId;
  final String? subjectId;
  final String? preferenceToken;
  final String? status;
  final String? linkExpiresAt;

  @override
  List<Object?> get props => [
        allMandatoryGranted,
        linkRequired,
        artifactId,
        status,
      ];
}
