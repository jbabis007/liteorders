import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:intl/intl.dart';
import 'package:liteorders/api/pdf_api.dart';
import 'package:liteorders/api/pdf_invoice_api.dart';
import 'package:liteorders/classes/delail.dart';
import 'package:liteorders/classes/enterprise.dart';
import 'package:liteorders/classes/enterprise_dbhelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liteorders/classes/invoice.dart';
import 'package:liteorders/classes/supplier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liteorders/classes/globals.dart' as  globals ;



class DetailForm extends StatefulWidget {
  const DetailForm({Key? key, this.com_id, this.com_date}) : super(key: key);
  final int? com_id;
  final String? com_date;

  @override
  State<DetailForm> createState() => _DetailFormState();
}

class _DetailFormState extends State<DetailForm> {
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _textQt = TextEditingController();
  final TextEditingController _textPrix = TextEditingController();
  final TextEditingController _textUpdateRef = TextEditingController();
  final TextEditingController _textUpdateQt = TextEditingController();
  final TextEditingController _textUpdatePrix = TextEditingController();
  late List<Detail> detailsForPdf ;
  bool iamBusy = false;

  final oCcy = new NumberFormat.currency(locale: 'fr', symbol: '');
  String pageTitle= '';

  Future<List<Detail>> Refresh40() async {
    var tempList = await EnterpriseDbHelper.instance.getDetailCommande(widget.com_id!);
    detailsForPdf = tempList;
    int articleTotalCount = 0;
    if (tempList.isNotEmpty){
      tempList.forEach((element) {articleTotalCount += element.qt;});
    }
    setState(() {
      pageTitle=  '${widget.com_date} (${articleTotalCount.toString()})' ;

    });
    return tempList;

  }



