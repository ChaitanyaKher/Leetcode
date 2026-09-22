/*
 * @lc app=leetcode id=67 lang=java
 *
 * [67] Add Binary
 */

// @lc code=start
class Solution {
    public String addBinary(String a, String b) {
        StringBuilder stringBuilder = new StringBuilder();
        int i = a.length()-1, j = b.length()-1;
        for(int carry =0; i>=0|| j>=0|| carry>0; --i, --j) {
            carry += (i>=0 ? a.charAt(i) - '0' : 0) + (j>=0? b.charAt(j)-'0': 0);
            stringBuilder.append(carry%2);
            carry/=2;
        }
        return stringBuilder.reverse().toString();
    }
}
// @lc code=end

