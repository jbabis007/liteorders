


class Detail{
  final int? com_id;
  final String ref;
  final int qt;
  final double prix;


  Detail(this.com_id, this.ref, this.qt, this.prix);

  Map<String, dynamic> toMap() {
    return {
      'com_id': com_id,
      'ref': ref,
      'qt': qt,
      'prix':prix

    };
  }

  factory Detail.fromMap(Map<String, dynamic> map) => Detail(
      map['com_id'],
      map['ref'],
      map['qt'],
      map['prix']
  );
}

//------------ONLY FOR PDF FILES----------------------------------------
class DetailPdfFile {
   String ref;
   int qt;
   double prix;
   double prixtotal;

   DetailPdfFile(this.ref, this.qt, this.prix, this.prixtotal);
}