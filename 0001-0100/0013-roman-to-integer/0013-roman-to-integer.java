/*
 * @lc app=leetcode id=13 lang=java
 *
 * [13] Roman to Integer
 */

// @lc code=start

import java.util.HashMap;
import java.util.Map;

class Solution {
    public int romanToInt(String s) {
        
        Map<Character, Integer> map = new HashMap<>();

        map.put('I', 1);
        map.put('V', 5);
        map.put('X', 10);
        map.put('L', 50);
        map.put('C', 100);
        map.put('D', 500);
        map.put('M', 1000);

        int ans = 0;

        for(int i = 0; i < s.length(); i++){

            // Value of current character
            int curr = map.get(s.charAt(i));

            // Value of next character
            int next = 0;

            // Check if next character exists
            if(i + 1 < s.length()){
                next = map.get(s.charAt(i + 1));
            }

            // Smaller value before larger value → subtract
            if(curr < next){
                ans = ans - curr;
            }
            else{
                ans = ans + curr;
            }
        }

        return ans;
    }
}
// @lc code=end

