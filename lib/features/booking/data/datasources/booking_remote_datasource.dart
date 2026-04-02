import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_error_parser.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDatasource {
  Future<BookingModel> createBooking({
    required String turfId,
    required String slotId,
    required DateTime slotStart,
    required DateTime slotEnd,
  });

  Future<List<BookingModel>> getBookings({String? status, int page = 1});
  Future<BookingModel> getBookingDetail(String bookingId);
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  final Dio _dio;
  const BookingRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<BookingModel> createBooking({
    required String turfId,
    required String slotId,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.bookings,
        data: {
          'turf_id': turfId,
          'slot_id': slotId,
          'slot_start': slotStart.toIso8601String(),
          'slot_end': slotEnd.toIso8601String(),
        },
      );
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<List<BookingModel>> getBookings({
    String? status,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.bookings,
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
        },
      );
      final mapData = response.data as Map<String, dynamic>;
      final list = mapData['data'] as List;
      return list
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<BookingModel> getBookingDetail(String bookingId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.bookingById(bookingId));
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _dio.post(ApiEndpoints.cancelBooking(bookingId));
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }
}
