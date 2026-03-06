import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/usecases/get_popular_product_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late GetPopularProductsUsecase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = GetPopularProductsUsecase(productRepository: repository);
  });

  final products = [
    ProductEntity(
      id: 'p1',
      name: 'Apple',
      price: 120,
      image: 'apple.png',
      description: 'Fresh apple',
      category: 'Fruits',
      inStock: 15,
      nutritionalInfo: 'Vitamin C',
      quantity: 1,
    ),
    ProductEntity(
      id: 'p2',
      name: 'Orange',
      price: 150,
      image: 'orange.png',
      description: 'Fresh orange',
      category: 'Fruits',
      inStock: 20,
      nutritionalInfo: 'Vitamin C',
      quantity: 1,
    ),
  ];

  test('returns popular products when repository call succeeds', () async {
    when(
      () => repository.getPopularProducts(),
    ).thenAnswer((_) async => Right(products));

    final result = await usecase();

    expect(result, Right(products));
    verify(() => repository.getPopularProducts()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns failure when repository call fails', () async {
    final failure = ApiFailure(message: 'Failed to fetch popular products');

    when(
      () => repository.getPopularProducts(),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left(failure));
    verify(() => repository.getPopularProducts()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
