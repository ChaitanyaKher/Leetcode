class Solution {
    public int maximumSafenessFactor(List<List<Integer>> grid) {
        int n = grid.size();
        int[][] dist = new int[n][n];
        for (int[] row : dist) Arrays.fill(row, -1);

        Deque<int[]> queue = new ArrayDeque<>();
          for (int i = 0; i < n; i++) {
              for (int j = 0; j < n; j++) {
                  if (grid.get(i).get(j) == 1) {
                      dist[i][j] = 0;
                      queue.offer(new int[]{i, j});
                  }
              }
          }

          int[][] dirs = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}};
          while (!queue.isEmpty()) {
              int[] cur = queue.poll();
              for (int[] d : dirs) {
                  int r = cur[0] + d[0], c = cur[1] + d[1];
                  if (r >= 0 && r < n && c >= 0 && c < n && dist[r][c] == -1) {
                      dist[r][c] = dist[cur[0]][cur[1]] + 1;
                      queue.offer(new int[]{r, c});
                  }
              }
          }

          PriorityQueue<int[]> pq = new PriorityQueue<>((a, b) -> b[0] - a[0]);
          boolean[][] visited = new boolean[n][n];
          pq.offer(new int[]{dist[0][0], 0, 0});
          visited[0][0] = true;

          while (!pq.isEmpty()) {
              int[] cur = pq.poll();
              int safeness = cur[0], row = cur[1], col = cur[2];
              if (row == n - 1 && col == n - 1) return safeness;
              for (int[] d : dirs) {
                  int r = row + d[0], c = col + d[1];
                  if (r >= 0 && r < n && c >= 0 && c < n && !visited[r][c]) {
                      visited[r][c] = true;
                      pq.offer(new int[]{Math.min(safeness, dist[r][c]), r, c});
                  }
              }
          }
          return 0;
    }
}