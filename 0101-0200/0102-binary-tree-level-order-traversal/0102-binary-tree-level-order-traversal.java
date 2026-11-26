/*
 * @lc app=leetcode id=102 lang=java
 *
 * [102] Binary Tree Level Order Traversal
 */

// @lc code=start

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode() {}
 *     TreeNode(int val) { this.val = val; }
 *     TreeNode(int val, TreeNode left, TreeNode right) {
 *         this.val = val;
 *         this.left = left;
 *         this.right = right;
 *     }
 * }
 */
class Solution {
    public List<List<Integer>> levelOrder(TreeNode root) {
        Queue<TreeNode> q = new LinkedList<>();
        List<List<Integer>> result = new ArrayList<>();

        if (root==null) {
            return result;
        }

        q.add(root);

        while (!q.isEmpty()) {
            int levels = q.size();
            List<Integer> subLevel = new ArrayList<>();
            for(int i=0;i<levels;i++){
                if (q.peek().left!=null) {
                    q.add(q.peek().left);
                }
                if (q.peek().right!=null) {
                    q.add(q.peek().right);
                }
                subLevel.add(q.remove().val);
            }
            result.add(subLevel);
        }

        return result;
    }
}
// @lc code=end

