// import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   Future<void> pumpWithWidth(WidgetTester tester, double width) async {
//     await tester.binding.setSurfaceSize(Size(width, 800));
//     await tester.pumpWidget(
//       const MaterialApp(home: Scaffold(body: HomeScreen())),
//     );
//     await tester.pumpAndSettle();

//     addTearDown(() async {
//       await tester.binding.setSurfaceSize(null);
//     });
//   }

//   int getCrossAxisCount(WidgetTester tester) {
//     final grid = tester.widget<GridView>(find.byType(GridView));
//     final delegate =
//         grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
//     return delegate.crossAxisCount;
//   }

//   testWidgets('phone width -> crossAxisCount = 2', (tester) async {
//     await pumpWithWidth(tester, 500);
//     expect(getCrossAxisCount(tester), 2);
//   });
//   testWidgets('tablet width -> crossAxisCount = 3', (tester) async {
//     await pumpWithWidth(tester, 700);
//     expect(getCrossAxisCount(tester), 3);
//   });

//   testWidgets('desktop width -> crossAxisCount = 4', (tester) async {
//     await pumpWithWidth(tester, 1000);
//     expect(getCrossAxisCount(tester), 4);
//   });

//   testWidgets('renders 10 CardWidget items (desktop width)', (tester) async {
//     await pumpWithWidth(tester, 1000);
//     expect(find.byType(GridView), findsOneWidget);
//   });
// }
