/*
 * @lc app=leetcode id=268 lang=java
 *
 * [268] Missing Number
 */

// @lc code=start
class Solution {
    public int missingNumber(int[] nums) {
        int n = 0;
    	
    	System.out.println("1. Full number range:");
    	for (int i = 0; i < nums.length + 1; i++)
    	{
    		System.out.print(String.format("1. [%d] XOR [%d] = ", n, i));
    		n = n ^ i;
    		System.out.println(String.format("[%d]", n));
    	}
    	
    	System.out.println("2. Actual array contents:");
    	for (int i = 0; i < nums.length; i++)
    	{
    		System.out.print(String.format("2. [%d] XOR [%d] = ", n, nums[i]));
    		n = n ^ nums[i];
    		System.out.println(String.format("[%d]", n));
    	}
    	
    	return n;
    }
}
// @lc code=end

