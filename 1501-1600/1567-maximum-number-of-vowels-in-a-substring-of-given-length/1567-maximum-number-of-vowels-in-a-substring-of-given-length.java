class Solution {
    private boolean isVowel(char c) {
        return c == 'a'||c == 'e'||c == 'i'||c == 'o'||c == 'u';
    }

    public int maxVowels(String s, int k) {
        int count = 0;
        for(int i=0;i<k;i++) {
            if (isVowel(s.charAt(i))) {
                count++;
            }
        }

        int maxCount = count;

        for(int i = k; i < s.length(); i++){
            
            // Add the new character entering from the right
            if(isVowel(s.charAt(i))){
                count++;
            }

            // Remove the character exiting from the left
            if(isVowel(s.charAt(i - k))){
                count--;
            }

            // Update the global maximum
            maxCount = Math.max(maxCount, count);
        }

        return maxCount;
    }
}