/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode() {}
 *     ListNode(int val) { this.val = val; }
 *     ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */
class Solution {
    public ListNode partition(ListNode head, int x) {
        if (head==null){
            return null;
        }

        ListNode dummy1 = new ListNode(0);
        ListNode smaller = dummy1;
        ListNode dummy2 = new ListNode(0);
        ListNode bigger = dummy2;

        while (head!= null) {
            if (head.val<x) {
                smaller.next = head;
                smaller = smaller.next;
            } else {
                bigger.next = head;
                bigger = bigger.next;
            }
            head = head.next;
        }
        bigger.next = null;
        smaller.next = dummy2.next;
        return  dummy1.next;
    }
}