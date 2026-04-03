import 'package:flutter_test/flutter_test.dart';
import 'package:turf_booking_app/core/network/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('parses wrapped success payload', () {
      final result = ApiResponse.fromJson<Map<String, dynamic>>({
        'status': true,
        'data': {'name': 'SlotNao'},
      }, (json) => json as Map<String, dynamic>);

      expect(result.status, isTrue);
      expect(result.data?['name'], 'SlotNao');
    });

    test('parses direct payload as success', () {
      final result = ApiResponse.fromJson<Map<String, dynamic>>({'name': 'Direct'}, (json) => json as Map<String, dynamic>);

      expect(result.status, isTrue);
      expect(result.data?['name'], 'Direct');
    });
  });
}
