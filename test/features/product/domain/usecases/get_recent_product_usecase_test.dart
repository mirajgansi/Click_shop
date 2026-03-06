import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/usecases/get_recent_product_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late GetRecentProductsUsecase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = GetRecentProductsUsecase(productRepository: repository);
  });

  final products = [
    ProductEntity(
      id: 'p1',
      name: 'Apple',
      price: 100,
      image: 'apple.png',
      description: 'Fresh apple',
      category: 'Fruits',
      inStock: 10,
      nutritionalInfo: 'Vitamin C',
      quantity: 1,
    ),
    ProductEntity(
      id: 'p2',
      name: 'Banana',
      price: 80,
      image: 'banana.png',
      description: 'Fresh banana',
      category: 'Fruits',
      inStock: 20,
      nutritionalInfo: 'Potassium',
      quantity: 1,
    ),
  ];

  test('returns recent products when repository call succeeds', () async {
    when(
      () => repository.getRecentProducts(),
    ).thenAnswer((_) async => Right(products));

    final result = await usecase();

    expect(result, Right(products));
    verify(() => repository.getRecentProducts()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns failure when repository call fails', () async {
    final failure = ApiFailure(message: 'Failed to fetch recent products');

    when(
      () => repository.getRecentProducts(),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left(failure));
    verify(() => repository.getRecentProducts()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
