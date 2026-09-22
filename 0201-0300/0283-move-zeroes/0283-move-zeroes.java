/*
 * @lc app=leetcode id=283 lang=java
 *
 * [283] Move Zeroes
 */

// @lc code=start
class Solution {
    public void moveZeroes(int[] nums) {
        int[] result = new int[nums.length];
        int j=0;

        for(int i=0;i<nums.length;i++) {
            if (nums[i]!=0) {
                result[j] = nums[i];
                j++;
            }
        }

        for(int i = 0; i< nums.length; i++) {
            nums[i] = result[i];
        }
    }
}
// @lc code=end

