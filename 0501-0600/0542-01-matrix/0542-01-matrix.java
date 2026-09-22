class Solution {
private static final int MAX_DISTANCE = 10_000;

    public int[][] updateMatrix(int[][] mat) {

        for (int i = 0; i < mat.length; i++) {
            for (int j = 0; j < mat[0].length; j++) {
                if (mat[i][j] != 0) {
                    mat[i][j] = 1 + minAbove(mat, i, j);
                }
            }
        }

        for (int i = mat.length - 1; i >= 0 ; i--) {
            for (int j = mat[0].length - 1; j >= 0; j--) {
                mat[i][j] = Math.min(mat[i][j], 1 + minBelow(mat, i, j));
            }
        }

        return mat;
    }


    private int minAbove(int[][] mat, int x, int y) {
        return Math.min(
            x > 0 ? mat[x-1][y] : MAX_DISTANCE, 
            y > 0 ? mat[x][y-1] : MAX_DISTANCE
        );
    }


    private int minBelow(int[][] mat, int x, int y) {
        return Math.min(
            (x + 1 < mat.length) ? mat[x+1][y] : MAX_DISTANCE, 
            (y + 1 < mat[0].length) ? mat[x][y+1] : MAX_DISTANCE
        );
    }
}