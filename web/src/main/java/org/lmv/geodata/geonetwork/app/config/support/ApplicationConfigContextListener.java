package org.lmv.geodata.geonetwork.app.config.support;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;

import org.lmv.geodata.common.server.app.spec.AbstractConfigContextListener;
import org.lmv.geodata.common.server.app.spec.ConfigurationException;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.web.context.support.ServletContextResourcePatternResolver;

public class ApplicationConfigContextListener extends AbstractConfigContextListener
{
    private static final org.apache.commons.logging.Log LOG = org.apache.commons.logging.LogFactory.getLog(ApplicationConfigContextListener.class);

    private static final String     ESAPI_PROPERTIES_PATH    = "/WEB-INF/ESAPI.properties";

    private ResourcePatternResolver m_resourceResolver       = null;

    /**
     *
     */
    public ApplicationConfigContextListener()
    {
        // TODO Auto-generated constructor stub
    }

    /*
     * (non-Javadoc)
     * @see
     * org.lmv.geodata.common.server.app.spec.AbstractConfigContextListener#
     * contextDestroyed(javax.servlet.ServletContextEvent)
     */
    @Override
    public void contextDestroyed(ServletContextEvent inSce)
    {
        LOG.info("******** Shutdown Geonetwork configuration *********");
        ServletContext ctx = inSce.getServletContext();
        if (ctx == null)
            throw new ConfigurationException("ServletContext was null in ServletContextEvent");

        // ...do cleanup

        disposeOWASPSecurity(ctx);
        disposeDrivers();

        LOG.info("****** Done Shutdown Geonetwork configuration *******");

    }

    /*
     * (non-Javadoc)
     * @see
     * org.lmv.geodata.common.server.app.spec.AbstractConfigContextListener#
     * contextInitialized(javax.servlet.ServletContextEvent)
     */
    @Override
    public void contextInitialized(ServletContextEvent inSce)
    {
        LOG.info("******** Initializing Geonetwork configuration *********");
        ServletContext ctx = inSce.getServletContext();
        if (ctx == null)
            throw new ConfigurationException("ServletContext was null in ServletContextEvent");

        m_resourceResolver = new ServletContextResourcePatternResolver(ctx);

        initOWASPSecurity(ctx);

        LOG.info("****** Done Initializing Geonetwork configuration *******");

    }

    private void disposeDrivers()
    {
        // http://stackoverflow.com/a/15816247
        try
        {
            Enumeration<Driver> drivers = DriverManager.getDrivers();
            while (drivers.hasMoreElements())
            {
                Driver driver = drivers.nextElement();
                LOG.info("Deregister driver " + driver);
                DriverManager.deregisterDriver(driver);
            }
        }
        catch (Exception e)
        {
            LOG.error("Exception caught while deregistering JDBC drivers", e);
        }
    }

    private Resource getESAPIResource(String relativePath)
    {
        if (isInvalidParamValue(relativePath))
        {
            // No path configured, use default path, i.e.
            // /WEB-INF/ESAPI.properties
            LOG.info("No path set in context param '" + AbstractConfigContextListener.CONTEXT_PARAM_APP_CONFIG_OWASP_CONFIG + ". Using default path: " + ESAPI_PROPERTIES_PATH);

            relativePath = ESAPI_PROPERTIES_PATH;
        }

        Resource esapiResource = m_resourceResolver.getResource(relativePath);
        if (esapiResource == null)
        {
            String msg = "ESAPI configuration. Resource resolver returned a null resource for file: " + relativePath;
            LOG.fatal(msg);
            throw new ConfigurationException(msg);
        }

        if (!esapiResource.exists())
        {
            String msg = "ESAPI configuration file does not exist: " + relativePath;
            LOG.fatal(msg);
            throw new ConfigurationException(msg);
        }

        return esapiResource;
    }

    /**
     * Override to be able to use relative /WEB-INF/... path for
     * ESAPI.properties configuration file.
     */
    @Override
    protected InputStream getESAPIConfigurationInputStream(ServletContext inCtx) throws ConfigurationException
    {
        String relativePath = inCtx.getInitParameter(AbstractConfigContextListener.CONTEXT_PARAM_APP_CONFIG_OWASP_CONFIG);

        Resource esapiResource = getESAPIResource(relativePath);

        InputStream is = null;

        try
        {
            is = esapiResource.getInputStream();
        }
        catch (IOException e)
        {
            String msg = "IOException fetching InputStream for ESAPI configuration file: " + relativePath;
            LOG.fatal(msg, e);
            throw new ConfigurationException(msg, e);
        }

        return is;
    }
}
