import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/dude_controller.dart';
import '../dude_theme.dart';
import '../services/navigation_service.dart';
import '../services/shared_preferences_service.dart';
import '../utils/texts.dart';
import '../widgets/settings_button.dart';
import '../widgets/switch_atsign.dart';
import '../widgets/widgets.dart';
import 'custom_blocked_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static String routeName = 'settingsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 4),
      body: Stack(
        children: [
          const AppBackground(alignment: Alignment.bottomCenter),
          SafeArea(
              child: ListView(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      ContactService().currentAtsign,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: kPrimaryColor),
                    ),
                    Text(
                      ContactService().loggedInUserDetails!.tags!['name'] ?? '',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SettingsButton(
                      icon: Icons.block_outlined,
                      title: 'Blocked Contacts',
                      onTap: () {
                        Navigator.of(context).pushNamed(CustomBlockedScreen.routeName);
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SettingsButton(
                      icon: Icons.bookmark_outline,
                      title: 'Backup Your Keys',
                      onTap: () {
                        BackupKeyWidget(atsign: ContactService().currentAtsign).showBackupDialog(context);
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SettingsButton(
                      icon: Icons.logout_rounded,
                      title: Texts.switchAtsign,
                      onTap: () async {
                        await showModalBottomSheet(
                            context: NavigationService.navKey.currentContext!,
                            builder: (context) => const AtSignBottomSheet());
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const ResetAppButton(),
                    const SizedBox(
                      height: 15,
                    ),
                    SettingsButton(
                      icon: Icons.help_center_outlined,
                      title: Texts.faq,
                      onTap: () async {
                        final Uri _url = Uri.parse('https://atsign.com/faqs/');
                        if (!await launchUrl(_url)) {
                          throw Exception('Could not launch $_url');
                        }
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SettingsButton(
                      icon: Icons.forum_outlined,
                      title: Texts.contactUs,
                      onTap: () async {
                        Uri _emailUri = Uri(
                          scheme: 'mailto',
                          path: 'atdude@atsign.com',
                        );
                        if (!await launchUrl(_emailUri)) {
                          throw Exception('Could not launch $_emailUri');
                        }
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SettingsButton(
                      icon: Icons.account_balance_wallet_outlined,
                      title: Texts.privacyPolicy,
                      onTap: () async {
                        final Uri _url = Uri.parse('https://atsign.com/apps/atDude-privacy/');
                        if (!await launchUrl(_url)) {
                          throw Exception('Could not launch $_url');
                        }
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SettingsButton(
                      icon: Icons.delete_forever,
                      title: Texts.deleteAllData,
                      onTap: () async {
                        SnackBars.notificationSnackBar(
                          content: 'Are you sure',
                          action: SnackBarAction(
                              label: 'Yes',
                              textColor: Colors.white,
                              onPressed: () async {
                                var dudes = context.read<DudeController>().dudes;

                                for (var dude in dudes) {
                                  await SharedPreferencesService.deleteDudeReadStatus(dude);
                                }
                                bool result = await context.read<DudeController>().deleteAllData();
                                if (result) {
                                  SnackBars.notificationSnackBar(content: "All Dude Deleted");
                                }
                              }),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
