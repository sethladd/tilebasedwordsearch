import java.io.*;
import java.util.*;

public class Solver {

    private Trie<String> words;
    private String[][] grid;
    private boolean[][] visited;
    private List<String> found;

    Solver(String[][] grid, Trie<String> words) {
        this.grid = grid;
        this.words = words;
        this.visited = new boolean[4][4];
        this.found = new ArrayList<String>();
    }

    public List<String> findAll() {
        for (int x = 0; x < 4; x++) {
            for (int y = 0; y < 4; y++) {
                solve(x, y, words);
            }
        }

        return found;
    }

    private void solve(int x, int y, Trie<String> inProgress) {

        final Trie<String> nextStep = inProgress.nodeFor(grid[x][y]);

        if (nextStep != null) {
            if (nextStep.getValue() != null) {
                found.add(nextStep.getValue());
            }

            visited[x][y] = true;

            for (int _x = -1; _x < 2; _x++) {
                int nX = x + _x;
                if (nX < 0 || nX > 3)
                    continue;
                for (int _y = -1; _y < 2; _y++) {
                    if (_x == 0 && _y == 0)
                        continue;
                    int nY = y + _y;
                    if (nY < 0 || nY > 3)
                        continue;
                    if (visited[nX][nY] == true)
                        continue;
                    solve(nX, nY, nextStep);
                }
            }

            visited[x][y] = false;
        }

    }

    public static void main(String[] args) throws Exception {
        String[][] grid = new String[][] { { "A", "B", "C", "D" },
                { "E", "F", "G", "H" }, { "I", "J", "K", "L" },
                { "M", "N", "O", "P" } };

        Trie<String> words = new Trie<String>();
        Scanner sc = new Scanner(new File(args[0]));
        while (sc.hasNextLine()) {
            String line = sc.nextLine();
            words.set(line, line);
        }

        //System.out.println(words.size());

        Solver solver = new Solver(grid, words);

        long start = System.currentTimeMillis();
        List<String> results = solver.findAll();
        long stop = System.currentTimeMillis();

        long time = stop - start;

        System.out.println(results);
        System.out.println(results.size());
        System.out.println(time);
    }

}
