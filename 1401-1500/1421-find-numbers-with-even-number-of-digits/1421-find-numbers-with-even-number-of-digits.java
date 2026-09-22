class Solution {
    public int findNumbers(int[] nums) {
        int evenCount = 0; //master counter
        
        
        for(int i:nums){
            int digits = 0; //digit counter
            while(i>0){
                i=i/10;
                digits++;
            }
            if(digits%2==0) evenCount++;
        }
        
        return evenCount;
        
    }
}