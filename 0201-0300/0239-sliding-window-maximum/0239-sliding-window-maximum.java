class Solution {
    public int[] maxSlidingWindow(int[] nums, int k) {
        int n = nums.length;
        int[] ans = new int[n-k+1];
        Deque<Integer> queue = new ArrayDeque<>();
        for(int i = 0;i<k;i++)
        {
            while(queue.size() > 0 && queue.getLast() < nums[i])
                queue.removeLast();
            queue.addLast(nums[i]);
        }
        int idx = 0;
        ans[idx++] = queue.getFirst();
        for(int i = k;i<n;i++)
        {
            if(queue.getFirst() == nums[i-k])
                queue.removeFirst();
            while(queue.size()>0 && queue.getLast() < nums[i])
                queue.removeLast();
            queue.addLast(nums[i]);
            ans[idx++] = queue.getFirst();
        }
        return ans;
    }
}