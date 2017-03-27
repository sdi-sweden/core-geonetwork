package se.lantmateriet.geonet;

import java.io.File;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.MultiFields;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.MatchAllDocsQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Bits;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.search.IndexAndTaxonomy;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.index.DirectoryFactory;
import org.fao.geonet.kernel.search.index.FSDirectoryFactory;
import org.fao.geonet.kernel.search.index.GeonetworkMultiReader;
import org.fao.geonet.kernel.search.index.LuceneIndexLanguageTracker;
import org.fao.geonet.utils.Log;
import org.springframework.context.ConfigurableApplicationContext;

import jeeves.config.springutil.JeevesDelegatingFilterProxy;

public class LmProxyFilter implements Filter {

    private Logger _logger = Log.createLogger(Geonet.GEONETWORK + ".lmproxy");

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // TODO Auto-generated method stub

    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        String debug = request.getParameter("debug");

        if (debug != null) {
            long start = System.currentTimeMillis();

            _logger.info("Execute the LmProxyFilter");

            ServletContext ctx = request.getServletContext();

            if (ctx == null) {
                _logger.warning("No ServletContext, can't continue");
            } else {

                ConfigurableApplicationContext applicationContext = JeevesDelegatingFilterProxy
                        .getApplicationContextFromServletContext(ctx);

                if (applicationContext == null) {
                    _logger.warning("No ApplicationContext, can't continue");
                } else {
                    GeonetworkDataDirectory dataDir = applicationContext.getBean(GeonetworkDataDirectory.class);
                    Set<Path> indexes = listIndexes(dataDir.getLuceneDir());

                    readIndexes(indexes);
                }
            }

            long diff = System.currentTimeMillis() - start;
            _logger.debug("Executed LmProxyFilter in " + diff + " ms");
        } else {
            _logger.debug("LmProxyFilter no-op since 'debug' parameter not found");
        }
        chain.doFilter(request, response);
    }

    private void readIndexes(Set<Path> indexes) {

        for (Path index : indexes) {

            _logger.debug("Read " + index);

            try (IndexReader reader = DirectoryReader.open(FSDirectory.open(index.toFile()))) {
                int maxdoc = reader.maxDoc();
                _logger.debug(" Maxdoc " + maxdoc);

                for (int i = 0; i < maxdoc; i++) {

                    Document doc = reader.document(i);
                    String[] links = doc.getValues("link");

                    if (_logger.isDebugEnabled()) {
                        _logger.info("  Uuid: " + doc.get("_uuid"));
                        _logger.info("  Title: " + doc.get("title"));
                        for (int j = 0; j < links.length; j++) {
                            _logger.info("  Link: " + links[j]);
                        }
                    }
                }
            } catch (IOException e) {
                _logger.error("Error reading index " + index.toString());
                _logger.error(e);
            }
        }

    }

    public Set<Path> listIndexes(Path luceneDir) throws IOException {

        Path newFile = luceneDir.resolve(FSDirectoryFactory.NON_SPATIAL_DIR);

        _logger.debug("Find indexes in lucene dir: " + newFile);

        Set<Path> indices = new LinkedHashSet<>();
        if (Files.exists(newFile)) {
            try (DirectoryStream<Path> dirStream = Files.newDirectoryStream(newFile)) {
                for (Path file : dirStream) {
                    if (Files.exists(file.resolve("segments.gen"))) {
                        _logger.debug("Found '" + file.getFileName().toString() + "'");
                        indices.add(file);
                    }
                }
            }
        } else {
            _logger.error("Lucene dir doesn't exist, no indexes found in " + newFile.toString());
        }
        return indices;
    }

    @Override
    public void destroy() {
        // TODO Auto-generated method stub

    }

}
