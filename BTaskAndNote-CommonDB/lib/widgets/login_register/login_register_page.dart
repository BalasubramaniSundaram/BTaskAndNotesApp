import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/database/database_provider.dart';
import 'package:sharing_app/model/user_model.dart';
import 'package:sharing_app/platform_channel/platform_method_channel.dart';
import 'package:sharing_app/repository/user_repository.dart';

import '../home_page.dart';

class LoginAndRegisterPage extends StatefulWidget {
  const LoginAndRegisterPage({Key? key, required this.pageType})
      : super(key: key);

  final String pageType;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<LoginAndRegisterPage> {
  /// Form field text controller
  final GlobalKey<FormState> loginFormGlobalKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  late BUserRepository userRepository;
  bool isUserExistOrNot = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.10),
              child: Form(
                key: loginFormGlobalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/app_icon.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('BTaskAndNote', style: TextStyle(fontSize: 40)),
                    ),
                    Text('${widget.pageType}', style: TextStyle(fontSize: 20)),
                    TextFormField(
                      controller: userNameController,
                      decoration: InputDecoration(hintText: 'UserName'),
                      keyboardType: TextInputType.text,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter user name';
                        } else if (value.length <= 3) {
                          return 'User name should more than 3 character';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(hintText: 'Phone Number'),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        } else if (value.length < 10) {
                          return 'Please valid phone number length';
                        } else if (value.length > 12) {
                          return 'Number must less then 12';
                        }

                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (loginFormGlobalKey.currentState!.validate()) {
                            if (widget.pageType == 'Register') {
                              performRegister();
                            } else {
                              performLogin();
                            }
                          }
                        },
                        child: Text(checkPageType() ? 'Sign Up' : 'Sign In'),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            checkPageType()
                                ? "Back to"
                                : "Don't have an account?",
                            textAlign: TextAlign.right,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginAndRegisterPage(
                                      pageType: checkPageType()
                                          ? 'Login'
                                          : 'Register'),
                                ));
                              },
                              child: Text(
                                checkPageType() ? "Sign In" : "Sign Up",
                                textAlign: TextAlign.left,
                              ))
                        ],
                      ),
                    ),
                    Visibility(
                      visible: errorMessage.isNotEmpty,
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    userRepository = Provider.of<BUserRepository>(context, listen: false);

    await setPhoneNumber().then((value) {
      if (value != '0000000000') {
        phoneNumberController.text = value;
      }
    });

    /// Checking the user exist or not and auto-register too
    await checkUserExistOrNot(phoneNumberController.text)
        .then((bool isExist) async {
      if (isExist) {
        await getUser(phoneNumberController.text)
            .then((QueryDocumentSnapshot doc) async {
          Provider.of<BUserRepository>(context, listen: false).currentUser =
              BUser(doc['userName'], doc['phoneNumber'], doc.reference);
          setState(() {
            userNameController.text = doc['userName'];
            phoneNumberController.text = doc['phoneNumber'];
          });
        });
      }
    });
  }

  bool checkPageType() {
    return widget.pageType == 'Register';
  }

  void performLogin() {
    checkUserExistOrNot(phoneNumberController.text).then((value) async {
      if (value) {
        await getUser(phoneNumberController.text)
            .then((QueryDocumentSnapshot doc) async {
          if (doc['userName'] != userNameController.text) {
            setState(() {
              errorMessage = 'Invalid UserName';
            });

            return;
          }

          userRepository.currentUser =
              BUser(doc['userName'], doc['phoneNumber'], doc.reference);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
        });
      } else {
        setState(() {
          errorMessage = 'Invalid UserName Or Password';
        });
      }
    });
  }

  void performRegister() {
    checkUserExistOrNot(phoneNumberController.text).then((value) async {
      if (!value) {
        /// Upload user into the collection
        addUser(
          {
            'userName': userNameController.text,
            'phoneNumber': phoneNumberController.text
          },
        );

        /// Show Dialogue
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('User Registered Successfully'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      /// Navigate to login page
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return LoginAndRegisterPage(pageType: 'Login');
                        },
                      ));
                    },
                    child: Text('Ok'))
              ],
            );
          },
        );
      } else {
        setState(() {
          errorMessage = 'User Already Exist';
        });
      }
    });
  }
}
