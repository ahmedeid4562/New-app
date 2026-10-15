import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  log('Background message ID: ${message.messageId}');
  log('Background message data: ${message.data}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'news_channel',
    'News Notifications',
    description: 'Notifications about news updates',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    try {
      await _initializeLocalNotifications();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      log('Notification permission: ${settings.authorizationStatus}');

      // Subscribe to automatic news update notifications.
      await _messaging.subscribeToTopic('news_updates');

      log('Subscribed to news_updates topic');

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        log('Notification opened: ${message.messageId}');
        log('Notification data: ${message.data}');
      });

      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        log('App opened from notification: ${initialMessage.messageId}');
      }

      final token = await _messaging.getToken();

      log('FCM Token: $token');
    } catch (error, stackTrace) {
      log(
        'Notification initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        log('Local notification tapped: ${response.payload}');
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ?? message.data['title']?.toString();

    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) {
      log('Received a data-only message without title or body');
      return;
    }

    await _localNotifications.show(
      id: message.hashCode,
      title: title ?? 'News App',
      body: body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
