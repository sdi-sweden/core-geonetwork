package se.lantmateriet.geonet;

import java.net.URL;
import java.util.concurrent.TimeUnit;

import com.google.common.cache.Cache;
import com.google.common.cache.CacheBuilder;

public class ParsingCache {

    private Cache<String, Boolean> cache;

    public ParsingCache() {
        cache = CacheBuilder.newBuilder().expireAfterWrite(6, TimeUnit.HOURS).build();
    }

    public synchronized void invalidate(){
        cache.invalidateAll();
    }

    public synchronized void add(URL url){
        cache.put(url.toString(), true);
    }

    public synchronized boolean isCached(URL url){
        String key = url.toString();

        Boolean value = cache.getIfPresent(key);

        return value != null;
    }

}
