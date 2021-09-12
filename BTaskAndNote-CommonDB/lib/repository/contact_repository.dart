import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:sharing_app/model/contact_model.dart';

class BContactRepository {
  List<BContact> contacts = List.empty(growable: true);

  void updateDocumentReferenceToExistOne(AsyncSnapshot snapshot) {
    for (var doc in snapshot.data!.docs) {
      final BContact? data = contacts.firstWhereOrNull(
          (element) => element.phoneNumber == doc['phoneNumber']);
      data?.reference = doc.reference;
    }
  }

  List<BContact> getExistingUsers(String skipThisNumber) {
    return contacts
        .where((value) => value.reference != null)
        .skipWhile((value) => value.phoneNumber == skipThisNumber)
        .toList();
  }

  List<BContact> getNonUsers() {
    return contacts.skipWhile((value) => value.reference != null).toList();
  }
}
