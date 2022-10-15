import 'dart:ui';
import 'package:liteorders/classes/globals.dart' as  globals ;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liteorders/classes/enterprise.dart';
import 'package:liteorders/classes/enterprise_dbhelper.dart';
import 'package:liteorders/forms/commandes_form.dart';
import 'package:liteorders/forms/config_form.dart';
import 'enterprise_details.dart';


class EnterpriseForm extends StatefulWidget {
  const EnterpriseForm({Key? key}) : super(key: key);

  @override
  State<EnterpriseForm> createState() => _EnterpriseFormState();
}

class _EnterpriseFormState extends State<EnterpriseForm> {
  late List<Enterprise> LesEnterprise;

  String LeTitre = 'Client';
  Future<List<Enterprise>> Refresh2() async {
    var entrpises = await EnterpriseDbHelper.instance.GetEnterprises();
    setState(() {
      LeTitre = (entrpises.length <=1) ?  'Client (${entrpises.length.toString()})' : 'Clients (${entrpises.length.toString()})';
    });
    return entrpises;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //globals.AUTHENTIF.signOut();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //Refresh();
  }

  Widget Momo(BuildContext context, List<Enterprise> laliste) {
    return Text(laliste[0].ent_nom_entite.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LeTitre),
        actions: [IconButton(onPressed: () async {
           await Navigator.of(context).push( MaterialPageRoute(builder: (context) => ConfigForm()), );
        }, icon: Icon(Icons.settings))],
      ),floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Enterprise_Details()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Enterprise>>(
          future: Refresh2(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var lesEnterprise = snapshot.data;
              return ListView.builder(
                  itemCount: lesEnterprise.length,
                  itemBuilder: (context, index) {
                    return Card(
                        color: Colors.lightBlueAccent,
                        elevation: 8,
                        child: GestureDetector( onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CommandesForm(enterprise: lesEnterprise[index],)),
                          );

                        },
                          onDoubleTap: ()async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Enterprise_Details(enterpriseToModify: lesEnterprise[index])),
                          );
                        },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesEnterprise[index].ent_nom_entite.toString(), textScaleFactor: 1.5, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),),
                                Text('${lesEnterprise[index].ent_nom.toString()} ${lesEnterprise[index].ent_prenom.toString()} '),
                                Text('${lesEnterprise[index].ent_adr.toString()}  ${lesEnterprise[index].ent_tels.toString()} ')
                              ],
                            ),
                          ),
                        ));
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
