import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liteorders/classes/globals.dart' as  globals ;

class ConfigForm extends StatefulWidget {
  const ConfigForm({Key? key}) : super(key: key);


  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {


  int _groupVal = 0 ;


  void InitPref() async {
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    setState(() {
      _groupVal = myprefs.getInt('DetectMode') ?? 1;
    });


  }
  void SavePref() async {
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    myprefs.setInt('DetectMode', _groupVal);
    globals.DETECTIONMODE = _groupVal;

  }


  @override
  void initState() {
    InitPref();
    super.initState();

  }

  @override
  void dispose(){
     SavePref();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(title: Text('Configuration'),),
    body: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [ Text('Mode de détection',style: TextStyle(fontSize: 20)),Row(
      children: [SizedBox(width: 10,),
        Radio(value: 1, groupValue: _groupVal, onChanged: (val){
          setState(() {
            _groupVal = val as int;
          });
        }),
        Text('OCR')
      ],
    ),
          Row(
            children: [SizedBox(width: 10,),
              Radio(value: 2, groupValue: _groupVal, onChanged: (val){
                setState(() {
                  _groupVal = val as int;
                });
              }),
              Text('Code Barre')
            ],
          ) ],
      ),
    ),);
  }
}
