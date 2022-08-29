import 'package:at_client/src/listener/sync_progress_listener.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dude_controller.dart';
import '../services/navigation_service.dart';

class MySyncProgressListener extends SyncProgressListener {
  @override
  void onSyncProgressEvent(SyncProgress syncProgress) async {
    if (syncProgress.syncStatus == SyncStatus.success) {
      BuildContext context = NavigationService.navKey.currentContext!;
      await context.read<DudeController>().getDudes();
    }
  }
}
