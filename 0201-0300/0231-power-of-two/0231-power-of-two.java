/*
 * @lc app=leetcode id=231 lang=java
 *
 * [231] Power of Two
 */

// @lc code=start
class Solution {
    public boolean isPowerOfTwo(int n) {
        while (n>1) {
            if (n%2!=0) {
                return false;
            }
            n/=2;
        }
        return n==1;
    }
}
// @lc code=end

