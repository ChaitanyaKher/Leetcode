/*
 * @lc app=leetcode id=373 lang=java
 *
 * [373] Find K Pairs with Smallest Sums
 */

// @lc code=start

import java.util.ArrayList;
import java.util.List;
import java.util.PriorityQueue;

class Solution {
    public List<List<Integer>> kSmallestPairs(int[] nums1, int[] nums2, int k) {
        List<List<Integer>> result = new ArrayList<>();
        PriorityQueue<int[]> priorityQueue = new PriorityQueue<>((a,b) -> a[0]-b[0]);

        for(int x: nums1) {
            priorityQueue.offer(new int[]{x+nums2[0],0});
        }

        while (k>0&&!priorityQueue.isEmpty()) {
            int[] pair = priorityQueue.poll();
            int sum = pair[0];
            int pos = pair[1];

            List<Integer> currentList = new ArrayList<>();
            currentList.add(sum-nums2[pos]);
            currentList.add(nums2[pos]);
            result.add(currentList);

            if (pos+1<nums2.length) {
                priorityQueue.offer(new int[]{sum - nums2[pos] + nums2[pos + 1], pos + 1});
            }

            k--;
            
        }

        return result;
    }
}
// @lc code=end

