class Solution {
    public boolean isPairEqual(int index, int[] nums){
        return nums[index] == nums[index+1];
    }

    public boolean isTripleEqual(int index, int[] nums){
        return nums[index] == nums[index+1] && nums[index] == nums[index+2];
    }

    public boolean isTripleConsecutive(int index, int[] nums){
        return nums[index] + 1 == nums[index+1] && nums[index+1] + 1 == nums[index+2];
    }
    public boolean validPartition(int[] nums) {
        int[] dp = new int[nums.length+1];
        dp[nums.length] =1;
        dp[nums.length-1] = 0; // if(index == nums.length - 1) return false;
        dp[nums.length-2] = isPairEqual(nums.length-2,nums) ? 1 : 0; //if(index == nums.length - 2) return isPairEqual(index,nums);
        for(int index=nums.length-3;index>=0;index--) {
            dp[index] = isPairEqual(index,nums) && dp[index+2] == 1 ? 1 : 0; // isPairEqual(index,nums) && memoSol(index+2,nums,dp);
            if(dp[index] == 0) {
                dp[index] = (isTripleEqual(index,nums) || isTripleConsecutive(index,nums)) && dp[index+3] == 1 ? 1 : 0; //(isTripleEqual(index,nums) || isTripleConsecutive(index,nums)) && memoSol(index+3,nums,dp);
            }
        }
        return dp[0] == 1;
    }
}