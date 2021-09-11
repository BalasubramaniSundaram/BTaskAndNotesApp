import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/model/contact_model.dart';
import 'package:sharing_app/platform_channel/platform_method_channel.dart';
import 'package:sharing_app/repository/contact_repository.dart';
import 'package:sharing_app/repository/user_repository.dart';

class ShareWithContacts extends StatefulWidget {
  const ShareWithContacts(
      {Key? key, required this.title, required this.database, this.reference})
      : super(key: key);

  final String title;
  final String database;
  final DocumentReference? reference;

  @override
  _ShareWithContactsState createState() => _ShareWithContactsState();
}

class _ShareWithContactsState extends State<ShareWithContacts> {
  late BContactRepository contactRepository;
  late BUserRepository userRepository;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    providePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            );
          } else {
            contactRepository.updateDocumentReferenceToExistOne(snapshot);
            final List<BContact> existUsers = contactRepository
                .getExistingUsers(userRepository.currentUser!.phoneNumber);
            final List<BContact> nonUsers = contactRepository.getNonUsers();

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Existing Users',
                        style: TextStyle(fontSize: 20),
                      )),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: ListView(
                    children: List.generate(existUsers.length, (index) {
                      return ListTile(
                        leading: Icon(Icons.face),
                        title: Text(existUsers[index].name),
                        subtitle: Text(existUsers[index].phoneNumber),
                        trailing: widget.title == 'Contacts'
                            ? null
                            : IconButton(
                                onPressed: () async {
                                  /// Getting the db of tasks and notes from current user
                                  var dbReference = usersCollectionReference
                                      .doc(userRepository
                                          .currentUser!.reference.id)
                                      .collection(widget.database);

                                  await dbReference
                                      .doc(widget.reference!.id)
                                      .get()
                                      .then((value) async {
                                    /// Add some properties
                                    var sentItem = value.data()!;
                                    sentItem['from'] =
                                        userRepository.currentUser!.name;
                                    sentItem['to'] = existUsers[index].name;

                                    /// Add the task or notes to received section
                                    usersCollectionReference
                                        .doc(existUsers[index].reference!.id)
                                        .collection('received')
                                        .add(sentItem);

                                    /// Add the task or notes to sent section
                                    usersCollectionReference
                                        .doc(userRepository
                                            .currentUser!.reference.id)
                                        .collection('sent')
                                        .add(sentItem);

                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              '${widget.database} successfully sent to ${existUsers[index].name}'),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await sendNotification(
                                                          existUsers[index]
                                                              .reference!)
                                                      .then((value) async {});
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Ok'))
                                          ],
                                        );
                                      },
                                    );
                                  });

                                  ;
                                },
                                icon: Icon(Icons.send),
                              ),
                      );
                    }),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Invite Users',
                        style: TextStyle(fontSize: 20),
                      )),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: ListView(
                      children: List.generate(nonUsers.length, (index) {
                        return ListTile(
                          leading: Icon(Icons.face),
                          title: Text(nonUsers[index].name),
                          subtitle: Text(nonUsers[index].phoneNumber),
                          trailing: TextButton(
                            onPressed: () {
                              setState(() {
                                addUser({
                                  'userName': nonUsers[index].name,
                                  'phoneNumber': nonUsers[index].phoneNumber
                                });
                              });
                            },
                            child: Text('Add'),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    userRepository = Provider.of<BUserRepository>(context);
    contactRepository = Provider.of<BContactRepository>(context);
    contactRepository.contacts.clear();
    await getContactList().then((value) {
      if (this.mounted) {
        setState(() {
          value.forEach((doc) {
            contactRepository.contacts.add(BContact.fromJson(doc));
          });
        });
      }
    });
  }

  Future<void> sendNotification(DocumentReference userId) async {
    await usersCollectionReference.doc(userId.id).get().then((value) async {});
  }

  Future<void> providePermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
