import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../services/services.dart';
import '../widgets/dude_card.dart';
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
              DudeCard(
                child: ListTile(
                  title: Text(
                    'Hey Dude!',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  subtitle: Text('Here are your statistics',
                      style: Theme.of(context).textTheme.bodyText2),
                  trailing: const Text(
                    '🏆',
                    style: TextStyle(
                      fontSize: 49,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                    ProfileStat(
                      stat: profileModel.dudeHours.inMilliseconds == 0
                          ? '-'
                          : profileModel.dudeHours >= const Duration(minutes: 1)
                              ? profileModel.dudeHours.inMinutes.toString()
                              : profileModel.dudeHours.inSeconds.toString(),
                      unit: profileModel.dudeHours >= const Duration(minutes: 1)
                          ? 'Minutes'
                          : 'Seconds',
                      description: 'Spent duding',
                    ),
                    ProfileStat(
                      stat: profileModel.longestDude.inMilliseconds == 0
                          ? '-'
                          : profileModel.longestDude >=
                                  const Duration(minutes: 1)
                              ? profileModel.longestDude.inMinutes.toString()
                              : profileModel.longestDude >=
                                      const Duration(seconds: 1)
                                  ? profileModel.longestDude.inSeconds
                                      .toString()
                                  : ">1",
                      unit:
                          profileModel.longestDude >= const Duration(minutes: 1)
                              ? 'Minutes'
                              : 'Seconds',
                      description: 'Longest Dude sent',
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
