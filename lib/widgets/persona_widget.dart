import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/persona_controller.dart';
import '../dude_theme.dart';
import '../models/models.dart';
import 'dude_card.dart';

class PersonaWidget extends StatefulWidget {
  const PersonaWidget({required this.data, required this.index, Key? key})
      : super(key: key);

  final PersonaModel data;
  final int index;

  @override
  State<PersonaWidget> createState() => _PersonaWidgetState();
}

class _PersonaWidgetState extends State<PersonaWidget> {
  var success = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DudeCard(
          child: Text(
            widget.data.names[widget.index].values.first,
            textAlign: TextAlign.center,
          ),
        ),
        DudeCard(
          child: Image.asset(
            widget.data.images[widget.index].values.first,
          ),
        ),
        ElevatedButton(
            style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                backgroundColor: MaterialStateProperty.all(
                    widget.data.selectedPersona.index == widget.index || success
                        ? kPrimaryColor
                        : Colors.grey)),
            onPressed: () async {
              var persona = PersonaModel(
                  selectedPersona: widget.data.getEnumFromIndex(
                      widget.data.names[widget.index].keys.first));
              success =
                  await Provider.of<PersonaController>(context, listen: false)
                      .putPersona(persona);
            },
            child: Text(
                widget.data.selectedPersona.index == widget.index || success
                    ? 'Selected'
                    : 'Select'))
      ],
    );
  }
}
