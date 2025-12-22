import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/ui_constants.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/widgets/copyright.dart';

import 'package:easy_localization/easy_localization.dart';

final logAbout = Logger('about');

const String riverbankSite = 'https://bookstore.rolcc.net/';

const String tiendaoSite =
    'https://www.ustiendao.com/22795917.html?srsltid=AfmBOoo3pbaTJvSOFuh10wbAeeggZpmTDq-yJ6kM7_sRCPWmP6Rho36i';

const String gracephSite = 'https://graceph.com/product/01i072/';

Future<void> lauchTargetUrl(String urlString) async {
  Uri urlForPurchasingBook = Uri.parse(urlString);
  if (!await launchUrl(urlForPurchasingBook)) {
    //throw Exception('無法啟動 $urlForPurchasingBook');
  }
}

int circleAvatarBgColorIndex = 0;

Color getNextCircleAvatarBgColor() {
  Color nextColor =
      UIConstants.circleAvatarBgColors[circleAvatarBgColorIndex %
          UIConstants.circleAvatarBgColors.length];
  circleAvatarBgColorIndex++;
  return nextColor;
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, required this.firestore});
  final FirebaseFirestore firestore;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': '笑裡藏道簡介Screen',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${LocaleKeys.about.tr()} (v${AppConfig.appVersion})'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.png'),
              onPressed: () {
                // Navigate to the joys list
                Routes(context).goJoys();
              },
            );
          },
        ),
      ),
      body: SafeArea(child: AboutContent(firestore: widget.firestore)),
    );
  }
}

class AboutContent extends StatefulWidget {
  const AboutContent({super.key, required this.firestore});
  final FirebaseFirestore firestore;

  @override
  State<AboutContent> createState() => _AboutContentState();
}

class _AboutContentState extends State<AboutContent> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'AboutContent',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return ListView(
      children: const <Widget>[
        QRCodeSection(),
        BookIntroSection(),
        BookAuthorSection(),
        BookPraiseSection(),
        AppDeveloperSection(),
        CopyrightSection(),
        SizedBox(height: 10),
      ],
    );
  }
}

class QRCodeSection extends StatefulWidget {
  const QRCodeSection({super.key});

  @override
  State<QRCodeSection> createState() => _QRCodeSectionState();
}

