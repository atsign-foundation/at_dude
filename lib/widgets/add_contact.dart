import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import 'widgets.dart';

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({Key? key}) : super(key: key);

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  late TextEditingController atsignController;
  bool isLoading = false;

  @override
  void initState() {
    atsignController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    atsignController.dispose();
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
              ],
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                updateIsLoading(true);
                await context
                    .read<ContactsController>()
                    .addContacts(atsignController.value.text);
                updateIsLoading(false);
                Navigator.of(context).pop();
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
