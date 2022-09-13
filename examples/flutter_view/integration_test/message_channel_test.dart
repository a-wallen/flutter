// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_view/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('flutter view to native view test counter',
        (WidgetTester tester) async {

      /*
      The app draws itself. As the MyHomePage is initialized, the message
      handler for "increment" is initialized in the `initState` override
      for _MyHomePageState.
      */
      app.main();
      await tester.pumpAndSettle();

      int expectedNativeCount = 0;

      /*
      Intercept the incoming response by setting the message handler for `increment`
      after it's set in the application.
      */
      const BasicMessageChannel<String?>('increment', StringCodec())
        .setMessageHandler((String? message) async {
        expectedNativeCount = expectedNativeCount + 1;

        expectSync(
          message,
          isNot(null),
          reason: 'The flutter_view app should send a non-null message through the message channel',
        );

        expectSync(
          message,
          isNotEmpty,
          reason: 'The message sent through the message channel on macos should not be empty',
        );

        final int? actualNativeCount = int.tryParse(message!);

        expectSync(
          actualNativeCount,
          isNot(null),
          reason: '$message could not be parsed as an integer. A valid integer must be sent through the platform channel to ensure that the flutter_view example works.',
        );

        expectSync(
          actualNativeCount,
          equals(expectedNativeCount),
          reason: 'The actual native counter value $actualNativeCount is not equal to the expected value $expectedNativeCount',
        );

        return null;
      });

      // Finds the floating action button to tap on.
      final Finder fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      // Emulate a tap on the floating action button.
      await tester.tap(fab);

      await tester.pumpAndSettle();
    });
  });
}
