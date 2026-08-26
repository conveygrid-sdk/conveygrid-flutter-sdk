import 'package:equatable/equatable.dart';

sealed class ConveyGridEvent extends Equatable {
  const ConveyGridEvent();

  @override
  List<Object?> get props => [];
}

final class ConsentLoaded extends ConveyGridEvent {
  const ConsentLoaded({required this.noticeCode, required this.purposeCount});
  final String noticeCode;
  final int purposeCount;

  @override
  List<Object?> get props => [noticeCode, purposeCount];
}

final class ConsentGranted extends ConveyGridEvent {
  const ConsentGranted({required this.grantedPurposeCount});
  final int grantedPurposeCount;

  @override
  List<Object?> get props => [grantedPurposeCount];
}

final class ConsentRejected extends ConveyGridEvent {
  const ConsentRejected();
}

final class ConsentUpdated extends ConveyGridEvent {
  const ConsentUpdated({required this.grantedPurposeCount});
  final int grantedPurposeCount;

  @override
  List<Object?> get props => [grantedPurposeCount];
}

final class ConsentWithdrawn extends ConveyGridEvent {
  const ConsentWithdrawn({required this.withdrawnPurposeCount});
  final int withdrawnPurposeCount;

  @override
  List<Object?> get props => [withdrawnPurposeCount];
}

final class ConsentFailed extends ConveyGridEvent {
  const ConsentFailed({required this.message, this.statusCode});
  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class CookiePreferencesUpdated extends ConveyGridEvent {
  const CookiePreferencesUpdated({required this.grantedCategoryCount});
  final int grantedCategoryCount;

  @override
  List<Object?> get props => [grantedCategoryCount];
}
