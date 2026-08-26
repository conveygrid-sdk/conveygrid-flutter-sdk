import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'The request timed out.'});
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Consent request was not authorized.',
    super.statusCode = 401,
  });
}

final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode = 422,
  });
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong. Please try again.',
  });
}
