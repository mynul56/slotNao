import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';

enum WsConnectionState { disconnected, connecting, connected, reconnecting }

class WsClient {
  final Logger _logger;
  final FlutterSecureStorage _secureStorage;

  WebSocketChannel? _channel;
  WsConnectionState _state = WsConnectionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  String? _currentPath;

  final _connectionStateController = StreamController<WsConnectionState>.broadcast();
  Stream<WsConnectionState> get connectionState => _connectionStateController.stream;

  WsClient({required Logger logger, required FlutterSecureStorage secureStorage})
    : _logger = logger,
      _secureStorage = secureStorage;

  Future<Stream<dynamic>?> connect(String path, {String? token}) async {
    _currentPath = path;
    _state = WsConnectionState.connecting;
    _connectionStateController.add(_state);

    try {
      final resolvedToken = token ?? await _secureStorage.read(key: AppConstants.accessTokenKey);

      final baseUri = Uri.parse(AppConstants.wsBaseUrl);
      if (baseUri.scheme != 'wss') {
        throw StateError('Insecure websocket URL is not allowed. Use wss://');
      }

      final uri = Uri.parse('${AppConstants.wsBaseUrl}$path').replace(
        queryParameters: {
          ...Uri.parse('${AppConstants.wsBaseUrl}$path').queryParameters,
          if (resolvedToken != null) 'token': resolvedToken,
        },
      );

      _channel = WebSocketChannel.connect(uri);
      _state = WsConnectionState.connected;
      _connectionStateController.add(_state);
      _reconnectAttempts = 0;

      _logger.i('WebSocket connected');
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

    _reconnectTimer = Timer(delay, () async {
      if (_currentPath != null) {
        await connect(_currentPath!, token: token);
      }
    });
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
  }
}
