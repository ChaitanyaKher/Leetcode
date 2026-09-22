/*
 * @lc app=leetcode id=706 lang=java
 *
 * [706] Design HashMap
 */

// @lc code=start

class ListNode {
    int key, val;
    ListNode  next;
    public ListNode(int key, int val, ListNode next){
        this.key = key;
        this.val = val;
        this.next = next;
    }
    
}

class MyHashMap {
    static final int size = 19997;
    static final int mult = 125282917;
    ListNode[] data;

    public MyHashMap() {
        this.data = new ListNode[size];
    }
    
    public void put(int key, int value) {
        array[key]  = value+1;
    }
    
    public int get(int key) {
        return array[key] == 0 ? -1 : array[key] - 1;
    }
    
    public void remove(int key) {
        array[key] = 0;
    }
}

/**
 * Your MyHashMap object will be instantiated and called as such:
 * MyHashMap obj = new MyHashMap();
 * obj.put(key,value);
 * int param_2 = obj.get(key);
 * obj.remove(key);
 */
// @lc code=end

