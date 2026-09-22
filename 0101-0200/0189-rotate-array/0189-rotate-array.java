class Solution {
    public void rotate(int[] nums, int k) {
        int n = nums.length;
        int[] result = new int[n];

        k = k%n;

        for(int i = 0; i<n; i++) {
            result[(i+k)%n] = nums[i];
        }

        for (int i = 0; i < nums.length; i++) {
            nums[i] = result[i];
        }
    }
}