class Solution {
    public int maxArea(int[] height) {
        // Initialize two pointers at the start and end of the array
        int leftPointer = 0;
        int rightPointer = height.length - 1;
      
        // Variable to track the maximum area found so far
        int maxAreaFound = 0;
      
        // Continue until the two pointers meet
        while (leftPointer < rightPointer) {
            // Calculate current area: minimum height * width between pointers
            int currentHeight = Math.min(height[leftPointer], height[rightPointer]);
            int currentWidth = rightPointer - leftPointer;
            int currentArea = currentHeight * currentWidth;
          
            // Update maximum area if current area is larger
            maxAreaFound = Math.max(maxAreaFound, currentArea);
          
            // Move the pointer with smaller height inward
            // This greedy approach works because moving the larger height
            // can never increase the area (width decreases, height is limited by smaller side)
            if (height[leftPointer] < height[rightPointer]) {
                leftPointer++;
            } else {
                rightPointer--;
            }
        }
      
        return maxAreaFound;   
    }
}