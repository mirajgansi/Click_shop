import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:click_shop/features/product/presentation/state/product_state.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/core/providers/socket_service_provider.dart';
import 'package:click_shop/core/services/connectivity/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// ---------------- Mocks ----------------
class MockSocketService extends Mock implements SocketService {}

class FakeProductViewModel extends ProductViewModel {
  int initHomeCalls = 0;
  int searchCalls = 0;
  int loadTrendingCalls = 0;
  int loadPopularCalls = 0;
  String? lastSearch;

  @override
  ProductState build() {
    return ProductState.initial();
  }

  @override
  Future<void> initHome() async => initHomeCalls++;

  @override
  Future<void> search(String query) async {
    searchCalls++;
    lastSearch = query;
  }

  @override
  Future<void> loadTrending() async => loadTrendingCalls++;

  @override
  Future<void> loadPopular() async => loadPopularCalls++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSocketService socket;
  late FakeProductViewModel fakeVm;

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        // override socket service
        socketServiceProvider.overrideWithValue(socket),

        // override your NotifierProvider with our fake notifier
        productViewModelProvider.overrideWith(() => fakeVm),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  setUp(() {
    socket = MockSocketService();
    fakeVm = FakeProductViewModel();

    when(() => socket.disconnect()).thenReturn(null);
  });

  testWidgets('HomeScreen calls initHome once on first build', (tester) async {
    await tester.pumpWidget(buildTestApp());

    // didChangeDependencies triggers microtask -> pump once more
    await tester.pump();

    expect(fakeVm.initHomeCalls, 1);

    // Rebuild again - should not call again because _booted prevents it
    await tester.pump();
    expect(fakeVm.initHomeCalls, 1);
  });

  testWidgets('Typing in search calls search(query); clearing calls initHome', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(); // run initHome microtask

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'milk');
    await tester.pump();

    expect(fakeVm.searchCalls, 1);
    expect(fakeVm.lastSearch, 'milk');

    // Tap the "close" icon to clear (only appears when isSearching)
    final closeBtn = find.byIcon(Icons.close);
    expect(closeBtn, findsOneWidget);

    await tester.tap(closeBtn);
    await tester.pump();

    // your code calls initHome after clearing
    expect(fakeVm.initHomeCalls, 2); // 1 from boot + 1 from clear
  });

  testWidgets('Pull-to-refresh calls initHome, loadTrending, loadPopular', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(); // run initHome microtask

    // RefreshIndicator needs a scrollable drag down
    final scroll = find.byType(CustomScrollView);
    expect(scroll, findsOneWidget);

    await tester.fling(scroll, const Offset(0, 400), 1000);
    await tester.pump(); // start refresh
    await tester.pump(const Duration(seconds: 1)); // let it settle

    // your onRefresh: initHome + loadTrending + loadPopular
    expect(fakeVm.initHomeCalls >= 2, true);
    expect(fakeVm.loadTrendingCalls, 1);
    expect(fakeVm.loadPopularCalls, 1);
  });

  testWidgets('dispose calls socket.disconnect', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(); // run initHome microtask

    // remove widget from tree -> triggers dispose
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    verify(() => socket.disconnect()).called(1);
  });
}
