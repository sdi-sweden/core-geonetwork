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

  goog.provide('gn_search_sweden_directive');

  var module = angular.module('gn_search_sweden_directive', []);

  module.directive('gnInfoList', ['gnMdView',
    function(gnMdView) {
      return {
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/views/sweden/directives/' +
            'partials/infolist.html',
        link: function linkFn(scope, element, attr) {
          scope.showMore = function(isDisplay) {
            var div = $('#gn-info-list' + this.md.getUuid());
            $(div.children()[isDisplay ? 0 : 1]).addClass('hidden');
            $(div.children()[isDisplay ? 1 : 0]).removeClass('hidden');
          };
          scope.go = function(uuid) {
            gnMdView(index, md, records);
            gnMdView.setLocationUuid(uuid);
          };
        }
      };
    }
  ]);

  module.directive('gnAttributeTableRenderer', ['gnMdView',
    function(gnMdView) {
      return {
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/views/sweden/directives/' +
        'partials/attributetable.html',
        scope: {
          attributeTable: '=gnAttributeTableRenderer'
        },
        link: function linkFn(scope, element, attrs) {
          if (angular.isDefined(scope.attributeTable) &&
            !angular.isArray(scope.attributeTable)) {
            scope.attributeTable = [scope.attributeTable];
          }
          scope.showCodeColumn = false;
          angular.forEach(scope.attributeTable, function(elem) {
            if(elem.code > '') {
              scope.showCodeColumn = true;
            }
          });
        }
      };
    }
  ]);

  module.directive('gnLinksBtn', [ 'gnTplResultlistLinksbtn',
    function(gnTplResultlistLinksbtn) {
      return {
        restrict: 'E',
        replace: true,
        scope: true,
        templateUrl: gnTplResultlistLinksbtn
      };
    }
  ]);

  module.directive('gnMdActionsMenu', ['gnMetadataActions', '$http', 'gnConfig', 'gnConfigService',
    function(gnMetadataActions, $http, gnConfig, gnConfigService) {
      return {
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/views/sweden/directives/' +
            'partials/mdactionmenu.html',
        link: function linkFn(scope, element, attrs) {
          scope.mdService = gnMetadataActions;
          scope.md = scope.$eval(attrs.gnMdActionsMenu);

          scope.tasks = [];
          scope.hasVisibletasks = false;

          gnConfigService.load().then(function(c) {
            scope.isMdWorkflowEnable = gnConfig['metadata.workflow.enable'];
          });

          function loadTasks() {
            return $http.get('../api/status/task', {cache: true}).
            success(function(data) {
              scope.tasks = data;
              scope.getVisibleTasks();
            });
          };

          scope.getVisibleTasks = function() {
            $.each(scope.tasks, function(i,t) {
              scope.hasVisibletasks = scope.taskConfiguration[t.name] &&
                scope.taskConfiguration[t.name].isVisible &&
                scope.taskConfiguration[t.name].isVisible();
            });
          }

          scope.taskConfiguration = {
            doiCreationTask: {
              isVisible: function(md) {
                return gnConfig['system.publication.doi.doienabled'];
              },
              isApplicable: function(md) {
                // TODO: Would be good to return why a task is not applicable as tooltip
                // TODO: Add has DOI already
                return md && md.isPublished()
                  && md.isTemplate === 'n'
                  && md.isHarvested === 'n';
              }
            }
          };

          loadTasks();

          scope.$watch(attrs.gnMdActionsMenu, function(a) {
            scope.md = a;
          });

          scope.getScope = function() {
            return scope;
          }
        }
      };
    }
  ]);

  module.directive('gnPeriodChooser', [
    function() {
      return {
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/views/sweden/directives/' +
            'partials/periodchooser.html',
        scope: {
          label: '@gnPeriodChooser',
          dateFrom: '=',
          dateTo: '='
        },
        link: function linkFn(scope, element, attr) {
          var today = moment();
          scope.format = 'YYYY-MM-DD';
          scope.options = ['today', 'yesterday', 'thisWeek', 'thisMonth',
            'last3Months', 'last6Months', 'thisYear'];
          scope.setPeriod = function(option) {
            if (option === 'today') {
              var date = today.format(scope.format);
              scope.dateFrom = date;
            } else if (option === 'yesterday') {
              var date = today.clone().subtract(1, 'day')
                .format(scope.format);
              scope.dateFrom = date;
              scope.dateTo = today.format(scope.format);
              return;
            } else if (option === 'thisWeek') {
              scope.dateFrom = today.clone().startOf('week')
                .format(scope.format);
            } else if (option === 'thisMonth') {
              scope.dateFrom = today.clone().startOf('month')
                .format(scope.format);
            } else if (option === 'last3Months') {
              scope.dateFrom = today.clone().startOf('month').
                  subtract(3, 'month').format(scope.format);
            } else if (option === 'last6Months') {
              scope.dateFrom = today.clone().startOf('month').
                  subtract(6, 'month').format(scope.format);
            } else if (option === 'thisYear') {
              scope.dateFrom = today.clone().startOf('year')
                .format(scope.format);
            }
            scope.dateTo = today.clone().add(1, 'day').format(scope.format);
          };
        }
      };
    }
  ]);

    /**
   * @ngdoc directive
   * @name swePredefinedMapsFilter
   * @function
   *
   * @description
   * Shows predefined maps filters on home page.
   *
   */
  module.directive('swePredefinedMapsFilter', ['$http', '$rootScope', 'gnOwsContextService', 'gnSearchSettings', '$timeout', 'gnViewerSettings',
    function($http, $rootScope, gnOwsContextService, gnSearchSettings, $timeout, gnViewerSettings) {
      return {
        restrict: 'EA',
        replace: true,
        templateUrl: '../../catalog/views/sweden/directives/' +
          'partials/predefinedMaps.html',
        scope: {
          predefinedMaps: '@',
          selectedMap: '@',
          showMapFn: '&',
          showMapFnApi: '&',
          configUrl: '@',
          selectedItem: '@',
          isImageClicked: '='
        },
        link: function(scope, element, attrs) {
          scope.$watch("configUrl", function(value) {
            if (value) {
              $http.get(scope.configUrl).success(function(data) {
                  scope.predefinedMaps = data;

                  if (scope.selectedMap != undefined) {
                	  var indexPredef;
                      var predefinedMapsFiltered =
                          scope.predefinedMaps.filter(function(x) {
                            if(x['id'] == scope.selectedMap){
                        	  indexPredef = scope.predefinedMaps.indexOf(x);
                        	}
                            return x['id'] == scope.selectedMap
                          });

                      if (predefinedMapsFiltered.length > 0) {
                          scope.doViewFromApi(indexPredef, predefinedMapsFiltered[0]);
                      }
                  }
              });
            }
          });

    	  $rootScope.$on('closePredefMap', function() {
              scope.selectedItem = -1;
              var predefMapArrow = angular.element('#predefmapsArrow');
              if(!predefMapArrow.hasClass('cls-btn icon-down-dir')){
            	  $timeout(function() {
            		  predefMapArrow.trigger('click'); 
            	  }, 100);
              };
              selectedPredefMap = angular.element('.selected-img');
              if(selectedPredefMap.length > 0){
                 selectedPredefMap.removeClass('selected-img').addClass('bg-img');
                  $timeout(function() {
                    angular.element('.bg-img').css("opacity", "1");
                    angular.element('.selected-img').css("opacity", "1");
                  }, 500);
              }
           });

          scope.doView = function(index, predefinedMap) {
          	  scope.selectedItem = index;
              scope.isImageClicked = true;
              gnOwsContextService.loadContext(predefinedMap.map, gnSearchSettings.viewerMap);
               $timeout(function() {
                  angular.element('.bg-img').css("opacity", "0.2");
                  angular.element('.selected-img').css("opacity", "1");
                }, 250);

              scope.showMapFn()();
              angular.element('#layers').removeClass('ng-hide');
  			  var layersButton = angular.element('#layersButton');
  			  if (!layersButton.hasClass('active')){
  			     $timeout(function() {
  			        layersButton.trigger('click');
  			     }, 500);
  			  }
            };

          scope.doViewFromApi = function(index, predefinedMap) {
            // delete owsContext cookie to avoid loading previous layers
            // if loading a predefined map from the Api
            var storage = gnViewerSettings.storage ?
              window[gnViewerSettings.storage] : window.localStorage;

            storage.removeItem('owsContext')

        	scope.selectedItem = index;
            scope.isImageClicked = true;
            gnOwsContextService.loadContext(predefinedMap.map, gnSearchSettings.viewerMap);
            $timeout(function() {
                angular.element('.bg-img').css("opacity", "0.2");
                angular.element('.selected-img').css("opacity", "1");
              }, 250);

            scope.showMapFnApi()();
            angular.element('#layers').removeClass('ng-hide');
			var layersButton = angular.element('#layersButton');
			if (!layersButton.hasClass('active')){
			   $timeout(function() {
			      layersButton.trigger('click');
			   }, 500);
			}
          };
        }
      };
  }]);
