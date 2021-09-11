import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';

class ViewNoteItemPage extends StatefulWidget {
  const ViewNoteItemPage(
      {Key? key,
      required this.database,
      required this.reference,
      bool isReadOnly = false})
      : this.isReadOnly = isReadOnly,
        super(key: key);

  final String database;
  final DocumentReference reference;
  final bool isReadOnly;

  @override
  _ViewNoteItemPageState createState() => _ViewNoteItemPageState();
}

class _ViewNoteItemPageState extends State<ViewNoteItemPage> {
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
                  "Notes",
                  textAlign: TextAlign.start,
                ),
              ),
              Visibility(
                visible: !widget.isReadOnly,
                child: ElevatedButton(
                  onPressed: () async {
                    updateNote(
                        repository.currentUser!.reference, widget.reference, {
                      'title': notesTitleController.text,
                      'content': notesContentController.text,
                      'dateAndTime': DateTime.now(),
                      'type': 'note'
                    });

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Notes saved successfully'),
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

                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green.shade400)),
                  child: Text('Save'),
                ),
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
                      readOnly: widget.isReadOnly,
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
                      readOnly: widget.isReadOnly,
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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    repository = Provider.of<BUserRepository>(context);
    CollectionReference notesCollectionReference = usersCollectionReference
        .doc(repository.currentUser!.reference.id)
        .collection(widget.database);

    await notesCollectionReference.doc(widget.reference.id).get().then((value) {
      if (this.mounted) {
        setState(() {
          notesTitleController.text = value['title'];
          notesContentController.text = value['content'];
        });
      }
    });
  }
}
