import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swim/main.dart';

void main() {
  testWidgets('MyApp exposes the expected MaterialApp shell', (tester) async {
    late MaterialApp app;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          app = const MyApp().build(context) as MaterialApp;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(app.title, 'EasySwim');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.routes, contains('/login'));
  });
}