/**
   * @ngdoc directive
   * @name sweGeoTechnic
   * @function
   *
   * @description
   * Shows geotechnics on home page.
   *
   */
  module.directive('sweGeoTechnicsFilter', ['$http', '$rootScope', 'gnOwsContextService', 'gnSearchSettings', '$timeout',
    function($http, $rootScope, gnOwsContextService, gnSearchSettings, $timeout) {
      return {
        restrict: 'E',
        replace: true,
        templateUrl: '../../catalog/views/sweden/directives/' +
          'partials/geoTechnics.html',
        scope: {
          geoTechnics: '@',
          showMapFn: '&',
          configUrl: '@'
        },
        link: function(scope, element, attrs) {

          scope.$watch("configUrl", function(value) {
            if (value) {
              $http.get(scope.configUrl).success(function(data) {
                  scope.geoTechnics = data[0];
              });
            }
          });

          scope.doView = function(geoTechnic) {
          	$rootScope.$emit('closePredefMap');
            gnOwsContextService.loadContext(geoTechnic.map, gnSearchSettings.viewerMap);
            scope.showMapFn()();
            angular.element('#layers').removeClass('ng-hide');
			var layersButton = angular.element('#layersButton');
			if (!layersButton.hasClass('active')){
			   $timeout(function() {
			      layersButton.trigger('click');
			   }, 500);
			}
          };
        }
      };
  }]);

  module.directive('sweFacetDimensionList', [
    'gnFacetConfigService', '$timeout',
    function(gnFacetConfigService, $timeout) {
      return {
        restrict: 'A',
        templateUrl: function($element, $attrs) {
          return '../../catalog/views/sweden/directives/' +
              'partials/dimension-facet-list.html';
        },
        scope: {
          dimension: '=sweFacetDimensionList',
          facetType: '=',
          params: '='
        },
        link: function(scope, element) {
          scope.facetQuery = scope.params['facet.q'];
          scope.facetConfig = null;

          // Facet is collapsed if not in current search criteria
          scope.isFacetsCollapse = function(facetKey) {
            return !angular.isDefined(scope.params[facetKey]);
          };

          scope.isInFilter = function(category) {
            if (!scope.facetConfig) {
              return false;
              // Facet configuration not yet loaded
            }

            var facetQParam = scope.params['facet.q'];
            if (facetQParam === undefined) {
              return false;
            } else {
              return facetQParam.indexOf(category) > -1;
            }
          };

          // Load facet configuration to know which index field
          // correspond to which dimension.
          gnFacetConfigService.loadConfig(scope.facetType).
              then(function(data) {
                scope.facetConfig = {
                  config: data,
                  map:  {}
                };

                angular.forEach(scope.facetConfig.config, function(key) {
                  scope.facetConfig.map[key.label] = key.name;
                });
              });
        }
      };
    }]);

  module.directive('sweFacetDimensionCategory', [
    'gnFacetConfigService', 'RecursionHelper', '$parse',
    function(gnFacetConfigService, RecursionHelper, $parse) {
      return {
        restrict: 'A',
        templateUrl: function($element, $attrs) {
          return '../../catalog/views/sweden/directives/' +
              'partials/dimension-facet-category.html';
        },
        scope: {
          category: '=sweFacetDimensionCategory',
          categoryKey: '=',
          path: '=',
          params: '=',
          facetConfig: '='
        },
        compile: function(element) {
          // Use the compile function from the RecursionHelper,
          // And return the linking function(s) which it returns
          return RecursionHelper.compile(element,
              function(scope, element, attrs) {
                var initialMaxItems = 5;
                scope.initialMaxItems = initialMaxItems;
                scope.maxItems = initialMaxItems;
                scope.toggleAll = function() {
                  scope.maxItems = (scope.maxItems == Infinity) ?
                      initialMaxItems : Infinity;
                };

                // Facet drill down is based on facet.q parameter.
                // The facet.q parameter contains a list of comma separated
                // dimensions
                // <dimension_name>{"/"<category_value>}
                // Note that drill down paths use '/' as the separator
                // between categories in the path, so embedded '/' characters
                // in categories should be escaped using %2F or alternatively,
                // each category in the path url encoded in addition to
                // normal parameter encoding.
                //
                // Multiple drill down queries can be specified by providing
                // multiple facet.q parameters or by combining drill down
                // queries in one facet.q parameter using '&'
                // appropriately encoded.
                //
                // http://localhost:8080/geonetwork/srv/fre/q?
                // resultType=hierarchy&
                // facet.q=gemetKeyword/http%253A%252F%252Fwww.eionet.europa.eu
                //  %252Fgemet%252Fconcept%252F2643
                //  %2F
                //  http%253A%252F%252Fwww.eionet.europa.eu
                //    %252Fgemet%252Fconcept%252F2641

                /**
               * Build the drill down path based on current category value
               * and its parent.
               * @param {Object} category
               * @return {boolean|*}
               */
                scope.buildPath = function(category) {
                  category.path =
                      (scope.path === undefined ? '' : scope.path + '/') +
                      encodeURIComponent(category['@value']);
                  return category.path;
                };


                /**
               * Build the facet.q paramaeter
               */
                scope.filter = function(category, $event) {
                  if (!scope.facetConfig) {
                    return; // Facet configuration not yet loaded.
                  }

                  var checked = !scope.isInFilter(category);


                  // Extract facet.q info
                  if (angular.isUndefined(scope.params['facet.q'])) {
                    scope.params['facet.q'] = '';
                  }
                  var facetQParam = scope.params['facet.q'];
                  var dimensionList =
                      facetQParam.split('&');
                  var categoryList = [];
                  $.each(dimensionList, function(idx) {
                    // Dimension filter contains the dimension name first
                    // and then the drilldown path. User may uncheck
                    // an element in the middle of the path. In such case
                    // only activate the parent node.
                    var dimensionFilter = dimensionList[idx].split('/');

                    // Dimension but not in that category path. Add filter.
                    if (dimensionFilter[1] &&
                        dimensionFilter[0] !=
                        scope.facetConfig.map[scope.categoryKey]) {
                      categoryList.push({
                        dimension: dimensionFilter[0],
                        value: dimensionFilter.slice(1, dimensionFilter.length)
                      });
                    } else if (dimensionFilter[1] &&
                        dimensionFilter.length > 2 &&
                        dimensionFilter[0] ==
                        scope.facetConfig.map[scope.categoryKey]) {

                      var filteredElementInPath =
                          $.inArray(
                          encodeURIComponent(category['@value']),
                          dimensionFilter);
                      // Restrict the path to its parent
                      if (filteredElementInPath !== -1) {
                        categoryList.push({
                          dimension: scope.categoryKey,
                          value: dimensionFilter.
                              slice(1, filteredElementInPath).
                              join('/')
                        });
                      }
                    }
                  });
                  // Add or remove new category
                  if (checked) {
                    categoryList.push({
                      dimension: scope.categoryKey,
                      value: category.path
                    });
                  } else {

                  }

                  // Build facet.q
                  facetQParam = '';
                  $.each(categoryList, function(idx) {
                    if (categoryList[idx].value) {
                      facetQParam = facetQParam +
                          (scope.facetConfig.map[categoryList[idx].dimension] ||
                          categoryList[idx].dimension) +
                          '/' +
                          categoryList[idx].value +
                          (idx < categoryList.length - 1 ? '&' : '');
                    }
                  });
                  scope.params['facet.q'] = facetQParam;

                  scope.$emit('resetSearch', scope.params);
                  $event.preventDefault();
                };


                /**
               * Check that current category is already used
               * in current filter.
               * @param {Object} category
               * @return {boolean|*}
               */
                scope.isOnDrillDownPath = function(category) {
                  // Is selected if the category value is defined in the
                  // facet.q parameter (ie. combination of
                  // dim1/dim1val/dim1val2&dim2/dim2Val...).
                  category.isSelected =
                      angular.isUndefined(scope.params['facet.q']) ?
                      false :
                      ($.inArray(
                      encodeURIComponent(category['@value']),
                      scope.params['facet.q'].split(/&|\//)) !== -1 ||
                      $.inArray(
                      category['@value'],
                      scope.params['facet.q'].split(/&|\//)) !== -1);
                  return category.isSelected;
                };

                scope.isInFilter = function(category) {
                  if (!scope.facetConfig) {
                    return false;
                    // Facet configuration not yet loaded
                  }

                  var facetQParam = scope.params['facet.q'];
                  if (facetQParam === undefined) {
                    return false;
                  }
                  var dimensionList =
                      facetQParam.split('&');
                  var categoryList = [];
                  for (var i = 0; i < dimensionList.length; i++) {
                    var dimensionFilter = dimensionList[i].split('/');
                    if (dimensionFilter[0] ==
                        scope.facetConfig.map[scope.categoryKey] &&
                        ($.inArray(
                        encodeURIComponent(category['@value']),
                        scope.params['facet.q'].split(/&|\//)) !== -1 ||
                        $.inArray(
                        category['@value'],
                        scope.params['facet.q'].split(/&|\//)) !== -1)) {
                      return true;
                    }
                  }
                  return false;
                };

                scope.toggleNode = function(evt) {
                  el = evt ?
                      $(evt.currentTarget).parent() :
                      element.find('span.fa');
                  el.find('.fa').first()
                  .toggleClass('fa-minus-square')
                  .toggleClass('fa-plus-square');
                  el.children('div').toggleClass('hidden');
                  !evt || evt.preventDefault();
                  return false;
                };
              });
        }
      };
    }]);

})();
