
import java.util.Arrays;

class MyHashMap {
    int[] array;
    int EMPTY = -1;

    public MyHashMap() {
        array = new int[10000001];    
    }
    
    public void put(int key, int value) {
        array[key] = value+1;
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