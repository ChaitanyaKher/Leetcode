class Solution {

    public static String process (String s) {
        Stack<Character> stack = new Stack<>();
        for (char a: s.toCharArray()) {
            if (a == '#') {
                if(!stack.isEmpty()) {
                    stack.pop();
                }
            } else {
                stack.push(a);
            }

        }
        StringBuilder g = new StringBuilder();
        while (!stack.isEmpty()){
            g.append(stack.pop());
        }

        return g.reverse().toString();
    }

    public boolean backspaceCompare(String s, String t) {
        return process(s).equals(process(t));
    }
}