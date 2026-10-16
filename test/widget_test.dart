import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_app/main.dart';

void main() {
  testWidgets('App shows welcome screen with shop name', (WidgetTester tester) async {
    await tester.pumpWidget(const SupermercadoApp());
    await tester.pump();

    expect(find.text('Mercado Full'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
