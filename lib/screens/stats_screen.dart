import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../services/services.dart';
import '../widgets/dude_card.dart';
import '../widgets/dude_list_tile.dart';
import '../widgets/widgets.dart';

class StatsScreen extends StatefulWidget {
  static const String routeName = 'stats';
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  ProfileModel profileModel = ProfileModel.newDude();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      profileModel = await DudeService.getInstance().getProfile();
      // profileName ??= DudeService.getInstance().atClient!.getCurrentAtSign();
      setState(() {});
    });
    super.initState();
  }

  // final ProfileModel profileModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 1),
      body: Stack(children: [
        const AppBackground(
          alignment: Alignment.bottomCenter,
        ),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const DudeListTile(
                title: 'Hey Dude!',
                subtitle: 'Here are your statistics',
                trailing: '🏆',
              ),
              DudeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ProfileStat(
                      stat: profileModel.dudesSent == 0
                          ? '-'
                          : profileModel.dudesSent.toString(),
                      description: 'Dudes sent',
                    ),
                  ],
                ),
              ),
              DudeCard(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Since ${profileModel.createdAt != null ? DateFormat('MMM yyyy').format(profileModel.createdAt!) : ''}'),
              ))
            ],
          ),
        ),
      ]),
    );
  }
}
