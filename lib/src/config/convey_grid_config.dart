import 'package:conveygrid_flutter_sdk/src/config/convey_grid_environment.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_theme.dart';
import 'package:equatable/equatable.dart';

final class ConveyGridConfig extends Equatable {
  const ConveyGridConfig({
    required this.apiBaseUrl,
    required this.applicationKey,
    this.origin = '',
    this.referer = '',
    this.sendOriginRefererHeaders = true,
    this.dataFiduciaryId,
    this.environment = ConveyGridEnvironment.dev,
    this.language = 'en',
    this.timeout = const Duration(seconds: 30),
    this.enableDebugLogging = false,
    this.theme = const ConveyGridTheme(),
    this.subject,
  });

  final String apiBaseUrl;
  final String applicationKey;
  final String origin;
  final String referer;
  final bool sendOriginRefererHeaders;
  final String? dataFiduciaryId;
  final ConveyGridEnvironment environment;
  final String language;
  final Duration timeout;
  final bool enableDebugLogging;
  final ConveyGridTheme theme;
  final ConveyGridSubject? subject;

  Uri get apiBaseUri => Uri.parse(apiBaseUrl);

  @override
  List<Object?> get props => [
        apiBaseUrl,
        origin,
        referer,
        sendOriginRefererHeaders,
        dataFiduciaryId,
        environment,
        language,
        timeout,
        enableDebugLogging,
        subject,
      ];
}
