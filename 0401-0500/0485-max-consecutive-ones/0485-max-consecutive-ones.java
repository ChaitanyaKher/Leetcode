class Solution {
    public int findMaxConsecutiveOnes(int[] nums) {
        int count = 0;
        int result = 0;
        for(int i:nums){
            if(i==0){
                count = 0;
            } else {
                count++;
                result = Math.max(result,count);
            }
        }
        
        return result;
    }
}