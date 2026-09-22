class Solution {
    public int[] arrayRankTransform(int[] arr) {
        int[] sorted = arr.clone();
        Arrays.sort(sorted);

        Map<Integer, Integer> rank = new HashMap<>();
        int curRank = 1;

        for (int x : sorted) {
            if (!rank.containsKey(x))
                rank.put(x, curRank++);
        }

        int[] ans = new int[arr.length];

        for (int i = 0; i < arr.length; i++)
            ans[i] = rank.get(arr[i]);

        return ans;
    }
}