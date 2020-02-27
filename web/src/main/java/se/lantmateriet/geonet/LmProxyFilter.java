package se.lantmateriet.geonet;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class LmProxyFilter implements Filter {

    private Logger _logger = Log.createLogger(Geonet.GEONETWORK + ".lmproxy");

    private static final String PARAM_ENDPOINT_PARAMETER = "endpoint.parameter";
    private static final String PARAM_ALLOWED_HOSTS = "allowed.hosts";
    private static final String PARAM_CLEARCACHE_ALLOWED = "clearcache.allowed";

    private String mFilterName;
    private HostVerifier verifier;

    private String mEndpointParameter = null;
    private boolean clearCacheAllowed = false;

    private DocumentBuilder builder;
    private XPathExpression expr;
    private ParsingCache parsingCache;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

        _logger.info("Init LmProxyFilter");

        mFilterName = filterConfig.getFilterName();
        if (mFilterName == null)
            mFilterName = "Noname LmProxyFilter";

        String endpointParam = filterConfig.getInitParameter(PARAM_ENDPOINT_PARAMETER);
        if (endpointParam == null || endpointParam.trim().length() <= 0 || endpointParam.startsWith("@")) {
            String errMsg = "Missing required init-param " + PARAM_ENDPOINT_PARAMETER;
            _logger.fatal(errMsg);
            throw new ServletException(errMsg);
        } else {
            mEndpointParameter = endpointParam;
            _logger.info(PARAM_ENDPOINT_PARAMETER + " : " + mEndpointParameter);
        }

        clearCacheAllowed = false;
        String clearParam = filterConfig.getInitParameter(PARAM_CLEARCACHE_ALLOWED);
        if (clearParam != null) {
            if ("true".equals(clearParam)) {
                clearCacheAllowed = true;
            }
        }

        _logger.info("Clearing of cache allowed: " + clearCacheAllowed);

        parsingCache = new ParsingCache();

        String allowedParam = filterConfig.getInitParameter(PARAM_ALLOWED_HOSTS);
        if (allowedParam == null || allowedParam.trim().length() <= 0 || allowedParam.startsWith("@")) {
            _logger.info("No static allowed hosts given (init-param '" + PARAM_ALLOWED_HOSTS + "')");

            verifier = new HostVerifier();
        } else {
            String[] parts = allowedParam.split(",");

            verifier = new HostVerifier(parts);

            _logger.info("Allowed hosts " + verifier.getWhitelistAsString());
        }

        // specify instance class??
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

        factory.setValidating(false);
        factory.setExpandEntityReferences(false);
        factory.setNamespaceAware(false);
        try {
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setFeature("http://apache.org/xml/features/validation/schema", false);
            factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
        } catch (ParserConfigurationException e) {
            throw new ServletException(e);
        }


        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new ServletException(e);
        }

        // specify instance class??
        XPathFactory xPathfactory = XPathFactory.newInstance();
        XPath xpath = xPathfactory.newXPath();
        try {
            expr = xpath.compile("/WMS_Capabilities/Capability//OnlineResource/@href");
        } catch (XPathExpressionException e) {
            throw new ServletException(e);
        }
    }

    @Override
    public void doFilter(ServletRequest inReq, ServletResponse inRes, FilterChain inChain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) inReq;
        HttpServletResponse res = (HttpServletResponse) inRes;

        if (clearCacheAllowed) {
            if (req.getParameter("reload") != null) {
                parsingCache.invalidate();
                verifier.clear();
                _logger.info("Cleared caches");
            }
        }

        long start = System.currentTimeMillis();

        URL endpointUrl = extractEndpointUrl(req);
        boolean isValid = isEndpointValid(endpointUrl, req);

        long diff = System.currentTimeMillis() - start;
        _logger.debug("Validated endpoint url in " + diff + " ms");

        if (isValid) {
            handleValidEndpoint(endpointUrl, req, res, inChain);

        } else {
            logInvalidRequest(req);

            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid endpoint");
            res.flushBuffer();
        }
    }

    private void handleValidEndpoint(URL endpoint, HttpServletRequest inReq, HttpServletResponse inRes,
            FilterChain inChain) throws IOException, ServletException {

        // parsing cache keep track of endpoints responses already parsed so we
        // don't do it again
        // the cache is invalidated at certain intervals

        if (isCapabilitiesRequest(endpoint)) {

            OutputStream out = inRes.getOutputStream();
            GenericResponseWrapper responseWrapper = new GenericResponseWrapper(inRes);

            inChain.doFilter(inReq, responseWrapper);

            byte[] data = responseWrapper.getData();
            
            //_logger.debug("received data: " + new String(responseWrapper.getData(), StandardCharsets.UTF_8));

            long start = System.currentTimeMillis();

            if( !parsingCache.isCached(endpoint)){
                try {

                    org.w3c.dom.Document doc = createDocument(data);
                    Set<String> hosts = extractHostsFromCapabilities(doc);
                    verifier.addToWhitelist(hosts);

                    long diff = System.currentTimeMillis() - start;
                    _logger.info("Parsed capabilities (found " + hosts.size() + " hosts) in " + diff + " ms ("+endpoint.toString()+")");

                    String contentType = responseWrapper.getContentType();
                    String encoding = null;
                    if(doc.getXmlEncoding()!=null){
                        encoding = doc.getXmlEncoding();
                    }
                    else{
                        encoding = responseWrapper.getCharacterEncoding();
                    }

                    _logger.info("  Storing contentType '"+contentType+"' and encoding '"+encoding+"' for that capabilities");
                    parsingCache.add(endpoint, contentType, encoding);

                } catch (XPathExpressionException | SAXException | IOException e) {
                    _logger.error("Can not parse capabilities from '" + endpoint.toString() + "'");
                    _logger.error(e);
                }
            }
            else{
                _logger.debug("Did not parse capabilities since it was cached ("+endpoint.toString()+")");
            }

            setCharset(responseWrapper, parsingCache.getContentType(endpoint), parsingCache.getEncoding(endpoint));

            out.write(data);
            out.close();

        } else {
            inChain.doFilter(inReq, inRes);
        }
    }

    private void setCharset(HttpServletResponse inRes, String contentType, String encoding){

        _logger.debug("Use content type '"+contentType+"' and encoding '"+encoding+"'");

        if(contentType!=null && !contentType.contains("charset") && encoding!=null){
            String ct = contentType+";charset="+encoding;
            inRes.setContentType(ct);
            inRes.setCharacterEncoding(encoding);

            _logger.debug("Set response content type: "+ct+" and character encoding: "+encoding);
        }
        else{
            _logger.debug("Did not set response content type. ContentType: "+contentType+", CharacterEncoding: "+encoding);
        }
    }

    private org.w3c.dom.Document createDocument(byte[] data) throws SAXException, IOException{
        ByteArrayInputStream stream = new ByteArrayInputStream(data);
        org.w3c.dom.Document doc = builder.parse(stream);

        return doc;
    }

    private Set<String> extractHostsFromCapabilities(org.w3c.dom.Document doc)
            throws XPathExpressionException {

        Set<String> hosts = new HashSet<String>();

        NodeList nl = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);

        for (int i = 0; i < nl.getLength(); i++) {
            Node node = nl.item(i);
            String value = node.getNodeValue();

            try {
                URL url = new URL(value);
                String host = url.getHost();
                hosts.add(host);
            } catch (Exception e) {
                _logger.debug("Can not extract host from '" + value + "'");
            }
        }

        return hosts;
    }

    private boolean isCapabilitiesRequest(URL endpoint) {
        String query = endpoint.getQuery();

        if (query != null) {
            query = query.toLowerCase();
            return query.contains("request=getcapabilities");
        }

        return false;
    }

    private URL extractEndpointUrl(HttpServletRequest inReq) {
        String endpoint = inReq.getParameter(mEndpointParameter);

        if (endpoint == null || endpoint.trim().length() <= 0) {
            _logger.debug("No endpoint found at parameter '" + mEndpointParameter + "'");
            return null;
        }

        URL endpointURL = null;
        try {
            endpointURL = new URL(endpoint);
        } catch (MalformedURLException e) {
            _logger.debug("Malformed endpoint: '" + endpoint + "'");
            return null;
        }

        String endpointHost = endpointURL.getHost();
        if (endpointHost == null || endpointHost.trim().length() <= 0) {
            _logger.debug("No host in endpoint url: '" + endpoint + "'");
            return null;
        }

        return endpointURL;
    }

    private boolean isEndpointValid(URL endpointUrl, HttpServletRequest inReq) {

        boolean valid = verifier.isValid(endpointUrl, new HostVerifierPopulator(inReq));
        return valid;
    }

    @Override
    public void destroy() {

    }

    protected void logInvalidRequest(HttpServletRequest inReq) {
        StringBuilder logBuf = new StringBuilder();
        if (mFilterName != null) {
            logBuf.append(mFilterName);
            logBuf.append(" - ");
        }
        logBuf.append("Invalid Request info: ");
        logBuf.append(getRequestDetails(inReq));
        _logger.warning(logBuf.toString());

    }

    private static StringBuilder getRequestDetails(HttpServletRequest inReq) {
        StringBuilder logBuf = new StringBuilder();
        logBuf.append("<method: ");
        logBuf.append(inReq.getMethod());
        logBuf.append("> <url: ");
        StringBuffer targetUrl = inReq.getRequestURL();
        String queryString = inReq.getQueryString();
        if (queryString != null) {
            targetUrl.append("?");
            targetUrl.append(queryString);
        }
        logBuf.append(targetUrl);
        logBuf.append("> <protocol: ");
        logBuf.append(inReq.getProtocol());
        logBuf.append("> <remote IP: ");
        logBuf.append(inReq.getRemoteAddr());
        logBuf.append("> <remote port: ");
        logBuf.append(inReq.getRemotePort());
        logBuf.append("> <user: ");
        if (inReq.getRemoteUser() != null)
            logBuf.append(inReq.getRemoteUser());
        else
            logBuf.append("null");

        logBuf.append(">");

        return logBuf;
    }
}
