import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/features/joys/data/joystore.dart';
import 'package:abideverse/features/joys/data/local_joystore.dart';
import 'package:abideverse/features/joys/data/local_joystore_en_us.dart';
import 'package:abideverse/features/joys/data/local_joystore_zh_cn.dart';
import 'package:abideverse/features/joys/data/local_joystore_zh_tw.dart';
import 'package:abideverse/features/joys/models/joy.dart';

class JoyStoreService {
  JoyStoreService._();
  static final JoyStoreService instance = JoyStoreService._();

  late JoyStore joystore;
  final _log = Logger("JoyStoreService");

  /// Initialize JoyStore: load local first, then optionally override with Firestore
  Future<void> initialize({bool prod = true}) async {
    joystore = loadLocalJoyStore();
    joystore = await loadFirestoreOrLocal(prod: prod);
  }

  JoyStore loadLocalJoyStore() {
    final js = JoyStore();
    List<Map<String, dynamic>> selectedLocale = localJoyStoreForZhTw;

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.enUS:
        selectedLocale = localJoyStoreForEnUs;
        break;
      case LocaleConstants.zhCN:
        selectedLocale = localJoyStoreForZhCn;
        break;
      case LocaleConstants.zhTW:
      default:
        selectedLocale = localJoyStoreForZhTw;
        break;
    }

    for (var joyMap in selectedLocale) {
      final joy = Joy.fromJson(joyMap);
      js.addJoy(
        id: joy.id,
        articleId: joy.articleId,
        title: joy.title,
        scriptureName: joy.scriptureName,
        scriptureVerse: joy.scriptureVerse,
        prelude: joy.prelude,
        laugh: joy.laugh,
        photoUrl: joy.photoUrl,
        videoId: joy.videoId,
        videoName: joy.videoName,
        talk: joy.talk,
        likes: joy.likes,
        type: joy.type,
        isNew: joy.isNew,
        category: joy.category,
      );
    }

    return js;
  }

  Future<JoyStore> loadFromFirestore() async {
    final query = FirebaseFirestore.instance
        .collection(LocaleConstants.joystoreName)
        .orderBy("articleId")
        .withConverter<Joy>(
          fromFirestore: (snap, _) => Joy.fromJson(snap.data()!),
          toFirestore: (joy, _) => joy.toJson(),
        );

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      _log.warning("Firestore returned empty JoyStore list.");
      return joystore;
    }

    final js = JoyStore();
    bool logged = false;

    for (var doc in snapshot.docs) {
      final joy = doc.data(); // Type: Joy? due to converter
      if (joy == null) continue;

      if (!logged) {
        _log.info(
          "[Firestore] ${doc.id}: id=${joy.id}, articleId=${joy.articleId}, likes=${joy.likes}, isNew=${joy.isNew}, category=${joy.category}",
        );
        logged = true;
      }

      js.addJoy(
        id: joy.id,
        articleId: joy.articleId,
        title: joy.title,
        scriptureName: joy.scriptureName,
        scriptureVerse: joy.scriptureVerse,
        prelude: joy.prelude,
        laugh: joy.laugh,
        photoUrl: joy.photoUrl,
        videoId: joy.videoId,
        videoName: joy.videoName,
        talk: joy.talk,
        likes: joy.likes,
        type: joy.type,
        isNew: joy.isNew,
        category: joy.category,
      );
    }

    return js;
  }

  Future<JoyStore> loadFirestoreOrLocal({bool prod = true}) async {
    joystore = loadLocalJoyStore();

    if (!AppConfig.useFilestore || !prod) return joystore;

    joystore = await loadFromFirestore();
    return joystore;
  }
}
