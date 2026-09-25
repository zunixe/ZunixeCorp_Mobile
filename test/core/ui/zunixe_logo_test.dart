import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';

void main() {
  Finder logoPaint() => find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.painter != null &&
            w.painter.runtimeType.toString().contains('ZunixeRobot'),
      );

  testWidgets('render CustomPaint dengan size benar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: ZunixeLogo(size: 72))),
      ),
    );
    expect(logoPaint(), findsOneWidget);
    final box = tester.getSize(find.byType(ZunixeLogo));
    expect(box.width, 72);
    expect(box.height, 72);
  });

  testWidgets('default size 40', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ZunixeLogo()),
      ),
    );
    final box = tester.getSize(find.byType(ZunixeLogo));
    expect(box.width, 40);
  });

  testWidgets('shouldRepaint false (tidak repaint sia-sia)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ZunixeLogo(size: 40))),
    );
    final customPaint = tester.widget<CustomPaint>(logoPaint());
    final painter = customPaint.painter!;
    expect(painter.shouldRepaint(painter), isFalse);
  });
}
