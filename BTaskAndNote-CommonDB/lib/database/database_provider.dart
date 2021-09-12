import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

CollectionReference usersCollectionReference =
    FirebaseFirestore.instance.collection('users');

CollectionReference itemsCollectionReference =
    FirebaseFirestore.instance.collection('items');

Stream<QuerySnapshot> getUserStream() {
  return usersCollectionReference.snapshots();
}

void addUser(Map<String, dynamic> data) {
  usersCollectionReference.doc().set(data);
}

Future<bool> checkUserExistOrNot(String phoneNumber) async {
  return usersCollectionReference.get().then((value) {
    final dynamic currentUser = value.docs
        .firstWhereOrNull((element) => element['phoneNumber'] == phoneNumber);
    if (currentUser == null) {
      return false;
    } else {
      return true;
    }
  });
}

Future<QueryDocumentSnapshot> getUser(String phoneNumber) async {
  return usersCollectionReference.get().then((value) {
    final QueryDocumentSnapshot currentUser = value.docs
        .firstWhereOrNull((element) => element['phoneNumber'] == phoneNumber)!;
    return currentUser;
  });
}

Future<Map<String, int>> getItemCount(DocumentReference userReference) async {
  Map<String, int> countData = {
    'Tasks': 0,
    'Notes': 0,
    'Sent Items': 0,
    'Received Items': 0
  };

  await itemsCollectionReference.get().then((value) {
    for (var data in value.docs) {
      if (data['createdBy'] == userReference.id && data['type'] == 'tasks') {
        countData.update('Tasks', (value) => ++value);
      }

      if (data['createdBy'] == userReference.id && data['type'] == 'notes') {
        countData.update('Notes', (value) => ++value);
      }

      if (data['sentTo'].length > 0 && data['createdBy'] == userReference.id) {
        countData.update('Sent Items', (value) => ++value);
      }

      if (data['sentTo'].contains(userReference.id) &&
          data['createdBy'] != userReference.id) {
        countData.update('Received Items', (value) => ++value);
      }
    }
  });

  return Future.value(countData);
}

Map<int, List<String>> getItemsBasedOnUserSentAndReceived(
    {required String type,
    required dynamic snapshot,
    required String userReferenceId}) {
  Map<int, List<String>> filteredItems = {};

  if (type == 'sent') {
    snapshot.data!.docs.forEach((element) async {
      dynamic data = element.data();
      print(data);
      if ((data['createdBy'] == userReferenceId) && data['sentTo'].isNotEmpty) {
        for (var sentUser in data['sentTo']) {
          var index = filteredItems.length + 1;
          filteredItems[index] = [sentUser, element.reference.id];
        }
      }
    });
  } else {
    snapshot.data!.docs.forEach((element) async {
      dynamic data = element.data();
      if (data['sentTo'].isNotEmpty &&
          data['sentTo'].contains(userReferenceId)) {
        data['sentTo'].forEach((e) {
          var index = filteredItems.length + 1;
          filteredItems[index] = [data['createdBy'], element.reference.id];
        });
      }
    });
  }

  return filteredItems;
}
