import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:smart_farm2/core/services/auth_service.dart';
import 'package:smart_farm2/core/services/locator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
  PusherChannelsClient? _pusher;
  bool _isInitialized = false;
  final Map<String, StreamSubscription> _eventSubscriptions = {};
  final Map<String, PrivateChannel> _channels = {};

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final String host = dotenv.get('IP_ADDRESS', fallback: '127.0.0.1');
      final String key = dotenv.get('REVERB_APP_KEY');
      final int port = int.parse(dotenv.get('REVERB_PORT', fallback: '8080'));
      
      log('Initializing WebSocket with Host: $host, Port: $port');

      final options = PusherChannelsOptions.fromHost(
        scheme: 'ws',
        host: host,
        key: key,
        port: port,
      );

      _pusher = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, context) {
          log('WebSocket Connection Error: $exception');
        },
      );

      _pusher!.lifecycleStream.listen((state) {
        _isConnected = state == PusherChannelsClientLifeCycleState.establishedConnection;
        log('WebSocket state changed: $state');
      });

      _isInitialized = true;
      log('WebSocket Service Initialized');
    } catch (e) {
      log('Error initializing WebSocket Service: $e');
    }
  }

  void connect() {
    if (!_isInitialized) {
      log('WebSocket not initialized. Call init() first.');
      return;
    }
    log('Connecting to WebSocket...');
    _pusher?.connect();
  }

  void disconnect() {
    log('Disconnecting WebSocket...');
    for (var sub in _eventSubscriptions.values) {
      sub.cancel();
    }
    _eventSubscriptions.clear();
    
    for (var channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
    
    _pusher?.disconnect();
  }

  /// Listen to the user's private channel for telemetry updates
  void listenToDeviceUpdates(String userId, Function(Map<String, dynamic>) onUpdate) {
    _listenToPrivateChannel('user.$userId', 'DeviceTelemetryUpdated', onUpdate);
  }

  /// Listen to the user's private channel for status updates
  void listenToStatusUpdates(String userId, Function(Map<String, dynamic>) onStatusUpdate) {
    _listenToPrivateChannel('user.$userId', 'DeviceStatusUpdated', onStatusUpdate);
  }

  Future<void> _listenToPrivateChannel(
    String channelName, 
    String eventName, 
    Function(Map<String, dynamic>) onData
  ) async {
    if (_pusher == null) return;

    final fullChannelName = 'private-$channelName';
    
    // Get token for authorization
    final String? token = await locator<AuthService>().getToken();
    final String authUrl = '${dotenv.get('API_BASE_URL')}/api/broadcasting/auth';

    if (!_channels.containsKey(fullChannelName)) {
      log('Subscribing to private channel: $fullChannelName');
      final channel = _pusher!.privateChannel(
        fullChannelName,
        authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
          authorizationEndpoint: Uri.parse(authUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      _channels[fullChannelName] = channel;
      channel.subscribe();
    }

    final channel = _channels[fullChannelName]!;
    
    // Bind to the event
    final subKey = '$fullChannelName-$eventName';
    _eventSubscriptions[subKey]?.cancel();
    
    _eventSubscriptions[subKey] = channel.bind(eventName).listen((event) {
      log('Received event $eventName on $fullChannelName');
      if (event.data != null) {
        try {
          final dynamic rawData = event.data;
          Map<String, dynamic>? data;
          
          if (rawData is Map) {
            data = Map<String, dynamic>.from(rawData);
          } else if (rawData is String) {
            data = Map<String, dynamic>.from(jsonDecode(rawData));
          }
          
          if (data != null) {
            onData(data);
          }
        } catch (e) {
          log('Error parsing event data: $e');
        }
      }
    });
  }

  void stopListening(String userId) {
    final channelName = 'private-user.$userId';
    
    _eventSubscriptions.removeWhere((key, value) {
      if (key.startsWith(channelName)) {
        value.cancel();
        return true;
      }
      return false;
    });

    if (_channels.containsKey(channelName)) {
      _channels[channelName]!.unsubscribe();
      _channels.remove(channelName);
      log('Unsubscribed from $channelName');
    }
  }
}
