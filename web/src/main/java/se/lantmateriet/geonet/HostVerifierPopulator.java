package se.lantmateriet.geonet;

import java.io.IOException;
import java.net.URL;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.store.FSDirectory;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.search.index.FSDirectoryFactory;
import org.fao.geonet.utils.Log;
import org.springframework.context.ConfigurableApplicationContext;

import jeeves.config.springutil.JeevesDelegatingFilterProxy;

public class HostVerifierPopulator {

     private Logger _logger = Log.createLogger(Geonet.GEONETWORK + ".lmproxy");

    private HttpServletRequest inReq;

    public HostVerifierPopulator(HttpServletRequest inReq) {
        this.inReq = inReq;
    }

    public Set<String> getHosts() {
        return getHosts_();
    }

    private Set<String> getHosts_() {
        ServletContext ctx = inReq.getServletContext();

        Set<String> hosts = null;
        if (ctx == null) {
            _logger.warning("No ServletContext, can't populate whitelist");
        } else {

            try {
                ConfigurableApplicationContext applicationContext = JeevesDelegatingFilterProxy
                        .getApplicationContextFromServletContext(ctx);

                GeonetworkDataDirectory dataDir = applicationContext.getBean(GeonetworkDataDirectory.class);

                // Path path = Paths.get("C:/...");
                Path path = dataDir.getLuceneDir();
                Set<Path> indexes = listIndexes(path);

                hosts = readIndexes(indexes);
            } catch (Exception e) {
                _logger.warning("No ApplicationContext, can't populate whitelist");
            }
        }

        if(hosts == null){
            hosts = new HashSet<String>();
        }

        return hosts;
    }

    private Set<String> readIndexes(Set<Path> indexes) {

        Set<String> hosts = new HashSet<String>();

        for (Path index : indexes) {

            _logger.debug("Read " + index);

            try (IndexReader reader = DirectoryReader.open(FSDirectory.open(index.toFile()))) {
                int maxdoc = reader.maxDoc();
                _logger.debug(" Number of documents in index (maxdoc): " + maxdoc);

                for (int i = 0; i < maxdoc; i++) {

                    Document doc = reader.document(i);
                    String[] links = doc.getValues("link");

                    for (int j = 0; j < links.length; j++) {
                        String[] parts = links[j].split("\\|");
                        String link = parts[2];
                        try {
                            URL url = new URL(link);
                            hosts.add(url.getHost());
                        } catch (Exception ignore) {
                        }

                    }
                }
            } catch (IOException e) {
                _logger.error("Error reading index " + index.toString());
                _logger.error(e);
            }
        }

        return hosts;
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



}
