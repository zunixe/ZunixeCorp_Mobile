import 'package:flutter_test/flutter_test.dart';

import 'package:zunixe_corp_mobile/main.dart';

void main() {
  testWidgets('App renders MainShell', (WidgetTester tester) async {
    await tester.pumpWidget(const ZunixeApp());
    expect(find.text('zunixe'), findsWidgets);
  });
}
