/*
 * @lc app=leetcode id=682 lang=java
 *
 * [682] Baseball Game
 */

// @lc code=start

import java.util.ArrayDeque;
import java.util.Deque;

class Solution {
    public int calPoints(String[] operations) {
        Deque<Integer> stack = new ArrayDeque<>();
        for(String operation: operations) {
            if ("+".equals(operation)) {
                int a = stack.pop();
                int b = stack.peek();
                stack.push(a);
                stack.push(a+b);
            }  else if ("D".equals(operation)) {
                stack.push(stack.peek() << 1);
            } else if ("C".equals(operation)) {
                stack.pop();
            } else {
                stack.push(Integer.valueOf(operation));
            }
        }
        return stack.stream().mapToInt(Integer::intValue).sum();
    }
}
// @lc code=end

