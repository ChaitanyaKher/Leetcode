class Solution {
    public int findPairs(int[] nums, int k) {
                if (k < 0) {
            return 0;
        }

        // Create a HashMap to store the frequency of each number
        Map<Integer, Integer> numCount = new HashMap<>();
        int result = 0;

        // Populate the HashMap with the frequency of each number in the array
        for (int num : nums) {
            numCount.put(num, numCount.getOrDefault(num, 0) + 1);
        }

        // Iterate through the HashMap to find k-diff pairs
        for (int num : numCount.keySet()) {
            if (k == 0) {
                if (numCount.get(num) > 1) {
                    result++;
                }
            } else {
                if (numCount.containsKey(num + k)) {
                    result++;
                }
            }
        }

        return result;

    }
}