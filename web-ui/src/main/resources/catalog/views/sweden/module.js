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

  goog.provide('gn_search_sweden');




  goog.require('cookie_warning');
  goog.require('gn_mdactions_directive');
  goog.require('gn_related_directive');
  goog.require('gn_search');
  goog.require('gn_gridrelated_directive');
  goog.require('gn_search_sweden_config');
  goog.require('gn_search_sweden_directive');

  var module = angular.module('gn_search_sweden',
      ['gn_search', 'gn_search_sweden_config',
       'gn_search_sweden_directive', 'gn_related_directive',
       'cookie_warning', 'gn_mdactions_directive', 'gn_gridrelated_directive']);


  module.controller('gnsSearchPopularController', [
    '$scope', 'gnSearchSettings',
    function($scope, gnSearchSettings) {
      $scope.searchObj = {
        permalink: false,
        internal: true,
        filters: gnSearchSettings.filters,
        params: {
          sortBy: 'popularity',
          from: 1,
          to: 12
        }
      };
    }]);


  module.controller('gnsSearchLatestController', [
    '$scope', 'gnSearchSettings',
    function($scope, gnSearchSettings) {
      $scope.searchObj = {
        permalink: false,
        internal: true,
        filters: gnSearchSettings.filters,
        params: {
          sortBy: 'changeDate',
          from: 1,
          to: 12
        }
      };
    }]);


  module.controller('gnsSearchTopEntriesController', [
    '$scope', 'gnGlobalSettings',
    function($scope, gnGlobalSettings) {
      $scope.resultTemplate = '../../catalog/views/sweden/' +
        'templates/grid4maps.html';
      $scope.searchObj = {
        permalink: false,
        internal: true,
        filters: {
          'type': 'interactiveMap'
        },
        params: {
          sortBy: 'changeDate',
          from: 1,
          to: 30
        }
      };
    }]);


  module.controller('gnsSweden', [
    '$rootScope',
    '$scope',
    '$location',
    '$filter',
    'suggestService',
    '$http',
    '$sce',
    '$compile',
    '$window',
    '$translate',
    'gnUtilityService',
    'gnSearchSettings',
    'gnViewerSettings',
    'gnMap',
    'gnMdView',
    'gnMdViewObj',
    'gnWmsQueue',
    'gnSearchLocation',
    'gnOwsContextService',
    'hotkeys',
    'gnGlobalSettings',
    'gnExternalViewer',
    'gnMdFormatter',
    'gnConfig',
    'gnConfigService',
    function($rootScope, $scope, $location, $filter,
             suggestService, $http, $sce, $compile, $window, $translate,
             gnUtilityService, gnSearchSettings, gnViewerSettings,
             gnMap, gnMdView, mdView, gnWmsQueue,
             gnSearchLocation, gnOwsContextService,
             hotkeys, gnGlobalSettings, gnExternalViewer,
             gnMdFormatter, gnConfig, gnConfigService) {

      var viewerMap = gnSearchSettings.viewerMap;
      var searchMap = gnSearchSettings.searchMap;

      $scope.modelOptions = angular.copy(gnGlobalSettings.modelOptions);
      $scope.modelOptionsForm = angular.copy(gnGlobalSettings.modelOptions);
      $scope.isFilterTagsDisplayedInSearch = gnGlobalSettings.gnCfg.mods.search.isFilterTagsDisplayedInSearch;
      $scope.gnWmsQueue = gnWmsQueue;
      $scope.$location = $location;
      $scope.activeTab = '/search';
      $scope.formatter = gnGlobalSettings.gnCfg.mods.search.formatter;
      $scope.listOfResultTemplate = gnGlobalSettings.gnCfg.mods.search.resultViewTpls;
      $scope.resultTemplate = gnSearchSettings.resultTemplate;
      $scope.advancedSearchTemplate = gnSearchSettings.advancedSearchTemplate ||
      '../../catalog/views/sweden/templates/advancedSearchForm/defaultAdvancedSearchForm.html';
      $scope.facetsSummaryType = gnSearchSettings.facetsSummaryType;
      $scope.facetConfig = gnSearchSettings.facetConfig;
      $scope.facetTabField = gnSearchSettings.facetTabField;
      $scope.location = gnSearchLocation;
      $scope.fluidLayout = gnGlobalSettings.gnCfg.mods.home.fluidLayout;
      $scope.fluidEditorLayout = gnGlobalSettings.gnCfg.mods.editor.fluidEditorLayout;
      
      gnConfigService.loadPromise.then(function() {
        // $scope.predefinedMapsUrl = '../../' + gnGlobalSettings.srvProxyUrl +
        //     gnConfig['map.predefinedMaps.url'];

        $scope.predefinedMapsUrl = 'https://www.geodata.se/geodataportalens-hjalpsidor/datasamlingar-rotsida';

        $scope.geotechnicsUrl = '../../' + gnGlobalSettings.srvProxyUrl +
            gnConfig['map.geotechnics.url'];
      });

      // initialize tooltips
      var activateTooltips = function() {
        $('[data-toggle="popover"]').popover();
      };
      // trigger it after page is loaded
      $rootScope.$on('$includeContentLoaded', function() {
        activateTooltips();
      });

      // pre-defined maps
      $scope.selectedPredefinedMap = gnGlobalSettings.predefinedSelectedMap;

      if ($scope.selectedPredefinedMap) {
        // Clean owsContext to load only the layers from the predefined map
        // It's already done in the directive, but seem in no debug mode it's "too late"
        // to do it in the directive
        var storage = gnViewerSettings.storage ?
          window[gnViewerSettings.storage] : window.localStorage;

        storage.removeItem('owsContext');
      }
      
      $scope.toggleMap = function () {
        $(searchMap.getTargetElement()).toggle();
        $('button.gn-minimap-toggle > i').toggleClass('fa-angle-double-left fa-angle-double-right');
      };

      hotkeys.bindTo($scope)
        .add({
            combo: 'h',
            description: $translate.instant('hotkeyHome'),
            callback: function(event) {
              $location.path('/home');
            }
          }).add({
            combo: 't',
            description: $translate.instant('hotkeyFocusToSearch'),
            callback: function(event) {
              event.preventDefault();
              var anyField = $('#gn-any-field');
              if (anyField) {
                gnUtilityService.scrollTo();
                $location.path('/search');
                anyField.focus();
              }
            }
          }).add({
            combo: 'enter',
            description: $translate.instant('hotkeySearchTheCatalog'),
            allowIn: 'INPUT',
            callback: function() {
              $location.search('tab=search');
            }
            //}).add({
            //  combo: 'r',
            //  description: $translate.instant('hotkeyResetSearch'),
            //  allowIn: 'INPUT',
            //  callback: function () {
            //    $scope.resetSearch();
            //  }
          }).add({
            combo: 'm',
            description: $translate.instant('hotkeyMap'),
            callback: function(event) {
              $location.path('/map');
            }
          });


      // TODO: Previous record should be stored on the client side
      $scope.mdView = mdView;
      gnMdView.initMdView();


      $scope.goToSearch = function (any) {
        $location.path('/search').search({'any': any});
      };
      $scope.canEdit = function(record) {
        // TODO: take catalog config for harvested records
        if (record && record['geonet:info'] &&
            record['geonet:info'].edit == 'true') {
          return true;
        }
        return false;
      };
      $scope.closeRecord = function() {
        gnMdView.removeLocationUuid();
      };
      $scope.nextPage = function() {
        $scope.$broadcast('nextPage');
      };
      $scope.previousPage = function() {
        $scope.$broadcast('previousPage');
      };

      /**
       * Toggle the list types on the homepage
       * @param  {String} type Type of list selected
       */
      $scope.toggleListType = function(type) {
        $scope.type = type;
      };

      /**
       * Toggles the filter panel.
       */
      $scope.toggleFilterPanel = function(doShow) {
        $scope.doShow = doShow;
      };
      
      $scope.infoTabs = {
        lastRecords: {
          title: 'lastRecords',
          titleInfo: '',
          active: true
        },
        preferredRecords: {
          title: 'preferredRecords',
          titleInfo: '',
          active: false
        }};

      // Set the default browse mode for the home page
      $scope.$watch('searchInfo', function (n, o) {
        if (angular.isDefined($scope.searchInfo.facet)) {
          if ($scope.searchInfo.facet['inspireThemes'].length > 0) {
            $scope.browse = 'inspire';
          } else if ($scope.searchInfo.facet['topicCats'].length > 0) {
            $scope.browse = 'topics';
          //} else if ($scope.searchInfo.facet['categories'].length > 0) {
          //  $scope.browse = 'cat';
          }
        }
      });

      $scope.$on('layerAddedFromContext', function(e,l) {
        var md = l.get('md');
        if(md) {
          var linkGroup = md.getLinkGroup(l);
          gnMap.feedLayerWithRelated(l,linkGroup);
        }
      });

      $scope.resultviewFns = {
        addMdLayerToMap: function (link, md) {
          var config = {
            uuid: md ? md.getUuid() : null,
            type: link.protocol.indexOf('WMTS') > -1 ? 'wmts' : 'wms',
            url: $filter('gnLocalized')(link.url) || link.url
          };

          if (angular.isObject(link.title)) {
            link.title = $filter('gnLocalized')(link.title);
          }
          if (angular.isObject(link.name)) {
            link.name = $filter('gnLocalized')(link.name);
          }

          if (link.name && link.name !== '') {
            config.name = link.name;
            config.group = link.group;
            // Related service return a property title for the name
          } else if (link.title) {
            config.name = link.title;
          }

          // if an external viewer is defined, use it here
          if (gnExternalViewer.isEnabled()) {
            gnExternalViewer.viewService({
              id: md ? md.getId() : null,
              uuid: config.uuid
            }, {
              type: config.type,
              url: config.url,
              name: config.name,
              title: link.title
            });
            return;
          }

          // This is probably only a service
          // Open the add service layer tab
          $location.path('map').search({
            add: encodeURIComponent(angular.toJson([config]))});
          return;
      },
        addAllMdLayersToMap: function (layers, md) {
          angular.forEach(layers, function (layer) {
            $scope.resultviewFns.addMdLayerToMap(layer, md);
          });
        },
        loadMap: function (map, md) {
          gnOwsContextService.loadContextFromUrl(map.url, viewerMap);
        }
      };

      // Share map loading functions
      gnViewerSettings.resultviewFns = $scope.resultviewFns;


      // Manage route at start and on $location change
      // depending on configuration
      if (!$location.path()) {
        var m = gnGlobalSettings.gnCfg.mods;
        $location.path(
          m.home.enabled ? '/home' :
          m.search.enabled ? '/search' :
          m.map.enabled ? '/map' : 'home'
        );
      }
      var setActiveTab = function() {
        $scope.activeTab = $location.path().
        match(/^(\/[a-zA-Z0-9]*)($|\/.*)/)[1];
      };

      setActiveTab();
      $scope.$on('$locationChangeSuccess', setActiveTab);

      $scope.activateTabs = function() {
        // activate tabs
        $('#tab-result-nav a').click(function (e) {
          e.preventDefault();
          $(this).tab('show');
        });
        // hide empty
        $('#tab-result-nav a').each(function() {
          if ($($(this).attr('href')).length === 0) {
            $(this).parent().hide();
          }
        });
        // show the first
        $('#tab-result-nav a:first').tab('show');
      };

      /**
       * Checks the metadata schema and if not Swedish schema,
       * confirms that the user wants to continue.
       *
       * @param {object} md  Metadata
       */
      $scope.editMetadata = function(md) {
        var schema = md['geonet:info'].schema;

        if (schema == 'iso19139') {
          if (!confirm($translate.instant('nonSweMetadata'))) {
            return;
          }
        }

        $window.open("catalog.edit#/metadata/" + md['geonet:info'].id, '_blank');
      };

      $scope.showMetadata = function(index, md, records) {

        gnMdView.feedMd(index, md, records);

        // construct full view url
        var mdUrl = 'md.format.xml?xsl=xsl-view&view=full-view-swe&uuid={{uuid}}'; // + md['geonet:info'].uuid;
        
        // set scope md
        $scope.md = md;

        // open modal dialog
        $('#metadata-popup').modal();

        gnMdFormatter.getFormatterUrl(mdUrl, $scope, md['geonet:info'].uuid).then(function(url) {
          $http.get(url).then(
            function(response) {
              var snippet = response.data.replace(
                  '<?xml version="1.0" encoding="UTF-8"?>', '');

              $('#gn-metadata-display').find('*').remove();

              // Compile against a new scope
              $scope.compileScope = $scope.$new();
              var content = $compile(snippet)($scope.compileScope);

              $('#gn-metadata-display').append(content);

              $scope.activateTabs();
            });
          });

      };

      $scope.fetchInitiativKeyword = function(md) {
        var imgPath = '../../catalog/views/sweden/images/noto.png';
        if(md) {
          var initiativKeyword = md.initiativKeyword;
          if(initiativKeyword) {
            var initiativKeywordString = initiativKeyword.toString();
            if(initiativKeywordString.indexOf('ppna data') > -1 ) { // Not using 'Ö' but just using word 'ppna data'. Has some issue with browsers. So keeping it simple.
              imgPath = '../../catalog/views/sweden/images/opendata.png';
            } else if(initiativKeywordString.indexOf('Geodatasamverkan') > -1) {
              imgPath = '../../catalog/views/sweden/images/geodatacooperation.png';
            }
          }
        }
        return imgPath;
      };

      var sortConfig = gnSearchSettings.sortBy.split('#');
      angular.extend($scope.searchObj, {
        advancedMode: false,
        from: 1,
        to: 30,
        selectionBucket: 's101',
        viewerMap: viewerMap,
        searchMap: searchMap,
        mapfieldOption: {
          relations: ['within_bbox']
        },
        hitsperpageValues: gnSearchSettings.hitsperpageValues,
        filters: gnSearchSettings.filters,
        defaultParams: {
          'facet.q': '',
          resultType: gnSearchSettings.facetsSummaryType || 'details',
          sortBy: sortConfig[0] || 'relevance',
          sortOrder: sortConfig[1] || ''
        },
        params: {
          'facet.q': gnSearchSettings.defaultSearchString || '',
          resultType: gnSearchSettings.facetsSummaryType || 'details',
          sortBy: sortConfig[0] || 'relevance',
          sortOrder: sortConfig[1] || ''
        },
        sortbyValues: gnSearchSettings.sortbyValues
      });
    }]);

    module.controller('SweLogoutController',
	  ['$scope', '$http',
	  function($scope, $http) {

		  $scope.logout = function() {
			  $http({method: 'GET',
	              url: '/AGLogout'

	              /*headers: {
	                'X-Ajax-call': true}*/})
	            .success(function(data) {
	             // Redirect to home page
	             window.location.href = 'catalog.search';
	           })
	            .error(function(data) {
	             // Show error message
	             alert('Error');
	           });
		  };
	  }]);

  /**
   * Controller for mail feedback popup.
   *
   */
  module.controller('SweMailController', [
    '$cookies', '$scope', '$http',
    function($cookies, $scope, $http) {
      $scope.feedbackResult = null;
      $scope.feedbackResultError = false;

      $scope.sendMail = function() {
        if ($scope.feedbackForm.$invalid) return;

        $http.post('../api/0.1/site/feedback-swe', null, {params: $scope.user})
            .then(function successCallback(response) {
              $scope.feedbackResult = response.data;
              $scope.feedbackResultError = false;

            }, function errorCallback(response) {
              $scope.feedbackResult = response.data;
              $scope.feedbackResultError = true;

            });
      };

      $scope.close = function() {
        // Cleanup and close the dialog
        $scope.user = {};
        $scope.feedbackResult = null;
        $scope.feedbackResultError = false;

        $scope.feedbackForm.$setPristine();
        $scope.feedbackForm.$setValidity();

        angular.element('#mail-popup').removeClass('show');
        $scope.$emit('body:class:remove', 'show-overlay');
      };
    }]);

  /**
   * Controller for help popup.
   *
   */
  module.controller('SweHelpController', [
    '$cookies', '$scope', '$http', '$rootScope', '$sce',
    function($cookies, $scope, $http, $rootScope, $sce) {

	  $rootScope.$on('openhelppopup', function (event, data) {
		  $scope.link = data;
		  });
	  $scope.trustSrc = function(link) {
		   return $sce.trustAsResourceUrl(link);
		};
      $scope.close = function() {
        // Cleanup and close the dialog
        angular.element('#help-popup').removeClass('show');
      };
    }]);



  /**
   * Controller for new metadata popup.
   *
   */
  module.controller('SweNewMetadataController', [
    '$cookies', '$scope', '$rootScope', '$http', '$window', 'gnSearchManagerService', 'gnMetadataManager',
    function($cookies, $scope, $rootScope, $http, $window, gnSearchManagerService, gnMetadataManager) {
      var dataTypesToExclude = ['staticMap', 'theme', 'place'];
      var defaultType = 'dataset';
      var unknownType = 'unknownType';
      var fullPrivileges = true;

      var init = function() {

        // Metadata creation could be on a template
        // or by duplicating an existing record
        var query = 'template=y';

          // TODO: Better handling of lots of templates
          gnSearchManagerService.search('qi@json?template=y' +
            '&fast=index&from=1&to=200&_schema=iso19139.swe').
          then(function(data) {

            $scope.mdList = data;
            $scope.hasTemplates = data.count != '0';

            var types = [];
            // TODO: A faster option, could be to rely on facet type
            // But it may not be available
            for (var i = 0; i < data.metadata.length; i++) {
              var type = data.metadata[i].type || unknownType;
              if (type instanceof Array) {
                for (var j = 0; j < type.length; j++) {
                  if ($.inArray(type[j], dataTypesToExclude) === -1 &&
                    $.inArray(type[j], types) === -1) {
                    types.push(type[j]);
                  }
                }
              } else if ($.inArray(type, dataTypesToExclude) === -1 &&
                $.inArray(type, types) === -1) {
                types.push(type);
              }
            }
            types.sort();
            $scope.mdTypes = types;

            // Select the default one or the first one
            if (defaultType &&
              $.inArray(defaultType, $scope.mdTypes) > -1) {
              $scope.getTemplateNamesByType(defaultType);
            } else if ($scope.mdTypes[0]) {
              $scope.getTemplateNamesByType($scope.mdTypes[0]);
            } else {
              // No templates available ?
            }
          });

      };

      /**
       * Get all the templates for a given type.
       * Will put this list into $scope.tpls variable.
       */
      $scope.getTemplateNamesByType = function(type) {
        var tpls = [];
        $scope.titleFilter = '';
        for (var i = 0; i < $scope.mdList.metadata.length; i++) {
          var mdType = $scope.mdList.metadata[i].type || unknownType;
          if (mdType instanceof Array) {
            tpls.push($scope.mdList.metadata[i]);

            //if (mdType.indexOf(type) >= 0) {
            //  tpls.push($scope.mdList.metadata[i]);
            //}
          } else if (mdType == type) {
            tpls.push($scope.mdList.metadata[i]);
          } else {
            tpls.push($scope.mdList.metadata[i]);
          }
        }

        // Sort template list
        function compare(a, b) {
          if (a.title < b.title)
            return -1;
          if (a.title > b.title)
            return 1;
          return 0;
        }
        tpls.sort(compare);

        $scope.tpls = tpls;
        $scope.activeType = type;
        $scope.setActiveTpl($scope.tpls[0]);
        return false;
      };

      $scope.setActiveTpl = function(tpl) {
        $scope.activeTpl = tpl;
      };

      $scope.createNewMetadata = function(isPublic) {
        var metadataUuid = '';

        var editorAppUrl = $window.location.origin +
            $window.location.pathname.replace('catalog.search', 'catalog.edit') + '#';

        return gnMetadataManager.create(
          $scope.activeTpl['geonet:info'].id,
          $scope.ownerGroup,
          isPublic || false,
          false,
          false,
          undefined,
          metadataUuid,
          editorAppUrl
        ).error(function(data) {
          $rootScope.$broadcast('StatusUpdated', {
            title: $translate('createMetadataError'),
            error: data.error,
            timeout: 0,
            type: 'danger'});
        });
      };

      $scope.close = function() {
        // Cleanup and close the dialog

        angular.element('#newmetadata-popup').removeClass('show');
        $scope.$emit('body:class:remove', 'show-overlay');
      };

      init();
    }]);


  /**
   * Controller for the filter panel.
   *
   */
  module.controller('SweFilterPanelController', ['$scope', '$filter', '$localStorage',
    function($scope, $filter, $localStorage) {

      $scope.advancedMode = false;

      // keys for topic categories translations
      $scope.topicCategories = ['farming', 'biota', 'boundaries',
        'climatologyMeteorologyAtmosphere', 'economy',
        'elevation', 'environment', 'geoscientificInformation', 'health',
        'imageryBaseMapsEarthCover', 'intelligenceMilitary', 'inlandWaters',
        'location', 'oceans', 'planningCadastre', 'society', 'structure',
        'transportation', 'utilitiesCommunication'];

      // Selected topic categories
      $scope.selectedTopicCategories = [];

      $scope.selectedExclusiveFilter = 'type';

      // Map with search criteria and search param related
      $scope.exclusiveFilterSeachParams = {
        'type': 'type',
        'map': 'dynamic',
        'download': 'download',
        'favorites': '_id'
      };

      /**
       * Toggles between exclusive filters.
       *
       * @param {String} param name used in the filter
       * @param {array} types
       */
      $scope.toggleExclusiveFilter = function(type, values) {
        // Exclusive filters act as radio buttons,
        // but can be disabled all
        if ($scope.selectedExclusiveFilter == type) {
          var paramName = $scope.exclusiveFilterSeachParams[type];
          $scope.searchObj.params[paramName] = '';
          $scope.selectedExclusiveFilter = '';
          $scope.triggerSearch();

          return;
        }

        $scope.selectedExclusiveFilter = type;

        // Clear the exclusive search filters
        Object.keys($scope.exclusiveFilterSeachParams).forEach(function(key) {
            var paramName = $scope.exclusiveFilterSeachParams[key];
            $scope.searchObj.params[paramName] = "";
        });

        if (type == 'favorites') {
          // Use an invalid value -- to manage the case no favorites are selected,
          // to don't display any metadata
          if ($localStorage.favoriteMetadata != undefined) {
            $scope.searchObj.params._id =
                ($scope.searchObj.params._id ? '' :
                    ($localStorage.favoriteMetadata.length > 0) ?
                        $localStorage.favoriteMetadata.join(' or ') : '--');
          } else {
            $scope.searchObj.params._id =
                ($scope.searchObj.params._id ? '' : '--');
          }
        } else {
          var paramName = $scope.exclusiveFilterSeachParams[type];
          $scope.searchObj.params[paramName] =
              (values instanceof Array)?values.join(' or '):values;
        }

        $scope.triggerSearch();
      };


      /**
       * Toggles a topic category selection.
       *
       * @param {string} topic
         */
      $scope.toggleTopicCategory = function(topic) {
        var pos = $scope.selectedTopicCategories.indexOf(topic);

        if (pos > -1) {
          $scope.selectedTopicCategories.splice(pos, 1);
        } else {
          $scope.selectedTopicCategories.push(topic);
        }

        $scope.searchObj.params.topicCat =
            $scope.selectedTopicCategories.join(' or ');
        $scope.triggerSearch();
      };


      /**
       * Unselects a topic category.
       *
       * @param {string} topic
         */
      $scope.unselectTopicCategory = function(topic) {
        var pos = $scope.selectedTopicCategories.indexOf(topic);

        if (pos > -1) {
          $scope.selectedTopicCategories.splice(pos, 1);
        }

        $scope.searchObj.params.topicCat =
            $scope.selectedTopicCategories.join(' or ');
        $scope.triggerSearch();
      };


      /**
       * Checks if a topic category is selected.
       *
       * @param {string} topic
       * @return {boolean}
         */
      $scope.isTopicCategorySelected = function(topic) {
        return ($scope.selectedTopicCategories.indexOf(topic) > -1);
      };


      /**
       * Unselects the resource date from.
       */
      $scope.unselectResourceDateFrom = function() {
        delete $scope.searchObj.params.resourceDateFrom;
        $scope.triggerSearch();
      };


      /**
       * Unselects the resource date to.
       */
      $scope.unselectResourceDateTo = function() {
        delete $scope.searchObj.params.resourceDateTo;
        $scope.triggerSearch();
      };


      /**
       * Unselects the geometry filter.
       */
      $scope.unselectGeoResources = function() {
        $scope.vectorLayer.getSource().clear();
        $scope.vectorLayerBM.getSource().clear();

        delete $scope.searchObj.params.geometry;
        delete $scope.searchObj.namesearch;
        $scope.triggerSearch();
      };

      $scope.translatedTopicCat = function(p) {
        return $filter('translate')(p);
      }

      /**
       * Clean search options to view all metadata.
       */
      $scope.viewAllMetadata = function() {

        $scope.selectedTopicCategories = [];
        $scope.selectedExclusiveFilter = 'type';
        $scope.searchObj.params.type =
            ['dataset', 'series'].join(' or ');

        delete $scope.searchObj.params.topicCat;
        delete $scope.searchObj.params.download;
        delete $scope.searchObj.params.dynamic;
        delete $scope.searchObj.params.any;
        delete $scope.searchObj.params._id;
        delete $scope.searchObj.params.resourceDateFrom;
        delete $scope.searchObj.params.resourceDateTo;
        delete $scope.searchObj.params.geometry;
        delete $scope.searchObj.namesearch;
        delete $scope.searchObj.params['facet.q'];
		delete $scope.searchObj.params.or;
        $scope.vectorLayer.getSource().clear();
        $scope.vectorLayerBM.getSource().clear();
        $scope.vectorLayer.unset("defaultTitle");
        $scope.vectorLayerBM.unset("defaultTitle");
        $scope.triggerSearch();
      };


      /**
       * Toggles the filter panel.
       */
      $scope.toggleFilterPanel = function() {
        var element = angular.element('.site-filter-cont');
        var filterSection = angular.element('.site-filter-result-cont');

        if (element.hasClass('open')) {
          element.removeClass('open');
          filterSection.removeClass('filter-is-open');
        } else {
          element.addClass('open');
          filterSection.addClass('filter-is-open');
        }
      };

      /**
       * Toggles the advance options panel.
       */
      $scope.toggleAdvancedOptions = function() {
        if ($scope.advancedMode) {
          angular.element('.filter-options-cont').removeClass('open');
          angular.element('.site-filter-cont').removeClass('advanced');
        } else {
          angular.element('.filter-options-cont').addClass('open');
          angular.element('.site-filter-cont').addClass('advanced');
        }

        $scope.advancedMode = !$scope.advancedMode;

        // clear filters
        $scope.viewAllMetadata();
      };

      /**
       * Closes the filter panel.
       */
      $scope.closeFilterPanel = function() {
        angular.element('.site-filter-cont').removeClass('open');
        angular.element('.site-filter-result-cont').removeClass('filter-is-open');

        $scope.open = false;
      };
    }]);

  /**
   * Controller for geo suggestions.
   *
   */
  module.controller('SweGeoSuggestionsController', ['$scope', '$http',
    function($scope, $http) {
    $scope.getNameSearch = function(val) {
      var posturl = 'https://www.geodata.se/NameWebService/search';
	  val = encodeURIComponent(val);
      var params = {
        'searchstring': val,
        'callback': 'JSON_CALLBACK'
      };
      return $http({
        method: 'JSONP',
        url: posturl,
        params: params
      }).then(function(res) {
        var data = res.data;
        var status = res.status;
        var headers = res.headers;
        var config = res.config;
        var statusText = res.statusText;


        return data;
      });
    };
  }]);

 /**
   * Controller for draw polygon using wfs getfeature.
   *
   */
  module.controller('SweGeoWfsGetFeatureController', ['$scope', '$http', 'gnSearchSettings', 'gnMap', 'gnConfig',
    function($scope, $http, gnSearchSettings, gnMap, gnConfig) {
     /**
       * Displays the polygon in map.
       *
       */
      $scope.drawPolygonInMap = function() {
        //var namesearch = $scope.searchObj.params.namesearch;
        var namesearch = $scope.searchObj.namesearch;
        var coordinates = namesearch.Coordinates;
        var geoJson = new ol.format.GeoJSON();
        if (coordinates) {
          var proj = $scope.searchObj.searchMap.getView().getProjection();

          var xy0 = coordinates[0];
          var xy1 = coordinates[1];
          var extent = []; // geoBox=10.59|55.15|24.18|69.05
          extent.push(parseFloat(xy0.X), parseFloat(xy0.Y),
            parseFloat(xy1.X), parseFloat(xy1.Y));
          //To transform projection for metadata list based on polygon drawn
          proj4.defs("EPSG:3006","+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs");
          //proj4.defs("EPSG:4258","+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs");
          var geom = gnMap.reprojExtent(extent , 'EPSG:3006', 'EPSG:4326');
          var geom_wkt = "POLYGON((" + geom[0] + " " + geom[1] + "," + geom[2] + " " + geom[1] + "," + geom[2] + " " + geom[3] + "," + geom[2] + " " + geom[1] + "," + geom[0] + " " + geom[1] + "))";
          $scope.searchObj.params.geometry = geom_wkt;
          var feature = new ol.Feature();
          //var feature = gnMap.getPolygonFeature(namesearch, $scope.searchObj.searchMap.getView().getProjection());

          // Build multipolygon from the set of bboxes
          geometry = new ol.geom.MultiPolygon(null);
          feature.setGeometry(geometry);

          //$scope.searchObj.searchMap.addLayer($scope.vectorLayer);
           var wfsurl = gnConfig['map.wfsServer.url'];
           var CQL_FILTER = "Name='" + encodeURIComponent(namesearch.Name) + "'";
            var params = {
              'request': 'GetFeature',
              'service': 'WFS',
              'srs': 'EPSG:3006',
              'version': '1.0.0',
              'typeName': gnConfig['map.wfsServer.workspace'] + ":" + gnConfig['map.wfsServer.layer'],
              'outputFormat': 'json',
              'callback': 'JSON_CALLBACK',
              'CQL_FILTER': CQL_FILTER
            };
            return $http({
              method: 'POST',
              url: wfsurl,
              params: params
            }).then(function(result) {
              $scope.vectorLayer.getSource().clear();
              //$scope.searchObj.viewerMap.getLayers().getArray()[1].getSource().clear()
              $scope.vectorLayer.getSource().addFeatures(geoJson.readFeatures(result.data));
              $scope.searchObj.searchMap.getView().setCenter([extent[0],extent[1]]);
              $scope.vectorLayerBM.getSource().clear();
              $scope.vectorLayerBM.getSource().addFeatures(geoJson.readFeatures(result.data));
              $scope.searchObj.searchMap.getView().fit(extent, $scope.searchObj.searchMap.getSize());
              $scope.searchObj.viewerMap.getView().fit(extent, $scope.searchObj.viewerMap.getSize());
              $scope.triggerSearch();
            });

          return true; // always return true so search query is fired.

        } else {
          return false; // always return false if cooridinates are absent. Not sure if we shall still return true.
        }
    };


  }]);

  module.controller('SweGeoFreeHandPolygonController', ['$scope', '$http', '$timeout', 'gnSearchSettings', 'gnMap',
    function($scope, $http, $timeout, gnSearchSettings, gnMap) {
      $scope.drawFreeHandPolygonInMap = function(){

        $scope.showMapPanel();

        var features = new ol.Collection();
        draw = new ol.interaction.Draw({
          features: features,
          type: 'Polygon'
        });

        $scope.searchObj.viewerMap.addInteraction(draw);

        draw.on('drawstart', function (e) {
          $scope.vectorLayer.getSource().clear();
          $scope.vectorLayerBM.getSource().clear();
        });

        draw.on('drawend', function (e) {
          var polygonFeature = e.feature;

          delete $scope.searchObj.namesearch;

          $scope.vectorLayer.getSource().clear();
          $scope.vectorLayer.getSource().addFeature(polygonFeature.clone());

          $scope.vectorLayerBM.getSource().clear();
          $scope.vectorLayerBM.getSource().addFeature(polygonFeature.clone());

          proj4.defs("EPSG:3006","+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs");

          var geom = polygonFeature.getGeometry().clone().transform('EPSG:3006', 'EPSG:4326');
          var format = new ol.format.WKT();
          var geom_wkt =format.writeGeometry(geom);

          $scope.hideMapPanel();

          $scope.searchObj.params.geometry = geom_wkt;
          $scope.triggerSearch();

          $timeout(function() {
            $scope.searchObj.viewerMap.removeInteraction(draw);
          }, 500);

        });
      }

    }]);

  /**
   * orderByTranslated Filter
   * Sort ng-options or ng-repeat by translated values
   * @example
   *   ng-repeat="scheme in data.schemes |
   *    orderByTranslated:'storage__':'collectionName'"
   * @param  {Array|Object} array or hash
   * @param  {String} i18nKeyPrefix
   * @param  {String} objKey (needed if hash)
   * @return {Array}
   */
  module.filter('orderByTranslated', ['$translate', '$filter',
    function($translate, $filter) {
      return function(array, i18nKeyPrefix, objKey) {
        var result = [];
        var translated = [];
        angular.forEach(array, function(value) {
          var i18nKeySuffix = objKey ? value[objKey] : value;
          translated.push({
            key: value,
            label: $translate.instant(i18nKeyPrefix + i18nKeySuffix)
          });
        });
        angular.forEach($filter('orderBy')(translated, 'label'),
            function(sortedObject) {
              result.push(sortedObject.key);
            }
        );
        return result;
      };
    }]);

  //To restrict GFI only when map are maximized
  module.factory("is_map_maximized", function() {
    return {data: false};
});

  //
    module.factory('exampleResize', function(){
    return{
      onResize: function($rootScope, $scope){
        cookieCheck = $rootScope.showCookieWarning;
        var $b = angular.element(document).find('body');
        is_full_view_map = ($b.hasClass('full-map-view')) ? true : false;
        is_small_view_map = ($b.hasClass('small-map-view')) ? true : false;
        if(is_small_view_map || is_full_view_map){
              $scope.$emit('body:class:remove', 'geodata-examples-collapsed-with-cookie-alert');
              $scope.$emit('body:class:remove', 'geodata-examples-expanded-with-cookie-alert');
              $scope.$emit('body:class:remove', 'geodata-examples-expanded-larger-with-cookie-alert');
              $scope.$emit('body:class:remove', 'geodata-examples-collapsed-without-cookie-alert');
              $scope.$emit('body:class:remove', 'geodata-examples-expanded-without-cookie-alert');
              $scope.$emit('body:class:remove', 'geodata-examples-expanded-larger-without-cookie-alert');
          if(cookieCheck){
             if($scope.collapsed){
              $scope.$emit('body:class:add', 'geodata-examples-collapsed-with-cookie-alert');
          }
              else{
                 if($scope.actual_height < 60){
                  $scope.$emit('body:class:add', 'geodata-examples-collapsed-with-cookie-alert');
                }
                else if($scope.actual_height < 250){
                  $scope.$emit('body:class:add', 'geodata-examples-expanded-with-cookie-alert');
                }
                else{
                  $scope.$emit('body:class:add', 'geodata-examples-expanded-larger-with-cookie-alert');
                }
            }
          }
          else{
              if($scope.collapsed){
                $scope.$emit('body:class:add', 'geodata-examples-collapsed-without-cookie-alert');
            }
              else{
                if($scope.actual_height < 60){
                  $scope.$emit('body:class:add', 'geodata-examples-collapsed-without-cookie-alert');
                }
                else if($scope.actual_height < 250){
                  $scope.$emit('body:class:add', 'geodata-examples-expanded-without-cookie-alert');
                }
                else{
                  $scope.$emit('body:class:add', 'geodata-examples-expanded-larger-without-cookie-alert');
                }
              }
          }
        }

      }
    }

  });

})();
