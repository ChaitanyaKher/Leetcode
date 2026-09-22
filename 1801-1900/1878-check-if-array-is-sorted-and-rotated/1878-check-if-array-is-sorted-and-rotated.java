class Solution {
    public boolean check(int[] nums) {
        int count = 0;
        int size = nums.length;

        for(int i = 1; i< size;i++) {
            if (nums[i-1]>nums[i]) {
                count++;
            }
        }

        if (nums[size-1]>nums[0]) {
            count++;
        }

        return count<=1;
    }
}