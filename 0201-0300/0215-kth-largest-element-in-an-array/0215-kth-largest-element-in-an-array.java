class Solution {
    public int findKthLargest(int[] nums, int k) {
        PriorityQueue<Integer> min = new PriorityQueue<>();
        for (int num = 0;num<nums.length;num++) {
            min.offer(nums[num]);

            if (min.size() > k) {
                min.poll();
            }
        }
        
        return min.peek();
    }
}