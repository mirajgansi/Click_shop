import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart'; // ✅ CHANGE PATH if needed
import 'package:click_shop/features/product/domain/usecases/ger_trending_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_all_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_category_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_increment_view_count_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_popular_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_recent_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/search_product_usecase.dart';
import 'package:click_shop/features/product/presentation/state/product_state.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// ------------------ Mocks ------------------
class MockGetAllProductsUsecase extends Mock implements GetAllProductsUsecase {}

class MockGetProductByIdUsecase extends Mock implements GetProductByIdUsecase {}

class MockGetProductsByCategoryUsecase extends Mock
    implements GetProductsByCategoryUsecase {}

class MockSearchProductsUsecase extends Mock implements SearchProductsUsecase {}

class MockGetRecentProductsUsecase extends Mock
    implements GetRecentProductsUsecase {}

class MockGetTrendingProductsUsecase extends Mock
    implements GetTrendingProductsUsecase {}

class MockGetPopularProductsUsecase extends Mock
    implements GetPopularProductsUsecase {}

class MockIncrementViewCountUsecase extends Mock
    implements IncrementViewCountUsecase {}

/// ------------------ Fakes for Params ------------------
class FakeGetByIdParams extends Fake implements GetProductByIdParams {}

class FakeSearchParams extends Fake implements SearchProductsParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetByIdParams());
    registerFallbackValue(FakeSearchParams());
  });

  ProviderContainer makeContainer({
    required MockGetAllProductsUsecase all,
    required MockGetProductByIdUsecase byId,
    required MockGetProductsByCategoryUsecase byCategory,
    required MockSearchProductsUsecase search,
    required MockGetRecentProductsUsecase recent,
    required MockGetTrendingProductsUsecase trending,
    required MockGetPopularProductsUsecase popular,
    required MockIncrementViewCountUsecase increment,
  }) {
    return ProviderContainer(
      overrides: [
        getAllProductUsecaseProvider.overrideWithValue(all),
        getProductByIdUsecaseProvider.overrideWithValue(byId),
        getProductsByCategoryUsecaseProvider.overrideWithValue(byCategory),
        searchProductsUsecaseProvider.overrideWithValue(search),
        getRecentProductsUsecaseProvider.overrideWithValue(recent),
        getTrendingProductsUsecaseProvider.overrideWithValue(trending),
        getPopularProductsUsecaseProvider.overrideWithValue(popular),
        incrementViewCountUsecaseProvider.overrideWithValue(increment),
      ],
    );
  }

  group('ProductViewModel', () {
    test(
      'loadProducts success -> sets allProducts and clears loading',
      () async {
        final mockAll = MockGetAllProductsUsecase();
        final mockById = MockGetProductByIdUsecase();
        final mockByCategory = MockGetProductsByCategoryUsecase();
        final mockSearch = MockSearchProductsUsecase();
        final mockRecent = MockGetRecentProductsUsecase();
        final mockTrending = MockGetTrendingProductsUsecase();
        final mockPopular = MockGetPopularProductsUsecase();
        final mockIncrement = MockIncrementViewCountUsecase();

        final products = <ProductEntity>[
          const ProductEntity(
            id: '1',
            name: 'P1',
            description: '',
            price: 100,
            inStock: 100,
            category: '',
            nutritionalInfo: '',
            image: '',
          ),
        ];

        when(() => mockAll()).thenAnswer((_) async => Right(products));

        final container = makeContainer(
          all: mockAll,
          byId: mockById,
          byCategory: mockByCategory,
          search: mockSearch,
          recent: mockRecent,
          trending: mockTrending,
          popular: mockPopular,
          increment: mockIncrement,
        );
        addTearDown(container.dispose);

        final vm = container.read(productViewModelProvider.notifier);
        await vm.loadProducts();

        final st = container.read(productViewModelProvider);
        expect(st.isLoading, isFalse);
        expect(st.allProducts.length, 1);
        expect(st.error, isNull);

        verify(() => mockAll()).called(1);
      },
    );

    test('loadProducts failure -> sets error and clears loading', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(() => mockAll()).thenAnswer(
        (_) async => Left(ApiFailure(message: 'fail', statusCode: 500)),
      );

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.loadProducts();

      final st = container.read(productViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.error, 'fail');
      verify(() => mockAll()).called(1);
    });

    test('loadRecent success -> sets recentProducts', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      final products = <ProductEntity>[
        const ProductEntity(
          id: '2',
          name: 'R',
          description: '',
          price: 100,
          inStock: 100,
          category: '',
          nutritionalInfo: '',
          image: '',
        ),
      ];

      when(() => mockRecent()).thenAnswer((_) async => Right(products));

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.loadRecent();

      final st = container.read(productViewModelProvider);
      expect(st.isRecentLoading, isFalse);
      expect(st.recentProducts.length, 1);
      expect(st.error, isNull);
      verify(() => mockRecent()).called(1);
    });

    test('loadTrending success -> sets trendingProducts', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(() => mockTrending()).thenAnswer(
        (_) async => Right(<ProductEntity>[
          const ProductEntity(
            id: '3',
            name: 'T',
            description: '',
            price: 200,
            inStock: 200,
            category: '',
            nutritionalInfo: '',
            image: '',
          ),
        ]),
      );

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.loadTrending();

      final st = container.read(productViewModelProvider);
      expect(st.isTrendingLoading, isFalse);
      expect(st.trendingProducts.length, 1);
      expect(st.error, isNull);
      verify(() => mockTrending()).called(1);
    });

    test('loadPopular success -> sets popularProducts', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(() => mockPopular()).thenAnswer(
        (_) async => Right(<ProductEntity>[
          const ProductEntity(
            id: '4',
            name: 'P',
            description: '',
            price: 300,
            inStock: 300,
            category: '',
            nutritionalInfo: '',
            image: '',
          ),
        ]),
      );

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.loadPopular();

      final st = container.read(productViewModelProvider);
      expect(st.isPopularLoading, isFalse);
      expect(st.popularProducts.length, 1);
      expect(st.error, isNull);
      verify(() => mockPopular()).called(1);
    });

    test('getProductById success -> sets selectedProduct', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      final product = const ProductEntity(
        id: '99',
        name: 'One',
        description: '',
        price: 400,
        inStock: 400,
        category: '',
        nutritionalInfo: '',
        image: '',
      );

      when(() => mockById(any())).thenAnswer((_) async => Right(product));

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.getProductById('99');

      final st = container.read(productViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.selectedProduct, product);
      expect(st.error, isNull);
      verify(() => mockById(any())).called(1);
    });

    test('loadProductsByCategory success -> sets categoryProducts', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(() => mockByCategory(any())).thenAnswer(
        (_) async => Right(<ProductEntity>[
          const ProductEntity(
            id: '5',
            name: 'C',
            description: '',
            price: 500,
            inStock: 500,
            category: '',
            nutritionalInfo: '',
            image: '',
          ),
        ]),
      );

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.loadProductsByCategory('cat1');

      final st = container.read(productViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.categoryProducts.length, 1);
      expect(st.error, isNull);
      verify(() => mockByCategory(any())).called(1);
    });

    test('search success -> updates allProducts', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(() => mockSearch(any())).thenAnswer(
        (_) async => Right(<ProductEntity>[
          const ProductEntity(
            id: '6',
            name: 'S',
            description: '',
            price: 900,
            inStock: 900,
            category: '',
            nutritionalInfo: '',
            image: '',
          ),
        ]),
      );

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.search('milk');

      final st = container.read(productViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.allProducts.length, 1);
      expect(st.error, isNull);
      verify(() => mockSearch(any())).called(1);
    });

    test('incrementView -> calls usecase', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(
        () => mockIncrement(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.incrementView('p1');

      verify(() => mockIncrement('p1')).called(1);
    });

    test('initHome -> triggers 4 loaders', () async {
      final mockAll = MockGetAllProductsUsecase();
      final mockById = MockGetProductByIdUsecase();
      final mockByCategory = MockGetProductsByCategoryUsecase();
      final mockSearch = MockSearchProductsUsecase();
      final mockRecent = MockGetRecentProductsUsecase();
      final mockTrending = MockGetTrendingProductsUsecase();
      final mockPopular = MockGetPopularProductsUsecase();
      final mockIncrement = MockIncrementViewCountUsecase();

      when(
        () => mockAll(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));
      when(
        () => mockRecent(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));
      when(
        () => mockTrending(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));
      when(
        () => mockPopular(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      final container = makeContainer(
        all: mockAll,
        byId: mockById,
        byCategory: mockByCategory,
        search: mockSearch,
        recent: mockRecent,
        trending: mockTrending,
        popular: mockPopular,
        increment: mockIncrement,
      );
      addTearDown(container.dispose);

      final vm = container.read(productViewModelProvider.notifier);
      await vm.initHome();

      verify(() => mockAll()).called(1);
      verify(() => mockRecent()).called(1);
      verify(() => mockTrending()).called(1);
      verify(() => mockPopular()).called(1);
    });
  });
}
