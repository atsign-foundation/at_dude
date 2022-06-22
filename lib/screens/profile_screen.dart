import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import '../models/profile_model.dart';
import '../services/services.dart';
import '../widgets/switch_atsign.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final String profileName =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Text(
          profileName,
          style: const TextStyle(color: Colors.black),
        ).asGlass(),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        const AppBackground(
          alignment: Alignment.centerRight,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello Dude',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    const Text('Your Stats'),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ProfileStat(
                      stat: profileModel.dudesSent == 0
                          ? '- Dudes Sent'
                          : '${profileModel.dudesSent} Dudes sent',
                    ).asGlass(),
                    ProfileStat(
                      stat: profileModel.dudeHours.inMilliseconds == 0
                          ? '- Seconds Duding'
                          : profileModel.dudeHours >= const Duration(minutes: 1)
                              ? '${profileModel.dudeHours.inMinutes} Minutes duding'
                              : '${profileModel.dudeHours.inSeconds} Seconds duding',
                    ).asGlass(),
                    ProfileStat(
                      stat: profileModel.longestDude.inMilliseconds == 0
                          ? '- Seconds Longest dude'
                          : profileModel.longestDude >=
                                  const Duration(minutes: 1)
                              ? '${profileModel.longestDude.inMinutes} Minute longest dude'
                              : profileModel.longestDude >=
                                      const Duration(seconds: 1)
                                  ? '${profileModel.longestDude.inSeconds} Seconds longest dude'
                                  : "longest dude less than 1 second",
                    ).asGlass(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const ResetAppButton(
                      buttonText: 'Reset @sign',
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await showModalBottomSheet(
                            context: NavigationService.navKey.currentContext!,
                            builder: (context) => const AtSignBottomSheet());
                      },
                      child: const Text('Switch @Sign'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
