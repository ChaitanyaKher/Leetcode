class Solution {
public int removeElement(int[] nums, int val) {
int x=nums.length;
int k=x;
for(int i=0;i<x;i++){
if(nums[i]==val){
for(int j=i;j<x-1;j++){
nums[j]=nums[j+1];
}
i-=1;
x-=1;
k-=1;
}
}
return k;
}
}