part of wordherd_shared;

class Match extends Object with Persistable {
  String p1_id;
  String p2_id;
  @serialized Board board;
  @serialized Game p1_game;
  @serialized Game p2_game;
}
