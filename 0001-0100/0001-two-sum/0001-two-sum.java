/*
 * @lc app=leetcode id=1 lang=java
 *
 * [1] Two Sum
 */

// @lc code=start

import java.security.Key;
import java.util.HashMap;

class Solution {
    public int[] twoSum(int[] nums, int target) {
        HashMap<Integer,Integer> arrayHashMap= new HashMap<>();
        for(int i=0;i<nums.length;i++) {
            arrayHashMap.put(nums[i], i);
        }
    }
}
// @lc code=end

