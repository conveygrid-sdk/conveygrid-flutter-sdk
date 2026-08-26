import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conveygrid_flutter_sdk/conveygrid_flutter_sdk.dart';

void main() {
  testWidgets('purpose tile does not preselect optional purposes',
      (tester) async {
    const purpose = ConsentPurpose(
      noticePurposeId: 'np',
      purposeId: 'p1',
      purposeCode: 'MARKETING_OFFERS',
      purposeName: 'Marketing',
      purposeDescription: 'Optional marketing',
      isMandatory: false,
      validityDays: 30,
      retentionDays: 30,
      displayOrder: 1,
      alreadyGranted: false,
      categories: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConveyGridPurposeTile(
            purpose: purpose,
            selected: false,
            onChanged: null,
            theme: ConveyGridTheme(),
          ),
        ),
      ),
    );

    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isFalse);
    expect(find.text('Optional'), findsOneWidget);
  });
}
