/*
 * @lc app=leetcode id=1 lang=java
 *
 * [1] Two Sum
 */

// @lc code=start

import java.util.HashMap;

class Solution {
    public int[] twoSum(int[] nums, int target) {
        HashMap<Integer, Integer> keys = new HashMap<>();
        for(int i=0; i<=nums.length-1;i++) {
            keys.put(nums[i], i);
        }
        for(int i=0;i<=nums.length-1;i++) {
            if ((keys.containsKey(target-nums[i]))&&(i!=keys.get(target-nums[i]))) {
                return new int[]{i,keys.get(target-nums[i])};
            }
        }  

        return null;
    }
}
// @lc code=end

