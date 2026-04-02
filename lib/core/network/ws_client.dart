import 'dart:async';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';

enum WsConnectionState { disconnected, connecting, connected, reconnecting }

class WsClient {
  final Logger _logger;

  WebSocketChannel? _channel;
  WsConnectionState _state = WsConnectionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  String? _currentPath;

  final _connectionStateController = StreamController<WsConnectionState>.broadcast();
  Stream<WsConnectionState> get connectionState => _connectionStateController.stream;

  WsClient({required Logger logger}) : _logger = logger;

  Stream<dynamic>? connect(String path, {String? token}) {
    _currentPath = path;
    _state = WsConnectionState.connecting;
    _connectionStateController.add(_state);

    try {
      final uri = Uri.parse(
        '${AppConstants.wsBaseUrl}$path'
        '${token != null ? '?token=$token' : ''}',
      );

      _channel = WebSocketChannel.connect(uri);
      _state = WsConnectionState.connected;
      _connectionStateController.add(_state);
      _reconnectAttempts = 0;

      _logger.i('WebSocket connected: $uri');
      return _channel!.stream.handleError(_onError);
    } catch (e) {
      _logger.e('WebSocket connection failed', error: e);
      _scheduleReconnect(token: token);
      return null;
    }
  }

  void send(dynamic data) {
    if (_state == WsConnectionState.connected) {
      _channel?.sink.add(data);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _state = WsConnectionState.disconnected;
    _connectionStateController.add(_state);
    _logger.i('WebSocket disconnected');
  }

  void _onError(Object error) {
    _logger.e('WebSocket error', error: error);
    if (_reconnectAttempts < AppConstants.maxWsReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect({String? token}) {
    if (_reconnectAttempts >= AppConstants.maxWsReconnectAttempts) {
      _state = WsConnectionState.disconnected;
      _connectionStateController.add(_state);
      return;
    }

    _state = WsConnectionState.reconnecting;
    _connectionStateController.add(_state);
    _reconnectAttempts++;
    final delay = Duration(milliseconds: AppConstants.wsReconnectDelayMs * _reconnectAttempts);

    _logger.i('WebSocket reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      if (_currentPath != null) connect(_currentPath!, token: token);
    });
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
  }
}
