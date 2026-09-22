/*
 * @lc app=leetcode id=238 lang=java
 *
 * [238] Product of Array Except Self
 */

// @lc code=start
class Solution {
    public int[] productExceptSelf(int[] nums) {
        int[] answer = new int[nums.length];
        int prefix = 1;
        for(int i=0; i<nums.length; i++) {
            answer[i] = prefix;
            prefix *= nums[i];
        }
        int suffix = 1;
        for(int j=nums.length-1; j>=0; j--) {
            answer[j] *= suffix;
            suffix *= nums[j];
        }
        return answer;
    }
}
// @lc code=end

