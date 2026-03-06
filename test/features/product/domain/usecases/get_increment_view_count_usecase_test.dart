import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/usecases/get_increment_view_count_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late IncrementViewCountUsecase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = IncrementViewCountUsecase(repository);
  });

  const productId = 'p1';

  test(
    'returns true when repository increments view count successfully',
    () async {
      when(
        () => repository.incrementViewCount(productId),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(productId);

      expect(result, const Right(true));
      verify(() => repository.incrementViewCount(productId)).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test('returns failure when repository increment fails', () async {
    final failure = ApiFailure(message: 'Failed to increment view count');

    when(
      () => repository.incrementViewCount(productId),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase(productId);

    expect(result, Left(failure));
    verify(() => repository.incrementViewCount(productId)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
