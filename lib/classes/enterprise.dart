class Enterprise {
  final int? ent_id;
  final String ent_nom_entite;
  final String? ent_nom;
  final String? ent_prenom;
  final String? ent_adr;
  final String? ent_tels;

  Enterprise(this.ent_id, this.ent_nom_entite, this.ent_nom, this.ent_prenom,
      this.ent_adr, this.ent_tels);

  Map<String, dynamic> toMap() {
    return {
      'ent_id': ent_id,
      'ent_nom_entite': ent_nom_entite,
      'ent_nom': ent_nom,
      'ent_prenom': ent_prenom,
      'ent_adr': ent_adr,
      'ent_tels': ent_tels
    };
  }

  factory Enterprise.fromMap(Map<String, dynamic> map) => Enterprise(
        map['ent_id'],
        map['ent_nom_entite'],
        map['ent_nom'],
        map['ent_prenom'],
        map['ent_adr'],
        map['ent_tels'],
      );
}
