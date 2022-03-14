import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_dude/models/dude_model.dart';

import '../main.dart';

class DudeService {
  Future<void> putDude(DudeModel dude, String contactAtsign) async {
    var atClientManager = AtClientManager.getInstance();
    Future<AtClientPreference> futurePreference = loadAtClientPreference();
    var preference = await futurePreference;

    late AtClient atClient;
    atClient = atClientManager.atClient;
    atClientManager.atClient.setPreferences(preference);
    dude.saveSender(atClient.getCurrentAtSign()!);
    dude.saveId();
    dude.saveReceiver(contactAtsign);

    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true;

    var key = AtKey()
      ..key = dude.id
      ..sharedBy = dude.sender
      ..sharedWith = dude.receiver
      ..metadata = metaData;

    await atClient.put(
      key,
      dude.toJson(),
    );
    atClientManager.syncService.sync();
  }

  Future<void> getDudes() async {}
}
