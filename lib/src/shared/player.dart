part of shared;

class Player extends Object with Persistable {
  String gplus_id;
  String name;
  
  Player();
  
  Player.fromPersistence(Map data) {
    dbId = data['id'];
    gplus_id = data['gplus_id'];
    name = data['name'];
  }
  
  Map toJson() {
    return {'id': dbId, 'gplus_id': gplus_id, 'name': name};
  }
}