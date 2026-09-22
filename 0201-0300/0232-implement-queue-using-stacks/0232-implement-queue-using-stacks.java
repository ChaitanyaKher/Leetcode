class MyQueue {

    Stack<Integer> stack = new Stack<>();

    public MyQueue() {

    }

    public void push(int x) {
        stack.push(x);
    }

    public int pop() {
        if (stack.isEmpty()) return -1;
        if (stack.size() == 1) return stack.pop();

        int item = stack.pop();
        int result = pop();
        stack.push(item);
        return result;
    }

    public int peek() {
        if (stack.size() == 1) return stack.peek();
        int item = stack.pop();
        int result = peek();
        stack.push(item);
        return result;
    }

    public boolean empty() {
        return stack.isEmpty();
    }
}

/**
 * Your MyQueue object will be instantiated and called as such:
 * MyQueue obj = new MyQueue();
 * obj.push(x);
 * int param_2 = obj.pop();
 * int param_3 = obj.peek();
 * boolean param_4 = obj.empty();
 */