import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
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
  final ApiClient _apiClient;
  const BookingRemoteDatasourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<BookingModel> createBooking({
    required String turfId,
    required String slotId,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) async {
    final envelope = await _apiClient.post<Map<String, dynamic>>(
      path: ApiEndpoints.bookings,
      body: {
        'turf_id': turfId,
        'slot_id': slotId,
        'slot_start': slotStart.toIso8601String(),
        'slot_end': slotEnd.toIso8601String(),
      },
      parser: (json) => json as Map<String, dynamic>,
      retryPost: false,
    );
    return BookingModel.fromJson(envelope.data ?? <String, dynamic>{});
  }

  @override
  Future<List<BookingModel>> getBookings({String? status, int page = 1}) async {
    final paginated = await _apiClient.getPaginated<BookingModel>(
      path: ApiEndpoints.bookings,
      queryParameters: {if (status != null) 'status': status},
      itemParser: (e) => BookingModel.fromJson(e as Map<String, dynamic>),
      page: page,
      pageSize: 20,
    );
    return paginated.items;
  }

  @override
  Future<BookingModel> getBookingDetail(String bookingId) async {
    final envelope = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.bookingById(bookingId),
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'booking-detail-$bookingId',
      cacheTtlSeconds: 30,
    );
    return BookingModel.fromJson(envelope.data ?? <String, dynamic>{});
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _apiClient.post<void>(path: ApiEndpoints.cancelBooking(bookingId), parser: (_) {});
  }
}
