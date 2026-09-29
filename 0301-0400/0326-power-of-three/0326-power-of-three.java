/*
 * @lc app=leetcode id=326 lang=java
 *
 * [326] Power of Three
 */

// @lc code=start
class Solution {
    public boolean isPowerOfThree(int n) {
        while (n>2) {
            if(n%3!=0) {
                return false;
            }
            n/=3;
        }
        return n==1;
    }
}
// @lc code=end

