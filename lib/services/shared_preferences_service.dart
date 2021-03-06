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

  /// Set the create_dude_status as false
  static Future<void> setCreateDudeStatus() async {
    final storage = await SharedPreferences.getInstance();

    var result = await storage.setBool('create_dude_status', false);
    log('set dude status: $result');
  }

  /// Return true if create_dude_status is null or the result otherwise.
  static Future<bool> getCreateDudeStatus() async {
    final storage = await SharedPreferences.getInstance();
    var result = storage.getBool('create_dude_status');
    log("create dude status: ${result ?? true}");
    return result ?? true;
  }

  // A false value means the tutorial was already seen by the user

  /// Set the navigate_to_contact_status as false
  static Future<void> setContactScreenNavigationStatus() async {
    final storage = await SharedPreferences.getInstance();

    final result = await storage.setBool('navigate_to_contact_status', false);
    log('set contact button status: $result');
  }

  /// Returns true if the navigate_to_contact_status is null or the result otherwise
  static Future<bool> getContactScreenNavigationStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('navigate_to_contact_status') ?? true;
  }

  /// Set the send_dude_to_favorite_status as false
  static Future<void> setSendDudeToFavoriteStatus() async {
    final storage = await SharedPreferences.getInstance();
    final bool result =
        await storage.setBool('send_dude_to_favorite_status', false);
    log("favorite status set : $result");
  }

  /// Returns true if the send_dude_to_favorite_status is null or the result otherwise
  static Future<bool> getSendDudeToFavoriteStatus() async {
    final storage = await SharedPreferences.getInstance();
    final bool result = storage.getBool('send_dude_to_favorite_status') ?? true;
    log("favorite status: $result");
    return result;
  }

  /// Set add_contact_status as false
  static Future<void> setContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    final result = await storage.setBool('add_contact_status', false);
    log('set add contact status: $result');
  }

  /// Returns true if the add_contact_status is null or the result otherwise
  static Future<bool> getAddContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('add_contact_status') ?? true;
  }

  /// Set the list_tile_status as false
  static Future<void> setListTileStatus() async {
    final storage = await SharedPreferences.getInstance();
    final result = await storage.setBool('list_tile_status', false);
    log('set list tile status: $result');
  }

  /// Returns true if the list_tile_status_status is null or the result otherwise
  static Future<bool> getListTileStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('list_tile_status') ?? true;
  }

  /// Set the send_dude_contact_status to false
  static Future<void> setSendDudeContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    await storage.setBool('send_dude_contact_status', false);
  }

  /// Returns true if the send_dude_contact_status is null or the result otherwise
  static Future<bool> getSendDudeContactStatus() async {
    final storage = await SharedPreferences.getInstance();
    return storage.getBool('send_dude_contact_status') ?? true;
  }
}
