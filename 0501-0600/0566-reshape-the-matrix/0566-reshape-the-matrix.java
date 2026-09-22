class Solution {
    public int[][] matrixReshape(int[][] mat, int r, int c) {
              if(r*c==mat.length*mat[0].length)
        {
            int[][] mat2 = new int[r][c];
            int a=0;
            int b=0;
            for(int i=0;i<r;i++)
            {
                for(int j=0;j<c;j++)
                {
                    mat2[i][j]=mat[a][b];
                    b++;
                    if(b==mat[0].length)
                    {
                        b=0;
                        a++;
                    }
                }
            }
             return mat2;
        }
        else
            return mat;

    }
}