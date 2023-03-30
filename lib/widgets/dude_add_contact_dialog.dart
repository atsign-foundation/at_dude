import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import 'widgets.dart';

class DudeAddContactDialog extends StatefulWidget {
  const DudeAddContactDialog({this.atsign, Key? key}) : super(key: key);

  final String? atsign;

  @override
  State<DudeAddContactDialog> createState() => _DudeAddContactDialogState();
}

class _DudeAddContactDialogState extends State<DudeAddContactDialog> {
  late TextEditingController atsignController;
  late TextEditingController nicknameController;
  bool isLoading = false;

  @override
  void initState() {
    atsignController = TextEditingController(text: widget.atsign);
    nicknameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    atsignController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  /// Update the isLoading property to it's appropriate state.
  void updateIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: const Text('Add Contact'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  controller: atsignController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixText: '@',
                    prefixStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                    hintText: '\tEnter @Sign',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextField(
                  autofocus: true,
                  controller: nicknameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                    hintText: 'Enter nick name',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  log('pop called');
                  Navigator.of(context).pop(false);
                  // Navigator.of(context).pushReplacementNamed(routeName)
                  // await Navigator.pushNamed(context, DudeNavigationScreen.routeName,
                  //     arguments: Arguments(
                  //       route: Screens.notifications.index,
                  //     ));
                },
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                updateIsLoading(true);
                await context
                    .read<ContactsController>()
                    .addContacts(atsignController.value.text, nicknameController.value.text);
                updateIsLoading(false);

                Navigator.of(context).pop(true);
              },
              child: const Text('Add to Contacts'),
            ),
          ],
        ),
        isLoading ? const LoadingIndicator() : const SizedBox()
      ],
    );
  }
}
