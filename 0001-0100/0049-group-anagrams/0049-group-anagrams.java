class Solution {
    public List<List<String>> groupAnagrams(String[] strs) {
        if (strs == null || strs.length == 0) return new ArrayList<>();
        Map<String, List<String>> frequencyStringMap = new HashMap<>();
        for (String string: strs) {
            String frequencyString = getFrequencyString(string);
            if (frequencyStringMap.containsKey(frequencyString)) {
                frequencyStringMap.get(frequencyString).add(string);
            } else {
                List<String> stringList = new ArrayList<>();
                stringList.add(string);
                frequencyStringMap.put(frequencyString,stringList);
            }
        }
        return new ArrayList<>(frequencyStringMap.values());
    }

     private static String getFrequencyString(String string) {
        int[]  charArray = new int[26];
        for (char c : string.toCharArray()) {
            charArray[c-'a']++;
        }

        StringBuilder frequencyString = new StringBuilder();
        char c = 'a';
        for (int i:charArray) {
            frequencyString.append(c);
            frequencyString.append(i);
            c++;
        }
        return frequencyString.toString();
    }
}