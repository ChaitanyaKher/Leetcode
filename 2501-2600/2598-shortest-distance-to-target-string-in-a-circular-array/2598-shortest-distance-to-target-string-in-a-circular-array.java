class Solution {
    public int closestTarget(String[] words, String target, int startIndex) {
        //* [2515] Shortest Distance to Target String in a Circular Array
        int index = Integer.MAX_VALUE;
        for(int i=0; i<words.length; i++) {
            if(words[i].equals(target)) {
                int diff = Math.abs(startIndex-i);
                int distance =  Math.min(diff, words.length-diff);
                index = Math.min(index, distance);
            }
        }
        return index == Integer.MAX_VALUE? -1: index;
    }
}