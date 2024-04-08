import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final CollectionReference gamesCollection = FirebaseFirestore.instance.collection('games');


  Future getGameData(String name, String description) async {
    return await gamesCollection.doc().get().then((value) {
      return value.data();
    });
  }


  
}
