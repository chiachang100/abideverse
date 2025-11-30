import 'package:logging/logging.dart';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../services/auth.dart';
import '../data/data_index.dart';

final abideverselogManageFirestore = Logger('manage-firestore');

class ManageFirestoreScreen extends StatefulWidget {
  const ManageFirestoreScreen({super.key, required this.firestore});
  final FirebaseFirestore firestore;

  @override
  State<ManageFirestoreScreen> createState() => _ManageFirestoreScreenState();
}

class _ManageFirestoreScreenState extends State<ManageFirestoreScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ManageFirestoreScreen',
        'abideverse_screen_class': 'ManageFirestoreScreenClass',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Firestore'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/xlcdapp-leading-icon.png'),
              onPressed: () {
                GoRouter.of(context).go('/joys/all');
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: FirestoreSettingsContent(firestore: widget.firestore),
      ),
    );
  }
}

class FirestoreSettingsContent extends StatelessWidget {
  const FirestoreSettingsContent({super.key, required this.firestore});
  final FirebaseFirestore firestore;

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ManageFirestoreScreen',
        'abideverse_screen_class': 'ManageFirestoreScreenClass',
      },
    );

    return ListView(
      children: <Widget>[
        FirebaseDbSection(firestore: firestore),
        CopyrightSection(),
        const SizedBox(height: 10),
      ],
    );
  }
}

class FirebaseDbSection extends StatelessWidget {
  const FirebaseDbSection({super.key, required this.firestore});
  final FirebaseFirestore firestore;

  final String xlcdFirestore = '儲藏庫初始設定和搜尋';

  void initializeJoystoreData() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'initializeJoystoreData',
        'abideverse_screen_class': 'ManageFirestoreScreenClass',
      },
    );

    // Build JoyStore Instance from local JoyStore
    JoyStore firestoreDbInstance = buildJoyStoreFromLocal();
    //JoyStore firestoreDbInstance = buildJoyStoreFromLocalWithLocale();

    // Initialize the new documents
    for (var joy in firestoreDbInstance.allJoys) {
      // final docRef = firestore.collection('joys').doc(joy.articleId.toString());
      final docRef = firestore
          .collection(joystoreName)
          .doc(joy.articleId.toString());
      // Add document
      docRef
          .set(joy.toJson())
          .onError(
            (e, _) => abideverselogManageFirestore.info(
              "[ManageFirestore] Error writing documen(t: $e",
            ),
          );
      // Read document
      docRef.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          abideverselogManageFirestore.info(
            '[ManageFirestore] $joystoreName: DocumentSnapshot added with ID: ${doc.id}:${data['id']}',
          );
        },
        onError: (e) => abideverselogManageFirestore.info(
          "[ManageFirestore] Error getting document: $e",
        ),
      );
    }
  }

  void readJoystoreData() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'readJoystoreData',
        'abideverse_screen_class': 'ManageFirestoreScreenClass',
      },
    );

    await firestore
        // .collection('joys')
        .collection(joystoreName)
        .orderBy('likes', descending: true)
        .get()
        .then((event) {
          for (var doc in event.docs) {
            abideverselogManageFirestore.info(
              "[ManageFirestore] $joystoreName: Firestore: ${doc.id} => ${doc.data()}",
            );
            var joy = Joy.fromJson(doc.data());
            abideverselogManageFirestore.info(
              "[ManageFirestore] $joystoreName: Joy: ${doc.id} => id=${joy.id}:articleId=${joy.articleId}:likes=${joy.likes}:isNew=${joy.isNew}:category=${joy.category}",
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'FirebaseDbSection',
        'abideverse_screen_class': 'ManageFirestoreScreenClass',
      },
    );

    return Card(
      // color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/photos/xlcdapp_photo_default.png',
              height: MediaQuery.of(context).size.width * (3 / 4),
              width: MediaQuery.of(context).size.width,
              //height: 120, width: 640,
              fit: BoxFit.scaleDown,
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                //backgroundColor: Colors.orange,
                backgroundColor: circleAvatarBgColor[2],
                child: Text(xlcdFirestore.substring(0, 1)),
              ),
              const SizedBox(width: 5),
              Text(
                xlcdFirestore,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Text('「笑裡藏道」: 儲藏庫初始設定和搜尋'),
          Center(
            child: ElevatedButton(
              onPressed: readJoystoreData,
              child: const Text('🔍搜尋'),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: initializeJoystoreData,
            child: const Text('⚙️初始設定'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CopyrightSection extends StatelessWidget {
  const CopyrightSection({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'CopyrightSection',
        'abideverse_screen_class': 'SettingsScreenClass',
      },
    );

    return const Row(
      children: <Widget>[
        Text('Copyright '),
        Icon(Icons.copyright),
        Text(' 2024 Chia Chang. All rights reserved.', softWrap: true),
      ],
    );
  }
}
