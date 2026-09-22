/*
 * @lc app=leetcode id=20 lang=java
 *
 * [20] Valid Parentheses
 */

// @lc code=start

import java.util.Stack;

class Solution {
        public boolean isValid(String s) {
            Stack<Character> characters = new Stack<>();

            char[] charArray= s.toCharArray();

            for(char c: charArray) {
                if (c== '('||c== '['||c== '{') {
                    characters.push(c);
                } else if (c == ')' || c == '}' || c == ']') {
                    if (characters.isEmpty()) return false;
                    char top = characters.pop();
                    if ((c == ')' && top != '(') ||
                            (c == '}' && top != '{') ||
                            (c == ']' && top != '[')) {
                        return false;
                    }
                }
            }

            return characters.isEmpty();
        }
}
// @lc code=end

