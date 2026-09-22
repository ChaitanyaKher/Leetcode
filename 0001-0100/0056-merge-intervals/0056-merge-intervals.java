class Solution {
    public int[][] merge(int[][] intervals) {
        Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));

          List<int[]> merged = new ArrayList<>();
          for (int[] interval : intervals) {
              // No overlap: current starts after the last merged interval ends.
              if (merged.isEmpty() || interval[0] > merged.get(merged.size() - 1)[1]) {
                  merged.add(interval);
              } else {
                  // Overlap: extend the end of the last interval.
                  int[] last = merged.get(merged.size() - 1);
                  last[1] = Math.max(last[1], interval[1]);
              }
          }

          return merged.toArray(new int[merged.size()][]);
    }
}