package fi.paikkatietohakemisto.geonetwork.servlet.filter;

/**
 * 
 * This is FREE software.
 * EUPL license.
 * 
 * This software is provided AS IS. Use at your own risk.
 * No Support will be provided.
 * 
 * This File contains a servlet filter class which wraps some local classes that 
 * process CSW requests to store request statistics to a log file. 
 * 
 */

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.xml.XMLConstants;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.io.IOUtils;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * 
 * Servlet Filter to log CSW requests
 * 
 * Parses query args if one of following is used.
 * 
 * 
 * GET, POST/application/x-www-form-urlencoded, POST (assumes xml)
 * 
 * 
 * If POST is used, uses XPath to request csw:XXX Method from request body. Note
 * this is stricter with namespaces than geonetwork itself...
 * 
 * Supports only CSW 2.0.2 requests
 * 
 * This is a REQUEST filter. Does NOT check exception responses.
 * 
 * 
 * @author jjk
 * 
 */

public class CSW202LogFilter implements Filter {

	

	List<String> paths;

	private static final Logger logger = Logger.getLogger("CSW202LogFilter");
	private static FileHandler fh;

	/**
	 * This processes GET and POST/application/x-www-form-urlencoded requests.
	 */
	Csw202RequestArgsProcessor argsProcessor = new Csw202RequestArgsProcessor();

	/**
	 * This processes POST (xml) requests
	 */
	Csw202RequestBodyProcessor bodyProcessor = new Csw202RequestBodyProcessor();

	/**
	 * 
	 */
	@Override
	public void destroy() {
		// TODO Auto-generated method stub

		logDebug("Logger is closing logger");
		fh.close();
	}

	/**
	 * Filters ANY request but processes only those requested to a configured
	 * URL.
	 * 
	 */
	@Override
	public void doFilter(ServletRequest req, ServletResponse rsp,
			FilterChain chain) throws IOException, ServletException {

		/**
		 * Check CSW request matches from URL if POST
		 * 
		 */
		if (!(req instanceof HttpServletRequest)) {
			chain.doFilter(req, rsp);
			return;
		}

		HttpServletRequest request = (HttpServletRequest) req;

		String pathToMatch = "" + request.getServletPath()
				+ request.getPathInfo();
		/*
		 * logger.info("CSW? ContextPath [ " + pathToMatch +
		 * " ] vs configured path [ " + path + " ]");
		 */

		if (!paths.contains(pathToMatch)) {
			// logger.info("not CSW");
			chain.doFilter(req, rsp);
			return;
		}

		// logger.info("Processing as CSW");

		String contentType = request.getContentType();

		String method = request.getMethod().toUpperCase();

		/**
		 * GET params
		 */
		if (method.equals("GET")) {
			/**
			 * Let's log based on URL params
			 * 
			 */

			String csw_Request_value = null;

			logDebug("Logger POST Processor...Query args");

			try {
				Map<String, String[]> params = request.getParameterMap();

				csw_Request_value = argsProcessor.getCswRequestFromArgs(params);
			} catch (Exception e) {
				e.printStackTrace();
			}

			chain.doFilter(req, rsp);

			if (csw_Request_value != null && !csw_Request_value.equals("")) {
				log(csw_Request_value, 1);
			} else {
				logDebug("N/A");
			}

			/**
			 * POST params
			 */
		} else if (method.equals("POST")
				&& (contentType != null && "application/x-www-form-urlencoded"
						.equals(contentType))) {
			String csw_Request_value = null;
			logDebug("Logger POST Processor...application/x-www-form-urlencoded");
			try {
				Map<String, String[]> params = request.getParameterMap();

				csw_Request_value = argsProcessor.getCswRequestFromArgs(params);

			} catch (Exception e) {
				e.printStackTrace();
			}

			chain.doFilter(req, rsp);

			if (csw_Request_value != null && !csw_Request_value.equals("")) {
				log(csw_Request_value, 1);
			} else {
				logDebug("N/A");
			}

			/**
			 * POST body
			 */
		} else if (method.equals("POST")) {
			/**
			 * Let's log based on BODY
			 */
			String csw_Request_value = null;

			logDebug("Logger POST Processor...assuming XML in body");
			MultiReadHttpServletRequest mrsr = new MultiReadHttpServletRequest(
					request);

			try {

				csw_Request_value = bodyProcessor.getCswRequestFromBody(mrsr
						.getAsByteArray());
			} catch (Exception ex) {
				ex.printStackTrace();
			}

			chain.doFilter(mrsr, rsp);

			if (csw_Request_value != null && !csw_Request_value.equals("")) {
				log(csw_Request_value, 1);
			} else {
				logDebug("N/A");
			}

		}

	}

