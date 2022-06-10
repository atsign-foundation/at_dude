import 'package:at_onboarding_flutter/services/at_error_dialog.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/services/sdk_service.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// Custom reset button widget is to reset an atsign from keychain list,

class ResetAppButton extends StatefulWidget {
  final String? buttonText;

  const ResetAppButton({
    Key? key,
    this.buttonText,
  }) : super(key: key);

  @override
  State<ResetAppButton> createState() => _ResetAppButtonState();
}

class _ResetAppButtonState extends State<ResetAppButton> {
  bool? loading = false;
  // @override
  // void initState() {
  //   super.initState();
  //   widget.loading = false;
  // }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showResetDialog,
      child: const Text(
        'Reset App',
      ),
    );
  }

  Future<void> _showResetDialog() async {
    bool isSelectAtsign = false;
    bool isSelectAll = false;
    List<String>? atsignsList = await SDKService().getAtsignList();
    Map<String, bool?> atsignMap = <String, bool>{};
    if (atsignsList != null) {
      for (String atsign in atsignsList) {
        atsignMap[atsign] = false;
      }
    }
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) stateSet) {
            return AlertDialog(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(Strings.resetDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 0.8,
                    )
                  ],
                ),
                content: atsignsList == null
                    ? Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        const Text(Strings.noAtsignToReset,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            )),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(AppConstants.closeButton,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 240, 94, 62),
                                    fontWeight: FontWeight.normal,
                                  ))),
                        )
                      ])
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CheckboxListTile(
                              onChanged: (bool? value) {
                                isSelectAll = value!;
                                if (atsignMap.isNotEmpty) {
                                  atsignMap.updateAll(
                                      (String? key, bool? value1) =>
                                          value1 = value);
                                }
                                // atsignMap[atsign] = value;
                                stateSet(() {});
                              },
                              value: isSelectAll,
                              checkColor: Colors.white,
                              activeColor:
                                  const Color.fromARGB(255, 240, 94, 62),
                              title: const Text('Select All',
                                  style: TextStyle(
                                    // fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                              // trailing: Checkbox,
                            ),
                            for (String atsign in atsignsList)
                              CheckboxListTile(
                                onChanged: (bool? value) {
                                  if (atsignMap.isNotEmpty) {
                                    atsignMap[atsign] = value;
                                  }
                                  stateSet(() {});
                                },
                                value: atsignMap.isNotEmpty
                                    ? atsignMap[atsign]
                                    : true,
                                checkColor: Colors.white,
                                activeColor:
                                    const Color.fromARGB(255, 240, 94, 62),
                                title: Text(atsign),
                                // trailing: Checkbox,
                              ),
                            const Divider(thickness: 0.8),
                            if (isSelectAtsign)
                              const Text(Strings.resetErrorText,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  )),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(Strings.resetWarningText,
                                style: TextStyle(
                                    color: ColorConstants.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Map<String, bool?> tempAtsignMap =
                                      <String, bool>{};
                                  tempAtsignMap.addAll(atsignMap);
                                  tempAtsignMap.removeWhere(
                                      (String? key, bool? value) =>
                                          value == false);
                                  if (tempAtsignMap.keys.toList().isEmpty) {
                                    isSelectAtsign = true;
                                    stateSet(() {});
                                  } else {
                                    isSelectAtsign = false;
                                    _resetDevice(tempAtsignMap.keys.toList());
                                  }
                                },
                                child: const Text(AppConstants.removeButton,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 240, 94, 62),
                                      fontWeight: FontWeight.normal,
                                    )),
                              ),
                              const Spacer(),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(AppConstants.cancelButton,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      )))
                            ])
                          ],
                        ),
                      ));
          });
          // );
        });
  }

  Future<void> _resetDevice(List<String> checkedAtsigns) async {
    Navigator.of(context).pop();
    setState(() {
      loading = true;
    });
    await SDKService().resetAtsigns(checkedAtsigns).then((void value) async {
      setState(() {
        loading = false;
      });

      List<String>? atsignsList = await SDKService().getAtsignList();
      if (atsignsList == null || atsignsList.length < 2) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const MyApp(),
          ),
        );
      }
    }).catchError((Object error) {
      setState(() {
        loading = false;
      });
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AtErrorDialog.getAlertDialog(error, context);
          });
    });
  }
}
