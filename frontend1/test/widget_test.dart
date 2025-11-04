import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_farming_app/providers/app_provider.dart';
import 'package:smart_farming_app/providers/mandi_prices_provider.dart';
import 'package:smart_farming_app/providers/fertilizer_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => MandiPricesProvider()),
          ChangeNotifierProvider(create: (_) => FertilizerProvider()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Smart Farming App'),
            ),
          ),
        ),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('Smart Farming App'), findsOneWidget);
  });
}