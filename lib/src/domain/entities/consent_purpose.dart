import 'package:equatable/equatable.dart';

final class ConsentDataCategory extends Equatable {
  const ConsentDataCategory({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.categoryDescription,
    required this.isMandatory,
    required this.isSensitive,
    required this.displayOrder,
  });

  final String categoryId;
  final String categoryCode;
  final String categoryName;
  final String categoryDescription;
  final bool isMandatory;
  final bool isSensitive;
  final int displayOrder;

  @override
  List<Object?> get props => [
        categoryId,
        categoryCode,
        categoryName,
        isMandatory,
        isSensitive,
        displayOrder,
      ];
}

final class ConsentPurpose extends Equatable {
  const ConsentPurpose({
    required this.noticePurposeId,
    required this.purposeId,
    required this.purposeCode,
    required this.purposeName,
    required this.purposeDescription,
    required this.isMandatory,
    required this.validityDays,
    required this.retentionDays,
    required this.displayOrder,
    required this.alreadyGranted,
    required this.categories,
  });

  final String noticePurposeId;
  final String purposeId;
  final String purposeCode;
  final String purposeName;
  final String purposeDescription;
  final bool isMandatory;
  final int? validityDays;
  final int? retentionDays;
  final int displayOrder;
  final bool alreadyGranted;
  final List<ConsentDataCategory> categories;

  @override
  List<Object?> get props => [
        noticePurposeId,
        purposeId,
        purposeCode,
        isMandatory,
        alreadyGranted,
        displayOrder,
      ];
}
