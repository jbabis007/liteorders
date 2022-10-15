import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liteorders/classes/enterprise.dart';
import 'package:liteorders/classes/enterprise_dbhelper.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class Enterprise_Details extends StatefulWidget {
  const Enterprise_Details({Key? key, this.enterpriseToModify}) : super(key: key);
  final Enterprise?  enterpriseToModify;

  @override
  State<Enterprise_Details> createState() => _Enterprise_DetailsState();
}

class _Enterprise_DetailsState extends State<Enterprise_Details> {
  var entite = TextEditingController();
  var nom = TextEditingController();
  var prenom = TextEditingController();
  var adr = TextEditingController();
  var tels = TextEditingController();
  var id = TextEditingController();
  String pageTitle = 'Nouveau';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.enterpriseToModify != null){
      setState(() {
        entite.text = widget.enterpriseToModify!.ent_nom_entite.toString();
        nom.text=  widget.enterpriseToModify!.ent_nom.toString();
        prenom.text =  widget.enterpriseToModify!.ent_prenom.toString();
        adr.text =  widget.enterpriseToModify!.ent_adr.toString();
        tels.text =  widget.enterpriseToModify!.ent_tels.toString();
        id.text = widget.enterpriseToModify!.ent_id.toString();
        pageTitle=entite.text;
      });

    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    entite.dispose();
    nom.dispose();
    prenom.dispose();
    adr.dispose();
    tels.dispose();
    id.dispose();
    super.dispose();
  }


  List<Widget> toolBar(){
    if (widget.enterpriseToModify ==null){
      return[
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'Enregister',
        onPressed: () {
          if (entite.text.isNotEmpty){
          var Ent = Enterprise(null, entite.text, nom.text, prenom.text,
              adr.text, tels.text);
          EnterpriseDbHelper.instance.InsertData(Ent);
          Navigator.of(context).pop();
          }
        },
      )];

    }else {
      return[ IconButton(
        icon: const Icon(Icons.edit),
        tooltip: 'Editer',
        onPressed: () async {
          if (entite.text.isNotEmpty) {
            if (await confirm(
                context, textCancel: Text('Non'), textOK: Text('Oui'),
                title: Text('Modification'),
                content: Text('Êtes vous sûr de vouloir continuer ?'))) {
              EnterpriseDbHelper.instance.updateEnterprise(Enterprise(
                  int.parse(id.text), entite.text, nom.text, prenom.text, adr.text, tels.text));

              Navigator.of(context).pop();
            }
          }
        },
      ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Supprimer',
          onPressed: () async {
            if (await confirm(context, textCancel: Text('Non'), textOK: Text('Oui'),
                title: Text('Suppresion'), 
                content: Text('Êtes vous sûr de vouloir continuer ?'))) {
              var tempMess = await EnterpriseDbHelper.instance.delEnterprise(
                  widget.enterpriseToModify!.ent_id!);
              Fluttertoast.showToast(msg: tempMess, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
              Navigator.of(context).pop();
            }
          },
        ),
      ];
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle),
        actions:toolBar() ,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 50),
            TextField(
              controller: entite,
              decoration: InputDecoration(hintText: 'Nom de l' 'entité'),
            ),
            Container(height: 10),
            TextField(
              controller: nom,
              decoration: InputDecoration(hintText: 'Nom du contacte'),
            ),
            Container(height: 10),
            TextField(
              controller: prenom,
              decoration: InputDecoration(hintText: 'Prénom du contacte'),
            ),
            Container(height: 10),
            TextField(
              controller: adr,
              decoration: InputDecoration(hintText: 'Adresse'),
            ),
            Container(height: 10),
            TextField(
              controller: tels,
              decoration: InputDecoration(hintText: 'Téléphones'),
            ),
            Container(height: 10),
            Visibility( visible: false,
              child: TextField(
                controller: id,
                decoration: InputDecoration(hintText: 'Code'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
