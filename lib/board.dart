library board;

import 'package:tilebasedwordsearch/game.dart';
import 'dart:math';

class Board {
  Game game;
  static const DIMENSIONS = 4;
  static const List<String> LETTERS = const ['A', 'B', 'C', 'D', 'E', 'F',
                                             'G', 'H', 'I', 'J', 'I', 'J',
                                             'K', 'L', 'M', 'N', 'O', 'P', 
                                             'QU', 'R', 'S', 'T', 'U', 'V',
                                             'W', 'X', 'Y', 'Z'];
  
  List<List<String>> grid = new List.generate(4, (_) => new List<String>(4));
  
  List currentSelection = new List();
  
  Board(this.game) {
    _assignCharsToTiles();
  }
  
  String letterAtTile(x, y) => grid[x][y];
  
  // TODO: Need better algorithm that ensures a minimum number of vowels.
  void _assignCharsToTiles() {
    Random random = new Random();
    for (var i = 0; i < DIMENSIONS; i++) {
      for (var j = 0; j < DIMENSIONS; j++) {
        this.grid[i][j] = LETTERS[random.nextInt(LETTERS.length)];
      }
    }
  }
}

// TODO: don't make this a top level function.
bool validPath(position1, position2) {
  bool validPath = true;
  
  if (!_vertical(position1, position2) && 
      !_horizontal(position1, position2) &&
      !_diagonal(position1, position2)) {
    validPath = false;
  }
  return validPath;
}

// Args are GameLoopTouchPosition(s).
bool _vertical(position1, position2) => position1.x == position2.x;

bool _horizontal(position1, position2) => position1.y == position2.y;

bool _diagonal(position1, position2) {
  return ((position1.x - position2.y).abs() == 1 && 
          (position1.y - position2.x).abs()) &&
         !(position1.x == position2.x && position1.x == position2.x);
}