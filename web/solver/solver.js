function Trie() {
	this.value = null;
	this.map = {};
}

Trie.prototype.nodeFor = function(character) {
	return map[character.charAt(0)];
}

Trie.prototype.get = function(key) {
	var node = this;
    for (var i = 0; i < key.length; i++) {
      var char = key.charAt(i);

      node = node.map[char];
      if (node == null) {
        return null;
      }
    }
    return node.value;
}

/**
 * character is a String
 */
Trie.prototype.nodeFor = function(character) {
	return this.map[character.charAt(0)];
}

Trie.prototype.set = function(key, value) {
    var node = this;
    for (var i = 0; i < key.length; i++) {
      var char = key.charAt(i);

      var current = node;
      node = node.map[char];
      if (node == null) {
        current.map[char] = node = new Trie();
      }
    }
    node.value = value;
}

function Solver(grid, words) {
	this._words = words;
	this._grid = grid;
	this._visited = [[false, false, false, false], [false, false, false, false], [false, false, false, false], [false, false, false, false]];
	this._found = [];
}

/**
 * inProgress is a Trie
 */
Solver.prototype._solve = function(x, y, inProgress) {
	var nextStep = inProgress.nodeFor(this._grid[x][y]);
	
	if (nextStep != null && nextStep != undefined) {
		if (nextStep.value != null) {
			this._found.push(nextStep.value);
		}
		
		this._visited[x][y] = true;
		
		for (var _x = -1; _x < 2; _x++) {
		    var nX = x + _x;
		    if (nX < 0 || nX > 3) continue;
		    for (var _y = -1; _y < 2; _y++) {
		      if (_x == 0 && _y == 0) continue;
		      var nY = y + _y;
		      if (nY < 0 || nY > 3) continue;
		      if (this._visited[nX][nY] == true) continue;
		      this._solve(nX, nY, nextStep);
		    }
	 	}
		
		this._visited[x][y] = false;
	}
}

Solver.prototype.findAll = function() {
	for (var x = 0; x < 4; x++) {
		for (var y = 0; y < 4; y++) {
			this._solve(x, y, this._words);
    	}
	}
	  
	return this._found;
}

function main() {
  var numWords = document.getElementById('num-words');
  var resultsWords = document.getElementById('results-words');
  var resultsLength = document.getElementById('results-length');
  var time = document.getElementById('time');
  
  var grid = [
    ['A', 'B', 'C', 'D'],
    ['E', 'F', 'G', 'H'],
    ['I', 'J', 'K', 'L'],
    ['M', 'N', 'O', 'P']
  ];
  
  var words = new Trie();
  
  var request = new XMLHttpRequest();
  request.onreadystatechange = function() {
  	if (request.readyState === 4) {
  	  if (request.status === 200) {
	  	  console.log('received file');
	  	  
	  	  var text = request.responseText;
	  	  text.split("\n").forEach(function(line) {
	  	  	words.set(line, line);
	  	  });
	  	  
	  	  var solver = new Solver(grid, words);
	  	  
	  	  var start = new Date();
	  	  var results = solver.findAll();
	  	  var stop = new Date();
	  	  
	  	  var elapsed = stop - start;
	  	  
	  	  resultsWords.innerHTML = results;
	      resultsLength.innerHTML = results.length;
	      time.innerHTML = 'Found in ' + elapsed + ' ms';
	  } else {
	      console.log('error');
	  }
  	}
  };
  request.open('GET', '../assets/dictionary.txt');
  request.send();
  

}

main();