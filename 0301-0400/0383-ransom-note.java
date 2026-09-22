/*
 * @lc app=leetcode id=383 lang=java
 *
 * [383] Ransom Note
 */

// @lc code=start

import java.util.HashMap;

class Solution {
    public boolean canConstruct(String ransomNote, String magazine) {
        //count characters in magazine 
        HashMap<Character, Integer> count = new HashMap<>();

        for(char c: magazine.toCharArray()) {
            count.put(c, count.getOrDefault(c, 0)+1);
        }

        for(char r: ransomNote.toCharArray()) {
            if (count.getOrDefault(r, 0) == 0) {
                return false;
            }
            count.put(r, count.get(r)-1);
        }
        return true;
    }
}
// @lc code=end

