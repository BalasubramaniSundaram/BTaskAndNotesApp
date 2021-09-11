import 'package:cloud_firestore/cloud_firestore.dart';

class BUser {
  BUser(this.name, this.phoneNumber, this.reference);

  final String name;
  final String phoneNumber;
  DocumentReference reference;
}
