class Solution {
    public boolean repeatedSubstringPattern(String s) {
        for (int i = 0; i < s.length() / 2; i ++) {
            int count = i + 1;
            if (s.length() % count != 0) {
                continue;
            }
            boolean same = true;
            for (int k = count; k + count <= s.length() && same; k+=count) {
                for (int j = 0; j <= i && same; j ++) {
                    if (s.charAt(j) != s.charAt(j + k)) {
                        same = false;
                    }
                }
            }
            if (same == true) {
                return true;
            }
        }
        return false;
    }
}