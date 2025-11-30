# Chia's Notes

## Firebase Local Emulator Suite

- [Install and Configure Local Emulator Suite](https://firebase.google.com/docs/emulator-suite/install_and_configure)

- `firebase init emulators`

  - `firebase.json`
  - `.firebaserc`

- Specifying Java options

  - `export JAVA_TOOL_OPTIONS="-Xmx4g"`

- Start up emulators

  - `firebase emulators:start --import c:\ws\fb_emulators --export-on-exit`
  - `firebase emulators:exec scriptpath`

- `Theme.of(context).textTheme.`

```
       displayLarge = displayLarge ?? headline1,
       displayMedium = displayMedium ?? headline2,
       displaySmall = displaySmall ?? headline3,
       headlineMedium = headlineMedium ?? headline4,
       headlineSmall = headlineSmall ?? headline5,
       titleLarge = titleLarge ?? headline6,
       titleMedium = titleMedium ?? subtitle1,
       titleSmall = titleSmall ?? subtitle2,
       bodyLarge = bodyLarge ?? bodyText1,
       bodyMedium = bodyMedium ?? bodyText2,
       bodySmall = bodySmall ?? caption,
       labelLarge = labelLarge ?? button,
       labelSmall = labelSmall ?? overline;

/// | NEW NAME       | OLD NAME  | SIZE |  WEIGHT |  SPACING |             |
/// |----------------|-----------|------|---------|----------|-------------|
/// | displayLarge   | headline1 | 96.0 | light   | -1.5     |             |
/// | displayMedium  | headline2 | 60.0 | light   | -0.5     |             |
/// | displaySmall   | headline3 | 48.0 | regular |  0.0     |             |
/// | headlineMedium | headline4 | 34.0 | regular |  0.25    |             |
/// | headlineSmall  | headline5 | 24.0 | regular |  0.0     |             |
/// | titleLarge     | headline6 | 20.0 | medium  |  0.15    |             |
/// | titleMedium    | subtitle1 | 16.0 | regular |  0.15    |             |
/// | titleSmall     | subtitle2 | 14.0 | medium  |  0.1     |             |
/// | bodyLarge      | bodyText1 | 16.0 | regular |  0.5     | (bodyText1) |
/// | bodyMedium     | bodyText2 | 14.0 | regular |  0.25    | (bodyText2) |
/// | labelLarge     | button    | 14.0 | medium  |  1.25    |             |
/// | bodySmall      | caption   | 12.0 | regular |  0.4     |             |
/// | labelSmall     | overline  | 10.0 | regular |  1.5     |             |

```

- Firestore Rule for Production

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read access, but only content owners can write
    match /some_collection/{document} {
      allow read: if true
      allow write: if request.auth != null && request.auth.uid == request.resource.data.author_uid
    }
  }
}
```

- Firestore Rule for Test

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // This rule allows anyone with your Firestore database reference to view, edit,
    // and delete all data in your Firestore database. It is useful for getting
    // started, but it is configured to expire after 30 days because it
    // leaves your app open to attackers. At that time, all client
    // requests to your Firestore database will be denied.
    //
    // Make sure to write security rules for your app before that time, or else
    // all client requests to your Firestore database will be denied until you Update
    // your rules
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2024, 12, 31);
    }
  }
}
```

---

```
=== Project Setup

First, let's associate this project directory with a Firebase project.
You can create multiple project aliases by running firebase use --add,
but for now we'll just set up a default project.

i  Using project abideverse (abideverse)

=== Emulators Setup
=== Emulators Setup
? Which Firebase emulators do you want to set up? Press Space to select emulators, then Enter to confirm your choices.
Authentication Emulator, Firestore Emulator, Database Emulator, Hosting Emulator
i  Port for auth already configured: 9099
i  Port for firestore already configured: 8080
i  Port for database already configured: 9000
i  Port for hosting already configured: 5000
i  Emulator UI already enabled with port: (automatic)
? Would you like to download the emulators now? Yes
```

## Updating to NavigationBar

- [Updating BottomNavigationBar to NavigationBar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)

```
Updating to NavigationBar
The NavigationBar widget's visuals are a little bit different, see the Material 3 spec at m3.material.io/components/navigation-bar/overview for more details.

The NavigationBar widget's API is also slightly different. To update from BottomNavigationBar to NavigationBar, you will need to make the following changes.

Instead of using BottomNavigationBar.items, which takes a list of BottomNavigationBarItems, use NavigationBar.destinations, which takes a list of widgets. Usually, you use a list of NavigationDestination widgets. Just like BottomNavigationBarItems, NavigationDestinations have a label and icon field.

Instead of using BottomNavigationBar.onTap, use NavigationBar.onDestinationSelected, which is also a callback that is called when the user taps on a navigation bar item.

Instead of using BottomNavigationBar.currentIndex, use NavigationBar.selectedIndex, which is also an integer that represents the index of the selected destination.

You may also need to make changes to the styling of the NavigationBar, see the properties in the NavigationBar constructor for more details.
```

---

```
  getData() async {
    var db = FirebaseFirestore.instance;
    var categoryList = [];
    await db.collection('categories').doc(value).get().then((DocumentSnapshot doc) {
      var listSubCol = doc["categoryCollection"];
      listSubCol.forEach((id) {
        db.collection('categories').doc(value).collection(id).get().then((snapshot) {
          snapshot.docs.forEach((element) {
            categoryList.add(element.data());
          });
        });
        return categoryList;
      });
    });
    return categoryList;
  }
```

---

```
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following TypeErrorImpl was thrown building StreamBuilder<QuerySnapshot<Object?>>(dirty, state:
_StreamBuilderBaseState<QuerySnapshot<Object?>, AsyncSnapshot<QuerySnapshot<Object?>>>#0b658):
Expected a value of type 'List<DocumentSnapshot<Object?>>', but got one of type '_JsonQuerySnapshot'

The relevant error-causing widget was:
  StreamBuilder<QuerySnapshot<Object?>>
  StreamBuilder:file:///c:/src/git/chiachang100/abideverse/lib/media_list/recommended_media.dart:399:18

```

---

- Display a SnackBar

```
          // IconButton(
          //   icon: const Icon(Icons.settings_outlined),
          //   tooltip: 'Settings',
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('There are currently no settings available.'),
          //       ),
          //     );
          //   },
          // ),

```

---
