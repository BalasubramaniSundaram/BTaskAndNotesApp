import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/repository/user_repository.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  //// Form field text controller
  GlobalKey<FormState> taskFormKey = GlobalKey<FormState>();
  TextEditingController taskTitleController = TextEditingController();
  TextEditingController taskContentController = TextEditingController();
  TextEditingController taskDateController = TextEditingController();
  TextEditingController taskTimeController = TextEditingController();
  TextEditingController reminderDateController = TextEditingController();
  TextEditingController reminderTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final BUserRepository repository = Provider.of<BUserRepository>(context);
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
                  "New Task",
                  textAlign: TextAlign.start,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (taskFormKey.currentState!.validate()) {
                    addTask(repository.currentUser!.reference, {
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
                          title: Text('Task add successfully'),
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
                child: Text('Save'),
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
      child: (Text(getEditingController().text.isEmpty
          ? DateFormat('MM/dd/yyyy').format(DateTime.now()).toString()
          : DateFormat('MM/dd/yyyy')
              .format(DateTime.parse(getEditingController().text))
              .toString())),
      onPressed: () {
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

    return TextButton(
      child: (Text(getEditingController().text.isEmpty
          ? TimeOfDay.now().format(context)
          : getEditingController().text)),
      onPressed: () {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reminderDateController.text.isEmpty ||
        taskDateController.text.isEmpty) {
      reminderDateController.text =
          taskDateController.text = DateTime.now().toString();
    }

    if (reminderTimeController.text.isEmpty ||
        taskTimeController.text.isEmpty) {
      reminderTimeController.text =
          taskTimeController.text = TimeOfDay.now().format(context);
    }
  }
}
