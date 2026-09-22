class Solution {
    public int countMajoritySubarrays(int[] nums, int target) {
        int n = nums.length;

        int fenwickSize = 2 * n + 5;
        int[] fenwick = new int[fenwickSize];

        int offset = n + 2;
        int balance = 0;
        long result = 0;

        update(fenwick, offset, 1);

        for (int num : nums) {

            balance += (num == target) ? 1 : -1;

            result += prefixSum(fenwick, offset + balance - 1);

            update(fenwick, offset + balance, 1);
        }

        return (int) result;
    }

    private void update(int[] fenwick, int index, int value) {
        while (index < fenwick.length) {
            fenwick[index] += value;
            index += index & -index;
        }
    }

    private int prefixSum(int[] fenwick, int index) {
        int sum = 0;

        while (index > 0) {
            sum += fenwick[index];
            index -= index & -index;
        }

        return sum;
    }
}