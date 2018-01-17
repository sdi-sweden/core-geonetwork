package se.lantmateriet.geonet;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.utils.Log;
import org.lmv.geodata.common.server.app.spec.ConfigurationException;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.EndpointCacheException;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.EndpointProxyUtil;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.EndpointValidator;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.EndpointValidatorException;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.IEndpointCache;
import org.lmv.geodata.common.server.servlet.filter.proxy.endpoint.IEndpointValidator;
import org.springframework.context.ConfigurableApplicationContext;

public class LmConfigContextListener implements ServletContextListener {

    private Logger _logger = Log.createLogger(Geonet.GEONETWORK + ".lmproxy");


    public void contextDestroyed(ServletContextEvent sce) {
        ServletContext ctx = getServletContext(sce);

        disposeProxyEndpointCache(ctx);
    }

    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = getServletContext(sce);

        initProxyEndpointCache(ctx);


    }

    protected ServletContext getServletContext(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        if (ctx == null) {
            throw new ConfigurationException("ServletContext was null in ServletContextEvent");
        }
        return ctx;
    }

    protected void initProxyEndpointCache(ServletContext ctx) throws ConfigurationException {
        /*
         * String resourcesString = ctx.getInitParameter("proxy.resources");
         * String[] resourcesArray = resourcesString.split(",");
         *
         * Set<String> resources = new HashSet<String>();
         *
         * for(String resource : resourcesArray){
         * resources.add("/../../data/"+resource+".json"); }
         */
        LmEndpointCache endpointCache = new LmEndpointCache();
        try {
            endpointCache.populate();
        } catch (EndpointCacheException e) {
            String errmsg = "Exception initializing endpoint cache";
            throw new ConfigurationException(errmsg, e);
        }

        EndpointValidator validator = new EndpointValidator();
        try {
            // TODO Add more configuration options, e.g. internal ip check
            // should be configurable, as well
            // as exclude reg.expr.
            validator.initialize(endpointCache, true, null);
        } catch (EndpointValidatorException e) {
            String errmsg = "Exception initializing endpoint validator";
            throw new ConfigurationException(errmsg, e);

        }

        ctx.setAttribute(EndpointProxyUtil.ENDPOINT_CACHE_CONTEXT_KEY, endpointCache);
        ctx.setAttribute(EndpointProxyUtil.ENDPOINT_VALIDATOR_CONTEXT_KEY, validator);
    }

    protected void disposeProxyEndpointCache(ServletContext inCtx) throws ConfigurationException {
        IEndpointValidator endpointValidator = EndpointProxyUtil.getEndpointValidator(inCtx);
        inCtx.removeAttribute(EndpointProxyUtil.ENDPOINT_VALIDATOR_CONTEXT_KEY);
        if (endpointValidator != null) {
            endpointValidator.dispose();
            endpointValidator = null;
        }

        IEndpointCache endpointCache = EndpointProxyUtil.getEndpointCache(inCtx);
        inCtx.removeAttribute(EndpointProxyUtil.ENDPOINT_CACHE_CONTEXT_KEY);
        if (endpointCache != null) {
            endpointCache.dispose();
            endpointCache = null;
        }

    }
}
