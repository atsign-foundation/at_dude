// 🎯 Dart imports:
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../screens/history_screen.dart';
import 'navigation_service.dart';

/// A singleton that controls all notifications for this app.
///
///
class LocalNotificationService {
  static final LocalNotificationService _notificationService =
      LocalNotificationService._internal();

  factory LocalNotificationService.getInstance() {
    return _notificationService;
  }

  factory LocalNotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationService._internal();

  /// Initializes all the settings required to use notifications on android and IOS.
  Future<void> initNotification() async {
    tz.initializeTimeZones();

    if (Platform.isIOS) {
      _requestIOSPermission();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_speaker_phone');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: () {}
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        switch (details.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Navigator.of(NavigationService.navKey.currentContext!)
                .popAndPushNamed(NotificationScreen.routeName);
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
    );
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  /// Shows notification when dude is sent to the current atsign.
  ///
  /// Notification currently only works in app on android.
  Future<void> showNotifications(
      int id, String title, String body, int seconds) async {
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
            icon: '@drawable/ic_stat_speaker_phone'),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }
}
