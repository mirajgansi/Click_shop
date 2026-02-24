import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/home_screen.dart'; // ✅ adjust path
import 'package:click_shop/features/product/presentation/state/product_state.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/skeleton_product_card_widget.dart';

import 'package:click_shop/core/providers/socket_service_provider.dart';
import 'package:click_shop/core/services/connectivity/socket_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// --------------------
/// Fake SocketService (so dispose() doesn't crash)
/// --------------------
class FakeSocketService implements SocketService {
  @override
  void disconnect() {}

  @override
  void connect(String userId) {
    // TODO: implement connect
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement notificationStream
  Stream<dynamic> get notificationStream => throw UnimplementedError();
}

/// --------------------
/// Fake ProductViewModel (avoid late usecases/backend)
/// --------------------
/// NOTE: This EXTENDS your real ProductViewModel so it matches the provider type.
class FakeProductViewModel extends ProductViewModel {
  FakeProductViewModel(this.initialState);

  final ProductState initialState;

  int initHomeCalls = 0;
  int searchCalls = 0;
  String? lastSearch;

  @override
  ProductState build() {
    return initialState;
  }

  @override
  Future<void> initHome() async {
    initHomeCalls++;
  }

  @override
  Future<void> search(String query) async {
    searchCalls++;
    lastSearch = query;
  }

  @override
  Future<void> loadTrending() async {}

  @override
  Future<void> loadPopular() async {}
}

Widget wrap(FakeProductViewModel vm) {
  return ProviderScope(
    overrides: [
      productViewModelProvider.overrideWith(() => vm),
      socketServiceProvider.overrideWithValue(FakeSocketService()),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeScreen())),
  );
}

Future<void> pumpHome(WidgetTester tester, FakeProductViewModel vm) async {
  await tester.pumpWidget(wrap(vm));
  await tester.pump();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('calls initHome once on first build', (tester) async {
    // Use whatever your ProductState type is; dynamic is used in fake above.
    // It MUST have: isLoading, allProducts
    final fakeState = _FakeProductState(
      isLoading: false,
      allProducts: const [],
    );

    final vm = FakeProductViewModel(
      ProductState(
        isLoading: false,
        allProducts: [],
        error: '',
        categoryProducts: [],
        selectedProduct: null,
        isRecentLoading: false,
        isTrendingLoading: false,
        isPopularLoading: false,
        isTopRatedLoading: false,
        recentProducts: [],
        trendingProducts: [],
        popularProducts: [],
        topRatedProducts: [],
      ),
    );

    await pumpHome(tester, vm);

    expect(vm.initHomeCalls, 1);
  });

  testWidgets('not loading + empty -> shows "No products"', (tester) async {
    final fakeState = _FakeProductState(
      isLoading: false,
      allProducts: const [],
    );
    final vm = FakeProductViewModel(
      ProductState(
        isLoading: false,
        allProducts: [],
        error: '',
        categoryProducts: [],
        selectedProduct: null,
        isRecentLoading: false,
        isTrendingLoading: false,
        isPopularLoading: false,
        isTopRatedLoading: false,
        recentProducts: [],
        trendingProducts: [],
        popularProducts: [],
        topRatedProducts: [],
      ),
    );

    await pumpHome(tester, vm);

    expect(find.text('No products'), findsOneWidget);
  });

  testWidgets('typing search -> calls search(query)', (tester) async {
    final fakeState = _FakeProductState(
      isLoading: false,
      allProducts: const [],
    );
    final vm = FakeProductViewModel(
      ProductState(
        isLoading: false,
        allProducts: [],
        error: '',
        categoryProducts: [],
        selectedProduct: null,
        isRecentLoading: false,
        isTrendingLoading: false,
        isPopularLoading: false,
        isTopRatedLoading: false,
        recentProducts: [],
        trendingProducts: [],
        popularProducts: [],
        topRatedProducts: [],
      ),
    );
    await pumpHome(tester, vm);

    await tester.enterText(find.byType(TextField), 'app');
    await tester.pump();

    expect(vm.searchCalls, 1);
    expect(vm.lastSearch, 'app');
  });

  testWidgets('clear search (close icon) -> calls initHome', (tester) async {
    final fakeState = _FakeProductState(
      isLoading: false,
      allProducts: const [],
    );
    final vm = FakeProductViewModel(
      ProductState(
        isLoading: false,
        allProducts: [],
        error: '',
        categoryProducts: [],
        selectedProduct: null,
        isRecentLoading: false,
        isTrendingLoading: false,
        isPopularLoading: false,
        isTopRatedLoading: false,
        recentProducts: [],
        trendingProducts: [],
        popularProducts: [],
        topRatedProducts: [],
      ),
    );

    await pumpHome(tester, vm);
    expect(vm.initHomeCalls, 1);

    // type something so close icon appears
    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pump();

    // tap the close icon in suffixIcon
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(vm.initHomeCalls, greaterThanOrEqualTo(2));
  });

  testWidgets('searching with no local matches -> shows No results for "q"', (
    tester,
  ) async {
    // put products that won't match "zzz"
    final p = _FakeProductEntity(id: '1', name: 'Apple');
    final fakeState = _FakeProductState(isLoading: false, allProducts: [p]);
    final vm = FakeProductViewModel(
      ProductState(
        isLoading: false,
        allProducts: [],
        error: '',
        categoryProducts: [],
        selectedProduct: null,
        isRecentLoading: false,
        isTrendingLoading: false,
        isPopularLoading: false,
        isTopRatedLoading: false,
        recentProducts: [],
        trendingProducts: [],
        popularProducts: [],
        topRatedProducts: [],
      ),
    );

    await pumpHome(tester, vm);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();

    expect(find.text('No results for "zzz"'), findsOneWidget);
  });
}

/// ---------------------------------------------------------------------------
/// IMPORTANT: These are tiny fakes so the test compiles without your real state.
/// Replace them with your real ProductState/ProductEntity if you want.
/// ---------------------------------------------------------------------------

class _FakeProductState {
  final bool isLoading;
  final List<ProductEntity> allProducts;
  const _FakeProductState({required this.isLoading, required this.allProducts});
}

/// Minimal ProductEntity fake (only fields HomeScreen uses: id, name)
class _FakeProductEntity implements ProductEntity {
  @override
  final String? id;
  @override
  final String name;

  _FakeProductEntity({required this.id, required this.name});

  // ----- everything else from ProductEntity can throw if accessed -----
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
