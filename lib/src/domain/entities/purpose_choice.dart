import 'package:equatable/equatable.dart';

final class PurposeChoice extends Equatable {
  const PurposeChoice({
    required this.purposeId,
    required this.granted,
  });

  final String purposeId;
  final bool granted;

  Map<String, dynamic> toJson() => {
        'purpose_id': purposeId,
        'granted': granted,
      };

  @override
  List<Object?> get props => [purposeId, granted];
}
