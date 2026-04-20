import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_flutter/widgets/blocked_user_card.dart';
import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import '../widgets/dude_card.dart';

/// Screen exposed to see blocked contacts and unblock them
class CustomBlockedScreen extends StatefulWidget {
  const CustomBlockedScreen({Key? key}) : super(key: key);

  static String routeName = 'customBlockedScreen';

  @override
  _CustomBlockedScreenState createState() => _CustomBlockedScreenState();
}

class _CustomBlockedScreenState extends State<CustomBlockedScreen> {
  late ContactService _contactService;
  bool errorOcurred = false;

  /// Boolean indicator of unblock action
  bool unblockingAtsign = false;
  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var _result = await _contactService.fetchBlockContactList();
      if (_result == null) {
        if (mounted) {
          setState(() {
            errorOcurred = true;
          });
        }
      }
    });

    super.initState();
  }

  /// boolean flag to indicate if blocking flow is in progress
  bool isBlocking = false;
  bool toggleList = true;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        appBarColor: Colors.transparent,
        showBackButton: true,
        showTitle: true,
        showLeadingIcon: true,
        titleText: TextStrings().blockedContacts,
      ),
      body: errorOcurred
          ? const ErrorScreen()
          : Stack(children: [
              const AppBackground(alignment: Alignment.bottomCenter),
              SafeArea(
                child: RefreshIndicator(
                  color: Colors.transparent,
                  strokeWidth: 0,
                  backgroundColor: Colors.transparent,
                  onRefresh: () async {
                    await _contactService.fetchBlockContactList();
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: StreamBuilder(
                          initialData: _contactService.baseBlockedList,
                          stream: _contactService.blockedContactStream,
                          builder: (context,
                              AsyncSnapshot<List<BaseContact?>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              return (snapshot.data!.isEmpty)
                                  ? Center(
                                      child: Text(
                                        TextStrings().emptyBlockedList,
                                        style: TextStyle(
                                          fontSize: 16.toFont,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    )
                                  : (toggleList)
                                      ? ListView.separated(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 40.toHeight),
                                          itemCount: _contactService
                                              .blockContactList.length,
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                            indent: 16.toWidth,
                                          ),
                                          itemBuilder: (context, index) {
                                            return DudeCard(
                                              child: BlockedUserCard(
                                                  blockeduser: snapshot
                                                      .data?[index]?.contact,
                                                  unblockAtsign: () async {
                                                    await unblockAtsign(snapshot
                                                            .data?[index]
                                                            ?.contact ??
                                                        AtContact());
                                                  }),
                                            );
                                          },
                                        )
                                      : GridView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: SizeConfig()
                                                          .isTablet(context)
                                                      ? 5
                                                      : 3,
                                                  childAspectRatio: 1 /
                                                      (SizeConfig()
                                                              .isTablet(context)
                                                          ? 1.2
                                                          : 1.1)),
                                          shrinkWrap: true,
                                          itemCount: _contactService
                                              .blockContactList.length,
                                          itemBuilder: (context, index) {
                                            return CircularContacts(
                                                contact: snapshot
                                                    .data?[index]?.contact,
                                                onCrossPressed: () async {
                                                  await unblockAtsign(snapshot
                                                          .data?[index]
                                                          ?.contact ??
                                                      AtContact());
                                                });
                                          },
                                        );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
    );
  }

  Future<void> unblockAtsign(AtContact atsign) async {
    setState(() {
      unblockingAtsign = true;
    });
    // ignore: unawaited_futures
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().unblockContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    await _contactService.blockUnblockContact(
        contact: atsign, blockAction: false);

    setState(() {
      unblockingAtsign = false;
      Navigator.pop(context);
    });
  }
}
