class Solution {
    public long distinctNames(String[] ideas) {
                //group all with the prefix,now length of the prefix will be 26 alphabets
        
        Map<Integer,HashSet<String>> group = new HashMap<>();
        
        for(String idea : ideas){
            int firstChar = idea.charAt(0) - 'a';
            if(!group.containsKey(firstChar)){
                group.put(firstChar,new HashSet<>());
            }
            group.get(firstChar).add(idea.substring(1));
        }
        
        //if suffix is same then we have to ignore them 
        // like 2nd example lack,back
        // l-->(ack) and b-->(ack)
        //if both are same the ignore
        long answer = 0;
        for(int a = 0 ; a < 25 ; a++){
            for(int b = a+1 ; b < 26 ; b++){
                int len = 0;
                if(group.get(a)!= null && group.get(b)!= null){
                    for(String word : group.get(a)){
                        if(group.get(b).contains(word)){
                            len++;
                        }
                    }
                    
                    int calc = 2 * ((group.get(a).size() - len) * (group.get(b).size() - len));
                    answer+=calc;
                }
                
            }
        }
        
        return answer;

    }
}