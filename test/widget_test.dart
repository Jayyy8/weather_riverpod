import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather_app_biometrics/app.dart';

void main() {
  testWidgets('app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeatherAppBiometrics(),
      ),
    );

    expect(find.byType(ProviderScope), findsOneWidget);
  });
}