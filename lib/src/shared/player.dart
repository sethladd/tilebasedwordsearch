part of shared;

class Player extends Object with Persistable {
  String gplus_id;
  
  Map toJson() {
    return {'id': dbId, 'gplus_id': gplus_id};
  }
}