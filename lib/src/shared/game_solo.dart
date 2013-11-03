part of wordherd_shared;

class GameSolo extends Object with Persistable {
  @serialized Board board;
  @serialized Game game;
  DateTime created_at; // set by persistance
  DateTime updated_at;
}