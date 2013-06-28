part of shared;

class Player extends Object with Persistable {
  String gplus_id;
  String name;
  
  Player();
  
  Player.fromPersistence(String id, Map data) {
    this.id = id;
    gplus_id = data['gplus_id'];
    name = data['name'];
  }
  
  Map toJson() {
    return {'id': id, 'gplus_id': gplus_id, 'name': name};
  }
  
  String toString() => toJson().toString();
}