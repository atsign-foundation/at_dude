import 'dart:math';
import 'dart:typed_data';
import 'package:at_common_flutter/services/size_config.dart';
// import 'package:at_contacts_group_flutter/utils/text_styles.dart';
// import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
// import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
// import 'package:atsign_atmosphere_pro/services/backend_service.dart';
// import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
// import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:at_contact/at_contact.dart';

import '../controller/controller.dart';
import '../services/authentication_service.dart';
import '../services/services.dart';
import 'widgets.dart';

class AtSignBottomSheet extends StatefulWidget {
  const AtSignBottomSheet({Key? key}) : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  bool isLoading = false;
  var atClientPrefernce;

  @override
  void initState() {
    NavigationService.navKey.currentContext!
        .read<AuthenticationController>()
        .getAtSignList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // backendService
    //     .getAtClientPreference()
    //     .then((value) => atClientPrefernce = value);
    Random r = Random();
    return Stack(
      children: [
        Positioned(
          child: BottomSheet(
            onClosing: () {},
            backgroundColor: Colors.transparent,
            builder: (context) => ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Container(
                height: 155.toHeight < 155 ? 155 : 150.toHeight,
                width: SizeConfig().screenWidth,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        'Switch @sign',
                      ),
                    ),
                    Container(
                      height: 100.toHeight < 105 ? 105 : 100.toHeight,
                      width: SizeConfig().screenWidth,
                      color: Colors.white,
                      child: Consumer<AuthenticationController>(
                        builder: (context, authenticationController, child) =>
                            Row(
                          children: [
                            Expanded(
                                child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  authenticationController.atsignList.length,
                              itemBuilder: (context, index) {
                                print('list builder');
                                return FutureBuilder(
                                    future: authenticationController
                                        .getAtContact(authenticationController
                                            .atsignList[index])
                                        .then((value) => value),
                                    builder: ((context, snapshot) {
                                      if (snapshot.hasData) {
                                        print('data present');
                                        return GestureDetector(
                                          onTap: isLoading
                                              ? () {}
                                              : () async {
                                                  Navigator.pop(context);
                                                  AuthenticationService
                                                          .getInstance()
                                                      .handleOnboard(
                                                          authenticationController
                                                                  .atsignList[
                                                              index]);

                                                  ;
                                                  // Navigator.pop(context);
                                                },
                                          child: CircularContacts(
                                              contact:
                                                  snapshot.data as AtContact),
                                        );
                                      } else if (!snapshot.hasData) {
                                        print('loading indicator');
                                        return SizedBox(
                                          child: const LoadingIndicator(),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                        );
                                      } else {
                                        print('error');
                                        SnackBars.errorSnackBar(
                                            content: 'Error', context: context);
                                        return const SizedBox();
                                      }
                                    }));
                              },
                            )),
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                  Navigator.pop(context);
                                });
                                AuthenticationService.getInstance()
                                    .handleOnboard("");

                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                height: 40,
                                width: 40,
                                child: Icon(Icons.add_circle_outline_outlined,
                                    color: Colors.orange, size: 25.toFont),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
