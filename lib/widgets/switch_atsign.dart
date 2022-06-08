import 'dart:math';
import 'dart:typed_data';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/authentication_controller.dart';
import '../services/authentication_service.dart';

class AtSignBottomSheet extends StatefulWidget {
  AtSignBottomSheet({Key? key}) : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  bool isLoading = false;
  var atClientPrefernce;
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(TextStrings().sidebarSwitchOut,
                          style: CustomTextStyles.blackBold(size: 15)),
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
                                Uint8List? image = CommonUtilityFunctions()
                                    .getCachedContactImage(
                                        widget.atSignList![index]);
                                return GestureDetector(
                                  onTap: isLoading
                                      ? () {}
                                      : () async {
                                          return await backendService
                                              .checkToOnboard(
                                                  atSign: widget
                                                      .atSignList![index]);

                                          Navigator.pop(context);
                                          // Navigator.pop(context);
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 20),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.toFont,
                                          width: 40.toFont,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255,
                                                r.nextInt(255),
                                                r.nextInt(255),
                                                r.nextInt(255)),
                                            borderRadius: BorderRadius.circular(
                                                50.toWidth),
                                          ),
                                          child: Center(
                                            child: image != null
                                                ? CustomCircleAvatar(
                                                    byteImage: image,
                                                    nonAsset: true,
                                                  )
                                                : ContactInitial(
                                                    initials:
                                                        authenticationController
                                                            .atsignList[index]),
                                          ),
                                        ),
                                        Text(
                                            authenticationController
                                                .atsignList[index],
                                            style: TextStyle(
                                              fontSize: 15.toFont,
                                              fontWeight: FontWeight.normal,
                                            ))
                                      ],
                                    ),
                                  ),
                                );
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
                                await backendService.checkToOnboard(atSign: "");

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
