part of wordherd_shared;

class Player extends Object with Persistable {
  String gplus_id;
  String name;
  String toString() => 'id: [$id], gplus_id: [$gplus_id], name: [$name]';
}