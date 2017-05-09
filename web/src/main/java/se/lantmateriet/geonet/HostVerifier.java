package se.lantmateriet.geonet;

import java.net.URL;
import java.util.HashSet;
import java.util.Set;

import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;

public class HostVerifier {

    private Logger _logger = Log.createLogger(Geonet.GEONETWORK + ".lmproxy");

    private Set<String> mValidProtocols;
    private Set<String> mWhitelist;
    private Set<String> mBlacklist;

    private String[] mStaticHosts;

    public HostVerifier() {
        mValidProtocols = new HashSet<String>();
        mValidProtocols.add("http");
        mValidProtocols.add("https");

        mWhitelist = new HashSet<String>();
        mBlacklist = new HashSet<String>();
        mStaticHosts = new String[0];
    }

    public HostVerifier(String[] staticHosts) {
        this();

        mStaticHosts = staticHosts;

        addStaticHostsToWhitelist();
    }

    private void addStaticHostsToWhitelist() {
        for (String host : mStaticHosts) {
            addToWhitelist(host);
        }
    }

    public synchronized void clear() {
        mWhitelist.clear();
        mBlacklist.clear();
        _logger.info("Cleared both whitelist and blacklist");

        addStaticHostsToWhitelist();
        if (mStaticHosts.length > 0) {
            _logger.info("Readded statically allowed hosts");
        }
    }

    public synchronized boolean isValid(URL endpointUrl, HostVerifierPopulator populator) {
        if (endpointUrl == null) {
            return false;
        }

        String endpointHost = endpointUrl.getHost();

        if (isBlacklisted(endpointHost)) {
            _logger.debug("Host is blacklisted: '" + endpointHost + "'");
            return false;
        }

        if (!hasValidProtocol(endpointUrl)) {
            _logger.debug(
                    "Invalid protocol '" + endpointUrl.getProtocol() + "'. Allowed: " + mValidProtocols.toString());
            return false;
        }

        if (isWhitelisted(endpointHost)) {
            return true;
        } else {
            // cache miss, re-read index and try again
            populateWhitelist(populator);

            if (isWhitelisted(endpointHost)) {
                return true;
            } else {
                addToBlacklist(endpointHost);
            }
        }

        return false;
    }

    public synchronized void addToWhitelist(String host) {
        if (addToSet(host, mWhitelist)) {
            _logger.info("Add '" + host + "' to whitelist");

            if(mBlacklist.remove(host)){
                _logger.info("Removed '"+host+"' from blacklist");
            }
        }
    }

    public synchronized void addToWhitelist(Set<String> hosts) {
        for (String h : hosts) {
            addToWhitelist(h);
        }
    }

    public String getWhitelistAsString() {
        return mWhitelist.toString();
    }

    private boolean hasValidProtocol(URL url) {
        return mValidProtocols.contains(url.getProtocol());
    }

    private void addToBlacklist(String host) {
        if (addToSet(host, mBlacklist)) {
            _logger.info("Add '" + host + "' to blacklist");
        }
    }

    private void populateWhitelist(HostVerifierPopulator populator) {
        addToWhitelist(populator.getHosts());
    }

    private boolean isWhitelisted(String host) {
        return mWhitelist.contains(host);
    }

    private boolean isBlacklisted(String host) {
        return mBlacklist.contains(host);
    }

    private boolean addToSet(String host, Set<String> set) {
        if (host == null) {
            host = "";

        } else {
            host = host.trim();
        }

        if (host.length() != 0 && !set.contains(host)) {
            set.add(host);
            return true;
        } else {
            return false;
        }
    }

}
