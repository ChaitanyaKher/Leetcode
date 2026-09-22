/*
 * @lc app=leetcode id=643 lang=java
 *
 * [643] Maximum Average Subarray I
 */

// @lc code=start
class Solution {
    public double findMaxAverage(int[] nums, int k) {
        int windowSum = 0;
        
        for (int i = 0; i < k; i++) {
            windowSum+=nums[i];
        }

        int maxSum = windowSum;

        for (int i = k; i < nums.length; i++) {
            windowSum = windowSum + nums[i] - nums[i-k];
            if (windowSum>maxSum) {
                maxSum = windowSum;
            }
        }

        return (double) maxSum/k;
    }
}
// @lc code=end

