class Solution {
    public int minimizeMax(int[] nums, int p) {
        Arrays.sort(nums);
        int low =0;
        int high = nums[nums.length-1]-nums[0];
        int ans = Integer.MAX_VALUE;
        while(low<=high){
            int mid = low + (high-low)/2;
             if(solve(nums,p,mid)){
                ans=mid;
                high=mid-1;
            } else {
                low=mid+1;
            }
        }  
        return ans;
    }

    public boolean solve(int nums[],int p,int mid){
        int st=0;
        int count=0;
        for(int i=1;i<nums.length;i++){
            if(st!=0){
                st=0;
                continue;
            }
            if(nums[i]-nums[i-1]<=mid){
                count++;
                st=1;
            }
        }
        return count>=p;
    }
}