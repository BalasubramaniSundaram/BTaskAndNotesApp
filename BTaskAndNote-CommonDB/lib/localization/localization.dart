import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

abstract class BLocalizations {
  String get userName;

  String get phoneNumber;

  String get signIn;

  String get signUp;

  String get invalidUserName;

  String get invalidPhoneNumber;

  String get backTo;

  String get doNotHaveAccount;

  String get login;

  String get register;

  static const LocalizationsDelegate<BLocalizations> delegate =
      _BLocalizationDelegates();

  static BLocalizations of(BuildContext context) {
    return Localizations.of<BLocalizations>(context, BLocalizations) ??
        const _DefaultLocalizations();
  }
}

class _BLocalizationDelegates extends LocalizationsDelegate<BLocalizations> {
  const _BLocalizationDelegates();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<BLocalizations> load(Locale locale) =>
      _DefaultLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<BLocalizations> old) => false;
}

/// US English strings for the Syncfusion widgets.
class _DefaultLocalizations implements BLocalizations {
  const _DefaultLocalizations();

  static Future<BLocalizations> load(Locale locale) {
    return SynchronousFuture<BLocalizations>(const _DefaultLocalizations());
  }

  //ignore: unused_field
  static const LocalizationsDelegate<BLocalizations> delegate =
      _BLocalizationDelegates();

  @override
  String get backTo => 'Back to';

  @override
  String get doNotHaveAccount => 'Do you have account ?';

  @override
  String get invalidPhoneNumber => 'Invalid Passcode';

  @override
  String get invalidUserName => 'Invalid UserName';

  @override
  String get phoneNumber => 'PhoneNumber';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get userName => 'UserName';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';
}

abstract class BGlobalLocalizations implements BLocalizations {
  /// Created an constructor of SfGlobalLocalizations class.
  const BGlobalLocalizations({
    required String localeName,
    // ignore: unnecessary_null_comparison
  })  : assert(localeName != null),
        _localeName = localeName;
  // ignore: unused_field
  final String _localeName;
  //ignore: public_member_api_docs
  static const LocalizationsDelegate<BLocalizations> delegate =
      _BLocalizationsDelegate();

  /// A value for [MaterialApp.localizationsDelegates] that's typically used by
  /// internationalized apps.
  ///
  /// ```dart
  /// new MaterialApp(
  ///   localizationsDelegates: SfGlobalLocalizations.delegates,
  ///   supportedLocales: [
  ///     Locale('en'),
  ///     Locale('fr'),
  ///     // ...
  ///   ],
  ///   // ...
  /// )
  /// ```
  ///
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
    BGlobalLocalizations.delegate,
  ];
}

/// The set of supported languages, as language code strings.
final Set<String> bSupportedLanguages =
    HashSet<String>.from(const <String>[
  'en', // English
  'zh', // Chinese
]);

class _BLocalizationsDelegate extends LocalizationsDelegate<BLocalizations> {
  const _BLocalizationsDelegate();

  static final Map<Locale, Future<BLocalizations>> _loadedTranslations =
      <Locale, Future<BLocalizations>>{};

  @override
  Future<BLocalizations> load(Locale locale) {
    assert(isSupported(locale));
    return _loadedTranslations.putIfAbsent(locale, () {
      final String localeName =
      intl.Intl.canonicalizedLocale(locale.toString());
      assert(
      locale.toString() == localeName,
      'Flutter does not support the non-standard locale form $locale (which '
          'might be $localeName',
      );

      return SynchronousFuture<BLocalizations>(getTranslation(
        locale,
      )!);
    });
  }

  @override
  bool shouldReload(_BLocalizationsDelegate old) => false;

  @override
  String toString() => 'BGlobalLocalizations.delegate('
      '${bSupportedLanguages.length} locales)';

  bool isSupported(Locale locale) =>
      bSupportedLanguages.contains(locale.languageCode);
}

BGlobalLocalizations? getTranslation(
    Locale locale,
    ) {
  switch (locale.languageCode) {
    case 'en':
      return const BLocalizationsEn();
    case 'zh':
      return const BLocalizationsZh();
  }
  assert(false,
  'getTranslation() called for unsupported locale "$locale"');
  return null;
}

/// The translations for Chinese (`zh`).
class BLocalizationsZh extends BGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsZh class
  const BLocalizationsZh({
    String localeName = 'zh',
  }) : super(
    localeName: localeName,
  );

  @override
  String get backTo => r'还';

  @override
  String get doNotHaveAccount => r'无帐户';

  @override
  String get invalidPhoneNumber => r'无效密码';

  @override
  String get invalidUserName => r'无效用户名';

  @override
  String get phoneNumber => r'电话号码';

  @override
  String get signIn => r'登录';

  @override
  String get signUp => r'登记';

  @override
  String get userName => r'用户名';

  @override
  String get login => r'登录';

  @override
  String get register => r'注册';
}

/// The translations for English (`en`).
class BLocalizationsEn extends BGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsEn class
  const BLocalizationsEn({
    String localeName = 'en',
  }) : super(
    localeName: localeName,
  );

  @override
  String get backTo => r'Back to';

  @override
  String get doNotHaveAccount => r'Do you have account';

  @override
  String get invalidPhoneNumber => r'InValid PhoneNumber';

  @override
  String get invalidUserName => r'Invalid UserName';

  @override
  String get phoneNumber => r'PhoneNumber';

  @override
  String get signIn => r'Sign In';

  @override
  String get signUp => r'Sign Up';

  @override
  String get userName => r'UserName';

  @override
  String get login => r'Login';

  @override
  String get register => r'Register';

}

