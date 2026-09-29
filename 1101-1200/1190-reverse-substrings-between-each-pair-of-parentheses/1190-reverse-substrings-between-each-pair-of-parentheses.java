/*
 * @lc app=leetcode id=1190 lang=java
 *
 * [1190] Reverse Substrings Between Each Pair of Parentheses
 */

// @lc code=start

import java.util.Stack;

class Solution {
    public String reverseParentheses(String s) {
        if (!s.contains("(")||!s.contains(")")) {
            return s;
        }

        Stack<Character> stack = new Stack<Character>();
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i)!=')') {
                stack.push(s.charAt(i));
            } else if (s.charAt(i) == ')') {
                String temp = "";
                while (stack.peek()!='(') {
                    temp+=stack.pop();
                }

                if (stack.size()>0) {
                    stack.pop();
                }

                for (int j = 0; j < temp.length(); j++) {
                    stack.push(temp.charAt(j));
                }
            }       
        }
         String ans = "";
            while (!stack.isEmpty()) {
                ans+=stack.pop();
            }

            StringBuilder result = new StringBuilder(ans);
        return result.reverse().toString();
    }
}
// @lc code=end

