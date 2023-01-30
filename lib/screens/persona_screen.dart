import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/persona_controller.dart';
import '../models/models.dart';
import '../utils/texts.dart';
import '../widgets/app_background.dart';
import '../widgets/dude_bottom_navigation_bar.dart';
import '../widgets/persona_widget.dart';

class PersonaScreen extends StatefulWidget {
  static const String routeName = 'select_dude';
  const PersonaScreen({Key? key}) : super(key: key);

  @override
  State<PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<PersonaScreen> {
  PersonaModel personaModel = PersonaModel.standard();
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<PersonaController>(context, listen: false).getPersona();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black),
        title: Text(
          Texts.eyeSelectYourDude,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
      body: Stack(children: [
        const AppBackground(
          alignment: Alignment.bottomCenter,
        ),
        SafeArea(
          child: Consumer<PersonaController>(
              builder: (BuildContext context, personaController, child) {
            if (personaController.personaModel.id.isNotEmpty) {
              var isSelectedPersona = true;
              return CarouselSlider.builder(
                itemCount: personaController.personaModel.names.length,
                itemBuilder: ((context, index, realIndex) {
                  return PersonaWidget(
                      data: personaController.personaModel, index: index);
                }),
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 7,
                  enlargeCenterPage: true,
                ),
                carouselController: _controller,
              );
            } else if (false) {
              return const Text('Error');
            } else {
              return const CircularProgressIndicator();
            }
          }),
        ),
      ]),
    );
  }
}
