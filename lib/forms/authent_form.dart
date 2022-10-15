import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liteorders/forms/entrprise_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liteorders/classes/globals.dart' as globals;

class AuthentificateForm extends StatefulWidget {
  const AuthentificateForm({Key? key}) : super(key: key);

  @override
  State<AuthentificateForm> createState() => _AuthentificateFormState();
}

class _AuthentificateFormState extends State<AuthentificateForm> {
  final mailControler = TextEditingController();
  final passControler = TextEditingController();
  int connectTentative = 0;

  @override
  void initState() {
    // TODO: implement initState
    InitPref();
    super.initState();
  }

  showAlertDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5),child:Text("Connexion ..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
    SavePref();
    mailControler.dispose();
    passControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(50)),
              child: TextField(
                controller: mailControler,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.mail),
                    hintText: 'Email'),
              ),
            ),
            Container(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(50)),
              child: TextField(
                controller: passControler,
                obscureText: true,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.lock),
                    hintText: 'Mot de passe'),
              ),
            ),
            Container(height: 10),
            Container(
                height: 50,
                width: 300,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    onPressed: () {
                      if (passControler.text.isNotEmpty & mailControler.text.isNotEmpty)   authentification();
                    },
                    child: Text(
                      "Connexion",
                      style: TextStyle(fontSize: 25),
                    )))
         ,Container(height: 50), Text(globals.APPLIVERSION, style: TextStyle(color: Colors.green),) ],
        ),
      ),
    );
  }

  void InitPref() async {
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    try {
      mailControler.text = myprefs.getString(globals.SUPPLIERMAIL)!;
    } catch (e) {}
  }

  void SavePref() async {
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    myprefs.setString(globals.SUPPLIERMAIL, mailControler.text);
  }

  Future<void> authentification() async {
    if (connectTentative == 3)
      SystemChannels.platform.invokeMethod(
          'SystemNavigator.pop'); //Arrêt de l'pplic apres 3 tentatives
    try {
      showAlertDialog(context);
     await globals.AUTHENTIF
          .signInWithEmailAndPassword(
              email: mailControler.text.trim(),
              password: passControler.text.trim());
         // connexion reussie on continu
        FirebaseFirestore.instance
            .collection('users_table')
            .doc(globals.AUTHENTIF.currentUser!.email!.trim())
            .get()
            .then((value) {
          if (value.exists) {
            globals.SUPPLIERNAME = value['user_name'];
            getCompanyInfos(value['company_id']);
            if (value['user_imei'].toString().isEmpty) {
              // premiére connexion on sauvegarde son fingerprint et on accepte la connection
              value.reference.update({'user_imei': globals.FINGERPRINT});
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => EnterpriseForm()));
            } else {
              // c'est pas la premiére connexion ont doit comparer les fingerprint
              // s'ils sont identiques on accepte la connexion sinon on la refuse !
              if (globals.FINGERPRINT == value['user_imei'].toString()) {
                // meme fingerprint on accept la connection
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => EnterpriseForm()));
              } else {
                // on refuse la connexion
                passControler.text='';
                Navigator.pop(context);
                Fluttertoast.showToast( backgroundColor: Colors.red,fontSize: 15,
                    msg:
                        "Connexion refusée : l' appareil n' est pas reconu !",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER);
              }
            }

          } else {
            print('-----------------------EMPTY---------------------------');
          }
        });


    }  on FirebaseAuthException catch (e) {
         Navigator.pop(context);
         Fluttertoast.showToast( backgroundColor: Colors.red,fontSize: 15,
          msg:"Connexion refusée : ${e.code}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      passControler.text='';
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast( backgroundColor: Colors.red,fontSize: 15,
          msg:"Erreur inattendue : ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      passControler.text='';
    }

    connectTentative++;
  }

  Future<void> getCompanyInfos(String company_id) async {
    FirebaseFirestore.instance
        .collection('companys_table')
        .doc(company_id)
        .get()
        .then((value) {
      if (value.exists) {
        globals.COMPANYNAME = value['name'];
        globals.SUPPLIERADRESS = value['adr'];
        globals.SUPPLIERPHONES = value['tels'];
      }
    });
  }
}
