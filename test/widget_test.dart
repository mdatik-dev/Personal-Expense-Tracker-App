import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/widgets/summary_card.dart';

void main() {
  testWidgets('summary card displays its title and formatted amount',
      (WidgetTester tester) async {
    const card = SummaryCard(
      title: 'Total Income',
      amount: 1250.50,
      icon: Icons.south_west_rounded,
      color: Color(0xFF159D76),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: card,
        ),
      ),
    );

    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text(card.formattedAmount), findsOneWidget);
  });
}
