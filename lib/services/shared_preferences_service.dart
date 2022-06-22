import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _notificationService =
      SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _notificationService;
  }
  SharedPreferencesService._internal();

  // Future<SharedPreferences> getPreference() async =>  SharedPreferences.getInstance();

  static Future<void> setCreateDudeStatus() async {
    final storage = await SharedPreferences.getInstance();

    var result = await storage.setBool('create_dude_status', false);
    log('set dude status: $result');
  }

  static Future<bool> getCreateDudeStatus() async {
    final storage = await SharedPreferences.getInstance();
    var result = storage.getBool('create_dude_status');
    log("create dude status: ${result ?? true}");
    return result ?? true;
  }

  // A false value means the tutorial was already seen by the user
  static Future<void> setContactScreenNavigationStatus() async {
    final storage = await SharedPreferences.getInstance();

    final result = await storage.setBool('navigate_to_contact_status', false);
    log('set contact button status: $result');
  }

  static Future<bool> getContactScreenNavigationStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('navigate_to_contact_status') ?? true;
  }

  static Future<void> setSendDudeToFavoriteStatus() async {
    final storage = await SharedPreferences.getInstance();
    final bool result =
        await storage.setBool('send_dude_to_favorite_status', false);
    log("favorite status set : $result");
  }

  static Future<bool> getSendDudeToFavoriteStatus() async {
    final storage = await SharedPreferences.getInstance();
    final bool result = storage.getBool('send_dude_to_favorite_status') ?? true;
    log("favorite status: $result");
    return result;
  }

  static Future<void> setContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    final result = await storage.setBool('add_contact_status', false);
    log('set add contact status: $result');
  }

  static Future<bool> getAddContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('add_contact_status') ?? true;
  }

  static Future<void> setListTileStatus() async {
    final storage = await SharedPreferences.getInstance();
    final result = await storage.setBool('list_tile_status', false);
    log('set list tile status: $result');
  }

  static Future<bool> getListTileStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('list_tile_status') ?? true;
  }

  static Future<void> setSendDudeContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    await storage.setBool('send_dude_contact_status', false);
  }

  static Future<bool> getSendDudeContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('send_dude_contact_status') ?? true;
  }
}
