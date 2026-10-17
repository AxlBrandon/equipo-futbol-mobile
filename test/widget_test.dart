// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:equipo_futbol_mobile/main.dart';

void main() {
  testWidgets('Carga la app de Liverpool F.C.', (WidgetTester tester) async {
    // Construye la aplicación con nuestra clase LiverpoolApp
    await tester.pumpWidget(const LiverpoolApp());

    // Verifica que el título Liverpool F.C. aparezca en pantalla
    expect(find.text('Liverpool'), findsOneWidget);
  });
}
