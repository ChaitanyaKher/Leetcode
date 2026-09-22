class Solution {
    public int search(int[] nums, int target) {
        int x= nums.length/2;
        int starting_index=0;
        if(nums[x]<=target){
            starting_index = x;
        }
        for(int i = starting_index; i <nums.length;i++){
            if(nums[i]==target) return i;
        }
        return -1;
    }
}