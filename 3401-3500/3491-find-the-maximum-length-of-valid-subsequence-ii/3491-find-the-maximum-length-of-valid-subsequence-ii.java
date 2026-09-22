class Solution {
    public int maximumLength(int[] nums, int k) {
        int n = nums.length;
        if(k==1) return n;

        int maxLen=2;
        int[] modArr = new int[n];
        for(int i= 0; i<n; i++) {
            modArr[i] = nums[i] %k;
        }

        for (int target = 0; target < k; target++) {
            int[] dp = new int[k];

            for (int i = 0; i < n; i++) {
                int currentRemainder = modArr[i];
                int required = (target - currentRemainder + k) % k;
                dp[currentRemainder] = dp[required] + 1;
                maxLen = Math.max(maxLen, dp[currentRemainder]);
            }
        }

        return maxLen;
    }
}