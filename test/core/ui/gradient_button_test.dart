import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required String label,
    VoidCallback? onPressed,
    bool loading = false,
    bool expanded = true,
    IconData? icon,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            label: label,
            onPressed: onPressed,
            loading: loading,
            expanded: expanded,
            icon: icon,
          ),
        ),
      ),
    );
  }

  testWidgets('menampilkan label', (tester) async {
    await pump(tester, label: 'Masuk', onPressed: () {});
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('tap memanggil onPressed', (tester) async {
    var tapped = false;
    await pump(tester, label: 'OK', onPressed: () => tapped = true);
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('loading -> spinner, tap no-op', (tester) async {
    var tapped = false;
    await pump(tester,
        label: 'Masuk', loading: true, onPressed: () => tapped = true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Masuk'), findsNothing);
    await tester.tap(find.byType(GradientButton));
    await tester.pump();
    expect(tapped, isFalse);
  });

  testWidgets('onPressed null -> tidak interaktif', (tester) async {
    await pump(tester, label: 'Checkout');
    expect(find.text('Checkout'), findsOneWidget);
    // InkWell disabled: tidak ada efek tap, dan tidak throw.
    await tester.tap(find.text('Checkout'));
    await tester.pump();
  });

  testWidgets('icon tampil bila diberikan', (tester) async {
    await pump(tester,
        label: 'Lihat', icon: Icons.receipt_long, onPressed: () {});
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
  });

  testWidgets('tanpa icon -> tidak ada Icon', (tester) async {
    await pump(tester, label: 'Lihat', onPressed: () {});
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('expanded=false -> tidak full width', (tester) async {
    await pump(tester, label: 'Kecil', expanded: false, onPressed: () {});
    // expanded=true membungkus SizedBox width tak terbatas.
    final sized = tester
        .widgetList<SizedBox>(find.ancestor(
          of: find.byType(Material),
          matching: find.byType(SizedBox),
        ))
        .toList();
    final hasInfinity = sized.any(
        (s) => s.width == double.infinity);
    expect(hasInfinity, isFalse);
  });
}
