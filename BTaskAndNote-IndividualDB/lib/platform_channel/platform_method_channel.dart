import 'package:flutter/services.dart';

MethodChannel platformChannel =
    MethodChannel('samples.flutter.dev/sharing_app');

Future<String> requestReadContactPermission() async {
  try {
    return await platformChannel.invokeMethod('requestReadContactsPermissions');
  } on PlatformException catch (e) {
    return '';
  }
}

Future<String> setPhoneNumber() async {
  try {
    return await platformChannel.invokeMethod('getPhoneNumber');
  } on PlatformException catch (e) {
    return '';
  }
}

Future<dynamic> getContactList() async {
  try {
    return await platformChannel.invokeMethod('getContactList');
  } on PlatformException catch (e) {
    return List.empty();
  }
}
