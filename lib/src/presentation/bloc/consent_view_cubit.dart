import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/usecases/consent_choice_factory.dart';
import 'package:conveygrid_flutter_sdk/src/client/convey_grid_client.dart';

final class ConsentViewState extends Equatable {
  const ConsentViewState({
    required this.notice,
    required this.grantedOptionalIds,
    this.isSubmitting = false,
    this.isCustomizing = false,
    this.errorMessage,
    this.result,
  });

  final ConsentNotice notice;
  final Set<String> grantedOptionalIds;
  final bool isSubmitting;
  final bool isCustomizing;
  final String? errorMessage;
  final ConsentSubmitResult? result;

  ConsentViewState copyWith({
    Set<String>? grantedOptionalIds,
    bool? isSubmitting,
    bool? isCustomizing,
    String? errorMessage,
    ConsentSubmitResult? result,
    bool clearError = false,
  }) {
    return ConsentViewState(
      notice: notice,
      grantedOptionalIds: grantedOptionalIds ?? this.grantedOptionalIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCustomizing: isCustomizing ?? this.isCustomizing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        notice,
        grantedOptionalIds,
        isSubmitting,
        isCustomizing,
        errorMessage,
        result,
      ];
}

final class ConsentViewCubit extends Cubit<ConsentViewState> {
  ConsentViewCubit({
    required ConveyGridClient client,
    required ConsentNotice notice,
    required this.subject,
    this.pageUrl,
  })  : _client = client,
        super(
          ConsentViewState(
            notice: notice,
            grantedOptionalIds: <String>{},
          ),
        );

  final ConveyGridClient _client;
  final ConveyGridSubject? subject;
  final String? pageUrl;

  void toggleOptional(String purposeId) {
    final next = Set<String>.from(state.grantedOptionalIds);
    if (next.contains(purposeId)) {
      next.remove(purposeId);
    } else {
      next.add(purposeId);
    }
    emit(state.copyWith(grantedOptionalIds: next, clearError: true));
  }

  void showCustomize() {
    emit(state.copyWith(isCustomizing: true, clearError: true));
  }

  Future<void> acceptAll() {
    return _submit(
      ConsentChoiceFactory.acceptAll(state.notice),
    );
  }

  Future<void> rejectOptional() {
    return _submit(
      ConsentChoiceFactory.rejectOptional(state.notice),
    );
  }

  Future<void> saveCustom() {
    return _submit(
      ConsentChoiceFactory.fromSelection(
        notice: state.notice,
        grantedPurposeIds: state.grantedOptionalIds,
      ),
    );
  }

  Future<void> _submit(List<PurposeChoice> choices) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _client.submitConsent(
      notice: state.notice,
      choices: choices,
      subject: subject,
      pageUrl: pageUrl,
    );
    result.fold(
      onSuccess: (value) => emit(
        state.copyWith(isSubmitting: false, result: value),
      ),
      onFailure: (failure) => emit(
        state.copyWith(isSubmitting: false, errorMessage: failure.message),
      ),
    );
  }
}
