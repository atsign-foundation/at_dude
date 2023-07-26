import 'dart:developer';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dude_controller.dart';
import '../services/navigation_service.dart';

class MySyncProgressListener extends SyncProgressListener {
  @override
  void onSyncProgressEvent(SyncProgress syncProgress) async {
    if (syncProgress.syncStatus == SyncStatus.success) {
      bool isKeyDude = false;
      // bool isKeyPersona = false;
      log(syncProgress.message ?? 'empty message');
      for (var keyInfo in syncProgress.keyInfoList!) {
        if (keyInfo.key.length >= 36 && keyInfo.key.startsWith('cached:@')) {
          isKeyDude = true;
          log(keyInfo.key);
        }
      }
      BuildContext context = NavigationService.navKey.currentContext!;
      if (isKeyDude) {
        await context.read<DudeController>().getDudes();
      }
    }
  }
}
