class Solution {
   public  int specialArray(int[] nums) {
        insertionSort(nums,nums.length); // sort array
        return checker(nums);
    }

    public  int checker(int[] nums) {
       
        for(int x = 0;  x <= nums.length ;x++ )//run all possibilities as x can be upto array's length
        {
            if(nums[nums.length-1]>=x)         
            if(nums.length - Binary(nums,x)==x){
                return x;
            }
        }
        return -1;
    }
    
 //Simple Binary Search
    public  int Binary(int[] nums,int i) {
        int s = 0;
        int e = nums.length-1;
        while(s<=e)
        {
            int mid = s + (e - s)/2;
            if(nums[mid]==i)
            {
                return dupcheck(mid,nums);
            }
            else if(nums[mid]<i)
            {
                s = mid + 1;
            }
            else
            {
                e = mid - 1;
            }
        }
        return dupcheck(s,nums); // Going to first occurance of x
    }
    
    //simple logic to traverse while equal
public static int dupcheck(int s,int[] nums) {
        int t = nums[s];
    if(s==0)
        return s;
        while(nums[s-1]==t)
        {
            s--; 
            if(s==0)
                break;     
        }
        return s;
    }
    
    //Sorting Algorithm Using Recursion
    public void insertionSort(int arr[], int n)
    {
        if (n <= 1)                           
        {
            return;
        }

        insertionSort( arr, n-1 );       

        int last = arr[n-1];                        
        int j = n-2;                                
        while (j >= 0 && arr[j] > last)                
        {
            arr[j+1] = arr[j];                          
            j--;
        }
        arr[j+1] = last;                            
    }
}