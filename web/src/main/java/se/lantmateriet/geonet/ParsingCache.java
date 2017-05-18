package se.lantmateriet.geonet;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import com.google.common.cache.Cache;
import com.google.common.cache.CacheBuilder;

public class ParsingCache {

    private Cache<String, Boolean> cache;

    private Map<String, String> contentTypes;
    private Map<String, String> encodings;


    public ParsingCache() {
        cache = CacheBuilder.newBuilder().expireAfterWrite(6, TimeUnit.HOURS).build();

        encodings = new HashMap<String, String>();
        contentTypes = new HashMap<String, String>();
    }

    public synchronized void invalidate(){
        cache.invalidateAll();
    }

    public synchronized void add(URL url, String contentType, String encoding){
        String key = url.toString();
        cache.put(key, true);

        contentTypes.put(key, contentType);
        encodings.put(key, encoding);
    }

    public String getContentType(URL url){
        return contentTypes.get(url.toString());
    }

    public String getEncoding(URL url){
        return encodings.get(url.toString());
    }

    public synchronized boolean isCached(URL url){
        String key = url.toString();

        Boolean value = cache.getIfPresent(key);

        return value != null;
    }

}
