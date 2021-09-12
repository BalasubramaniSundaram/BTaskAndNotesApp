import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';
import 'package:sharing_app/widgets/notes/add_new_note_page.dart';
import 'package:sharing_app/widgets/tasks/add_new_task_page.dart';

class SendItemPage extends StatefulWidget {
  const SendItemPage({Key? key, required this.finderKey}) : super(key: key);
  final String finderKey;

  @override
  _SendItemPageState createState() => _SendItemPageState();
}

class _SendItemPageState extends State<SendItemPage> {
  @override
  Widget build(BuildContext context) {
    final BUserRepository repository = Provider.of<BUserRepository>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                '${widget.finderKey.toUpperCase()} ITEM',
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: itemsCollectionReference.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null ||
                snapshot.data!.docs.isEmpty ||
                snapshot.hasError ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              );
            } else {
              final Map<int, List<String>> currentUserNotesAndTasks =
                  getItemsBasedOnUserSentAndReceived(
                      snapshot: snapshot,
                      type: widget.finderKey,
                      userReferenceId: repository.currentUser!.reference.id);

              return ListView(
                children: currentUserNotesAndTasks.entries.map<Widget>((e) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream:
                        itemsCollectionReference.doc(e.value[1]).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        final dynamic itemData = snapshot.data!.data();
                        if (itemData['type'] == 'tasks') {
                          return buildTaskItem(
                              itemData, e.value[0], snapshot.data!.reference);
                        } else {
                          return buildNoteItem(
                              itemData, e.value[0], snapshot.data!.reference);
                        }
                      }
                    },
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildTaskItem(
      dynamic doc, String userID, DocumentReference itemReference) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: Icon(
          Icons.task,
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
            SizedBox(
              height: 5,
            ),
            buildFromAndToNameWidget(userID),
            SizedBox(
              height: 10,
            ),
            Text(
              'StartDate: ${DateFormat('MM/dd/yyyy').format(doc['taskCreateDateAndTime'].toDate())}',
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'EndDate: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(doc['taskEndDate']))}',
              textAlign: TextAlign.left,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTaskPage(
                currentItemReference: itemReference,
                enableReadAndWrite: true,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNoteItem(
      dynamic doc, String userID, DocumentReference itemReference) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: Icon(Icons.notes),
        title: Text(
          doc['title'],
          style: TextStyle(fontSize: 20),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            buildFromAndToNameWidget(userID),
            SizedBox(
              height: 10,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddNewNote(
                currentItemReference: itemReference,
                enableReadAndWrite: true,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildFromAndToNameWidget(String userID) {
    return StreamBuilder<DocumentSnapshot>(
      stream: usersCollectionReference.doc(userID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        } else {
          final dynamic userData = snapshot.data!.data();
          return Text(
            widget.finderKey == 'sent'
                ? 'Sent to: ${userData['userName']}'
                : 'From: ${userData['userName']}',
            textAlign: TextAlign.left,
          );
        }
      },
    );
  }
}
