// import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
// import 'package:click_shop/features/product/presentation/state/product_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
// import 'package:click_shop/core/providers/socket_service_provider.dart';
// import 'package:click_shop/core/services/connectivity/socket_service.dart';

// import 'package:click_shop/features/product/domain/entities/product_entity.dart';
// import 'package:click_shop/features/dashboard/presentation/widgets/skeleton_product_card_widget.dart';
// import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';

// // ----- fakes -----
// class FakeSocketService implements SocketService {
//   bool disconnected = false;

//   @override
//   void disconnect() {
//     disconnected = true;
//   }

//   @override
//   void connect(String userId) {
//     // TODO: implement connect
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//   }

//   @override
//   // TODO: implement notificationStream
//   Stream<dynamic> get notificationStream => throw UnimplementedError();
// }

// // ✅ Replace ProductState with your real state type import
// class FakeProductViewModel extends Notifier<ProductState> {
//   int initHomeCalls = 0;
//   int searchCalls = 0;
//   String? lastSearch;

//   final ProductState initial;

//   FakeProductViewModel(this.initial);

//   @override
//   ProductState build() => initial;

//   Future<void> initHome() async {
//     initHomeCalls++;
//   }

//   Future<void> loadTrending() async {}
//   Future<void> loadPopular() async {}

//   Future<void> search(String query) async {
//     searchCalls++;
//     lastSearch = query;
//   }
// }

// Widget _wrap(Widget child, {required List<Override> overrides}) {
//   return ProviderScope(
//     overrides: overrides,
//     child: MaterialApp(home: child),
//   );
// }

// void main() {
//   testWidgets('shows skeleton grid when state.isLoading = true', (
//     tester,
//   ) async {
//     final fakeSocket = FakeSocketService();

//     // ✅ Build a loading state (adjust fields to your ProductState)
//     final loadingState = ProductState(
//       isLoading: true,
//       allProducts: const [],
//       error: '',
//       categoryProducts: [],
//       selectedProduct: null,
//       isRecentLoading: null,
//       isTrendingLoading: null,
//       isPopularLoading: null,
//       isTopRatedLoading: null,
//       recentProducts: [],
//       trendingProducts: [],
//       popularProducts: [],
//       topRatedProducts: [],
//       // ... add other required fields in your state constructor
//     );

//     final fakeVm = FakeProductViewModel(loadingState);

//     await tester.pumpWidget(
//       _wrap(
//         const HomeScreen(),
//         overrides: [
//           socketServiceProvider.overrideWithValue(fakeSocket),
//           productViewModelProvider.overrideWith(() => fakeVm),
//         ],
//       ),
//     );

//     // let didChangeDependencies microtask run
//     await tester.pump();

//     expect(find.byType(ProductCardSkeleton), findsWidgets);
//   });

//   testWidgets('shows "No products" when not loading and list empty', (
//     tester,
//   ) async {
//     final fakeSocket = FakeSocketService();

//     final emptyState = ProductState(
//       isLoading: false,
//       allProducts: const [],
//       error: '',
//       categoryProducts: [],
//       selectedProduct: null,
//       isRecentLoading: false,
//       isTrendingLoading: false,
//       isPopularLoading: false,
//       isTopRatedLoading: false,
//       recentProducts: [],
//       trendingProducts: [],
//       popularProducts: [],
//       topRatedProducts: [],
//     );

//     final fakeVm = FakeProductViewModel(emptyState);

//     await tester.pumpWidget(
//       _wrap(
//         const HomeScreen(),
//         overrides: [
//           socketServiceProvider.overrideWithValue(fakeSocket),
//           productViewModelProvider.overrideWith(() => fakeVm),
//         ],
//       ),
//     );

//     await tester.pump();

//     expect(find.text('All Products'), findsOneWidget);
//     expect(find.text('No products'), findsOneWidget);
//   });

//   testWidgets('shows products grid when products exist', (tester) async {
//     final fakeSocket = FakeSocketService();

//     final products = [
//       ProductEntity(
//         id: '1',
//         name: 'Apple',
//         description: '',
//         price: 12,
//         inStock: 12,
//         category: '',
//         nutritionalInfo: '',
//         image: '' /* fill required fields */,
//       ),
//       ProductEntity(
//         id: '2',
//         name: 'Banana',
//         description: '',
//         price: 33,
//         inStock: 22,
//         category: '',
//         nutritionalInfo: '',
//         image: '' /* fill required fields */,
//       ),
//     ];

//     final state = ProductState(isLoading: false, allProducts: products);

//     final fakeVm = FakeProductViewModel(state);

//     await tester.pumpWidget(
//       _wrap(
//         const HomeScreen(),
//         overrides: [
//           socketServiceProvider.overrideWithValue(fakeSocket),
//           productViewModelProvider.overrideWith(() => fakeVm),
//         ],
//       ),
//     );

//     await tester.pump();

//     expect(find.byType(CardWidget), findsWidgets);
//   });

//   testWidgets(
//     'typing in search calls search(query) and shows Search Results title',
//     (tester) async {
//       final fakeSocket = FakeSocketService();

//       final products = [
//         ProductEntity(id: '1', name: 'Apple' /* required fields */),
//       ];

//       final state = ProductState(isLoading: false, allProducts: products);

//       final fakeVm = FakeProductViewModel(state);

//       await tester.pumpWidget(
//         _wrap(
//           const HomeScreen(),
//           overrides: [
//             socketServiceProvider.overrideWithValue(fakeSocket),
//             productViewModelProvider.overrideWith(() => fakeVm),
//           ],
//         ),
//       );

//       await tester.pump();

//       // enter search text
//       await tester.enterText(find.byType(TextField), 'app');
//       await tester.pump();

//       expect(fakeVm.searchCalls, 1);
//       expect(fakeVm.lastSearch, 'app');
//       expect(find.text('Search Results'), findsOneWidget);
//     },
//   );
// }