	void log(String request, int i) {
		logger.log(Level.INFO, "CSW," + request + "," + i);
	}

	void logDebug(String info) {
		logger.log(Level.FINER, "DBG," + info + ",0");
	}

	void logException(String exception, String info) {
		logger.log(Level.SEVERE, "XXX," + exception + ",0," + info);
	}

	@Override
	public void init(FilterConfig config) throws ServletException {
		// TODO Auto-generated method stub

		String path_ = config.getInitParameter("path");
		String[] pathParts = path_.split(",");
		paths = Arrays.asList(pathParts);

		String isDebug = config.getInitParameter("debug");
		boolean debug = isDebug != null && "on".equals(isDebug);
		
		String logpath = config.getInitParameter("logpath");
		String logfile = logpath + "/csw-statistics-%g.log";

		try {
			fh = new FileHandler(logfile, 1024 * 1024 * 256, 16, true);
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			throw new ServletException(e);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			throw new ServletException(e);
		}
		fh.setFormatter(new LogFileFormatter());
		logger.addHandler(fh);
		
		if( debug )
			logger.setLevel(Level.ALL);
		else
			logger.setLevel(Level.INFO);
		
		logDebug("Log initialised to filter CSW requests to " + paths);

	}

}

class LogFileFormatter extends java.util.logging.Formatter {
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	public String format(LogRecord record) {
		return (df.format(new Date(record.getMillis())) + ","
				+ record.getMessage() + '\n');
	}

	public String getHead(Handler h) {
		return "";
	}

	public String getTail(Handler h) {
		return "\n";
	}
}

/**
 * helper to not resolve any entities
 * 
 * @author JKORHONEN
 * 
 */
class NullResolver implements EntityResolver {
	public InputSource resolveEntity(String publicId, String systemId)
			throws SAXException, IOException {
		return new InputSource(new StringReader(""));
	}
}

/**
 * 
 * helper to read and store request body
 * 
 */
class MultiReadHttpServletRequest extends HttpServletRequestWrapper {

	private byte[] body = {};

	public byte[] getAsByteArray() {
		return body;
	}

	public MultiReadHttpServletRequest(HttpServletRequest httpServletRequest)
			throws IOException {
		super(httpServletRequest);
		// Read the request body and save it as a byte array
		InputStream is = super.getInputStream();
		if (is == null)
			return;
		try {
			body = IOUtils.toByteArray(is);
		} finally {
			is.close();
			is = null;
		}

	}

	@Override
	public ServletInputStream getInputStream() throws IOException {
		return new ServletInputStreamImpl(new ByteArrayInputStream(body));
	}

	@Override
	public BufferedReader getReader() throws IOException {
		String enc = getCharacterEncoding();
		if (enc == null)
			return new BufferedReader(new InputStreamReader(getInputStream()));
		else
			return new BufferedReader(new InputStreamReader(getInputStream(),
					enc));
	}

	private class ServletInputStreamImpl extends ServletInputStream {

		private InputStream is;

		public ServletInputStreamImpl(InputStream is) {
			this.is = is;
		}

		public int read() throws IOException {
			return is.read();
		}

		public boolean markSupported() {
			return false;
		}

		public synchronized void mark(int i) {
			throw new UnsupportedOperationException();
		}

		public synchronized void reset() throws IOException {
			throw new UnsupportedOperationException();
		}
	}
}

