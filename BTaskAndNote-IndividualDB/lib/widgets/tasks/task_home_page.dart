import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';

import '../common/contact_page.dart';
import 'add_new_task_page.dart';
import 'view_task_item_page.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({Key? key}) : super(key: key);

  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final math.Random randomGenerator = math.Random();

  static List<Color> cardColors = [
    Colors.green.shade50,
    Colors.pink.shade50,
    Colors.red.shade50,
    Colors.blue.shade50
  ];

  late BUserRepository userRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userRepository = Provider.of<BUserRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: Text('Tasks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTasksStream(userRepository.currentUser!.reference),
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
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: snapshot.data!.docs.map<Widget>((doc) {
                  return Card(
                    color:
                        cardColors[randomGenerator.nextInt(cardColors.length)],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(4.0),
                        title: Text(
                          doc['title'],
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w300,
                              color: Colors.black),
                        ),
                        leading: Icon(Icons.task),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'StartDate: ${DateFormat('MM/dd/yyyy').format(doc['taskCreateDateAndTime'].toDate())}',
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              'EndDate: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(doc['taskEndDate']))}',
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
                                  database: 'tasks',
                                  reference: doc.reference,
                                ),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ViewTaskItemPage(
                                reference: doc.reference,
                                database: 'tasks',
                                isReadOnly: false,
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
            builder: (context) => AddTaskPage(),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
