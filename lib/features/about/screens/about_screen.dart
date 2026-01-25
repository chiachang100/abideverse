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
        ResourceCopyrightNoticeSection(),
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

  final String abideVerseAppLink = 'https://abideverse.web.app/';

  final String joyolordComLink = 'https://www.joyolord.com/';

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
            OverflowBar(
              spacing: 10,
              overflowSpacing: 20,
              alignment: MainAxisAlignment.center,
              overflowAlignment: OverflowBarAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(bibleGatewayLink),
                  child: Text(LocaleKeys.onlineBible.tr()),
                ),
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(abideVerseAppLink),
                  child: Text(LocaleKeys.abideverseApp.tr()),
                ),
                OutlinedButton(
                  onPressed: () => lauchTargetUrl(joyolordComLink),
                  child: Text(LocaleKeys.joyolordCom.tr()),
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

class ResourceCopyrightNoticeSection extends StatefulWidget {
  const ResourceCopyrightNoticeSection({super.key});

  @override
  State<ResourceCopyrightNoticeSection> createState() =>
      _ResourceCopyrightNoticeSectionState();
}

class _ResourceCopyrightNoticeSectionState
    extends State<ResourceCopyrightNoticeSection> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ResourceCopyrightNoticeSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    // No Copyright - Public Domain
    return Column(
      children: [
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
                Text(
                  "No Copyright - Public Domain",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    "1. Berean Standard Bible (BSB). \n\nThe Holy Bible, Berean Standard Bible, BSB is produced in cooperation with Bible Hub, Discovery Bible, OpenBible.com, and the Berean Bible Translation Committee. This text of God's Word has been dedicated to the public domain. The Berean Bible and Majority Bible texts are officially dedicated to the public domain as of April 30, 2023. All uses are freely permitted. (https://berean.bible/terms.htm).",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "2. The World English Bible (WEB). \n\nBible text used in this application: World English Bible Update (WEBU). (c) Public Domain — dedicated to the public domain by the editors and translators. The name “World English Bible” is a trademark of eBible.org. (https://worldenglish.bible/) (https://ebible.org/)\n\nThe World English Bible (WEB) is a Public Domain (no copyright) Modern English translation of the Holy Bible. That means that you may freely copy it in any form, including electronic and print formats. The World English Bible is based on the American Standard Version (ASV) of the Holy Bible first published in 1901.",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "3. The Original 'Chinese Union Version (和合本)' (1919). \n\nThe original CUV (和合本), first published in 1919, is in the Public Domain worldwide. Copyright Status: Expired. Usage: You can freely copy, distribute, and quote from the 1919 text (both Traditional and Simplified) without asking for permission or paying royalties.",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "4. Chinese Union Version New Punctuation Versions (CUVNP/新標點和合本). \n\nThe version most people use today is the 'New Punctuation' version (新標點和合本), which updated the archaic punctuation and names of the 1919 original. Copyright Status: This is a grey area. While the text is public domain, the layout and specific punctuation are often claimed by the United Bible Societies (UBS). Safe Practice: If you are using a digital version from a site like BibleGateway or a physical Bible from a specific publisher, it is polite and legally safer to credit the source.",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "5. YouVersion of Bible.com. \n\nScripture quotations are from The Holy Bible, [NIV, ESV, WEB, CUVNP] of YouVersion. Provided courtesy of Bible.com. For more information, visit https://help.youversion.com/l/en/article/o8t2xmy9q2-copyright.",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "6. BibleGateway.com. \n\nScripture quotations are from The Holy Bible, [NIV, ESV, WEB, CUVNP]. Provided courtesy of BibleGateway.com. For more information, visit https://www.biblegateway.com/.",
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16), // Spacing between cards
        // Copyright Notices
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
                Text(
                  "Copyright Notices",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    "1. The New International Version (NIV) Copyright Notice. \n\nScripture quotations taken from The Holy Bible, New International Version®, NIV®. Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.® Used by permission. All rights reserved worldwide.",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "2. The English Standard Version (ESV) Copyright Notice. \n\nScripture quotations are from The ESV® Bible (The Holy Bible, English Standard Version®), © 2001 by Crossway, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.",
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    "3. 《笑裡藏道》書籍版權聲明。 \n\n© 2016, 天恩出版社, 版權所有, 請勿翻印。 (網址: http://www.graceph.com)",
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
