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
        backgroundColor: Colors.blue.shade300,
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
            existUsers.sort();
            final List<BContact> nonUsers = contactRepository.getNonUsers();
            nonUsers.sort();

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
                buildExistingUsersContactList(context, existUsers),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Invite Users',
                        style: TextStyle(fontSize: 20),
                      )),
                ),
                buildNonUserList(context, nonUsers),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildExistingUsersContactList(
      BuildContext context, List<BContact> existUsers) {
    return Container(
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
                      itemsCollectionReference
                          .doc(widget.reference!.id)
                          .get()
                          .then((value) async {
                        updateSentToListInDB(value, existUsers, index);

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  '${widget.database} successfully shared to ${existUsers[index].name}'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await sendNotificationToSender(
                                              existUsers[index].reference!)
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
                    },
                    icon: Icon(Icons.send),
                  ),
          );
        }),
      ),
    );
  }

  void updateSentToListInDB(
      dynamic value, List<BContact> existUsers, int index) {
    List<dynamic> sentItem = value['sentTo'];
    sentItem.add(existUsers[index].reference!.id);
    itemsCollectionReference
        .doc(widget.reference!.id)
        .update({'sentTo': sentItem});
  }

  Widget buildNonUserList(BuildContext context, List<BContact> nonUsers) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.50,
        child: ListView(
          children: List.generate(nonUsers.length, (index) {
            return ListTile(
              leading: Icon(Icons.face),
              title: Text(nonUsers[index].name),
              subtitle: Text(nonUsers[index].phoneNumber),
              trailing: TextButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            'Instead of invite is used the add for direct register users, its completely easy registering of user B. \nPlease remember username and phone number format to login to User B Before Click Ok '
                            '\n User Name : ${nonUsers[index].name} \n Phone Number: ${nonUsers[index].phoneNumber}'),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  addUser({
                                    'userName': nonUsers[index].name,
                                    'phoneNumber': nonUsers[index].phoneNumber
                                  });
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Ok')),
                          ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'))
                        ],
                      );
                    },
                  );
                },
                child: Text('Add'),
              ),
            );
          }),
        ),
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

  /// Sending the notification to particular user
  Future<void> sendNotificationToSender(DocumentReference userId) async {
    // await usersCollectionReference.doc(userId.id).get().then((value) async {
    //   var lastToken;
    //   for (var token in value['tokens']) {
    //     lastToken = token;
    //   }
    //
    //   // await sendNotification(lastToken, {});
    // });
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
