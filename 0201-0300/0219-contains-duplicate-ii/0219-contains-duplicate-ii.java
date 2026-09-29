/*
 * @lc app=leetcode id=219 lang=java
 *
 * [219] Contains Duplicate II
 */

// @lc code=start

import java.util.HashSet;
import java.util.Set;

class Solution {
    public boolean containsNearbyDuplicate(int[] nums, int k) {
        Set<Integer> set = new HashSet<>();

          for (int i = 0; i < nums.length; i++) {
            // Remove the element that is now outside the window
            if (i > k) {
                set.remove(nums[i - k - 1]);
            }

            // Try to add the current element. If it fails, a duplicate exists.
            if (!set.add(nums[i])) {
                return true;
            }
        }

        return false;
    }
}
// @lc code=end

