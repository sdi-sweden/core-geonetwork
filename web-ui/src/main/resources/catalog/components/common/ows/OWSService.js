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

(function() {
  goog.provide('gn_ows_service');


  var module = angular.module('gn_ows_service', [
  ]);

  module.provider('gnOwsCapabilities', function() {
    this.$get = ['$http', '$q',
      'gnUrlUtils', 'gnGlobalSettings', 'gfiOutputFormatCheck',
      function($http, $q, gnUrlUtils, gnGlobalSettings, gfiOutputFormatCheck) {

    	var proxyfyURL = function(url) {
    		if (url.includes("proxy") || url.includes("topo-wms")) {
    			return url;    			
    		}
    		var newUrl = url;
            if (url.includes("maps.lantmateriet.se") || url.includes("www.geodata.se/gateway/gateto")) {
                newUrl = '../../' + gnGlobalSettings.lmProxyUrl + encodeURIComponent(url);
            } else if (url.includes("maps-ver.lantmateriet.se")) {
            	newUrl = '../../' + gnGlobalSettings.lmProxyVerUrl + encodeURIComponent(url);
            }
             else {
           	    if (!url.includes("https://")) {
             	    newUrl = gnGlobalSettings.proxyUrl + encodeURIComponent(url);
                }
            }
            return newUrl;
    	}
    	
        var displayFileContent = function(wmsUrl,data) {
          var parser = new ol.format.WMSCapabilities();
          var result = parser.read(data);
          var layers = [];
          var layerCheck = [];
          var layerGroupCheck = [];
          var url = result.Capability.Request.GetMap.
              DCPType[0].HTTP.Get.OnlineResource;
          //layer case insenstive
          var parseUrl = wmsUrl.substring(wmsUrl.indexOf("&") + 1).split("&") 
          if (parseUrl.length > 1) {
             var wmsLayers = parseUrl[1].split("=")
          }
          
          //Function to parse layers inside each layergroup 
          var parseLayerGroup = function(layer){
            for  (var l in layer) {
                if("Layer" in layer[l]){
                   layerGroupCheck.push({
                      layergroup: layer[l].Name,
                      Layer: layer[l]
                  });
                  parseLayerGroup(layer[l].Layer)
                }
                else{
                  layerCheck.push(layer[l])
                }
            }
            return layerCheck;
          }

          url = proxyfyURL(url);

          // Push all leaves into a flat array of Layers.
          var getFlatLayers = function(layer) {
            if (angular.isArray(layer)) {
              for (var i = 0, len = layer.length; i < len; i++) { 
                  getFlatLayers(layer[i]);
              }
            } else if (angular.isDefined(layer)) {
              if(parseUrl.length > 1 && wmsLayers[0].toLowerCase() == "layers"){
                  var splitLayer = wmsLayers[1].split(",")
                  parseLayerGroup([layer]);
              //To check whether given layer is layer    
                for (var i in layerCheck) {
                  if(splitLayer.indexOf(layerCheck[i].Name) > -1){
                    layerCheck[i].url = url;
                    layers.push(layerCheck[i]);
                  }
                } 
              //To check whether given layer is layergroup     
                for (var l in layerGroupCheck){
                  if(splitLayer.indexOf(layerGroupCheck[l].layergroup) > -1){
                    layerGroupCheck[l].layergroup.url = url;
                    layers.push(layerGroupCheck[l].Layer);
                  }
                }
            }       
            else{
              layer.url = url;
              if(!layer.Layer){
                layers.push(layer);
              }
              getFlatLayers(layer.Layer);
            }
                         
          }
        };

          // Make sure Layer property is an array even if
          // there is only one element.
          var setLayerAsArray = function(node) {
            if (node) {
              if (angular.isDefined(node.Layer) &&
                  !angular.isArray(node.Layer)) {
                node.Layer = [node.Layer];
              }
              if (angular.isDefined(node.Layer)) {
                for (var i = 0; i < node.Layer.length; i++) {
                  setLayerAsArray(node.Layer[i]);
                }
              }
            }
          };
          
          // Check if the Style OnlineReource URL needs to go through proxy
          var checkOnlineResourceURL = function(layers) {
        	  if(layers) {
        		  for (var j = 0; j < layers.length; j++) {
        			  if (angular.isDefined(layers[j].Style)) {
        				  for (var k = 0; k < layers[j].Style.length; k++) {
        					  if (angular.isDefined(layers[j].Style[k].LegendURL)) {
        						  for (var l = 0; l < layers[j].Style[k].LegendURL.length; l++) {
        							  layers[j].Style[k].LegendURL[l].OnlineResource = proxyfyURL(layers[j].Style[k].LegendURL[l].OnlineResource);
        						  }
        					  } 
        				  }
        			  }
        			  
        		  }
        	  }
          };
          getFlatLayers(result.Capability.Layer);
          setLayerAsArray(result.Capability);
          checkOnlineResourceURL(layers);
          result.Capability.layers = layers;
          if(parseUrl.length > 1 && wmsLayers[0].toLowerCase() == "layers"){
              result.Capability.Layer[0].Layer = layers;
          }
          return result.Capability;
        };

        var parseWMTSCapabilities = function(data) {
          var parser = new ol.format.WMTSCapabilities();
          var result = parser.read(data);

          //result.contents.Layer = result.contents.layers;
          result.Contents.operationsMetadata = result.OperationsMetadata;
          return result.Contents;
        };

        var mergeDefaultParams = function(url, defaultParams) {
          //merge URL parameters with default ones
          var parts = url.split('?');
          var urlParams = angular.isDefined(parts[1]) ?
              gnUrlUtils.parseKeyValue(parts[1]) : {};

          for (var p in urlParams) {
            defaultParams[p] = urlParams[p];
            if (defaultParams.hasOwnProperty(p.toLowerCase()) &&
                p != p.toLowerCase()) {
              delete defaultParams[p.toLowerCase()];
            }
          }
    	  return gnUrlUtils.append(parts[0], gnUrlUtils.toKeyValue(defaultParams));

        };
        return {
          mergeDefaultParams: mergeDefaultParams,

          getWMSCapabilities: function(url) {
            var defer = $q.defer();
            if (url) {
              url = mergeDefaultParams(url, {
                service: 'WMS',
                request: 'GetCapabilities'
              });

              if (gnUrlUtils.isValid(url)) {
             	url = proxyfyURL(url);
           	  //send request and decode result
                $http.get(url, {
                  cache: true
                })
                    .success(function(data) {
                      try {
                        defer.resolve(displayFileContent(url,data));
                        gfiOutputFormatCheck.result = defer.promise.$$state.value.Request.GetFeatureInfo.Format
                      } catch (e) {
                        defer.reject('capabilitiesParseError');
                      }
                    })
                    .error(function(data, status) {
                      defer.reject(status);
                    });
              }
            }
            return defer.promise;
          },

          getWMTSCapabilities: function(url) {
            var defer = $q.defer();
            if (url) {
              url = mergeDefaultParams(url, {
                REQUEST: 'GetCapabilities',
                service: 'WMTS'
              });

              if (gnUrlUtils.isValid(url)) {
            	  url = proxyfyURL(url);
                  $http.get(url, {
                  cache: true
                })
                    .success(function(data, status, headers, config) {
                      defer.resolve(parseWMTSCapabilities(data));
                    })
                    .error(function(data, status, headers, config) {
                      defer.reject(status);
                    });
              }
            }
            return defer.promise;
          },

          getLayerExtentFromGetCap: function(map, getCapLayer) {
            var extent = null;
            var layer = getCapLayer;
            var proj = map.getView().getProjection();

            //var ext = layer.BoundingBox[0].extent;
            //var olExtent = [ext[1],ext[0],ext[3],ext[2]];
            // TODO fix using layer.BoundingBox[0].extent
            // when sextant fix his capabilities

            var bboxProp;
            ['EX_GeographicBoundingBox', 'WGS84BoundingBox'].forEach(
                function(prop) {
                  if (angular.isArray(layer[prop])) {
                    bboxProp = layer[prop];
                  }
                });

            if (bboxProp) {
              extent = ol.extent.containsExtent(proj.getWorldExtent(),
                      bboxProp) ?
                      ol.proj.transformExtent(bboxProp, 'EPSG:4326', proj) :
                      proj.getExtent();
            } else if (angular.isArray(layer.BoundingBox)) {
              for (var i = 0; i < layer.BoundingBox.length; i++) {
                var bbox = layer.BoundingBox[i];
                // Use the bbox with the code matching the map projection
                // or the first one.
                if (bbox.crs === proj.getCode() ||
                    layer.BoundingBox.length === 1) {

                  extent =
                      ol.extent.containsExtent(
                          proj.getWorldExtent(),
                          bbox.extent) ?
                          ol.proj.transformExtent(bbox.extent,
                      bbox.crs || 'EPSG:4326', proj) :
                          proj.getExtent();
                  break;
                }
              }
            }
            return extent;
          },

          getLayerInfoFromCap: function(name, capObj, uuid) {
            var needles = [];
            var layers = capObj.layers || capObj.Layer;
            var parse_name = name.split(":");
            var parsed_name = parse_name[1];
            for (var i = 0, len = layers.length; i < len; i++) {
              //check layername
              if (name == layers[i].Name || name == layers[i].Identifier) {
                layers[i].nameToUse = name;
                return layers[i];
              }
              //check layername with workspace name
              if(parsed_name){
                if (parsed_name == layers[i].Name || parsed_name == layers[i].Identifier) {
                layers[i].nameToUse = parsed_name;
                return layers[i];
              }
              }
              
              //check dataset identifer match
              if (uuid != null) {
                if (angular.isArray(layers[i].Identifier)) {
                  angular.forEach(layers[i].Identifier, function(id) {
                    if (id == uuid) {
                      needles.push(layers[i]);
                    }
                  });
                }
              }

              //check uuid from metadata url
              if (uuid != null) {
                if (angular.isArray(layers[i].MetadataURL)) {
                  angular.forEach(layers[i].MetadataURL, function(mdu) {
                    if (mdu && mdu.OnlineResource &&
                        mdu.OnlineResource.indexOf(uuid) > 0) {
                      needles.push(layers[i]);
                    }
                  });
                }
              }
            }

            //FIXME: allow multiple, remove duplicates
            if (needles.length > 0) {
              return needles[0];
            }
            else {
              return;
            }
          },


          getLayerInfoFromWfsCap: function(name, capObj, uuid) {
            var needles = [];
            var layers = capObj.featureTypeList.featureType;

            for (var i = 0, len = layers.length; i < len; i++) {
              //check layername
              if (name == layers[i].name.localPart ||
                  name == layers[i].name.prefix + ':' +
                  layers[i].name.localPart ||
                  name == layers[i].Name) {
                return layers[i];
              }

              //check title
              if (name == layers[i].title || name == layers[i].Title) {
                return layers[i];
              }

              //check dataset identifer match
              if (uuid != null) {
                if (angular.isArray(layers[i].Identifier)) {
                  angular.forEach(layers[i].Identifier, function(id) {
                    if (id == uuid) {
                      needles.push(layers[i]);
                    }
                  });
                }
              }

              //check uuid from metadata url
              if (uuid != null) {
                if (angular.isArray(layers[i].MetadataURL)) {
                  angular.forEach(layers[i].MetadataURL, function(mdu) {
                    if (mdu && mdu.OnlineResource &&
                        mdu.OnlineResource.indexOf(uuid) > 0) {
                      needles.push(layers[i]);
                    }
                  });
                }
              }
            }

            //FIXME: allow multiple, remove duplicates
            if (needles.length > 0) {
              return needles[0];
            }
            else {
              return;
            }
          }
        };
      }];
  });
})();
