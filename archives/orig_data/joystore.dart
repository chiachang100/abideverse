import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scripture.dart';
import 'joy.dart';
import 'global_config.dart';
import 'local_joystore.dart';
import 'local_joystore_en_us.dart';
import 'local_joystore_zh_cn.dart';
import 'local_joystore_zh_tw.dart';

final xlcdlogJoyStore = Logger('joystore');

const int topList = 7;
const int allList = 0;

class JoyStore {
  List<Joy> allJoys = [];
  List<Scripture> allScriptures = [];

  void addJoy({
    required int id,
    required int articleId,
    required String title,
    required String scriptureName,
    required String scriptureVerse,
    required String prelude,
    required String laugh,
    required String photoUrl,
    required String videoId,
    required String videoName,
    required String talk,
    required int likes,
    required int type,
    required bool isNew,
    required String category,
  }) {
    var scripture = allScriptures.firstWhere(
      (scripture) => scripture.name == scriptureName,
      orElse: () {
        final value = Scripture(
          allScriptures.length,
          articleId,
          title,
          scriptureName,
          scriptureVerse,
        );
        allScriptures.add(value);
        return value;
      },
    );
    var joy = Joy(
      id: allJoys.length,
      articleId: articleId,
      title: title,
      scriptureName: scriptureName,
      scriptureVerse: scriptureVerse,
      prelude: prelude,
      laugh: laugh,
      photoUrl: photoUrl,
      videoId: videoId,
      videoName: videoName,
      talk: talk,
      likes: likes,
      type: type,
      isNew: isNew,
      category: category,
      scripture: scripture,
    );

    scripture.joys.add(joy);
    allJoys.add(joy);
  }

  Joy getJoy(String id) {
    return allJoys[int.parse(id)];
  }

/* 
  List<Joy> getSortedList(List<Joy> listOfJoys, int topOnes) {
    // Reindex the value of id
    //listOfJoys.sort((a, b) => a.likes.compareTo(b.likes)); // ascending
    listOfJoys.sort((a, b) => b.likes.compareTo(a.likes)); // descending
    var index = 0;
    while (index < listOfJoys.length) {
      listOfJoys[index].id = index;
      index++;
    }

    // Return the sorted order
    allJoys = listOfJoys.toList();

    if (topOnes > 0) {
      // Return the selected list
      return listOfJoys.take(topOnes).toList();
    } else {
      // Return the All List
      allJoys = listOfJoys.toList();
      return listOfJoys.toList();
    }
  }
 */

  List<Joy> getTopList(List<Joy> listOfJoys, int topOnes) {
    List<Joy> joyList;

    if (topOnes > 0) {
      // Return the selected list
      joyList = listOfJoys.take(topOnes).toList();
    } else {
      // Return the All List
      joyList = listOfJoys;
    }

    //joyList.sort((a, b) => a.likes.compareTo(b.likes)); // ascending
    joyList.sort((a, b) => b.likes.compareTo(a.likes)); // descending

    return joyList;
  }

  List<Joy> get wholeJoys => [
        ...allJoys,
      ];

  List<Joy> get likeJoys => [
        ...getTopList(allJoys, topList).where((joy) => (joy.likes > 0)),
      ];

  List<Joy> get newJoys => [
        ...allJoys.where((joy) => joy.isNew),
      ];
}

// Build JoyStore Instance from Remote Firestore JoyStore
JoyStore buildJoyStoreFromFirestore(JoyStore joystore) {
  final joysRef = FirebaseFirestore.instance
      // .collection('joys')
      .collection(joystoreName)
      .orderBy("articleId", descending: false)
      .withConverter<Joy>(
        fromFirestore: (snapshots, _) => Joy.fromJson(snapshots.data()!),
        toFirestore: (joy, _) => joy.toJson(),
      );
  joysRef.get().then((event) {
    if (event.docs.isNotEmpty) {
      var js = JoyStore();
      var isLogged = false;
      for (var doc in event.docs) {
        var joy = doc.data();
        if (!isLogged) {
          xlcdlogJoyStore.info(
              "[JoyStore] $joystoreName: Firestore: ${doc.id} => id=${doc.data().id}:articleId=${doc.data().articleId}:likes=${doc.data().likes}:isNew=${doc.data().isNew}:category=${doc.data().category}");
          xlcdlogJoyStore.info(
              "[JoyStore] $joystoreName: JoyStore:  ${doc.id} => id=${joy.id}:articleId=${doc.data().articleId}:likes=${joy.likes}:isNew=${joy.isNew}:category=${joy.category}");
          isLogged = true;
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
      joystoreInstance = js;
      return js;
    }
  });

  return joystore;
}

/* 
// Build JoyStore Instance from local JoyStore
JoyStore buildJoyStoreFromLocal() {
  var js = JoyStore();
  for (var joyMap in localJoyStore) {
    var joy = Joy.fromJson(joyMap);
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
 */

// Build JoyStore Instance from local JoyStore
JoyStore buildJoyStoreFromLocal() {
  var js = JoyStore();
  var joystoreByLocale = localJoyStoreForZhTw;
  switch (joysCurrentLocale) {
    case LOCALE_EN_US:
      joystoreByLocale = localJoyStoreForEnUs;
    case LOCALE_ZH_CN:
      joystoreByLocale = localJoyStoreForZhCn;
    case LOCALE_ZH_TW:
      joystoreByLocale = localJoyStoreForZhTw;
    default:
      joystoreByLocale = localJoyStoreForZhTw;
  }

  //for (var joyMap in localJoyStore) {
  for (var joyMap in joystoreByLocale) {
    var joy = Joy.fromJson(joyMap);
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

JoyStore buildJoyStoreFromFirestoreOrLocal({prod = true}) {
  // Build JoyStore Instance from local JoyStore
  var js = buildJoyStoreFromLocal();
  if (useFilestore) {
    if (prod) {
      // Build JoyStore Instance from Firestore JoyStore
      js = buildJoyStoreFromFirestore(js);
    }
  }
  return js;
}
