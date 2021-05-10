String START = "$";
String END = ".";

class NameGenerator {
    HashMap<String, HashMap<String, Integer>> trainedSet;
    int chunkSize;
    int longestData = 0;
    ArrayList<String> cache;
    
    NameGenerator(String[] dataSet, int chunkSize) {
        trainedSet = new HashMap<String, HashMap<String, Integer>>();
        this.chunkSize = chunkSize;
        cache = new ArrayList<String>();
        train(dataSet);
    }
    
    void train(String[] dataSet) {
        for (String data : dataSet) {
            if (data.length() > longestData) {
                longestData = data.length();
            }
            apply(START, data.substring(0, min(data.length(), chunkSize)));
            for (int i = 0; i < data.length() - chunkSize; i++) {
                //println("i = " + i);
                //println(data.substring(i, i + chunkSize));
                apply(data.substring(i, i + chunkSize), "" + data.charAt(i + chunkSize));
            }
            apply(data.substring(max(data.length() - chunkSize, 0), data.length()), END);
        }
    }
    
    void apply(String chunk, String c) {
        //println("apply " + chunk + " : " + c);
        HashMap<String, Integer> hits = trainedSet.get(chunk);
        if (hits != null) {
            if (hits.get(c) != null) {
                hits.put(c, hits.get(c) + 1);
            }
            else {
                 hits.put(c, 1);
            }
        }
        else {
            hits = new HashMap<String, Integer>();
            hits.put(c, 1);
            trainedSet.put(chunk, hits);
        }
    }
    
    String next(String chunk) {
        HashMap<String, Integer> hits = trainedSet.get(chunk);
        if (hits == null) {
            return null;
        }
        ArrayList<String> choices = new ArrayList<String>();
        //println("choices for " + chunk + " = " + hits);
        for (String hitKey : hits.keySet()) {
            for (int i = 0; i < hits.get(hitKey); i++) {
                choices.add(hitKey);
            }
        }
        return choices.get((int) random(choices.size()));
    }
    
    String genName() {
        String sofar = START;
        int cacheTries = 0;
        while (cacheTries++ < 5) {
            int tries = 0;
            while (sofar.length() - 2 < longestData) {
                String next = next(sofar.substring(max(0, sofar.length() - chunkSize), max(sofar.length(), sofar.length() - chunkSize)));
                //println("next = " + next);
                if (next == null) {
                    //println("nulled");
                    break;
                }
                else if (next.equals(".")) {
                    if (sofar.length() < 4 && tries < 5) {
                        tries++;
                        continue;
                    }
                }
                sofar += next;
            }
            String name = sofar.substring(1, 2).toUpperCase() + sofar.substring(2, sofar.length() - 1);
            if (!cache.contains(name)) {
                return name;
            }
        }
        return null;
    }
}
