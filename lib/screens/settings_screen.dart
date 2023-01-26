import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dude_theme.dart';
import '../services/navigation_service.dart';
import '../utils/texts.dart';
import '../widgets/settings_button.dart';
import '../widgets/switch_atsign.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            ContactService().currentAtsign,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: kPrimaryColor),
                          ),
                          Text(
                            ContactService()
                                    .loggedInUserDetails!
                                    .tags!['name'] ??
                                '',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: 300,
                        height: 72,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: ListTile(
                            leading: const Text(
                              '👀',
                              style: TextStyle(fontSize: 33),
                            ),
                            title: const Text(
                              Texts.selectYourDude,
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {},
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SettingsButton(
                            icon: Icons.bookmark_outline,
                            title: 'Backup Your Keys',
                            onTap: () {
                              BackupKeyWidget(
                                      atsign: ContactService().currentAtsign)
                                  .showBackupDialog(context);
                            },
                          ),
                          SettingsButton(
                            icon: Icons.logout_rounded,
                            title: Texts.switchAtsign,
                            onTap: () async {
                              await showModalBottomSheet(
                                  context:
                                      NavigationService.navKey.currentContext!,
                                  builder: (context) =>
                                      const AtSignBottomSheet());
                            },
                          ),
                          const ResetAppButton(),
                          SettingsButton(
                            icon: Icons.help_center_outlined,
                            title: Texts.faq,
                            onTap: () async {
                              final Uri _url =
                                  Uri.parse('https://atsign.com/faqs/');
                              if (!await launchUrl(_url)) {
                                throw Exception('Could not launch $_url');
                              }
                            },
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
                          SettingsButton(
                            icon: Icons.account_balance_wallet_outlined,
                            title: Texts.privacyPolicy,
                            onTap: () async {
                              final Uri _url = Uri.parse(
                                  'https://atsign.com/apps/atDude-privacy/');
                              if (!await launchUrl(_url)) {
                                throw Exception('Could not launch $_url');
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
