class Solution {
    public String longestCommonPrefix(String[] strs) {
        int size = strs.length;
        if (size == 0)
            return "";

        if (size == 1)
            return strs[0];

        Arrays.sort(strs);

        /* find the minimum length from first and last string */
        int end = Math.min(strs[0].length(), strs[size-1].length());

        /* find the common prefix between the first and
           last string */
        int i = 0;
        while (i < end && strs[0].charAt(i) == strs[size-1].charAt(i) )
            i++;

        String pre = strs[0].substring(0, i);
        return pre;
    }
}