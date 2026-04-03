import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../api_endpoints.dart';

part 'app_api_service.g.dart';

@RestApi()
abstract class AppApiService {
  factory AppApiService(Dio dio, {String baseUrl}) = _AppApiService;

  @GET(ApiEndpoints.turfs)
  Future<Map<String, dynamic>> getTurfs({@Query('page') int page = 1, @Query('page_size') int pageSize = 20});

  @POST(ApiEndpoints.requestOtp)
  Future<Map<String, dynamic>> requestOtp(@Body() Map<String, dynamic> body);

  @POST(ApiEndpoints.login)
  Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> body);

  @POST(ApiEndpoints.bookings)
  Future<Map<String, dynamic>> createBooking(@Body() Map<String, dynamic> body);
}
