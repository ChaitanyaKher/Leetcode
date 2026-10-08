/*
 * @lc app=leetcode id=1 lang=java
 *
 * [1] Two Sum
 */

// @lc code=start
import java.util.*;
class Solution {
    public int[] twoSum(int[] nums, int target) {
        HashMap<Integer, Integer> map = new HashMap<>();
        for(int i =0;i<nums.length;i++) {
            map.put(nums[i], i);
        }
        int[] result = new int[2];
        for(int i=0;i< nums.length;i++) {
            int value = target-nums[i];
            if (map.containsKey(value)&&map.get(value)!=i) {
                result[0] = i;
                result[1] = map.get(value);
                return result;
            }
        }
        return result;
    }
}
// @lc code=end

