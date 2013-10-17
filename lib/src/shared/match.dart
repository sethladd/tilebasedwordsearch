part of wordherd_shared;

class Match extends Object with Persistable {
  String p1_id;
  String p2_id;
  
  Match();
  
  Match.fromJson(Map data) {
    p1_id = data['p1_id'];
    p2_id = data['p2_id'];
  }
  
  Map toJson() {
    return {'p1_id': p1_id, 'p2_id': p2_id};
  }
}
