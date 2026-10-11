/*
 * @lc app=leetcode id=2778 lang=java
 *
 * [2778] Sum of Squares of Special Elements 
 */

// @lc code=start
class Solution {
    public int sumOfSquares(int[] nums) {
        int n = nums.length;
        int ans = 0;
        for (int i = 1; i <= n; i++) {
            if (n % i == 0) {
                ans += nums[i - 1] * nums[i - 1];
            }
        }
        return ans;
    }
}
// @lc code=end

