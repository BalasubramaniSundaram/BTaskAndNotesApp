import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';
import 'package:sharing_app/widgets/tasks/task_home_page.dart';

import 'common/contact_page.dart';
import 'common/item_page.dart';
import 'login_register/login_register_page.dart';
import 'notes/notes_home_page.dart';
import 'common/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BUserRepository repository;

  static const Map<String, Widget> mainMenu = {
    'Tasks': Icon(Icons.task, color: Colors.deepPurple),
    'Notes': Icon(Icons.notes, color: Colors.green),
    'Sent Items': Icon(Icons.send, color: Colors.green),
    'Received Items': Icon(Icons.inbox, color: Colors.deepOrange)
  };

  Map<String, int> eachItemCount = {};

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    repository = Provider.of<BUserRepository>(context);
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();
    // Save the initial token to the database
    await saveTokenToDatabase(token);
    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
    await refreshItem();
  }

  Future<void> refreshItem() async {
    await getItemCount(repository.currentUser!.reference).then((value) {
      if (this.mounted) {
        setState(() {
          eachItemCount = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade300,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePageView(
                      repository.currentUser!.name,
                      'images/app_icon.png',
                      '${repository.currentUser!.name}@gmail.com',
                      repository.currentUser!.phoneNumber,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.face)),
          title: buildUserDisplayBar(context, repository),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: mainMenu.entries.map<Widget>((MapEntry entry) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(5.0),
                    title: Text(entry.key),
                    leading: entry.value,
                    trailing: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        eachItemCount.isEmpty
                            ? ""
                            : eachItemCount[entry.key].toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      if (entry.key == 'Tasks') {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => TaskHomePage(),
                          ),
                        )
                            .then((value) async {
                          await refreshItem();
                        });
                      } else if (entry.key == 'Notes') {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => NotesHomePage(),
                          ),
                        )
                            .then((value) async {
                          await refreshItem();
                        });
                      } else if (entry.key == 'Sent Items') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SendItemPage(
                              finderKey: 'sent',
                            ),
                          ),
                        );
                      } else if (entry.key == 'Received Items') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SendItemPage(
                              finderKey: 'received',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            }).toList(growable: true),
          ),
        ),
      ),
    );
  }

  Container buildUserDisplayBar(
      BuildContext context, BUserRepository repository) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${repository.currentUser!.name}'),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${repository.currentUser!.phoneNumber}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShareWithContacts(
                      title: 'Contacts',
                      database: 'users',
                    ),
                  ),
                );
              },
              icon: Icon(Icons.contacts)),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.blue.shade700)),
            onPressed: () {
              repository.currentUser = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginAndRegisterPage(
                    pageType: 'Login',
                  ),
                ),
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveTokenToDatabase(String? token) async {
    // Assume user is logged in for this example
    String userId = repository.currentUser!.reference.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }
}
