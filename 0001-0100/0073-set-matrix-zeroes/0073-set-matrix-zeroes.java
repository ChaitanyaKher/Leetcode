/*
 * @lc app=leetcode id=73 lang=java
 *
 * [73] Set Matrix Zeroes
 */

// @lc code=start
class Solution {
    public void setZeroes(int[][] matrix) {
        int rows = matrix.length;
          int cols = matrix[0].length;
          int col0 = 1;

          // Mark rows and columns

          for (int i = 0; i < rows; i++) {
              if (matrix[i][0] == 0)
                  col0 = 0;
              for (int j = 1; j < cols; j++) {
                  if (matrix[i][j] == 0) {
                      matrix[i][0] = 0;
                      matrix[0][j] = 0;
                  }
              }
          }

          // Fill matrix using markers

          for (int i = rows - 1; i >= 0; i--) {
              for (int j = cols - 1; j >= 1; j--) {
                  if (matrix[i][0] == 0 || matrix[0][j] == 0)
                      matrix[i][j] = 0;
              }
              if (col0 == 0)
                  matrix[i][0] = 0;
          }
    }
}
// @lc code=end

