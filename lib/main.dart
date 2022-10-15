
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liteorders/forms/authent_form.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:liteorders/classes/globals.dart' as  globals ;
import 'package:package_info_plus/package_info_plus.dart';




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //globals.FINGERPRINT = androidInfo.fingerprint.toString();
    globals.FINGERPRINT = androidInfo.androidId.toString();
    globals.APPLIVERSION = packageInfo.version;
    } on Exception catch (e) {
    //print(' ERRRRRRORRRRR ===  ${e.toString()}');

  }
  await Firebase.initializeApp();
  globals.AUTHENTIF =  FirebaseAuth.instance;

  runApp(const MaterialApp(debugShowCheckedModeBanner: false,
    home:AuthentificateForm() , //EnterpriseForm()

  ));
}


