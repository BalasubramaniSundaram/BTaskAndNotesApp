import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';

class ViewTaskItemPage extends StatefulWidget {
  const ViewTaskItemPage(
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
  _ViewItemPageState createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewTaskItemPage> {
  GlobalKey<FormState> taskFormKey = GlobalKey<FormState>();
  TextEditingController taskTitleController = TextEditingController();
  TextEditingController taskContentController = TextEditingController();
  TextEditingController taskDateController = TextEditingController();
  TextEditingController taskTimeController = TextEditingController();
  TextEditingController reminderDateController = TextEditingController();
  TextEditingController reminderTimeController = TextEditingController();
  late BUserRepository userRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final BUserRepository repository = Provider.of<BUserRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  "New Task",
                  textAlign: TextAlign.start,
                ),
              ),
              Visibility(
                visible: !widget.isReadOnly,
                child: ElevatedButton(
                  onPressed: () async {
                    if (taskFormKey.currentState!.validate()) {
                      updateTask(
                          repository.currentUser!.reference, widget.reference, {
                        'title': taskTitleController.text,
                        'content': taskContentController.text,
                        'taskCreateDateAndTime': DateTime.now(),
                        'taskEndDate': taskDateController.text,
                        'taskEndTime': taskTimeController.text,
                        'taskReminderDate': reminderDateController.text,
                        'taskReminderTime': reminderTimeController.text,
                        'type': 'tasks'
                      });

                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Task saved successfully'),
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
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                  child: Text('Update'),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: taskFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ListTile(
                  leading: Icon(Icons.title),
                  title: TextFormField(
                    controller: taskTitleController,
                    readOnly: widget.isReadOnly,
                    decoration: InputDecoration(hintText: 'Task title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please add title';
                      }

                      return null;
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.content_paste_outlined),
                  title: TextFormField(
                    controller: taskContentController,
                    readOnly: widget.isReadOnly,
                    decoration: InputDecoration(
                        hintText: 'Would you like to add more details'),
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please add tasks details';
                      }

                      return null;
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              border:
                                  Border.all(color: Colors.black, width: 1.0)),
                          height: 50.0,
                          width: 150.0,
                          child: taskDatePicker(context, 'tasks'),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              border:
                                  Border.all(color: Colors.black, width: 1.0)),
                          height: 50.0,
                          width: 150.0,
                          child: taskTimePicker(context, '.tasks'),
                        )
                        //taskDateTimePicker(context)
                      ]),
                ),
                ListTile(
                  leading: Icon(Icons.alarm),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              border:
                                  Border.all(color: Colors.black, width: 1.0)),
                          height: 50.0,
                          width: 150.0,
                          child: taskDatePicker(context, 'reminder'),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              border:
                                  Border.all(color: Colors.black, width: 1.0)),
                          height: 50.0,
                          width: 150.0,
                          child: taskTimePicker(context, '.reminder'),
                        )
                        //taskDateTimePicker(context)
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget taskDatePicker(BuildContext context, String type) {
    TextEditingController getEditingController() {
      if (type == 'reminder') {
        return reminderDateController;
      } else {
        return taskDateController;
      }
    }

    return TextButton(
      child: (Text(DateFormat('MM/dd/yyyy')
          .format(DateTime.parse(getEditingController().text.isEmpty
              ? DateTime.now().toString()
              : getEditingController().text))
          .toString())),
      onPressed: () {
        if (widget.isReadOnly) {
          return;
        }

        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.parse("1990-01-01"),
          lastDate: DateTime.parse("2022-01-01"),
        ).then((DateTime? value) {
          if (value != null) {
            setState(() {
              getEditingController().text = value.toString();
            });
          }
        });
      },
    );
  }

  Widget taskTimePicker(BuildContext context, String type) {
    TextEditingController getEditingController() {
      if (type == 'reminder') {
        return reminderTimeController;
      } else {
        return taskTimeController;
      }
    }

    print(getEditingController().text);

    return TextButton(
      child: (Text(getEditingController().text.isEmpty
          ? TimeOfDay.now().format(context)
          : getEditingController().text)),
      onPressed: () {
        if (widget.isReadOnly) {
          return;
        }

        showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        ).then((TimeOfDay? value) {
          if (value != null) {
            setState(() {
              getEditingController().text = value.format(context).toString();
            });
          }
        });
      },
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    userRepository = Provider.of<BUserRepository>(context);

    /// Getting the db of tasks and notes from current user
    var dbReference = usersCollectionReference
        .doc(userRepository.currentUser!.reference.id)
        .collection(widget.database);

    await dbReference.doc(widget.reference.id).get().then((value) {
      if (this.mounted) {
        setState(() {
          taskTitleController.text = value['title'];
          taskContentController.text = value['content'];
          taskDateController.text = value['taskEndDate'];
          taskTimeController.text = value['taskEndTime'];
          reminderDateController.text = value['taskReminderDate'];
          reminderTimeController.text = value['taskReminderTime'];
        });
      }
    });
  }
}
