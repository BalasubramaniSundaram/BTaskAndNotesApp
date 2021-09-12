import 'package:cloud_firestore/cloud_firestore.dart';

class BContact implements Comparable<BContact> {
  BContact(this.name, this.phoneNumber, this.reference);

  final String name;
  final String phoneNumber;
  DocumentReference? reference;

  factory BContact.fromJson(dynamic json) => contactFromJson(json);

  @override
  int compareTo(BContact other) {
    return name.compareTo(other.name);
  }
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
