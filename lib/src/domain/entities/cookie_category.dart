import 'package:equatable/equatable.dart';

final class CookieCategory extends Equatable {
  const CookieCategory({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.description,
    required this.isEssential,
    required this.displayOrder,
    required this.isActive,
  });

  final String categoryId;
  final String categoryCode;
  final String categoryName;
  final String description;
  final bool isEssential;
  final int displayOrder;
  final bool isActive;

  @override
  List<Object?> get props => [categoryId, categoryCode, isEssential];
}
