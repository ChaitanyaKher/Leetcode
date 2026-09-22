class Solution {
    public int findGCD(int[] nums) {
        int min = Integer.MAX_VALUE;
        int max = 0;
        for (int i = 0; i < nums.length; i++) {
            min = Math.min(min, nums[i]);
            max = Math.max(max, nums[i]);
        }
        return find(min, max);
    }
    
    private int find(int a, int b) {
        if (a == 0) return b;
        // if (b % a == 0) return a;
        // else if (a % b == 0) return b;
        // return b - a > 0 ? find(b - a, a) : find(a - b, a);
        return find(b % a, a);
    }
}