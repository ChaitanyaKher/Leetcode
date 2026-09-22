class Solution {
    public boolean isValid(String word) {
        if(word.length()<3) {
            return false;   
        }

        String vowels = "aeiouAEIOU";

        boolean hasVowel =false;
        boolean hasConsonant = false;

        for(char c: word.toCharArray()) {
            if(!Character.isLetter(c) && !Character.isDigit(c)) {
                return false;
            }

            if(Character.isLetter(c)) {
                if(vowels.indexOf(c)!= -1) {
                    hasVowel = true;
                } else {
                    hasConsonant = true;
                }
            }
        }

        return hasVowel && hasConsonant;
    }
}