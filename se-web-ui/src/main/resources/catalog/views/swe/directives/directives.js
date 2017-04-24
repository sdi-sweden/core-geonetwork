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
  goog.provide('swe_directives');
  goog.require('gn_utility_service');

  var module = angular.module('swe_directives', ['gn_utility_service']);

  /**
   * @ngdoc directive
   * @name body
   * @function
   *
   * @description
   * Adds/removes a class from the page body.
   * Used for overlay style when displaying dialogs.
   *
   * Example of usage in controllers:
   *
   * - Add class: $scope.$emit('body:class:add', 'show-overlay')
   * - Remove class: $scope.$emit('body:class:remove', 'show-overlay')
   */
  module.directive('body', [function() {
    return {
      restrict: 'E',
      link: function(scope, element, attrs) {
        scope.$on('body:class:add', function(e, name) {
          element.addClass(name);
        });
        scope.$on('body:class:remove', function(e, name) {
          element.removeClass(name);
        });
        return;
      }
    };
  }]);


  /**
   * @ngdoc directive
   * @name sweSortbyCombo
   * @function
   *
   * @description
   * Provides a sort-by combo list in the search page.
   *
   */
  module.directive('sweSortbyCombo', ['$translate', 'hotkeys', 'gnSearchSettings',
    function($translate, hotkeys, gnSearchSettings) {
      return {
        restrict: 'A',
        require: '^ngSearchForm',
        templateUrl: function(elem, attrs) {
          return attrs.template ||
              '../../catalog/views/swe/directives/partials/' +
              'sortByCombo.html';
        }, scope: {
          params: '=',
          values: '=sweSortbyValues'
        },
        link: function(scope, element, attrs, searchFormCtrl) {
          scope.params.sortBy = scope.params.sortBy ||
              scope.values[0].sortBy;

          scope.sortBy = function(v) {
            angular.extend(scope.params, v);
            scope.sortByOrder(scope.params.sortOrder);
          };

          if (angular.isUndefined(scope.params.sortOrder) || 
              (scope.params.sortOrder == '')) {
            scope.sortOrder = 'descending';
          } else {
            scope.sortOrder = 'ascending';
          }

          scope.sortByOrder = function(v) {
            scope.params.sortOrder = v;

            if (angular.isUndefined(v) || (v == '')) {
              delete scope.params.sortOrder;
              scope.sortOrder = 'descending';
            } else {
              scope.params.sortOrder = v;
              scope.sortOrder = 'ascending';
            }

            // after sorting the results go back to the first page of results (with from & to)
            scope.params.from = 1;
            scope.params.to = gnSearchSettings.hitsperpageValues[0];

            searchFormCtrl.triggerSearch(true);
          };

          hotkeys.bindTo(scope)
              .add({
                combo: 's',
                description: $translate('hotkeySortBy'),
                callback: function() {
                  for (var i = 0; i < scope.values.length; i++) {
                    if (scope.values[i].sortBy === scope.params.sortBy) {
                      var nextOptions = i === scope.values.length - 1 ?
                          0 : i + 1;
                      '';
                      return;
                    }
                  }
                }
              });
        }
      };
    }
  ]);


  /**
   * @ngdoc directive
   * @name sweShowDialog
   * @function
   *
   * @description
   * Adds "show" class for the dialog referenced in scope.dialog.
   *
   */
  module.directive('sweShowDialog', [
    function() {
      return {
        restrict: 'A',
        scope: { dialog: '@dialog', focusControl: '@focusControl'},
        link: function(scope, elem) {
          elem.on('click', function() {
            angular.element(scope.dialog).addClass('show');
            if (scope.focusControl) {
              angular.element(scope.focusControl).focus();
            }

            scope.$emit('body:class:add', 'show-overlay');
          });
        }
      };
    }
  ]);
  
  /**
   * @ngdoc directive
   * @name sweShowDialog
   * @function
   *
   * @description
   * Adds "show" class for the dialog referenced in scope.dialog.
   *
   */
  module.directive('sweShowDialogForHelp', [
    function() {
      return {
        restrict: 'A',
        scope: { dialog: '@dialog', focusControl: '@focusControl'},
        link: function(scope, elem) {
          elem.on('click', function() {
            angular.element(scope.dialog).addClass('show');
            if (scope.focusControl) {
              angular.element(scope.focusControl).focus();
            }
          });
        }
      };
    }
  ]);
  
  module.directive('dragable', function(){   
	  return {
	    restrict: 'A',
	    link : function(scope,elem,attr){
	    	$(elem).draggable({
	    		containment: "window"
	        });
	    }
	  }  
	});

  /**
   * @ngdoc directive
   * @name sweHideDialog
   * @function
   *
   * @description
   * Removes "show" class for the dialog referenced in scope.dialog.
   *
   */
  module.directive('sweHideDialog', [
    function() {
      return {
        restrict: 'A',
        scope: { dialog: '@dialog' },
        link: function(scope, elem) {
          elem.on('click', function() {
            angular.element(scope.dialog).removeClass('show');
            scope.$emit('body:class:remove', 'show-overlay');
          });
        }
      };
    }
  ]);

  /**
   * @ngdoc directive
   * @name sweToggleStyle
   * @function
   *
   * @description
   * Adds/removed "open" class. Used for drop down menus to show/hide entries
   *
   */
  module.directive('sweToggleStyle', [
    function() {
      return {
        restrict: 'A',
        scope: { element: '@element' },
        link: function(scope, elem) {
          var currentState = true;

          elem.on('click', function() {
            var e = (scope.element !== undefined) ? scope.element : elem;

            if (currentState === true) {
              angular.element(e).addClass('open');
            } else {
              angular.element(e).removeClass('open');
            }

            currentState = !currentState;
          });
        }
      };
    }
  ]);

  /**
   * @ngdoc directive
   * @name sweTooltip
   * @function
   *
   * @description
   * Displays a tooltip element.
   *
   */
  module.directive('sweTooltip', ['$timeout','$rootScope','gnConfig','gnConfigService',
    function($timeout, $rootScope, gnConfig, gnConfigService) {
      return {
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/views/swe/directives/' +
          'partials/tooltip.html',
        scope: {
          title: '@',
          text: '@',
          link: '@'
        },
        link: function(scope, elem) {
          gnConfigService.loadPromise.then(function() {
            scope.prefix = gnConfig['system.server.host'];
          });

          $timeout(function () {
            elem.on('click', '.help-icn-circle', function () {
              var tooltipElem = elem.find('.tool-tip-cont');
              if (tooltipElem.hasClass('open')) {
                tooltipElem.removeClass('open');
              } else {
                tooltipElem.addClass('open');
              }
              $rootScope.$emit('closetooltip', tooltipElem);
            })
          });
          
		  $rootScope.$on('closetooltip', function (event, tooltipElem) {
		     var tmpElem = elem.find('.tool-tip-cont');
		     if(tmpElem != undefined && tooltipElem != undefined){
		        if(tmpElem.get(0) !== tooltipElem.get(0)){
				   if (tmpElem.hasClass('open')) {
	                  tmpElem.removeClass('open');
			       }
			    }
		     }
	      });
		  
          scope.openPopup = function() {
        	  var url = scope.prefix + scope.link;
        	  $rootScope.$emit('openhelppopup', scope.link);
		  }
        }
      };
    }
  ]);
  

  /**
   * @ngdoc directive
   * @name sweMdActionsMenu
   * @function
   *
   * @description
   * Actions menu in search results.
   *
   */
  module.directive('sweMdActionsMenu', ['gnMetadataActions',
    function(gnMetadataActions) {
      return {
        restrict: 'A',
        replace: true,
        templateUrl: '../../catalog/views/swe/directives/' +
            'partials/mdactionmenu.html',
        link: function linkFn(scope, element, attrs) {
          scope.mdService = gnMetadataActions;
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
  module.directive('swePredefinedMapsFilter', ['$http', '$rootScope', 'gnOwsContextService', 'gnSearchSettings', '$timeout',
    function($http, $rootScope, gnOwsContextService, gnSearchSettings, $timeout) {
      return {
        restrict: 'EA',
        replace: true,
        templateUrl: '../../catalog/views/swe/directives/' +
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
        templateUrl: '../../catalog/views/swe/directives/' +
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
          return '../../catalog/views/swe/directives/' +
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
          return '../../catalog/views/swe/directives/' +
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


    /**
     * Directive used to close the typeahead suggestions
     * list when clicking ENTER key.
     *
     * The solution is a bit "special": to add extra element that
     * is focus so the popup with suggestions gets closed.
     */
    module.directive('allowPostOnEnter', ['$timeout' ,function($timeout) {
      return {
          link: function($scope, elem, attrs) {
              var hiddenInpt = angular.element('<input class="hide">');
              elem.parent().append(hiddenInpt);
              elem.bind('keydown', function(evt) {
                  if (evt.which === 13) {
                          $timeout(function() {
                              hiddenInpt[0].click();
                          });
                  }
              })
          } //end of link
      }
    }]);

}());
