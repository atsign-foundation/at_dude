import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';
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
        centerTitle: true,
        title: Text(profileName),
      ),
      body: Padding(
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
                  ProfileStat(stat: '${profileModel.dudesSent} Dudes sent'),
                  ProfileStat(
                      stat: profileModel.dudeHours > const Duration(minutes: 1)
                          ? '${profileModel.dudeHours.inMinutes} Minutes duding'
                          : '${profileModel.dudeHours.inSeconds} Seconds duding'),
                  ProfileStat(
                      stat: profileModel.dudeHours > const Duration(minutes: 1)
                          ? '${profileModel.longestDude.inMinutes} Minute longest dude'
                          : '${profileModel.longestDude.inSeconds} Seconds longest dude'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Row(
                children: [
                  const ResetAppButton(
                    buttonText: 'Reset @sign',
                    width: 210,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                          context: NavigationService.navKey.currentContext!,
                          builder: (context) => AtSignBottomSheet());
                    },
                    child: const Text('Switch @Sign'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
