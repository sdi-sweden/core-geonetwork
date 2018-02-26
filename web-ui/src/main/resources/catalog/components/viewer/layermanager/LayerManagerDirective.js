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
  goog.provide('gn_layermanager');

  var module = angular.module('gn_layermanager', [
  ]);

  /**
   * @ngdoc filter
   * @name gn_viewer.filter:gnReverse
   *
   * @description
   * Filter for the gnLayermanager directive's ngRepeat. The filter
   * reverses the array of layers so layers in the layer manager UI
   * have the same order as in the map.
   */
  module.filter('gnReverse', function() {
    return function(items) {
      return items.slice().reverse();
    };
  });

  /**
   * @ngdoc directive
   * @name gn_viewer.directive:gnLayermanager
   *
   * @description
   * The `gnLayermanager` directive display a list of all active layers
   * on the map and provides some tools/actions for each.
   * It also displays info if some layers failed to load.
   */
  module.directive('gnLayermanager', [
    'gnLayerFilters',
    'gnWmsQueue',
    function(gnLayerFilters, gnWmsQueue) {
      return {
        restrict: 'A',
        templateUrl: '../../catalog/components/viewer/layermanager/' +
            'partials/layermanager.html',
        scope: {
          map: '=gnLayermanagerMap'
        },
        controllerAs: 'gnLayermanagerCtrl',
        controller: ['$scope', '$compile', function($scope, $compile) {

          /**
         * Change layer index in the map.
         *
         * @param {ol.layer} layer
         * @param {float} delta
         */
          this.moveLayer = function(layer, delta) {
            var index = $scope.layers.indexOf(layer);
            var layersCollection = $scope.map.getLayers();
            layersCollection.removeAt(index);
            layersCollection.insertAt(index + delta, layer);
          };


          /**
         * Set a property to the layer 'showInfo' to true and
         * false to all other layers. Used to display layer information
         * in the layer manager.
         *
         * @param {ol.layer} layer
         */
          this.showInfo = function(layer) {
            /* Commented out so that legends are shown for all layers without closing previously opened one*/
            /*
            angular.forEach($scope.layers, function(l) {
              if (l != layer) {
                l.showInfo = false;
              }
            });*/
            layer.showInfo = !layer.showInfo;
          };

          this.setWPS = function(wpsLink, layer, parent) {

            var scope = $scope.$new();
            wpsLink.layer = layer;
            scope.wpsLink = wpsLink;
            var el = angular.element(
                '<gn-wps-process-form map="map" ' +
                'data-wps-link="wpsLink"></gn-wps-process-form>');
            $compile(el)(scope);
            parent.append(el);
          };
        }],
        link: function(scope, element, attrs) {

          scope.layers = scope.map.getLayers().getArray();
          scope.layerFilterFn = gnLayerFilters.selected;

          scope.failedLayers = gnWmsQueue.errors;
          scope.removeFailed = function(layer) {
            gnWmsQueue.removeFromError(layer);
          };

          scope.removeLayers = function() {
            var layerList = [];
            scope.map.getLayers().forEach(function (layer) {
              var layerGroup = layer.get('group') || '';
              if (layerGroup.toLowerCase() != 'background layers') {
                layerList.push(layer);
              }
            });
            for(var i = 0; i < layerList.length; i++) {
              scope.map.removeLayer(layerList[i]);
            }
            if (scope.failedLayers) {
               for(var i = 0; i < scope.failedLayers.length; i++) {
                   scope.removeFailed(layerList[i]);
               }
            }
          };
        }
      };
    }]);

  /**
   * @ngdoc directive
   * @name gn_viewer.directive:gnLayermanagerItem
   *
   * @description
   * The `gnLayermanagerItem` directive display one layer in the layer manager
   * list, and provides all tools to interacts with the layer.
   * <ul>
   *   <li>Show metadata</li>
   *   <li>Zoom to extent</li>
   *   <li>Change order</li>
   * </ul>
   */
  module.directive('gnLayermanagerItem', [
    'gnMdView',
    'gfiOutputFormatCheck',
    function(gnMdView, gfiOutputFormatCheck) {
      return {
        require: '^gnLayermanager',
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/components/viewer/layermanager/' +
            'partials/layermanageritem.html',
        scope: true,
        link: function(scope, element, attrs, ctrl) {
          scope.layer = scope.$eval(attrs['gnLayermanagerItem']);
          var layer = scope.layer;
          layer.showInfo = true;
          scope.showInfo = ctrl.showInfo;
          scope.moveLayer = ctrl.moveLayer;
          gml_format_check = gfiOutputFormatCheck.result;
          var GML_2 = "text/xml; subtype=gml/2.1.2";
          var GML_3 = "application/vnd.ogc.gml/3.1.1";
          var GML = "application/vnd.ogc.gml";
          if(gml_format_check.indexOf(GML_2) > -1){
            layer.gfiOutputFormat = "GML2";
          }
          else if(gml_format_check.indexOf(GML_3) > -1){
            layer.gfiOutputFormat = "GML3";
          }
          else if(gml_format_check.indexOf(GML) > -1){
            layer.gfiOutputFormat = "GML3";
          }
          else{
              layer.gfiOutputFormat = "XML";
          }

          scope.showMetadata = function() {
            gnMdView.openMdFromLayer(scope.layer);
          };
          function resetPopup() {
            // Hack to remove popup on layer remove eg.
            $('[gn-popover-dropdown] .btn').each(function(i, button) {
              $(button).popover('hide');
            });
          };
          scope.removeLayer = function(layer, map) {
            resetPopup();
            map.removeLayer(layer);
          };
          scope.zoomToExtent = function(layer, map) {
            if (layer.get('cextent')) {
              map.getView().fit(layer.get('cextent'), map.getSize());
            } else if (layer.get('extent')) {
              map.getView().fit(layer.get('extent'), map.getSize());
            }
          };

          if (layer.get('md')) {
            var d = layer.get('downloads');
            var downloadable =
                layer.get('md')['geonet:info'].download == 'true';
            if (angular.isArray(d) && downloadable) {
              scope.download = d[0];
            }

            var wfs = layer.get('wfs');
            if (angular.isArray(wfs) && downloadable) {
              scope.wfs = wfs[0];
            }

            var p = layer.get('processes');
            if (angular.isArray(p)) {
              scope.process = p;
            }
          }

          scope.showWPS = function(process) {
            ctrl.setWPS(process, layer, element);
          };
        }
      };
    }]);

})();
