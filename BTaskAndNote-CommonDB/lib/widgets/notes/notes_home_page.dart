import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';
import 'package:sharing_app/widgets/common/contact_page.dart';

import 'add_new_note_page.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({Key? key}) : super(key: key);

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final math.Random randomGenerator = math.Random();
  late BUserRepository repository;

  static List<Color> cardColors = [
    Colors.green.shade50,
    Colors.pink.shade50,
    Colors.red.shade50,
    Colors.blue.shade50
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: Text(
          'Notes',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsCollectionReference.snapshots(),
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
            final List<QueryDocumentSnapshot<dynamic>> filteredNotes = snapshot
                .data!.docs
                .where((element) => (element['type'] == 'notes' &&
                    element['createdBy'] ==
                        repository.currentUser!.reference.id))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: filteredNotes.map<Widget>((doc) {
                  return Card(
                    color:
                        cardColors[randomGenerator.nextInt(cardColors.length)],
                    elevation: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(5.0),
                        leading: Icon(
                          Icons.notes,
                          color: Colors.green,
                        ),
                        title: Text(
                          doc['title'],
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Created Date ${DateFormat('MM/dd/yyyy').format(doc['dateAndTime'].toDate())}',
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ShareWithContacts(
                                  title: 'Share to contact',
                                  database: 'notes',
                                  reference: doc.reference,
                                ),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddNewNote(
                                currentItemReference: doc.reference,
                                enableReadAndWrite: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddNewNote(
              enableReadAndWrite: false,
              currentItemReference: null,
            ),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = Provider.of<BUserRepository>(context);
  }
}
