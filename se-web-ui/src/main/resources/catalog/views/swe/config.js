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

  goog.provide('swe_search_config');

  //var module = angular.module('swe_search_config', ['pascalprecht.translate']);
  var module = angular.module('swe_search_config', []);


  module.run(['gnSearchSettings', 'gnViewerSettings',
    'gnOwsContextService', 'gnMap',
    function(gnSearchSettings, gnViewerSettings,
             gnOwsContextService, gnMap) {

      // Load the context defined in the configuration
      gnViewerSettings.defaultContext =
          gnViewerSettings.mapConfig.viewerMap ||
          '../../map/config-viewer.xml';

      // Keep one layer in the background
      // while the context is not yet loaded.
      gnViewerSettings.bgLayers = [
        gnMap.createLayerForType('osm')
      ];

      gnViewerSettings.servicesUrl =
          gnViewerSettings.mapConfig.listOfServices || {};

      // WMS settings
      gnViewerSettings.singleTileWMS = true;

      var bboxStyle = new ol.style.Style({
        stroke: new ol.style.Stroke({
          color: 'rgba(255,0,0,1)',
          width: 2
        }),
        fill: new ol.style.Fill({
          color: 'rgba(255,0,0,0.3)'
        })
      });

      gnSearchSettings.olStyles = {
        drawBbox: bboxStyle,
        mdExtent: new ol.style.Style({
          stroke: new ol.style.Stroke({
            color: 'orange',
            width: 2
          })
        }),
        mdExtentHighlight: new ol.style.Style({
          stroke: new ol.style.Stroke({
            color: 'orange',
            width: 3
          }),
          fill: new ol.style.Fill({
            color: 'rgba(255,255,0,0.3)'
          })
        })

      };

      // Object to store the current Map context
      gnViewerSettings.storage = 'sessionStorage';

      /*******************************************************************
       * Define maps
       */
      var mapsConfig = {
        center: [280274.03240585705, 6053178.654789996],
        zoom: 2
        //maxResolution: 9783.93962050256
      };

      var viewerMap = new ol.Map({
        controls: [],
        view: new ol.View(mapsConfig)
      });

      var searchMap = new ol.Map({
        controls: [],
        layers: viewerMap.getLayers(),
        view: new ol.View(mapsConfig)
      });

      /** Facets configuration */
      gnSearchSettings.facetsSummaryType = 'details';

      /*
       * Hits per page combo values configuration. The first one is the
       * default.
       */
      gnSearchSettings.hitsperpageValues = [20, 50, 100];

      /* Pagination configuration */
      gnSearchSettings.paginationInfo = {
        hitsPerPage: gnSearchSettings.hitsperpageValues[0]
      };

      gnSearchSettings.sortbyValues = [{
        sortBy: 'relevance',
        sortOrder: ''
      }, {
        sortBy: 'changeDate',
        sortOrder: ''
      }, {
        sortBy: 'title',
        sortOrder: 'reverse'
      }];

      /* Default search by option */
      gnSearchSettings.sortbyDefault = gnSearchSettings.sortbyValues[0];

      gnSearchSettings.resultTemplate = '../../catalog/views/swe/' +
          'templates/resultList.html';

      // Mapping for md links in search result list.
      gnSearchSettings.linkTypes = {
        links: ['LINK', 'kml'],
        downloads: ['DOWNLOAD'],
        //layers:['OGC', 'kml'],
        layers: ['OGC'],
        maps: ['ows']
      };

      // Set custom config in gnSearchSettings
      angular.extend(gnSearchSettings, {
        viewerMap: viewerMap,
        searchMap: searchMap
      });
    }
  ]);


  /*module.config(['$LOCALES', function($LOCALES) {
    $LOCALES.push('../../catalog/views/swe/locales/|search');
  }]);*/

})();
