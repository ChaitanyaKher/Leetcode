/*
 * @lc app=leetcode id=128 lang=java
 *
 * [128] Longest Consecutive Sequence
 */

// @lc code=start

import java.util.HashSet;

class Solution {
    public int longestConsecutive(int[] nums) {
        HashMap<Integer, Integer> map = new HashMap<>();
        int max = 0;

        for (int num : nums) {

            // Ignore duplicates
            if (map.containsKey(num))
                continue;

            int left = map.getOrDefault(num - 1, 0);
            int right = map.getOrDefault(num + 1, 0);

            // Length of the merged sequence
            int length = left + 1 + right;

            // Store for duplicate detection
            map.put(num, length);

            // Update the two boundaries
            map.put(num - left, length);
            map.put(num + right, length);

            max = Math.max(max, length);
        }

        return max;
    }
}
// @lc code=end