/**
 * helper to map csw to http://www.opengis.net/cat/csw/2.0.2
 * 
 * 
 */
class Csw202NamespaceContext implements NamespaceContext {
	static final String ns_csw = "http://www.opengis.net/cat/csw/2.0.2";
	Map<String, String> ns2prefix = new HashMap<String, String>();
	Map<String, String> prefix2ns = new HashMap<String, String>();

	Csw202NamespaceContext() {
		add("csw", ns_csw);
	}

	public void add(String prefix, String ns) {
		ns2prefix.put(ns, prefix);
		prefix2ns.put(prefix, ns);
	}

	public String getNamespaceURI(String prefix) {
		if (prefix == null)
			throw new NullPointerException("Null prefix");

		String ns = prefix2ns.get(prefix);

		return ns != null ? ns : XMLConstants.NULL_NS_URI;
	}

	// This method isn't necessary for XPath processing.
	public String getPrefix(String uri) {
		throw new UnsupportedOperationException();
	}

	// This method isn't necessary for XPath processing either.
	public Iterator<String> getPrefixes(String uri) {
		throw new UnsupportedOperationException();
	}

}

/**
 * some constants
 */
interface Csw202RequestProcessor {
	static final String ns_csw_prefix = "csw";

	static final String ns_csw = "http://www.opengis.net/cat/csw/2.0.2";
	static final String csw_GetCapabilities = "GetCapabilities";
	static final String csw_GetDomain = "GetDomain";
	static final String csw_GetRecords = "GetRecords";
	static final String csw_param_Service = "Service";
	static final String csw_param_Request = "Request";
	static final String csw_param_Version = "Version";
	static final String csw = "CSW";
}

/*
 * checks service, request and version query parameters
 */
class Csw202RequestArgsProcessor implements Csw202RequestProcessor {

	public String getCswRequestFromArgs(Map<String, String[]> params) {
		// TODO Auto-generated method stub
		// Enumeration<String> params = request.getParameterNames();

		Iterator<String> iter = params.keySet().iterator();

		boolean isCSW = false;
		String csw_Request_value = null;
		String csw_Version_value = null;

		while (iter.hasNext()) {
			String paramName = iter.next();
			String paramValue = params.get(paramName)[0];

			if (paramName.equalsIgnoreCase(csw_param_Service)) {
				isCSW = paramValue.equalsIgnoreCase(csw);
				if (!isCSW) {
					break;
				}
			} else if (paramName.equalsIgnoreCase(csw_param_Request)) {
				csw_Request_value = paramValue;
				break;
			} else if (paramName.equalsIgnoreCase(csw_param_Version)) {
				csw_Version_value = paramValue;
				if (!"2.0.2".equals(csw_Version_value)) {
					break;
				}

			}

		}

		return csw_Request_value;

	}

}

/**
 * checks POST body as byte[] for any CSW operations
 * 
 * @author JKORHONEN
 * 
 */
class Csw202RequestBodyProcessor implements Csw202RequestProcessor {

	Csw202RequestBodyProcessor() {
	}

	/**
	 * processes BODY with XPath. Creates any XPath related objects per request
	 * as XPath processing is not thread safe.
	 * 
	 * @param arr
	 * @return
	 * @throws IOException
	 */
	String getCswRequestFromBody(byte[] arr) throws IOException {
		XPathFactory factory = XPathFactory.newInstance();
		Csw202NamespaceContext nscontext = new Csw202NamespaceContext();

		XPath xpath = factory.newXPath();
		xpath.setNamespaceContext(nscontext);

		String result = null;

		try {
			ByteArrayInputStream in = new ByteArrayInputStream(arr);
			InputSource inputSource = new InputSource(in);

			/**
			 * Let's check what's this all about
			 */
			XPathExpression xpathGetCswOp = xpath
					.compile("local-name(/csw:*[1])");

			String localName = xpathGetCswOp.evaluate(inputSource);

			return localName;

		} catch (XPathExpressionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return result;
	}

}
