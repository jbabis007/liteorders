class Commandes{
  final int? com_id;
  final int ent_id;
  final String com_date;

  Commandes(this.com_id, this.ent_id, this.com_date);


  Map<String, dynamic> toMap() {
    return {
      'com_id': com_id,
      'ent_id': ent_id,
      'com_date': com_date
    };
  }

  factory Commandes.fromMap(Map<String, dynamic> map) => Commandes(
    map['com_id'],
    map['ent_id'],
    map['com_date']
  );

}