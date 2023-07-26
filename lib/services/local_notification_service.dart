// 🎯 Dart imports:
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/arguments.dart';
import '../utils/enums.dart';
import '../widgets/widgets.dart';
import 'navigation_service.dart';

/// A singleton that controls all notifications for this app.
///
///
class LocalNotificationService {
  static final LocalNotificationService _notificationService = LocalNotificationService._internal();

  factory LocalNotificationService.getInstance() {
    return _notificationService;
  }

  factory LocalNotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  LocalNotificationService._internal();

  /// Initializes all the settings required to use notifications on android and IOS.
  Future<void> initNotification() async {
    tz.initializeTimeZones();

    if (Platform.isIOS) {
      _requestIOSPermission();
    }

    if (Platform.isAndroid) {
      _requestAndroidPermission();
    }

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: () {}
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        switch (details.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Navigator.of(NavigationService.navKey.currentContext!).popAndPushNamed(DudeNavigationScreen.routeName,
                arguments: Arguments(route: Screens.notifications.index));
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
    );
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  _requestAndroidPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();
  }

  /// Shows notification when dude is sent to the current atsign.
  ///
  /// Notification currently only works in app on android.
  Future<void> showNotifications(int id, String title, String body, int seconds) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      const NotificationDetails(
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            channelDescription: 'Main channel  notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'launcher_icon'),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }
}
