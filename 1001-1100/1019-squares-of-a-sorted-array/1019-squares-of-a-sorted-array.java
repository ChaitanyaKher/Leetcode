class Solution {
    public int[] sortedSquares(int[] nums) {
        int N = nums.length;
        int[] squares = new int[N];
        for(int i=0; i<nums.length;i++){
            squares[i] = nums[i]*nums[i];
        }
        
        sortArray(squares);
        
        return squares;
    }
    
    public int[] sortArray(int[] nums){
        int temp = 0;
        for(int lastIndex = nums.length - 1; lastIndex>0;lastIndex--){
            for(int j = 0; j<lastIndex;j++){
                if(nums[j]>nums[j+1]){
                    temp = nums[j];
                nums[j]=nums[j+1];
                    nums[j+1]=temp;
                }
            }
        }
        return nums;
    }
}