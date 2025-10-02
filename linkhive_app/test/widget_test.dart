// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:linkhive_app/main.dart';
import 'package:linkhive_app/providers/auth_provider.dart';
import 'package:linkhive_app/providers/link_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LinkProvider()),
        ],
        child: const LinkHiveApp(), // Changed from MyApp to LinkHiveApp
      ),
    );

    // Verify that our app starts with the splash screen
    expect(find.text('LinkHive'), findsOneWidget);
    expect(find.text('Personal Link Management'), findsOneWidget);

    // Since this is a link management app, let's test for relevant elements
    // You can expand these tests based on your app's functionality
  });

  testWidgets('LinkHive app smoke test', (WidgetTester tester) async {
    // Test that the app builds without throwing
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LinkProvider()),
        ],
        child: const LinkHiveApp(),
      ),
    );

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify the splash screen elements are present
    expect(find.byIcon(Icons.link), findsOneWidget);
    expect(find.text('LinkHive'), findsOneWidget);
  });
}