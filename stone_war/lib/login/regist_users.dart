import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stone_war/login/random_generate.dart';

Future<void> registUsers(
  String nickName,
  UserCredential user,
) async {
  //DocumentReference gameRef = FirebaseFirestore.instance.collection('o_mok').doc();

  List<String> classicSkins = [
    "classicGirl1.webp",
    "classicGirl2.webp",
    "classicBoy1.webp",
    "classicBoy2.webp",
  ];
  String uid = FirebaseAuth.instance.currentUser!.uid;
  //print('Current UID: $uid');

  // Firestore에 저장
  Map<String, dynamic> userData = {
    "createdAt": FieldValue.serverTimestamp(),
    "nickName": nickName,
    "uid": uid,
    "friends": [],
    "playerSkin": classicSkins[random.nextInt(4)],
    "playerSkins": classicSkins,
    "dolSkins": {
      "sa_mok": ['classic'],
      "o_mok": ['classic'],
      "yuk_mok": ['classic'],
      "dol_mok": ['classic'],
    },
    "boardSkins": {
      "sa_mok": ['classic'],
      "o_mok": ['classic'],
      "yuk_mok": ['classic'],
      "dol_mok": ['classic'],
    },
    "currentDolSkins": {
      "sa_mok": ['classic'],
      "o_mok": ['classic'],
      "yuk_mok": ['classic'],
      "dol_mok": ['classic'],
    },
    "currentBoardSkins": {
      "sa_mok": ['classic'],
      "o_mok": ['classic'],
      "yuk_mok": ['classic'],
      "dol_mok": ['classic'],
    },
    "winningStreak": {
      //연승은 양수로, 연패는 음수로 적용.
      "sa_mok": 0,
      "o_mok": 0,
      "yuk_mok": 0,
      "dol_mok": 0,
    },
    "gameRatings": {
      "sa_mok": {
        "rating": 1000,
        "ratingDeviation": 350,
        "ratingVolatility": 0.06,
      },
      "o_mok": {
        "rating": 1000,
        "ratingDeviation": 350,
        "ratingVolatility": 0.06,
      },
      "yuk_mok": {
        "rating": 1000,
        "ratingDeviation": 350,
        "ratingVolatility": 0.06,
      },
      "dol_mok": {
        "rating": 1000,
        "ratingDeviation": 350,
        "ratingVolatility": 0.06,
      },
    },
    "gameCounts": {
      "sa_mok": {
        "win": 0,
        "lose": 0,
        "games": 0,
        "matchIds": [],
        //전적인데 반대로 매치를 기록하는 곳에서 가져오는게 더 좋은가? 이러면 데이터를 2번씩 저장하니까?
      },
      "o_mok": {
        "win": 0,
        "lose": 0,
        "games": 0,
        "matchIds": [],
      },
      "yuk_mok": {
        "win": 0,
        "lose": 0,
        "games": 0,
        "matchIds": [],
      },
      "dol_mok": {
        "win": 0,
        "lose": 0,
        "games": 0,
        "matchIds": [],
      },
    }
  };
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .set(userData);
  } catch (e) {
    //print(e);
  }
}
