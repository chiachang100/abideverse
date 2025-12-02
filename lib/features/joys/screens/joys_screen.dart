import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../auth/data/auth_repository.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

import 'package:abideverse/src/data/global_config.dart';

final abideverselogJoysScreen = Logger('joyscreen');

class JoysScreen extends StatefulWidget {
  final Widget child;
  final ValueChanged<int> onTap;
  final int selectedIndex;

  const JoysScreen({
    required this.child,
    required this.onTap,
    required this.selectedIndex,
    super.key,
  });

  @override
  State<JoysScreen> createState() => _JoysScreenState();
}

class _JoysScreenState extends State<JoysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': '笑裡藏道HomeScreen',
        'abideverse_screen_class': 'JoysScreenClass',
      },
    );

    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabIndexChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController.index = widget.selectedIndex;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('笑裡藏道'),
        title: Text(LocaleKeys.appTitle.tr()),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.png'),
              onPressed: () {
                GoRouter.of(context).go('/joys/all');
              },
            );
          },
        ),
        //backgroundColor: Colors.orange,
        /*         bottom: TabBar(
          //isScrollable: true,
          controller: _tabController,
          tabs: [
            Tab(
              // text: '喜樂榜',
              text: LocaleKeys.topList.tr(),
              icon: const Icon(Icons.format_list_numbered, color: Colors.red),
            ),
            Tab(
              // text: '新出爐',
              text: LocaleKeys.newList.tr(),
              icon:
                  const Icon(Icons.rocket_launch_outlined, color: Colors.green),
            ),
            Tab(
              // text: '目錄表',
              text: LocaleKeys.allList.tr(),
              icon: const Icon(Icons.collections_outlined,
                  color: Colors.blueAccent),
            ),
          ],
        ),
 */
        actions: <Widget>[
          if (turnonSignIn)
            TextButton(
              child: Text(LocaleKeys.signOut.tr()),
              onPressed: () async {
                await JoystoreAuth.of(context).signOut();
                abideverselogJoysScreen.info(
                  '[JoysScreen] User just signed out!',
                );

                FirebaseAnalytics.instance.logEvent(
                  name: 'signin_view',
                  parameters: {
                    'abideverse_screen': 'UserSignedOut',
                    'abideverse_screen_class': 'SettingsScreenClass',
                  },
                );
              },
            ),
        ],
      ),
      body: widget.child,
    );
  }

  void _handleTabIndexChanged() {
    widget.onTap(_tabController.index);
  }
}