  @override
  void initState() {
    // TODO: implement initState
    _clearAllFiles();
    super.initState();
    FlutterMobileVision.start().then((x) => setState(() {}));
    
    setState(() {  });
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _textQt.dispose();
    _textPrix.dispose();
    _textUpdateRef.dispose() ;
    _textUpdateQt.dispose() ;
    _textUpdatePrix.dispose() ;
    _clearAllFiles();
    super.dispose();
  }
_clearAllFiles() async {
  final dir = await getApplicationDocumentsDirectory();
  dir.deleteSync(recursive: true);

}
 _comfirmDialog(Detail detail, bool isForUpdate) {
    String dialogTitle = (isForUpdate) ? 'Modification ' : 'Suppression';
   showDialog(
       barrierDismissible: false,
       context: context,
       builder: (BuildContext ctx) {
         return AlertDialog(
           title:  Text(dialogTitle),
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
                   if (isForUpdate){
                     if (_textUpdateRef.text.isNotEmpty){
                       var tempMess = await EnterpriseDbHelper.instance.updateDetail(detail, _textUpdateRef.text.toString().toUpperCase(),
                           int.parse(_textUpdateQt.text.toString()),
                           double.parse(_textUpdatePrix.text.toString()));
                       Fluttertoast.showToast(msg: tempMess, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
                     }
                   }else {
                     var tempMess = await EnterpriseDbHelper.instance.deleteDetail(detail);
                     Fluttertoast.showToast(msg: tempMess, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
                   }

                   setState(() { });

                   Navigator.of(context).pop();
                 },
                 child: const Text('Oui')),

           ],
         );
       });

 }

  Future<void> _updateDialog(Detail detail) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textUpdateRef,
                decoration: InputDecoration(hintText: "Text Field in Dialog"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _textUpdateQt,
                decoration: InputDecoration(hintText: "Quantité"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _textUpdatePrix,
                decoration: InputDecoration(hintText: "Prix"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ANNULER'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {

                });

              },
            ),
            TextButton(
              child: Text('MODIFIER'),
              onPressed: () async {
                Navigator.pop(context);
                _comfirmDialog(detail , true);
                  setState(() {

                  });

                }
                //Navigator.pop(context);

            ),
          ],
        );
      },
    );
  }



  Future<void> _displayTextInputDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Text Field in Dialog"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _textQt,
                decoration: InputDecoration(hintText: "Quantité"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _textPrix,
                decoration: InputDecoration(hintText: "Prix"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {

                });

              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () async {
                Navigator.pop(context);
                if (_textFieldController.text.isNotEmpty) {
                   await EnterpriseDbHelper.instance.insertDEtails(Detail(
                      widget.com_id!,
                      _textFieldController.text.toUpperCase(),
                      int.parse(_textQt.text),
                      double.parse(_textPrix.text)));
                  setState(() {

                  });
                 _textFieldController.text = '';
                  _runOcr();
                }
                //Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  _runOcr() async {

     if (globals.DETECTIONMODE == 1 ){
       // ----OCR DETECTION------
       List<OcrText> texts = [];
       try {
         texts = await FlutterMobileVision.read(
             waitTap: true, multiple: false, fps: 5);
         if (texts.isNotEmpty) {
           texts.forEach((element) {
             _textFieldController.text = element.value.toUpperCase();
             _textPrix.text = '0';
             _textQt.text = '1';
             _displayTextInputDialog();
           });
         }
       } on Exception {
         texts.add(new OcrText('Failed to recognize text.'));
       }
     }else {
      //-------- CODE BARRE DETECTION --------------
       List<Barcode> barcodes = [];
       try {
         barcodes = await FlutterMobileVision.scan(
           waitTap: true  );
           if (barcodes.isNotEmpty){
             //print(' DISPLAY VALUE == ${barcodes.first.displayValue} ');
             //print(' RAW VALUE == ${barcodes.first.rawValue} ');
             _textFieldController.text = barcodes.first.displayValue.toUpperCase();
             _textPrix.text = '0';
             _textQt.text = '1';
             _displayTextInputDialog();
           }

       } on Exception {
         barcodes.add(new Barcode('Failed to get barcode.'));
       }

     }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle), actions: [IconButton( icon: Icon(Icons.remove_red_eye_outlined),onPressed:(){
        _makePdfFile(false);
      } ),
          IconButton(onPressed: iamBusy ? null :  (){

          _makePdfFile(true);

      },
          icon: Icon(Icons.share, color: Colors.white,))],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          //var temp = await  EnterpriseDbHelper.instance.insertDEtails(Detail(
           //   widget.com_id!,
            //  '_textFieldController.text',
             // 5,
             // 25));
          _runOcr();
         setState(() {

         });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: FutureBuilder<List<Detail>>(
          future: Refresh40(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var lesDetails = snapshot.data;
             return ListView.builder(
                  itemCount: lesDetails.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile( trailing:IconButton(onPressed: (){
                        _comfirmDialog(lesDetails[index] , false);
                      },
                      icon: Icon(Icons.delete, color: Colors.red,),)

                        ,leading: IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: (){
                          _textUpdateRef.text = lesDetails[index].ref.toString() ;
                          _textUpdateQt.text = lesDetails[index].qt.toString() ;
                          _textUpdatePrix.text = lesDetails[index].prix.toString() ;
                          _updateDialog(lesDetails[index]);
                        },
                      ),
                        title: Text(lesDetails[index].ref.toString()),
                        subtitle: Text(
                            'Qt : ${lesDetails[index].qt}  PU : ${oCcy.format(lesDetails[index].prix)}'),
                      ),
                    );
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
          }),
    );
  }

  _makePdfFile(bool isForSharing) async{
    setState(() {
      iamBusy = true;
    });
     if (detailsForPdf.isNotEmpty){

       var enterprise = await EnterpriseDbHelper.instance.getEnterpriseFromCom_Id(widget.com_id!);
       var com_date = await EnterpriseDbHelper.instance.getDateFromCom_id(widget.com_id!);
       String fileName = '${enterprise.ent_id}_${widget.com_id}_${com_date}';

       final Invoice invoice = Invoice(info:
       InvoiceInfo(date: com_date, description: 'description',
           number: fileName),
           supplier: Supplier(name : globals.COMPANYNAME,
               address : globals.SUPPLIERADRESS,
               representant : globals.SUPPLIERNAME,
               telephones: globals.SUPPLIERPHONES),
           customer: enterprise,
           items: detailsForPdf);
       final pdfFile = await PdfInvoiceApi.generate(invoice,fileName);
       List<String> filesPaths =[pdfFile.path];

       isForSharing ?  Share.shareFiles(filesPaths) : PdfApi.openFile(pdfFile);
     }

    setState(() {
      iamBusy = false;
    });
    //PdfApi.openFile(pdfFile);


  }
}
