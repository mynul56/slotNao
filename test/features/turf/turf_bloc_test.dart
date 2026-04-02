import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:turf_booking_app/core/errors/failures.dart';
import 'package:turf_booking_app/features/turf/domain/entities/turf_entity.dart';
import 'package:turf_booking_app/features/turf/domain/usecases/get_turfs_usecase.dart';
import 'package:turf_booking_app/features/turf/presentation/bloc/turf_bloc.dart';
import 'package:turf_booking_app/features/turf/presentation/bloc/turf_event.dart';
import 'package:turf_booking_app/features/turf/presentation/bloc/turf_state.dart';

class MockGetTurfsUseCase extends Mock implements GetTurfsUseCase {}
class MockGetTurfDetailUseCase extends Mock implements GetTurfDetailUseCase {}
class MockSearchTurfsUseCase extends Mock implements SearchTurfsUseCase {}

const tTurf = TurfEntity(
  id: 'turf-001',
  name: 'Dhaka Premier Turf',
  description: 'Best turf in Dhaka',
  address: 'Gulshan, Dhaka',
  latitude: 23.7935,
  longitude: 90.4066,
  imageUrls: ['https://example.com/img.jpg'],
  pricePerHour: 1200,
  amenities: ['Parking', 'Flood Lights'],
  rating: 4.8,
  reviewCount: 120,
  isAvailable: true,
  type: TurfType.football,
  ownerId: 'owner-001',
);

void main() {
  late TurfBloc turfBloc;
  late MockGetTurfsUseCase mockGetTurfs;
  late MockGetTurfDetailUseCase mockGetDetail;
  late MockSearchTurfsUseCase mockSearch;

  setUp(() {
    mockGetTurfs = MockGetTurfsUseCase();
    mockGetDetail = MockGetTurfDetailUseCase();
    mockSearch = MockSearchTurfsUseCase();

    turfBloc = TurfBloc(
      getTurfsUseCase: mockGetTurfs,
      getTurfDetailUseCase: mockGetDetail,
      searchTurfsUseCase: mockSearch,
    );

    registerFallbackValue(const GetTurfsParams());
    registerFallbackValue(const SearchTurfsParams(query: 'test'));
  });

  tearDown(() => turfBloc.close());

  group('TurfBloc - Load', () {
    blocTest<TurfBloc, TurfState>(
      'emits [TurfLoading, TurfListLoaded] on success',
      build: () {
        when(() => mockGetTurfs(any()))
            .thenAnswer((_) async => const Right([tTurf]));
        return turfBloc;
      },
      act: (bloc) => bloc.add(const TurfLoadRequested()),
      expect: () => [
        const TurfLoading(),
        const TurfListLoaded(turfs: [tTurf]),
      ],
    );

    blocTest<TurfBloc, TurfState>(
      'emits [TurfLoading, TurfError] on network failure',
      build: () {
        when(() => mockGetTurfs(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return turfBloc;
      },
      act: (bloc) => bloc.add(const TurfLoadRequested()),
      expect: () => [
        const TurfLoading(),
        const TurfError('No internet connection. Please check your network.'),
      ],
    );
  });

  group('TurfBloc - Detail', () {
    blocTest<TurfBloc, TurfState>(
      'emits [TurfLoading, TurfDetailLoaded] on success',
      build: () {
        when(() => mockGetDetail(any()))
            .thenAnswer((_) async => const Right(tTurf));
        return turfBloc;
      },
      act: (bloc) => bloc.add(const TurfDetailRequested('turf-001')),
      expect: () => [
        const TurfLoading(),
        const TurfDetailLoaded(tTurf),
      ],
    );
  });
}
