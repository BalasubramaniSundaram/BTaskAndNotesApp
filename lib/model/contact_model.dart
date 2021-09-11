import 'package:cloud_firestore/cloud_firestore.dart';

class BContact {
  BContact(this.name, this.phoneNumber, this.reference);

  final String name;
  final String phoneNumber;
  DocumentReference? reference;

  factory BContact.fromJson(dynamic json) => contactFromJson(json);
}

BContact contactFromJson(dynamic data) {
  var formattedPhoneNumber = data['registered_user_phone']
      .replaceAll("(", " ")
      .replaceAll(')', "")
      .replaceAll('+', "")
      .replaceAll("-", "")
      .replaceAll(" ", "")
      .trim();

  return BContact(
    data['registered_user_name'],
    formattedPhoneNumber,
    null,
  );
}
