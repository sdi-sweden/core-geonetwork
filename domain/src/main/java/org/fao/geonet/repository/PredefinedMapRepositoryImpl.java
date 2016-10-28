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
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.fao.geonet.domain.PredefinedMap;
import org.fao.geonet.repository.statistic.PathSpec;
import org.jdom.Element;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;

import com.google.common.collect.ImmutableList;

public class PredefinedMapRepositoryImpl implements PredefinedMapRepository {

    private List<PredefinedMap> resultList;
    private String url = "https://ver.geodata.se/geodataportalens-hjalpsidor/datasamlingar-rotsida";

    @Override
    public List<PredefinedMap> findAll() {
        if (resultList == null) {
            resultList = new ArrayList<PredefinedMap>();
            // call URL to retrieve JSON file
            String jsonResponse = getJSON();
            // convert JSON to list of SimplePredefinedMap objects
            convertResponseToList(jsonResponse, resultList);
        }
        // return List of PredefinedMap objects
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
    
    private void convertResponseToList(String jsonResponse, List<PredefinedMap> resultList) {

         createStaticResult(resultList);


//        JsonFactory f = new JsonFactory();
//        JsonParser jp;
//        try {
//            PredefinedMap predefinedMap = new PredefinedMap();
//            jp = f.createParser(jsonResponse);
//            while (jp.nextToken() != JsonToken.END_OBJECT) {
//
//                String fieldname = jp.getCurrentName();
//                
//                if ("title".equals(fieldname)) {
//                    jp.nextToken(); 
//                    predefinedMap.setName(jp.getText());
//                } else if ("description".equals(fieldname)) {
//                    jp.nextToken(); 
//                    predefinedMap.setDescription(jp.getText());
//                } else if ("link".equals(fieldname)) {
//                    jp.nextToken(); 
//                    predefinedMap.setImage(jp.getText());
//                } else if ("text".equals(fieldname)) { // contains an object
//                    jp.nextToken(); 
//                    String owsText = "";
//                  while (jp.nextToken() != JsonToken.END_OBJECT) {
//                      owsText = owsText + jp.getText();
//                      jp.nextToken(); // move to value
//                  }
//                  predefinedMap.setMap(owsText);
//                
//                } else {
////                    throw new IllegalStateException("Unrecognized field '" + fieldname + "'!");
//                    System.out.println("unknown fieldname = " + fieldname);
//                }
//
//                if (jp.nextToken() == JsonToken.START_OBJECT) {
//                    predefinedMap = new PredefinedMap();
//                }
//                if (jp.nextToken() == JsonToken.END_ARRAY) {
//                    resultList.add(predefinedMap);
//                }
//
//            }
//            jp.close(); // ensure resources get cleaned up timely and properly
//        } catch (IOException e) {
//            // TODO Auto-generated catch block
//            e.printStackTrace();
//        }
    }

    private void createStaticResult(List<PredefinedMap> resultList) {

        PredefinedMap map1 = new PredefinedMap();
        map1.setId(1);
        map1.setPosition(1);
        map1.setEnabled(Boolean.TRUE);
        map1.setName("Vatten och Jord");
        map1.setDescription("<p>Den har är en exempel av en rekomenderade datasamlingar</p>");
        map1.setImage("http:/ver.geodata.se/contentassets/7f2ae34b2b30491d90a0a38845d11cd4/bild2.jpg");
        map1.setMap("<ows-context:OWSContext xmlns:ows-context=\"http://www.opengis.net/ows-context\" version=\"0.3.1\"\n id=\"ows-context-ex-1-v3\">\n <ows-context:General>\n <ows:BoundingBox xmlns:ows=\"http://www.opengis.net/ows\" crs=\"EPSG:3006\">\n <ows:LowerCorner>98304 5899264</ows:LowerCorner>\n <ows:UpperCorner>3031040 7330816</ows:UpperCorner>\n </ows:BoundingBox>\n </ows-context:General>\n <ows-context:ResourceList>\n <ows-context:Layer name=\"{type=wmts,name=undefined}\" hidden=\"false\" opacity=\"1\">\n <ows-context:Server service=\"urn:ogc:serviceType:WMS\">\n <ows-context:OnlineResource/>\n </ows-context:Server>\n </ows-context:Layer>\n <ows-context:Layer name=\"{type=wmts,name=undefined}\" hidden=\"false\" opacity=\"1\">\n <ows-context:Server service=\"urn:ogc:serviceType:WMS\">\n <ows-context:OnlineResource/>\n </ows-context:Server>\n </ows-context:Layer>\n <ows-context:Layer name=\"GEONETWORK:phy_landf_7386\" hidden=\"false\" opacity=\"1\">\n <ows-context:Server service=\"urn:ogc:serviceType:WMS\">\n <ows-context:OnlineResource xlink:href=\"http://data.fao.org/maps/wms\"\n xmlns:xlink=\"http://www.w3.org/1999/xlink\"/>\n </ows-context:Server>\n </ows-context:Layer>\n </ows-context:ResourceList>\n</ows-context:OWSContext>");
        resultList.add(map1);

        PredefinedMap map2 = new PredefinedMap();
        map2.setId(2);
        map1.setPosition(2);
        map2.setEnabled(Boolean.TRUE);
        map2.setName("Brunn och Jord");
        map2.setDescription("<p>Förbättrade jordartskartor över landskapet ger detaljerad information om markförhållandena. Kartorna visar bland annat vilken kornstorlek marken innehåller, hur genomsläpplig marken är för rent eller</p>");
        map2.setImage("http:/ver.geodata.se/contentassets/71ef34b68b3f4d0a842b2c7986dd878e/bild1.jpg");
        map2.setMap("<ows-context:OWSContext xmlns:ows-context=\"http://www.opengis.net/ows-context\" version=\"0.3.1\"\n id=\"ows-context-ex-1-v3\">\n <ows-context:General>\n <ows:BoundingBox xmlns:ows=\"http://www.opengis.net/ows\" crs=\"EPSG:3006\">\n <ows:LowerCorner>98304 5899264</ows:LowerCorner>\n <ows:UpperCorner>3031040 7330816</ows:UpperCorner>\n </ows:BoundingBox>\n </ows-context:General>\n <ows-context:ResourceList>\n <ows-context:Layer name=\"{type=wmts,name=undefined}\" hidden=\"false\" opacity=\"1\">\n <ows-context:Server service=\"urn:ogc:serviceType:WMS\">\n <ows-context:OnlineResource/>\n </ows-context:Server>\n </ows-context:Layer>\n <ows-context:Layer name=\"{type=wmts,name=undefined}\" hidden=\"false\" opacity=\"1\">\n <ows-context:Server service=\"urn:ogc:serviceType:WMS\">\n <ows-context:OnlineResource/>\n </ows-context:Server>\n </ows-context:Layer>\n <ows-context:Layer name=\"GEONETWORK:phy_landf_7386\" hidden=\"false\" opacity=\"1\">\n <ows-context:Server service=\"urn:ogc:serviceType:WMS\">\n <ows-context:OnlineResource xlink:href=\"http://data.fao.org/maps/wms\"\n xmlns:xlink=\"http://www.w3.org/1999/xlink\"/>\n </ows-context:Server>\n </ows-context:Layer>\n </ows-context:ResourceList>\n</ows-context:OWSContext>");
        resultList.add(map2);
        
    }

    private String getJSON() {
        try {
            URL obj = new URL(url);
            HttpURLConnection con = (HttpURLConnection) obj.openConnection();
            con.setRequestMethod("GET");
            int responseCode = con.getResponseCode();

            System.out.println("\nSending 'GET' request to URL : " + url);
            System.out.println("Response Code : " + responseCode);

            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            // print result
            System.out.println("response = " + response.toString());
            
            return response.toString();

        } catch (MalformedURLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return "";

    }

    
    private class SimplePredefinedMap {
        public String title;
        public String description;
        public String link;
        public String text;
        
        public SimplePredefinedMap(String title, String description, String link, String text) {
            super();
            this.title = title;
            this.description = description;
            this.link = link;
            this.text = text;
        }
        
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
        // TODO Auto-generated method stub
        return 0;
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