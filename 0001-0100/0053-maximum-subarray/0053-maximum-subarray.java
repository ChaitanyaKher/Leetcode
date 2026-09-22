class Solution {
    public int maxSubArray(int[] nums) {
        int maxSum = Integer.MIN_VALUE;
        int prefixSum = 0;
        for(int i =0; i<nums.length;i++) {
            prefixSum=Math.max(prefixSum+nums[i], nums[i]);
            maxSum = Math.max(prefixSum,maxSum);
        }
        return maxSum;
    }
}