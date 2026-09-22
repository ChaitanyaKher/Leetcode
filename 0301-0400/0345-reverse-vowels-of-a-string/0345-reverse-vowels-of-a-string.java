/*
 * @lc app=leetcode id=345 lang=java
 *
 * [345] Reverse Vowels of a String
 */

// @lc code=start

class Solution {
    public String reverseVowels(String s) {
        boolean[] vowels = new boolean[128];
        for(char c: "aeiouAEIOU".toCharArray()) {
            vowels[c] = true;
        }

        char[] result = s.toCharArray();
        int left = 0;
        int right = result.length-1;

        while (left <right) {
            while (left < right && !vowels[result[left]]) {
                left++;
            }

            while (left < right && !vowels[result[right]]) {
                right--;
            }

            if (left<right) {
                char temp = result[right];
                result[right] = result[left];
                result[left] = temp;
                left++;
                right--;
            }
        }
        return String.valueOf(result);
    }
}
// @lc code=end