class _QRCodeSectionState extends State<QRCodeSection> {
  final String abideverseAppLink = 'https://abideverse.web.app';
  final String joyolordComLink = 'https://joyolord.com';

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'QRCodeSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return Column(
      children: <Widget>[
        Card(
          // color: Colors.yellow[50],
          elevation: 8.0,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: Image.asset(
                        'assets/icons/abideverse_qrcode.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Text(
                  // xabideverseQrCode Intro,
                  LocaleKeys.abideverseQrCode.tr(),
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  '${LocaleKeys.useQrCode.tr()} ${LocaleKeys.abideverseApp.tr()}',
                ),
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton(
                    //onPressed: visitYouTubePlaylist,
                    onPressed: () => lauchTargetUrl(abideverseAppLink),
                    child: Text(LocaleKeys.abideverseApp.tr()),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Add vertical spacing here
        const SizedBox(height: 20.0), // Adjust the height value as needed

        Card(
          // color: Colors.yellow[50],
          elevation: 8.0,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 300,
                      width: 300, // adjust as needed
                      child: Image.asset(
                        'assets/icons/joyolord_com_qrcode.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Text(
                  // joyolordComQrCode,
                  LocaleKeys.joyolordComQrCode.tr(),
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  '${LocaleKeys.useQrCode.tr()} ${LocaleKeys.joyolordCom.tr()}',
                ),
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton(
                    //onPressed: visitYouTubePlaylist,
                    onPressed: () => lauchTargetUrl(joyolordComLink),
                    child: Text(LocaleKeys.joyolordCom.tr()),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BookIntroSection extends StatefulWidget {
  const BookIntroSection({super.key});

  @override
  State<BookIntroSection> createState() => _BookIntroSectionState();
}

class _BookIntroSectionState extends State<BookIntroSection> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'BookIntroSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return Card(
      // color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: SizedBox(
                height: 400,
                width: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    'assets/photos/xlcdapp_photo_default.png',
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Text(
              // xlcdBookIntro,
              LocaleKeys.bookIntro.tr(),
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10),
            Text(LocaleKeys.bookIntroSubtitle.tr()),
            const SizedBox(height: 10),
            Text(LocaleKeys.bookIntroContent.tr()),
            const SizedBox(height: 10),
            OverflowBar(
              spacing: 10,
              overflowSpacing: 20,
              alignment: MainAxisAlignment.center,
              overflowAlignment: OverflowBarAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(gracephSite),
                  child: Text(LocaleKeys.gracephBookStore.tr()),
                ),
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(riverbankSite),
                  child: Text(LocaleKeys.riverbankBookStore.tr()),
                ),
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(tiendaoSite),
                  child: Text(LocaleKeys.tiendaoBookStore.tr()),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class BookAuthorSection extends StatefulWidget {
  const BookAuthorSection({super.key});

  @override
  State<BookAuthorSection> createState() => _BookAuthorSectionState();
}

class _BookAuthorSectionState extends State<BookAuthorSection> {
  final String youtubePlaylistLink =
      'https://www.youtube.com/playlist?list=PLFyg5v4HpNhVEKQd7IGhXmz_a4dEbQgme';

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'BookAuthorSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return Card(
      // color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(
                      'assets/photos/pastor_cheng_photo.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              LocaleKeys.bookAuthor.tr(),
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10),
            Text(LocaleKeys.bookAuthorSubtitle.tr()),
            const SizedBox(height: 10),
            Text(LocaleKeys.bookAuthorContent.tr()),
            Center(
              child: OutlinedButton(
                //onPressed: visitYouTubePlaylist,
                onPressed: () => lauchTargetUrl(youtubePlaylistLink),
                child: Text(LocaleKeys.bookAuthorYouTube.tr()),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class BookPraiseSection extends StatefulWidget {
  const BookPraiseSection({super.key});

  @override
  State<BookPraiseSection> createState() => _BookPraiseSectionState();
}

class _BookPraiseSectionState extends State<BookPraiseSection> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'BookPraiseSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return Card(
      // color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  height: 400,
                  width: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.asset(
                      'assets/photos/xlcdapp_photo_default.png',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              LocaleKeys.bookPraisesTitle.tr(),
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10),
            ListTile(
              // tileColor: Colors.yellow[50],
              title: Text(LocaleKeys.bookPraisesSubtitle.tr()),
            ),
            const Divider(height: 0),
            ListTile(title: Text(LocaleKeys.bookPraises1.tr())),
            const Divider(height: 0),
            ListTile(
              // tileColor: Colors.yellow[50],
              title: Text(LocaleKeys.bookPraises2.tr()),
            ),
            const Divider(height: 0),
            ListTile(title: Text(LocaleKeys.bookPraises3.tr())),
            const Divider(height: 0),
            ListTile(
              // tileColor: Colors.yellow[50],
              title: Text(LocaleKeys.bookPraises4.tr()),
            ),
            const Divider(height: 0),
            ListTile(title: Text(LocaleKeys.bookPraises5.tr())),
            const SizedBox(height: 10),
            OverflowBar(
              spacing: 10,
              overflowSpacing: 20,
              alignment: MainAxisAlignment.center,
              overflowAlignment: OverflowBarAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(gracephSite),
                  child: Text(LocaleKeys.gracephBookStore.tr()),
                ),
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(riverbankSite),
                  child: Text(LocaleKeys.riverbankBookStore.tr()),
                ),
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(tiendaoSite),
                  child: Text(LocaleKeys.tiendaoBookStore.tr()),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class AppDeveloperSection extends StatefulWidget {
  const AppDeveloperSection({super.key});

  @override
  State<AppDeveloperSection> createState() => _AppDeveloperSectionState();
}

class _AppDeveloperSectionState extends State<AppDeveloperSection> {
  final String bibleGatewayLink =
      'https://www.biblegateway.com/passage/?search=%E5%B8%96%E6%92%92%E7%BE%85%E5%B0%BC%E8%BF%A6%E5%89%8D%E6%9B%B8+5%3A16-18&version=CUVMPT';

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'AppDevelopeSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return Card(
      // color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                  child: Image.asset(
                    'assets/photos/joy_pray_thanks.png',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                ),
              ),
            ),
            Text(
              LocaleKeys.appDeveloper.tr(),
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10),
            Text(LocaleKeys.appDeveloperSubtitle.tr()),
            const SizedBox(height: 10),
            Text(LocaleKeys.appDeveloperContent.tr()),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton(
                //onPressed: visitBibleWebsite,
                onPressed: () => lauchTargetUrl(bibleGatewayLink),
                child: Text(LocaleKeys.onlineBible.tr()),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
