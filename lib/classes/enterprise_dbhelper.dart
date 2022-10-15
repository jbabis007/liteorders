import 'package:flutter/material.dart';
import 'package:liteorders/classes/delail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'enterprise.dart';
import 'commandes.dart';

class EnterpriseDbHelper {
  EnterpriseDbHelper._init();

  static final EnterpriseDbHelper instance = EnterpriseDbHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initiateDatabase();
    return _database!;
  }

  initiateDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "mydatabase.db");
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE "Enterprise" ( "ent_id" INTEGER NOT NULL,
                                                     "ent_nom_entite" TEXT NOT NULL,
                                                     "ent_nom" TEXT,
                                                     "ent_prenom" TEXT,
                                                     "ent_adr" TEXT,
                                                     "ent_tels" TEXT,
                                                     PRIMARY KEY ("ent_id" AUTOINCREMENT));                                              
                                                     ''');
    await db.execute(''' CREATE TABLE "Commandes" ( "com_id" INTEGER NOT NULL,
                                                   "ent_id" INTEGER NOT NULL,
                                                   "com_date" TEXT,
                                                   FOREIGN KEY ("ent_id") REFERENCES "Enterprise"("ent_id"),
                                                   PRIMARY KEY ("com_id" AUTOINCREMENT));''');
    await db.execute('''CREATE TABLE "Detaille" ( "com_id" INTEGER NOT NULL,
                                                  "ref" TEXT NOT NULL,
                                                  "qt" INTEGER ,
                                                  "prix" REAL ,
                                                  FOREIGN KEY ("com_id") REFERENCES "Commandes" ("com_id"),
                                                  PRIMARY KEY ("com_id","ref"));''');
  }

  Future<int> LaTota() async {
    final db = await database;
    return 5;
  }

  void InsertData(Enterprise enterprise) async {
    final db = await database;
    await db.insert('Enterprise', enterprise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<List<Enterprise>> GetEnterprises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Enterprise');
    List<Enterprise> Enters = List.generate(maps.length, (index) {
      return Enterprise.fromMap(maps[index]);
    });
    return Enters;
  }

  Future<List<Commandes>> GetLesCommandes(int ent_id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''SELECT * FROM Commandes WHERE ent_id = ?''', [ent_id]);
    return List.generate(
        maps.length, (index) => Commandes.fromMap(maps[index]));
  }

  Future<String> delEnterprise(int id) async {
    final db = await database;
    var maps = await db.rawQuery('''SELECT * FROM Commandes WHERE ent_id = ? ''',[id]);
    if (maps.length >0 ){
      return "Suppression impossible : Le client posséde des commandes ! ";
    }else {
      var count = await db.delete('Enterprise', where: 'ent_id = ?', whereArgs: [id]);
      return (count >0) ?'Suppression Reussie' : 'Echec de la suppression';
    }


  }

  void updateEnterprise(Enterprise enterprise) async {
    final db = await database;
    if (enterprise.ent_nom_entite.isNotEmpty) {
      await db.rawUpdate('''UPDATE  Enterprise 
                          SET ent_nom_entite = ? , ent_nom = ?,
                          ent_prenom = ?, ent_adr = ?, ent_tels = ? 
                          WHERE ent_id =?
                           ''', [
        enterprise.ent_nom_entite.toString(),
        enterprise.ent_nom.toString(),
        enterprise.ent_prenom.toString(),
        enterprise.ent_adr.toString(),
        enterprise.ent_tels.toString(),
        enterprise.ent_id
      ]);
    }
  }

  Future<int> insertCommandes(Commandes commande) async {
    final db = await database;
    return await db.insert('Commandes', commande.toMap());
  }

  Future<List<Detail>> getDetailCommande(int com_id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''SELECT * FROM Detaille WHERE com_id = ? ''', [com_id]);
    return List.generate(maps.length, (index) => Detail.fromMap(maps[index]));
  }

  Future<int> insertDEtails(Detail detail) async {
    final db = await database;
    var maps = await db.rawQuery(
        '''SELECT * FROM Detaille WHERE com_id = ? AND ref = ? ''',  [detail.com_id, detail.ref]);
    if (maps.isNotEmpty) {
     int oldQt = maps.first['qt'] as int;

    return await db.rawUpdate('''UPDATE Detaille SET qt = ? WHERE com_id = ? AND ref = ?''',
                                          [oldQt+detail.qt,detail.com_id, detail.ref]);
    } else {
     return await db.insert('Detaille', detail.toMap());
    }
  }
  Future<String> updateDetail (Detail detail, String newRef, int qt, double prix) async {
    final db = await database;
    if (detail.ref != newRef){
      var tempResult = await db.rawQuery(
          '''SELECT * FROM Detaille WHERE com_id = ? AND ref = ? ''',  [detail.com_id, newRef]);
      if (tempResult.isNotEmpty){
        return 'Modification impossible, référence déja existante !';
      }else{
        await db.rawUpdate('''UPDATE Detaille SET ref = ? ,   
                                    qt = ?, prix = ?  WHERE com_id = ? AND ref = ?''',
            [newRef,qt,prix,detail.com_id, detail.ref]);
        return 'Modification Reussie .';
      }
    }else{
      await db.rawUpdate('''UPDATE Detaille SET   
                                    qt = ?, prix = ?  WHERE com_id = ? AND ref = ?''',
          [qt,prix,detail.com_id, detail.ref]);
      return 'Modification Reussie .';
    }
  }

 Future<String> deleteDetail(Detail detail) async {
    final db = await database;
    var count = await db.delete('Detaille',where: ' com_id = ? AND ref = ?', whereArgs: [detail.com_id, detail.ref]);
    return (count >0) ?'Suppression Reussie' : 'Echec de la suppression';

 }

 Future<Enterprise> getEnterpriseFromCom_Id (int com_id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''SELECT DISTINCT  Enterprise.ent_id , Enterprise.ent_nom_entite, 
                                  Enterprise.ent_nom, Enterprise.ent_prenom,
                                  Enterprise.ent_adr, Enterprise.ent_tels FROM 
                                  Enterprise ,  Commandes WHERE 
                                  Enterprise.ent_id = Commandes.ent_id AND 
                                  Commandes.com_id =  ?''',[com_id]);
    var tempList = List.generate(maps.length, (index) => Enterprise.fromMap(maps[index]));
    return tempList[0];
 }

 Future<String> getDateFromCom_id (int com_id) async {
    final db = await database;
    var maps = await db.rawQuery('''SELECT Commandes.com_date FROM Commandes WHERE Commandes.com_id = ?''',[com_id]);
    String date =  maps.first['com_date'] as String ;
    return date;

 }

 Future<String> deleteCommande (int com_id) async {
    final db = await database;
    var maps = await db.rawQuery('''SELECT * FROM Detaille WHERE com_id = ? ''',[com_id]);
    if (maps.length >0 ){
      return "Suppression impossible : La commande n'est pas vide ! ";
    }else {
      var count = await db.delete('Commandes',where: ' com_id = ? ', whereArgs: [com_id]);
      return (count >0) ?'Suppression Reussie' : 'Echec de la suppression';
    }
    
 }
 
}
