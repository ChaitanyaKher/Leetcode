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
   public void traversal(TreeNode node, List<Integer> result) {
        if (node == null)
            return;
        if (node.left!= null)
            traversal(node.left, result);
        result.add(node.val);
        if (node.right!=null)
            traversal(node.right, result);
    }
    public List<Integer> inorderTraversal(TreeNode root) {
        List<Integer> result = new ArrayList<Integer>();
        traversal(root, result);
        return result;
    }
}