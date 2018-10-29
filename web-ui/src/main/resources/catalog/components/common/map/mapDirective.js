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
  goog.provide('gn_map_directive');
  goog.require('gn_owscontext_service');

  angular.module('gn_map_directive',
      ['gn_owscontext_service'])

      .directive(
      'gnDrawBbox',
      [
       'gnMap',
       'gnOwsContextService',
       '$http',
       function(gnMap, gnOwsContextService, $http) {
         return {
           restrict: 'A',
           replace: true,
           templateUrl: '../../catalog/components/common/map/' +
           'partials/drawbbox.html',
           scope: {
             htopRef: '@',
             hbottomRef: '@',
             hleftRef: '@',
             hrightRef: '@',
             dcRef: '@',
             extentXml: '=?',
             lang: '=',
             schema: '@',
             location: '@'
           },
           link: function(scope, element, attrs) {
             scope.drawing = false;
             var mapRef = scope.htopRef || scope.dcRef || '';
             scope.mapId = 'map-drawbbox-' +
             mapRef.substring(1, mapRef.length);

             var extentTpl = {
               'iso19139': '<gmd:EX_Extent ' +
               'xmlns:gmd="http://www.isotc211.org/2005/gmd" ' +
               'xmlns:gco="http://www.isotc211.org/2005/gco">' +
               '<gmd:geographicElement>' +
               '<gmd:EX_GeographicBoundingBox>' +
               '<gmd:westBoundLongitude><gco:Decimal>{{west}}</gco:Decimal>' +
               '</gmd:westBoundLongitude>' +
               '<gmd:eastBoundLongitude><gco:Decimal>{{east}}</gco:Decimal>' +
               '</gmd:eastBoundLongitude>' +
               '<gmd:southBoundLatitude><gco:Decimal>{{south}}</gco:Decimal>' +
               '</gmd:southBoundLatitude>' +
               '<gmd:northBoundLatitude><gco:Decimal>{{north}}</gco:Decimal>' +
               '</gmd:northBoundLatitude>' +
               '</gmd:EX_GeographicBoundingBox></gmd:geographicElement>' +
               '</gmd:EX_Extent>',
               'iso19115-3': '<gex:EX_Extent ' +
               'xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0" ' +
               'xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0">' +
               '<gex:geographicElement>' +
               '<gex:EX_GeographicBoundingBox>' +
               '<gex:westBoundLongitude><gco:Decimal>{{west}}</gco:Decimal>' +
               '</gex:westBoundLongitude>' +
               '<gex:eastBoundLongitude><gco:Decimal>{{east}}</gco:Decimal>' +
               '</gex:eastBoundLongitude>' +
               '<gex:southBoundLatitude><gco:Decimal>{{south}}</gco:Decimal>' +
               '</gex:southBoundLatitude>' +
               '<gex:northBoundLatitude><gco:Decimal>{{north}}</gco:Decimal>' +
               '</gex:northBoundLatitude>' +
               '</gex:EX_GeographicBoundingBox></gex:geographicElement>' +
               '</gex:EX_Extent>'
             };
             var xmlExtentFn = function(coords, location) {
               if (angular.isArray(coords) &&
               coords.length === 4 &&
               !isNaN(coords[0]) &&
               !isNaN(coords[1]) &&
               !isNaN(coords[2]) &&
               !isNaN(coords[3]) &&
               angular.isNumber(coords[0]) &&
               angular.isNumber(coords[1]) &&
               angular.isNumber(coords[2]) &&
               angular.isNumber(coords[3])) {
                 scope.extentXml = extentTpl[scope.schema || 'iso19139']
                 .replace('{{west}}', coords[0])
                 .replace('{{south}}', coords[1])
                 .replace('{{east}}', coords[2])
                 .replace('{{north}}', coords[3]);
               }
             };

             /**
              * set dublin-core coverage output
              */
             var setDcOutput = function() {
               if (scope.dcRef) {
                 scope.dcExtent = gnMap.getDcExtent(
                 scope.extent.md,
                 scope.location);
               }
               xmlExtentFn(scope.extent.md, scope.location);
             };

             /**
              * Different projections used in the directive:
              * - md : the proj system in the metadata. It is defined as
              *   4326 by iso19139 schema
              * - map : the projection of the ol3 map, this projection
              *   is defined as 3006
              * - form : projection used for the form, it is defined as 4326
              * - county: projection used for the county select, it is defined as 3006 
              */
             scope.projs = {
               md: 'EPSG:4326',
               map: 'EPSG:3006',
               form: 'EPSG:4326',
               county: 'EPSG:3006'
             };
             scope.extent = {
               md: null,
               map: [],
               form: [],
               county: []
             };
             if (attrs.hleft !== '' && attrs.hbottom !== '' &&
                 attrs.hright !== '' && attrs.htop !== '') {
               scope.extent.md = [
                 parseFloat(attrs.hleft), parseFloat(attrs.hbottom),
                 parseFloat(attrs.hright), parseFloat(attrs.htop)
               ];
             }

             var reprojExtent = function(from, to) {
               scope.extent[to] = gnMap.reprojExtent(
                   scope.extent[from],
                   scope.projs[from], scope.projs[to]
               );
             };

             // Init extent from md for map and form
             reprojExtent('md', 'map');
             reprojExtent('md', 'form');
             setDcOutput();

             // TODO: move style in db config
             var boxStyle = new ol.style.Style({
               stroke: new ol.style.Stroke({
                 color: 'rgba(255,0,0,1)',
                 width: 2
               }),
               fill: new ol.style.Fill({
                 color: 'rgba(255,0,0,0.3)'
               }),
               image: new ol.style.Circle({
                 radius: 7,
                 fill: new ol.style.Fill({
                   color: 'rgba(255,0,0,1)'
                 })
               })
             });

             var feature = new ol.Feature();
             var source = new ol.source.Vector();
             source.addFeature(feature);

             var bboxLayer = new ol.layer.Vector({
               source: source,
               style: boxStyle
             });

             //To set base map of editor
            var extent = [-1200000, 4700000, 2540000, 8500000];
            var resolutions = [4096.0, 2048.0, 1024.0, 512.0, 256.0,
              128.0, 64.0, 32.0, 16.0, 8.0];
            var matrixIds = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

            proj4.defs(
                'EPSG:3006',
                '+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 ' +
                '+units=m +axis=neu +no_defs');
            ol.proj.get('EPSG:3006').setExtent(extent);
            ol.proj.get('EPSG:3006').setWorldExtent([-5.05651650131, 40.6662879582,
              28.0689828648, 71.7832476487]);

            proj4.defs('urn:ogc:def:crs:EPSG::3006', proj4.defs('EPSG:3006'));
            proj4.defs('http://www.opengis.net/gml/srs/epsg.xml#3006', proj4.defs('EPSG:3006'));

            var projection = ol.proj.get('EPSG:3006');

            var tileGrid = new ol.tilegrid.WMTS({
              tileSize: 256,
              extent: extent,
              resolutions: resolutions,
              matrixIds: matrixIds
            });

            var apiKey = 'a9a380d6b6f25f22e232b8640b05ea8';

            var wmts = new ol.layer.Tile({
              extent: extent,
              group: 'Background layers',
              url:  'https://api.lantmateriet.se/open/topowebb-ccby/' +
              'v1/wmts/token/' + apiKey + '/',
              source: new ol.source.WMTS({
                url: 'https://api.lantmateriet.se/open/topowebb-ccby/' +
                    'v1/wmts/token/' + apiKey + '/',
                layer: 'topowebb',
                format: 'image/png',
                matrixSet: '3006',
                tileGrid: tileGrid,
                version: '1.0.0',
                style: 'default',
                crossOrigin: 'anonymous'
              })
            }); 

            var mapsConfig = {
              resolutions: resolutions,
              extent: extent,
              projection: projection,
              center: [572087, 6802255],
              zoom: 0
            };

             var map = new ol.Map({
               layers: [
                 wmts,
                 bboxLayer
               ],
               renderer: 'canvas',
               view: new ol.View(mapsConfig)
             });
             element.data('map', map);
             //Uses configuration from database
             if (gnMap.getMapConfig().context) {
               gnOwsContextService.
                   loadContextFromUrl(gnMap.getMapConfig().context, map);
             }

             var dragbox = new ol.interaction.DragBox({
               style: boxStyle,
               condition: function() {
                  return scope.drawing;
               }
             });

             dragbox.on('boxstart', function(mapBrowserEvent) {
               feature.setGeometry(null);
             });

             dragbox.on('boxend', function(mapBrowserEvent) {
              if (angular.isDefined(scope.search)) {
                 delete scope.search.namesearch
              }            
               scope.extent.map = dragbox.getGeometry().getExtent();
               feature.setGeometry(dragbox.getGeometry());

               scope.$apply(function() {
                 reprojExtent('map', 'form');
                 reprojExtent('map', 'md');
                 setDcOutput();
               });
             });

             map.addInteraction(dragbox);

             /**
              * Draw the map extent as a bbox onto the map.
              */
             var drawBbox = function() {
               var coordinates, geom;

               // no geometry
               if (scope.extent.map == null) {
                 return;
               }

               if (gnMap.isPoint(scope.extent.map)) {
                 coordinates = [scope.extent.map[0],
                   scope.extent.map[1]];
                 geom = new ol.geom.Point(coordinates);
               }
               else {
                 coordinates = gnMap.getPolygonFromExtent(
                     scope.extent.map);                 
                 geom = new ol.geom.Polygon(coordinates);
               }
               feature.setGeometry(geom);
               feature.getGeometry().setCoordinates(coordinates);
               scope.extent.map = geom.getExtent();
             };

             /**
              * When form is loaded
              * - set map div
              * - draw the feature with MD initial coordinates
              * - fit map extent
              */
             scope.$watch('gnCurrentEdit.version', function(newValue) {
               map.setTarget(scope.mapId);
               drawBbox();
               if (gnMap.isValidExtent(scope.extent.map)) {
                 map.getView().fit(scope.extent.map, map.getSize());
               }
             });

             /**
              * Switch mode (panning or drawing)
              */
             scope.drawMap = function() {
               scope.drawing = !scope.drawing;
             };

             /**
              * Called on form input change.
              * Set map and md extent from form reprojection, and draw
              * the bbox from the map extent.
              */
             scope.updateBbox = function() {

               reprojExtent('form', 'map');
               reprojExtent('form', 'md');
               setDcOutput();
               drawBbox();
               if (gnMap.isValidExtent(scope.extent.map)) {
                 map.getView().fit(scope.extent.map, map.getSize());
               }
             };
              /**
              * Called on to remove 4 extent in map.
              */
             scope.removeExtent = function(){
              scope.extent.form = [];
              scope.updateBbox();
             };

             /**
              * Called on for showing geo suggestions.
              */
             scope.getNameSearch = function(val) {
//               var posturl = 'https://www.geodata.se/NameWebService/search';
//                val = encodeURIComponent(val);
//                var params = {
//                  'searchstring': val,
//                  'callback': 'JSON_CALLBACK'
//                };
//                return $http({
//                  method: 'JSONP',
//                  url: posturl,
//                  params: params
//                }).then(function(res) {
//                  var data = res.data;
//                  var status = res.status;
//                  var headers = res.headers;
//                  var config = res.config;
//                  var statusText = res.statusText;
//                  return data;
//                });
                //TODO: move api url and username to config
                var url = 'http://api.geonames.org/searchJSON';
            	  //redirect http request via proxy
             	  if (!url.includes("https://")) {
            		url = gnGlobalSettings.proxyUrl + encodeURIComponent(url);
                  }  
                  $http.get(url, {
                    params: {
                      lang: lang,
                      style: 'full',
                      type: 'json',
                      maxRows: 10,
                      name_startsWith: val,
                      country: 'SE',
                      east: 24.1633,
                      west: 10.9614,
                      north: 69.059,
                      south: 55.3363,
                      username: 'georchestra'
                    }
                  }).
                    success(function(response) {
                      var loc;
                      var results = [];
                      for (var i = 0; i < response.geonames.length; i++) {
                        loc = response.geonames[i];
                        if (loc.bbox) {
                          $scope.results.push({
                            name: loc.name,
                            formattedName: formatter(loc),
                            extent: ol.proj.transformExtent([loc.bbox.west,
                              loc.bbox.south, loc.bbox.east, loc.bbox.north],
                            'EPSG:4326', $scope.map.getView().getProjection())
                          });
                        }
                      }
                      return results;
                    });                
            };

             /**
              * Called on county input change.
              * Set map and md extent from form reprojection, and draw
              * the bbox from the map extent.
              */
            scope.onCountySelect = function() {
              var namesearch = scope.search.namesearch;
              var coordinates = namesearch.Coordinates;
              var geoJson = new ol.format.GeoJSON();
              if (coordinates) {
                //var proj = $scope.searchObj.searchMap.getView().getProjection();
                var xy0 = coordinates[0];
                var xy1 = coordinates[1];
                var extent = []; // geoBox=10.59|55.15|24.18|69.05
                extent.push(parseFloat(xy0.X), parseFloat(xy0.Y),
                  parseFloat(xy1.X), parseFloat(xy1.Y));
                scope.extent.county = extent
                reprojExtent('county', 'form');
                scope.updateBbox();
              } else {
                return false; // always return false if cooridinates are absent. Not sure if we shall still return true.
              }
            };

             /**
              * Callback sent to gn-country-picker directive.
              * Called on region selection from typeahead.
              * Zoom to extent.
              */
             scope.onRegionSelect = function(region) {
               scope.$apply(function() {
                 scope.extent.md = [parseFloat(region.west),
                   parseFloat(region.south),
                   parseFloat(region.east),
                   parseFloat(region.north)];
                 scope.location = region.name;
                 reprojExtent('md', 'map');
                 reprojExtent('md', 'form');
                 setDcOutput();
                 drawBbox();
                 map.getView().fit(scope.extent.map, map.getSize());
               });
             };
           }
         };
       }]);
})();
