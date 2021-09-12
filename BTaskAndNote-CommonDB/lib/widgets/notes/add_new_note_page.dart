import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';

class AddNewNote extends StatefulWidget {
  const AddNewNote(
      {Key? key,
      required this.currentItemReference,
      required this.enableReadAndWrite})
      : super(key: key);

  final DocumentReference? currentItemReference;
  final bool enableReadAndWrite;

  @override
  _AddNewNoteState createState() => _AddNewNoteState();
}

class _AddNewNoteState extends State<AddNewNote> {
  final GlobalKey<FormState> notesFormKey = GlobalKey<FormState>();
  TextEditingController notesTitleController = TextEditingController();
  TextEditingController notesContentController = TextEditingController();
  late BUserRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  "New Note",
                  textAlign: TextAlign.start,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (notesFormKey.currentState!.validate()) {
                    String currentProcess = '';
                    if (widget.enableReadAndWrite) {
                      currentProcess = 'updated';
                      itemsCollectionReference
                          .doc(widget.currentItemReference!.id)
                          .update({
                        'title': notesTitleController.text,
                        'content': notesContentController.text,
                      });
                    } else {
                      currentProcess = 'added';
                      itemsCollectionReference.add({
                        'title': notesTitleController.text,
                        'content': notesContentController.text,
                        'dateAndTime': DateTime.now(),
                        'type': 'notes',
                        'createdBy': repository.currentUser!.reference.id,
                        'sentTo': []
                      });
                    }

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Notes $currentProcess successfully'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Ok'))
                          ],
                        );
                      },
                    );
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.green.shade400)),
                child: Text(widget.enableReadAndWrite ? 'Update' : 'Save'),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Form(
            key: notesFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(5.0),
                    leading: Icon(Icons.title),
                    title: TextFormField(
                      controller: notesTitleController,
                      decoration: InputDecoration(hintText: 'Notes Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }

                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notes),
                    title: TextFormField(
                      controller: notesContentController,
                      decoration: InputDecoration(hintText: 'Add notes'),
                      maxLines: 50,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = Provider.of<BUserRepository>(context);
    if (widget.enableReadAndWrite) {
      itemsCollectionReference
          .doc(widget.currentItemReference!.id)
          .get()
          .then((value) {
        if (this.mounted) {
          setState(() {
            notesTitleController.text = value['title'];
            notesContentController.text = value['content'];
          });
        }
      });
    }
  }
}
