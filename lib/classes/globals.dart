
library liteorders.globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

String COMPANYNAME = 'COMPANYNAME';
String SUPPLIERNAME = 'SUPPLIERNAME';
String SUPPLIERADRESS = 'SUPPLIERADRESS';
String SUPPLIERPHONES = 'SUPPLIERPHONES';
String FINGERPRINT="";
String SUPPLIERMAIL="SUPPLIERMAIL";
String APPLIVERSION="";
late FirebaseAuth AUTHENTIF ;
int DETECTIONMODE =0 ; // 1 is ocr 2 is code barre

checkUser() async{
  try{
    await AUTHENTIF.currentUser!.reload();
  } on FirebaseAuthException catch (e){
    AUTHENTIF.signOut();
    Fluttertoast.showToast( backgroundColor: Colors.red,fontSize: 15,
        msg:"Connexion refusée : ${e.code}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER);
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

}