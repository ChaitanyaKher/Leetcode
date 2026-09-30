/*
 * @lc app=leetcode id=1111 lang=java
 *
 * [1111] Maximum Nesting Depth of Two Valid Parentheses Strings
 */

// @lc code=start
class Solution {
    public int[] maxDepthAfterSplit(String seq) {
        int n = seq.length();
        int[] ans = new int[n];

        int open = 0;
        int i = 0;

        for (char ch : seq.toCharArray()) {
            if (ch=='(') {
                open++;
                ans[i]=open%2;
            } else {
                ans[i] = open%2;
                open--;
            }
            i++;
        }

        return ans;
    }
}
// @lc code=end

