class Solution {
    public String processStr(String s) {
        StringBuilder result = new StringBuilder();
        for(char ch: s.toCharArray()) {
            switch(ch) {
                case '*':
                    if(result.length()>0) {
                        result.deleteCharAt(result.length() - 1);
                    }
                    break;
                case '#':
                    result.append(result);
                    break;
                case '%':
                    result.reverse();
                    break;
                default:
                    result.append(ch);
                    break;
            }
        }
        return result.toString();
    }
}