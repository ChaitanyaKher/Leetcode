/*
 * @lc app=leetcode id=35 lang=java
 *
 * [35] Search Insert Position
 */

// @lc code=start
class Solution {
    public int searchInsert(int[] nums, int target) {
        int index = 0;
        for(int i = 0; i<=nums.length-1; i++) {
            if (target<=nums[i]) {
                index = i;
            }
        }

        return index;
    }
}
// @lc code=end

