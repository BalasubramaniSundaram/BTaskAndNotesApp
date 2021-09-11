import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';
import 'package:sharing_app/widgets/notes/view_note_item_page.dart';
import 'package:sharing_app/widgets/tasks/view_task_item_page.dart';

class SendItemPage extends StatefulWidget {
  const SendItemPage({Key? key, required this.databaseName}) : super(key: key);
  final String databaseName;

  @override
  _SendItemPageState createState() => _SendItemPageState();
}

class _SendItemPageState extends State<SendItemPage> {
  @override
  Widget build(BuildContext context) {
    final BUserRepository repository = Provider.of<BUserRepository>(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                '${widget.databaseName.toUpperCase()} ITEM',
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: usersCollectionReference
              .doc(repository.currentUser!.reference.id)
              .collection('${widget.databaseName.toLowerCase()}')
              .snapshots(),
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
              return ListView(
                children: snapshot.data!.docs.map<Widget>(
                  (doc) {
                    if (doc['type'] == 'tasks') {
                      return buildTaskItem(doc);
                    } else {
                      return buildNoteItem(doc);
                    }
                  },
                ).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildTaskItem(QueryDocumentSnapshot doc) {
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
            Text(
              'Sent to: ${doc['to']}',
              textAlign: TextAlign.left,
            ),
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
              builder: (context) => ViewTaskItemPage(
                reference: doc.reference,
                database: widget.databaseName,
                isReadOnly: true,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNoteItem(QueryDocumentSnapshot doc) {
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
            Text(
              'Sent to: ${doc['to']}',
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ViewNoteItemPage(
                reference: doc.reference,
                database: widget.databaseName,
                isReadOnly: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
