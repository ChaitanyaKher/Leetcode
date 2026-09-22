/*
 * @lc app=leetcode id=704 lang=java
 *
 * [704] Binary Search
 */

// @lc code=start
class Solution {
    public int search(int[] nums, int target) {
        int left = 0;
        int right = nums.length-1;

        while (left<=right) {
            int pivot = left+ (right-left)/2;
            if (nums[pivot] == target) {
                return pivot;
            } else if (nums[pivot]>target) {
                right = pivot-1;
            } else {
                left = pivot+1;
            }
        }

        return -1;
    }
}
// @lc code=end

