import 'package:drim_ai/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('skill celebration route renders without extra data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go('/celebration/skill');
    await tester.pumpAndSettle();

    expect(find.text('NEXT SKILL'), findsOneWidget);
  });
}
