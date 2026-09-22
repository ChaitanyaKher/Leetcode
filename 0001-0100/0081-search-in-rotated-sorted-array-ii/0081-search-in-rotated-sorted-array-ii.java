
class Solution{
	public boolean search(int[] nums, int target) {
		if(nums.length == 0) return false;
		int mid = nums[nums.length/2];
		return -1 != binarySearch(nums, 0, nums.length-1, target);
	}
	public static int binarySearch(int[] nums, int low, int high, int target) {
		if(low > high) return -1;
        int mid = (low + high) / 2;
        int lowVal = nums[low];
        int midVal = nums[mid];
        int highVal = nums[high];
        if(midVal == target) return mid;
        if(midVal == lowVal){
            return binarySearch(nums, low + 1, high, target);
        }else if(midVal > lowVal){  //left is sorted
            if(target < midVal && target >= lowVal)
                return binarySearch(nums, low, mid - 1, target);
            else
                return binarySearch(nums, mid + 1, high, target);
        }else{    //right is sorted
            if(target > midVal && target <= highVal)
                return binarySearch(nums, mid + 1, high, target);
            else
                return binarySearch(nums, low, mid - 1, target);
        }
	}
}