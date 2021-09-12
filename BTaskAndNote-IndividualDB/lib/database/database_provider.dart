import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

CollectionReference usersCollectionReference =
    FirebaseFirestore.instance.collection('users');

CollectionReference getTaskCollectionReference(String? id) {
  return usersCollectionReference.doc(id).collection('tasks');
}

CollectionReference getNotesCollectionReference(String? id) {
  return usersCollectionReference.doc(id).collection('notes');
}

CollectionReference sentItemCollectionReference(String? id) {
  return usersCollectionReference.doc(id).collection('sent');
}

CollectionReference receivedItemCollectionReference(String? id) {
  return usersCollectionReference.doc(id).collection('received');
}

Stream<QuerySnapshot> getUserStream() {
  return usersCollectionReference.snapshots();
}

Stream<QuerySnapshot> getTasksStream(DocumentReference userReference) {
  return getTaskCollectionReference(userReference.id).snapshots();
}

Stream<QuerySnapshot> getNotesStream(DocumentReference userReference) {
  return getNotesCollectionReference(userReference.id).snapshots();
}

void addUser(Map<String, dynamic> data) {
  usersCollectionReference.doc().set(data);
}

void addTask(DocumentReference reference, Map<String, dynamic> data) async {
  await getTaskCollectionReference(reference.id).add(data);
}

void updateTask(DocumentReference reference, DocumentReference taskReference,
    Map<String, dynamic> data) async {
  await getTaskCollectionReference(reference.id)
      .doc(taskReference.id)
      .update(data);
}

void addNote(DocumentReference reference, Map<String, dynamic> data) async {
  await getNotesCollectionReference(reference.id).add(data);
}

void updateNote(DocumentReference reference, DocumentReference notesReference,
    Map<String, dynamic> data) async {
  await getNotesCollectionReference(reference.id).doc().update(data);
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
  Map<String, int> countData = {};
  await getTaskCollectionReference(userReference.id).get().then((value) {
    countData['Tasks'] = value.docs.length;
  });

  await getNotesCollectionReference(userReference.id).get().then((value) {
    countData['Notes'] = value.docs.length;
  });

  await sentItemCollectionReference(userReference.id).get().then((value) {
    countData['Sent Items'] = value.docs.length;
  });

  await receivedItemCollectionReference(userReference.id).get().then((value) {
    countData['Received Items'] = value.docs.length;
  });

  return Future.value(countData);
}
