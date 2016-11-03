/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.repository;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.domain.PredefinedMap;
import org.fao.geonet.repository.statistic.PathSpec;
import org.jdom.Element;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;

import com.google.common.collect.ImmutableList;

public class PredefinedMapRepositoryImpl implements PredefinedMapRepository {

    private static final String TEXT = "\"text\":\"";
    private static final String LINK = "\"link\":\"";
    private static final String DESCRIPTION = "\"description\":\"";
    private static final String TITLE = "\"title\":\"";
    private static final String URL = "https://ver.geodata.se/geodataportalens-hjalpsidor/datasamlingar-rotsida";
    private List<PredefinedMap> resultList;

    @Override
    public List<PredefinedMap> findAll() {
        if (resultList == null) {
            resultList = new ArrayList<PredefinedMap>();
        }
        String jsonResponse = getJSON();
        parseJsonToList(jsonResponse, resultList);
        return ImmutableList.copyOf(resultList);
    }

    @Override
    public PredefinedMap findOne(Integer arg0) {

        for (PredefinedMap predefinedMap : resultList) {
            if (predefinedMap.getId() == arg0) {
                return predefinedMap;
            }
        }
        return null;
    }

    private String getJSON() {
        try {
            HttpURLConnection con = getConnection(URL);
            con.setRequestMethod("GET");
            con.getResponseCode();

            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            String result = StringEscapeUtils.unescapeJava(response.toString());
            return result;

        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";

    }

    protected HttpURLConnection getConnection(String url) throws MalformedURLException, IOException {
        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        return con;
    }

    public List<PredefinedMap> parseJsonToList(String jsonString, List<PredefinedMap> result) {

        boolean inMap = false;
        boolean endOfObject = false;

        int counter = 1;

        String title = "";
        String description = "";
        String link = "";
        String map = "";

        String[] jsonSplit = StringUtils.split(jsonString, ",");
        for (String splitString : jsonSplit) {
            int pos = -1;
            pos = StringUtils.indexOf(splitString, TITLE);
            if (pos > 0) {
                title = StringUtils.substring(splitString, pos + TITLE.length());
                title = StringUtils.mid(title, 0, title.length() - 1);
            }

            pos = StringUtils.indexOf(splitString, DESCRIPTION);
            if (pos > -1) {
                description = StringUtils.substring(splitString, pos + DESCRIPTION.length());
                description = StringUtils.mid(description, 0, description.length() - 1);
            }

            pos = StringUtils.indexOf(splitString, LINK);
            if (pos > -1) {
                link = StringUtils.substring(splitString, pos + LINK.length());
                link = StringUtils.mid(link, 0, link.length() - 1);
                link = StringUtils.replace(link, "http", "https");
            }

            pos = StringUtils.indexOf(splitString, TEXT);
            if (pos > -1) {
                inMap = true;
            }

            if (inMap) {
                map = map + StringUtils.substring(splitString, pos + TEXT.length());

                if (map.endsWith("]")) {
                    map = StringUtils.mid(map, 0, map.length() - 1);
                }
                if (map.endsWith("}")) {
                    inMap = false;
                    endOfObject = true;
                    map = StringUtils.mid(map, 0, map.length() - 2);
                }

                if (endOfObject) {
                    PredefinedMap predefinedMap = createPredefineMap(counter, title, description, link, map);
                    result.add(predefinedMap);
                    counter++;

                    description = "";
                    title = "";
                    link = "";
                    map = "";
                    endOfObject = false;
                }
            }
        }
        return result;
    }

    PredefinedMap createPredefineMap(int counter, String title, String description, String link, String map) {
        PredefinedMap predefinedMap = new PredefinedMap();
        predefinedMap.setDescription(description);
        predefinedMap.setName(title);
        predefinedMap.setImage(link);
        predefinedMap.setMap(map);
        predefinedMap.setEnabled(true);
        predefinedMap.setId(counter);
        predefinedMap.setPosition(counter);
        return predefinedMap;
    }

    @Override
    public <V> BatchUpdateQuery<PredefinedMap> createBatchUpdateQuery(PathSpec<PredefinedMap, V> pathToUpdate, V newValue) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public <V> BatchUpdateQuery<PredefinedMap> createBatchUpdateQuery(PathSpec<PredefinedMap, V> pathToUpdate, V newValue,
            Specification<PredefinedMap> spec) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Element findAllAsXml() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Element findAllAsXml(Specification<PredefinedMap> specification) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Element findAllAsXml(Specification<PredefinedMap> specification, Sort sort) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Element findAllAsXml(Sort sort) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Element findAllAsXml(Specification<PredefinedMap> specification, Pageable pageable) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Element findAllAsXml(Pageable pageable) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public int deleteAll(Specification<PredefinedMap> specification) {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public List<PredefinedMap> findAll(Sort sort) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public List<PredefinedMap> findAll(Iterable<Integer> ids) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public <S extends PredefinedMap> List<S> save(Iterable<S> entities) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public void flush() {
        // TODO Auto-generated method stub
    }

    @Override
    public PredefinedMap saveAndFlush(PredefinedMap entity) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public void deleteInBatch(Iterable<PredefinedMap> entities) {
        // TODO Auto-generated method stub

    }

    @Override
    public void deleteAllInBatch() {
        // TODO Auto-generated method stub

    }

    @Override
    public Page<PredefinedMap> findAll(Pageable arg0) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public long count() {
        return resultList.size();
    }

    @Override
    public void delete(Integer arg0) {
        // TODO Auto-generated method stub

    }

    @Override
    public void delete(PredefinedMap arg0) {
        // TODO Auto-generated method stub

    }

    @Override
    public void delete(Iterable<? extends PredefinedMap> arg0) {
        // TODO Auto-generated method stub

    }

    @Override
    public void deleteAll() {
        // TODO Auto-generated method stub

    }

    @Override
    public boolean exists(Integer arg0) {
        // TODO Auto-generated method stub
        return false;
    }

    @Override
    public <S extends PredefinedMap> S save(S arg0) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public PredefinedMap findOne(Specification<PredefinedMap> spec) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public List<PredefinedMap> findAll(Specification<PredefinedMap> spec) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public Page<PredefinedMap> findAll(Specification<PredefinedMap> spec, Pageable pageable) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public List<PredefinedMap> findAll(Specification<PredefinedMap> spec, Sort sort) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public long count(Specification<PredefinedMap> spec) {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public PredefinedMap update(Integer id, Updater<PredefinedMap> updater) {
        // TODO Auto-generated method stub
        return null;
    }

}