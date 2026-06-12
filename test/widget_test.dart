import 'package:flutter_test/flutter_test.dart';

import 'package:historyguessr/main.dart';

void main() {
  testWidgets('Game screen renders main UI', (WidgetTester tester) async {
    await tester.pumpWidget(const HistoryGuessrApp());

    expect(find.text('HistoryGuessr'), findsOneWidget);
    expect(find.text('GUESS'), findsOneWidget);
  });
}
