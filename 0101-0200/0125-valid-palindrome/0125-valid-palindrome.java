/*
 * @lc app=leetcode id=125 lang=java
 *
 * [125] Valid Palindrome
 */

// @lc code=start
class Solution {
    public boolean isPalindrome(String s) {
        if (s.isEmpty()) {
            return true;
        }
        int low = 0;
        int high = s.length()-1;
        while (low<=high) {
            char start = s.charAt(low);
            char last = s.charAt(high);

            if (!Character.isLetterOrDigit(start)) {
                low++;
            } else if (!Character.isLetterOrDigit(last)) {
                high--;
            } else if (Character.toLowerCase(start)!=Character.toLowerCase(last)) {
                return false;
            }

            low++;
            high--;

        }
        return true;
    }
}
// @lc code=end

