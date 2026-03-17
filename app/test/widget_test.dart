import 'package:flutter_test/flutter_test.dart';

import 'package:jobpet/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JobPetApp());
    
    expect(find.text('倾诉室'), findsOneWidget);
  });
}
