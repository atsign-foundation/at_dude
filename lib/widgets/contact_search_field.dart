import 'package:flutter/material.dart';

import '../dude_theme.dart';

class ContactSearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  const ContactSearchField(this.hintText, this.onChanged, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.name,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: const Icon(
            Icons.search,
            color: kPrimaryColor,
            size: 20,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          // color: ColorConstants.fontPrimary,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
