import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'dart:io' show Platform;

import 'api_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _lastKnownUnreadCount = 0;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('NotificationService: Starting initialization');

      // Initialize local notifications with timeout
      await _initializeLocalNotifications().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Notification initialization timed out');
        },
      );

      print('NotificationService: Local notifications initialized');

      // Set initialized flag before checking updates
      _initialized = true;

      // Initial unread count check - don't await this
      checkUnreadUpdates().catchError((e) {
        print('NotificationService: Initial unread check failed: $e');
      });

      print('NotificationService: Initialization complete');
    } catch (e) {
      print('NotificationService: Initialization failed: $e');
      // Set initialized anyway to prevent hanging
      _initialized = true;
      // Rethrow if you want to handle the error in main.dart
      // throw e;
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null) {
          print('Notification tapped: ${details.payload}');
        }
      },
    );
  }

  static Future<void> checkUnreadUpdates() async {
    try {
      // TODO: Migrate to ApiClient
      final unreadCount = await ApiService.getUnreadCount();

      print("test 4");
      // Only show notification if unread count increased
      if (unreadCount > _lastKnownUnreadCount) {
        await showUpdateNotification(
          title: 'New Updates Available',
          body: 'You have $unreadCount unread updates',
          payload: 'updates',
        );
      }
      print("test 5");

      // Update badge count
      await updateBadgeCount(unreadCount);
      print("test 6");

      _lastKnownUnreadCount = unreadCount;
    } catch (e) {
      print('Error checking unread updates: $e');
    }
  }

  static Future<void> showUpdateNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'updates_channel',
      'Updates Notifications',
      channelDescription: 'Notifications for new updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> updateBadgeCount(int count) async {
    try {

      print("test 7");
      if (count > 0) {
        await FlutterAppBadgeControl.updateBadgeCount(count);

        print("test 8");
        // For Android: Show silent notification with badge
        if (Platform.isAndroid) {

          print("test 9");
          await _notifications.show(
            0, // Use consistent ID for badge notification
            '',
            '',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'badge_channel',
                'Badge Notifications',
                channelDescription: 'Channel for badge notifications',
                importance: Importance.min,
                priority: Priority.low,
                showWhen: false,
                enableVibration: false,
                playSound: false,
                ongoing: true,
                number: 0, // This will be updated with the count
                visibility: NotificationVisibility.secret,
              ),
            ),
          );

          print("test 10");
        }
      } else {
        print("test 11");
        // await FlutterAppBadgeControl.updateBadgeCount(0);
        FlutterAppBadgeControl.removeBadge();
        print("test 12");
        await _notifications.cancel(0); // Cancel badge notification
        print("test 13");
      }
    } catch (e) {
      print('Error updating badge: $e');
    }
  }

}

