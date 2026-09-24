/*
 * @lc app=leetcode id=213 lang=java
 *
 * [213] House Robber II
 */

// @lc code=start
class Solution {
    public int rob(int[] nums) {
        if (nums.length==1) {
            return nums[0];
        }
        int n = nums.length;
        int oddSum = robCircular(nums, 0, n-1);
        int evenSum = robCircular(nums, 1, n);
        return Math.max(oddSum, evenSum);
    }

    private int robCircular(int[] nums, int i, int j) {
        int prev1= 0;
        int prev2= 0;
        
        for (int k = i; k < j; k++) {
            int current = Math.max(prev1, prev2+nums[k]);
            prev2= prev1;
            prev1 = current;
        }

        return prev1;
    }

    private int ifFirstNotRobbed(int[] nums, int i, int j) {
        int sum = 0;
        for(int k=i;k<j;k++) {
            sum+=nums[k];
        }

        return sum;
    }

    private int ifFirstRobbed(int[] nums, int i, int j) {
        int sum = 0;
        for(int k=i;k<j;k++) {
            sum+=nums[k];
        }

        return sum;
    }
}
// @lc code=end

