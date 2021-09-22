import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sharing_app/localization/localization.dart';
import 'package:sharing_app/platform_channel/platform_method_channel.dart';
import 'package:sharing_app/repository/contact_repository.dart';
import 'package:sharing_app/widgets/login_register/login_register_page.dart';

import 'database/cloud_messaging_provider.dart';
import 'repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await setUpCloudMessage();
  runApp(MyApp());
}

typedef LanguageChangeCallback = void Function(String language);

@immutable
///
class MyApp extends StatelessWidget {
  final StreamController<Locale> controller = StreamController<Locale>();
  LanguageChangeCallback? languageChangeCallback;

  ///
  MyApp() {
    languageChangeCallback = setLocale;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BUserRepository>(create: (context) => BUserRepository()),
        Provider<BContactRepository>(create: (context) => BContactRepository())
      ],
      child: StreamBuilder<Locale>(
        stream: controller.stream,
        initialData: Locale('en', ''),
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            home: MyHomePage(
              language: this.languageChangeCallback!,
            ),
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              BGlobalLocalizations.delegate
            ],
            supportedLocales: [
              Locale('en', ''),
              Locale.fromSubtags(
                  languageCode: 'zh'), // Spanish, no country code
            ],
            locale: snapshot.data,
          );
        },
      ),
    );
  }

  void setLocale(String language) {
    if (language == 'en') {
      controller.add(Locale('en', ''));
    } else {
      controller.add(Locale.fromSubtags(languageCode: 'zh'));
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.language}) : super(key: key);

  final LanguageChangeCallback language;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<String> languages = ['English', 'Chinese-Legacy'];
  String? selectedLanguage = languages[0];
  Locale localLanguage = Locale('en', '');

  @override
  void initState() {
    super.initState();
    setUpMessageListener();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            DropdownButton(
              style: TextStyle(color: Colors.black),
              items: languages.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem<String>(
                  child: Text(e),
                  value: e,
                );
              }).toList(),
              value: selectedLanguage,
              onChanged: (value) {
                if (value == selectedLanguage) {
                  return;
                }

                selectedLanguage = value as String;
                if (value == 'Chinese-Legacy') {
                  widget.language.call('zh');
                } else {
                  widget.language.call('en');
                }
              },
            )
          ],
        ),
        body: FutureBuilder<String>(
          initialData: 'false',
          future: requestReadContactPermission(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              );
            } else {
              return LoginAndRegisterPage(
                pageType: 'Login',
              );
            }
          },
        ),
      ),
    );
  }
}
