import java.io.*;
import java.util.*;

public class Solver {
    
    private Map<String, Boolean> words;
    private String[][] grid;
    private boolean[][] visited;
    private Map<String, Boolean> found;

    Solver(String[][] grid, Map<String, Boolean> words) {
        this.grid = grid;
        this.words = words;
        this.visited = new boolean[4][4];
        this.found = new HashMap<String, Boolean>();
    }
    
    public Set<String> findAll() {
        for (int x = 0; x < 4; x++) {
            for (int y = 0; y < 4; y++) {
                solve(x, y, "");
            }
        }
        
        return found.keySet();
    }
    
    private void solve(int x, int y, String word) {
        visited[x][y] = true;
        
        String newWord = word + grid[x][y];
        
        if (words.containsKey(newWord)) {
          found.put(newWord, true);
        }
        
        for (int _x = -1; _x < 2; _x++) {
          int nX = x + _x;
          if (nX < 0 || nX > 3) continue;
          for (int _y = -1; _y < 2; _y++) {
            if (_x == 0 && _y == 0) continue;
            int nY = y + _y;
            if (nY < 0 || nY > 3) continue;
            if (visited[nX][nY] == true) continue;
            solve(nX, nY, newWord);
          }
        }
        
        visited[x][y] = false;
    }

	public static void main(String[] args) throws Exception {
	    String[][] grid = new String[][] {
	            {"A", "B", "C", "D"},
	            {"E", "F", "G", "H"},
	            {"I", "J", "K", "L"},
	            {"M", "N", "O", "P"}
	    };
	    
	    Map<String, Boolean> words = new HashMap<String, Boolean>();
	    Scanner sc = new Scanner(new File(args[0]));
	    while (sc.hasNextLine()) {
	        words.put(sc.nextLine(), true);
	    }
	    
	    System.out.println(words.size());
	    
	    Solver solver = new Solver(grid, words);
	    
	    Date start = new Date();
	    Set<String> results = solver.findAll();
	    Date stop = new Date();
	    
	    long time = stop.getTime() - start.getTime();
	    
	    System.out.println(results);
	    System.out.println(results.size());
	    System.out.println(time);
	}

}
