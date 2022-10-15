import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:liteorders/classes/commandes.dart';
import 'package:liteorders/classes/enterprise.dart';
import 'package:liteorders/classes/enterprise_dbhelper.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:liteorders/forms/detail_form.dart';
import 'package:liteorders/classes/globals.dart' as globals;


class CommandesForm extends StatefulWidget {
  const CommandesForm({Key? key, this.enterprise}) : super(key: key);
  final Enterprise? enterprise;

  @override
  State<CommandesForm> createState() => _CommandesFormState();
}

class _CommandesFormState extends State<CommandesForm> {
 static const String ORDERIMAGE = 'img/order.png';
 late Image monImage;

  Future<List<Commandes>> Refresh(int ent_id) async {
    var commandes = await EnterpriseDbHelper.instance.GetLesCommandes(ent_id);
    return commandes;
  }

   @override
  void initState() {
    // TODO: implement initState
     globals.checkUser();
      monImage= Image.asset(ORDERIMAGE, gaplessPlayback: true);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    precacheImage(monImage.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.enterprise!.ent_nom_entite.toString()),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.small(onPressed: () async {
        var com = Commandes(null,widget.enterprise!.ent_id!,DateFormat("yyyy-MM-dd").format(DateTime.now()));
        int dd = await EnterpriseDbHelper.instance.insertCommandes(com);

        setState(() {

        });
      },
        child: Icon(Icons.add),

      ),
      body: FutureBuilder<List<Commandes>>(
        future: Refresh(widget.enterprise!.ent_id!),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var lesCommandes = snapshot.data;
            return ListView.builder(
                itemCount: lesCommandes.length,
                itemBuilder: (context, index){

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector( onTap: ()async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DetailForm( com_date: lesCommandes[index].com_date , com_id: lesCommandes[index].com_id)),
                  );

                },
                  child: Card(color: Colors.cyanAccent,
                      child: ListTile( dense: true, trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed:()  {
                        delCommandeDialog(lesCommandes[index].com_id);


                      }),
                          leading: monImage,
                        title: Text(lesCommandes[index].com_date, style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),) )
                  ),
                ),
              );
            });
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
        },
      ),);
  }

 delCommandeDialog(int com_id) async {

   showDialog(
       barrierDismissible: false,
       context: context,
       builder: (BuildContext ctx) {
         return AlertDialog(
           title:  Text('Suppresion'),
           content: const Text('Êtes vous sûr de vouloir continuer ?'),
           actions: [TextButton(
               onPressed: () {
                 setState(() { });
                 Navigator.of(context).pop();
               },
               child: const Text('Non')),
             // The "Yes" button
             TextButton(
                 onPressed: () async{

                       var tempMess = await EnterpriseDbHelper.instance.deleteCommande(com_id);
                       Fluttertoast.showToast(msg: tempMess, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);


                   setState(() { });

                   Navigator.of(context).pop();
                 },
                 child: const Text('Oui')),

           ],
         );
       });
}

}
