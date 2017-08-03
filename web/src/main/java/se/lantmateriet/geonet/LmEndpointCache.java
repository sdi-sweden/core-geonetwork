package se.lantmateriet.geonet;

import java.util.HashSet;
import java.util.Set;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.utils.Log;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.EndpointCacheException;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.IEndpointCache;
import org.springframework.context.ConfigurableApplicationContext;

public class LmEndpointCache implements IEndpointCache{

    private Logger _logger = Log.createLogger(Geonet.GEONETWORK + ".lmproxy");

    private Set<String> whitelist;

    public LmEndpointCache() {
        whitelist = new HashSet<String>();
    }

    @Override
    public void populate() throws EndpointCacheException {
        whitelist.add("maps.lantmateriet.se");

        _logger.info("Whitelist: "+whitelist.toString());
    }

    @Override
    public void refresh() throws EndpointCacheException {
        // TODO Auto-generated method stub

    }

    @Override
    public boolean contains(String inEndpoint) {

        if (inEndpoint == null) {
            return false;
        }

        boolean contains = whitelist.contains(inEndpoint.trim());

        if(_logger.isDebugEnabled()){
            _logger.debug("Whitelist contains '"+inEndpoint+"': "+contains);
        }

        return contains;
    }

    @Override
    public boolean isEmpty() {
        return whitelist.isEmpty();
    }

    @Override
    public void dispose() {
        whitelist.clear();
    }

}
