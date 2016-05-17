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

  goog.provide('gn_search_swe');






  goog.require('cookie_warning');
  goog.require('gn_related_directive');
  goog.require('gn_resultsview');
  goog.require('gn_search');
  goog.require('swe_directives');
  goog.require('swe_search_config');

  var module = angular.module('gn_search_swe', [
    'gn_related_directive', 'gn_search',
    'gn_resultsview', 'cookie_warning',
    'swe_search_config', 'swe_directives']);

  module.controller('gnsSwe', [
    '$scope',
    '$location',
    'suggestService',
    '$http',
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
    function($scope, $location, suggestService, $http, $window, $translate,
             gnUtilityService, gnSearchSettings, gnViewerSettings,
             gnMap, gnMdView, mdView, gnWmsQueue,
             gnSearchLocation, gnOwsContextService,
             hotkeys, gnGlobalSettings) {

      var viewerMap = gnSearchSettings.viewerMap;
      var searchMap = gnSearchSettings.searchMap;

      $scope.viewMode = 'full';

      $scope.modelOptions = angular.copy(gnGlobalSettings.modelOptions);
      $scope.modelOptionsForm = angular.copy(gnGlobalSettings.modelOptions);
      $scope.gnWmsQueue = gnWmsQueue;
      $scope.$location = $location;
      $scope.activeTab = '/home';
      $scope.resultTemplate = gnSearchSettings.resultTemplate;
      $scope.facetsSummaryType = gnSearchSettings.facetsSummaryType;
      $scope.location = gnSearchLocation;
      $scope.toggleMap = function() {
        $(searchMap.getTargetElement()).toggle();
      };
      hotkeys.bindTo($scope)
          .add({
            combo: 'h',
            description: $translate('hotkeyHome'),
            callback: function(event) {
              $location.path('/home');
            }
          }).add({
            combo: 't',
            description: $translate('hotkeyFocusToSearch'),
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
            description: $translate('hotkeySearchTheCatalog'),
            allowIn: 'INPUT',
            callback: function() {
              $location.search('tab=search');
            }
            //}).add({
            //  combo: 'r',
            //  description: $translate('hotkeyResetSearch'),
            //  allowIn: 'INPUT',
            //  callback: function () {
            //    $scope.resetSearch();
            //  }
          }).add({
            combo: 'm',
            description: $translate('hotkeyMap'),
            callback: function(event) {
              $location.path('/map');
            }
          });


      // TODO: Previous record should be stored on the client side
      $scope.mdView = mdView;
      gnMdView.initMdView();
      $scope.goToSearch = function(any) {
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
      $scope.openRecord = function(index, md, records) {
        gnMdView.feedMd(index, md, records);
      };

      $scope.closeRecord = function() {
        gnMdView.removeLocationUuid();
      };
      $scope.nextRecord = function() {
        // TODO: When last record of page reached, go to next page...
        $scope.openRecord(mdView.current.index + 1);
      };
      $scope.previousRecord = function() {
        $scope.openRecord(mdView.current.index - 1);
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
      $scope.$watch('searchInfo', function() {
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

      $scope.resultviewFns = {
        addMdLayerToMap: function(link, md) {

          if (gnMap.isLayerInMap(viewerMap,
              link.name, link.url)) {
            return;
          }
          gnMap.addWmsFromScratch(viewerMap, link.url, link.name, false, md);
        },
        addAllMdLayersToMap: function(layers, md) {
          angular.forEach(layers, function(layer) {
            $scope.resultviewFns.addMdLayerToMap(layer, md);
          });
        },
        loadMap: function(map, md) {
          gnOwsContextService.loadContextFromUrl(map.url, viewerMap);
        }
      };

      // Manage route at start and on $location change
      if (!$location.path()) {
        $location.path('/home');
      }
      $scope.activeTab = $location.path().
          match(/^(\/[a-zA-Z0-9]*)($|\/.*)/)[1];


      $scope.showMetadata = function(index, md, records) {
        angular.element('.geodata-row-popup').addClass('show');
        $scope.$emit('body:class:add', 'show-overlay');
        gnMdView.feedMd(index, md, records);
      };

      /**
       * Show full view results.
       */
      $scope.setFullViewResults = function() {
        angular.element('.geo-data-row').removeClass('compact-view');
        angular.element('.detail-view').addClass('active');
        angular.element('.compact-view').removeClass('active');
        $scope.viewMode = 'full';
      };

      /**
       * Show compact view results.
       */
      $scope.setCompactViewResults = function() {
        angular.element('.geo-data-row').addClass('compact-view');
        angular.element('.compact-view').addClass('active');
        angular.element('.detail-view').removeClass('active');
        $scope.viewMode = 'compact';
      };

      /**
       * Show map panel.
       */
      $scope.showMapPanel = function() {
        angular.element('.floating-map-cont').hide();
        $scope.$emit('body:class:add', 'small-map-view');
      };

      /**
       * Hide map panel.
       */
      $scope.hideMapPanel = function() {
        angular.element('.floating-map-cont').show();
        $scope.$emit('body:class:remove', 'small-map-view');
        $scope.$emit('body:class:remove', 'full-map-view');
        $scope.$emit('body:class:remove', 'medium-map-view');
      };

      $scope.resizeMapPanel = function() {
        var $b = angular.element(document).find('body');
        window_width = angular.element($window).width(),
        $map_data_list_cont = angular.element('.map-data-list-cont'),
        is_side_data_bar_open =
            ($map_data_list_cont.hasClass('open')) ? true : false,
        is_full_view_map = ($b.hasClass('full-map-view')) ? true : false,
        $data_list_cont = angular.element('.data-list-cont'),
        $map_cont = angular.element('.map-cont'),
        $obj = angular.element('#map-panel-resize');

        if (is_full_view_map) {
          if (is_side_data_bar_open) {
            $scope.$emit('body:class:remove', 'full-map-view');
            $scope.$emit('body:class:add', 'medium-map-view');
          } else {
            $scope.$emit('body:class:remove', 'full-map-view');
            $scope.$emit('body:class:add', 'small-map-view');
          }

          $obj.removeClass('small').addClass('full');
        } else {
          $scope.$emit('body:class:remove', 'medium-map-view');
          $scope.$emit('body:class:remove', 'small-map-view');
          $scope.$emit('body:class:add', 'full-map-view');

          if (is_side_data_bar_open) {
            $map_cont.css({
              width: (window_width - $data_list_cont.width())
            });
          } else {
            $map_cont.css({
              width: window_width
            });
          }
          $obj.removeClass('full').addClass('small');
        }
        return false;
      };

      $scope.$on('$locationChangeSuccess', function(next, current) {
        $scope.activeTab = $location.path().
            match(/^(\/[a-zA-Z0-9]*)($|\/.*)/)[1];

        if (gnSearchLocation.isSearch() && (!angular.isArray(
            searchMap.getSize()) || searchMap.getSize()[0] < 0)) {
          setTimeout(function() {
            searchMap.updateSize();

            // TODO: load custom context to the search map
            //gnOwsContextService.loadContextFromUrl(
            //  gnViewerSettings.defaultContext,
            //  searchMap);

          }, 0);
        }
        if (gnSearchLocation.isMap() && (!angular.isArray(
            viewerMap.getSize()) || viewerMap.getSize().indexOf(0) >= 0)) {
          setTimeout(function() {
            viewerMap.updateSize();
          }, 0);
        }
      });

      angular.extend($scope.searchObj, {
        advancedMode: false,
        from: 1,
        to: 30,
        viewerMap: viewerMap,
        searchMap: searchMap,
        mapfieldOption: {
          relations: ['within']
        },
        defaultParams: {
          'facet.q': '',
          resultType: gnSearchSettings.facetsSummaryType || 'details'
        },
        params: {
          'facet.q': '',
          resultType: gnSearchSettings.facetsSummaryType || 'details'
        }
      }, gnSearchSettings.sortbyDefault);

    }]);

  /**
   * Controller for the login page popup.
   */
  module.controller('SweLoginController',
      ['$scope', '$http', '$rootScope', '$translate',
       '$location', '$window', '$timeout',
       'gnUtilityService', 'gnConfig',
       function($scope, $http, $rootScope, $translate,
               $location, $window, $timeout,
               gnUtilityService, gnConfig) {
         $scope.formAction = '../../j_spring_security_check#' +
          $location.path();

         $scope.formData = {};

         $scope.redirectUrl = gnUtilityService.getUrlParameter('redirect');
         $scope.signinFailure = gnUtilityService.getUrlParameter('failure');
         $scope.gnConfig = gnConfig;

         $scope.mode = 'login';
         $scope.usernameToRemind = '';
         $scope.errorForgotPassword = '';

         // TODO: https://github.com/angular/angular.js/issues/1460
         // Browser autofill does not work properly
         $timeout(function() {
           $('input[data-ng-model], select[data-ng-model]').each(function() {
             angular.element(this).controller('ngModel')
              .$setViewValue($(this).val());
           });
         }, 300);

         /**
         * Ajax login.
         */
         $scope.login = function() {

           $http({method: 'POST',
              url: '../../j_spring_security_check',
              data: $.param($scope.formData),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Ajax-call': true}})
            .success(function(data) {
              // Redirect to home page
              window.location.href = '../../catalog.search?view=swe';
            })
            .error(function(data) {
              // Show error message
              alert('Error');
            });
         };
       }]);


  /**
   * Controller for the landing page popup.
   *
   */
  module.controller('SweLandingPageWarningController', [
    '$cookies', '$scope',
    function($cookies, $scope) {

      $scope.hideLandingPage = true;

      $scope.init = function() {
        var hiddenLandingPage = window.localStorage.getItem('hideLandingPage');

        if (hiddenLandingPage) {
          angular.element('#landing-popup').removeClass('show');
        } else {
          angular.element('#landing-popup').addClass('show');
          $scope.$emit('body:class:add', 'show-overlay');
        }
      };

      $scope.close = function() {
        if ($scope.hideLandingPage) {
          window.localStorage.setItem('hideLandingPage', true);
        }
        angular.element('#landing-popup').removeClass('show');
        $scope.$emit('body:class:remove', 'show-overlay');
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

        $http.post('../api/0.1/site/feedback', null, {params: $scope.user})
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
   * Controller for the filter panel.
   *
   */
  module.controller('SweFilterPanelController', ['$scope',
    function($scope) {

      $scope.open = false;
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

      $scope.unselectTopicCategory = function(topic) {
        var pos = $scope.selectedTopicCategories.indexOf(topic);

        if (pos > -1) {
          $scope.selectedTopicCategories.splice(pos, 1);
        }

        $scope.searchObj.params.topicCat =
            $scope.selectedTopicCategories.join(' or ');
        $scope.triggerSearch();
      };

      $scope.isTopicCategorySelected = function(topic) {
        return ($scope.selectedTopicCategories.indexOf(topic) > -1);
      };

      $scope.toggleMapResources = function() {
        $scope.searchObj.params.dynamic =
            ($scope.searchObj.params.dynamic == 'true' ? '' : 'true');
        $scope.triggerSearch();
      };

      $scope.unselectMapResources = function() {
        delete $scope.searchObj.params.dynamic;
        $scope.triggerSearch();
      };

      $scope.toggleDownloadResources = function() {
        $scope.searchObj.params.download =
            ($scope.searchObj.params.download == 'true' ? '' : 'true');
        $scope.triggerSearch();
      };

      $scope.unselectDownloadResources = function() {
        delete $scope.searchObj.params.download;
        $scope.triggerSearch();
      };

      $scope.viewAllMetadata = function() {
        // Clean search options
        $scope.selectedTopicCategories = [];
        delete $scope.searchObj.params.topicCat;
        delete $scope.searchObj.params.download;
        delete $scope.searchObj.params.dynamic;
        delete $scope.searchObj.params.any;

        $scope.triggerSearch();
      };

      $scope.toggleFilterPanel = function() {
        if ($scope.open) {
          angular.element('.site-filter-cont').removeClass('open');
        } else {
          angular.element('.site-filter-cont').addClass('open');
        }

        $scope.open = !$scope.open;
      };

      $scope.toggleAdvancedOptions = function() {
        if ($scope.advancedMode) {
          angular.element('.filter-options-cont').removeClass('open');
          angular.element('.site-filter-cont').removeClass('advanced');
        } else {
          angular.element('.filter-options-cont').addClass('open');
          angular.element('.site-filter-cont').addClass('advanced');
        }

        $scope.advancedMode = !$scope.advancedMode;
      };


      $scope.closeFilterPanel = function() {
        angular.element('.site-filter-cont').removeClass('open');

        $scope.open = false;
      };
    }]);

  /**
  * Controller for the image filter panel.
  *
  */
  module.controller('SweFilterController', ['$scope', function($scope) {
    $scope.hovering = false;
    // replace prefined queries with a service returning the possible queries
    $scope.predefinedQueries = [{
          image: 'http://lorempixel.com/210/125/nature/?id=1',
          tooltip: 'Filter 1',
          text: 'Filter 1',
          query: 'Filter Query 1'
    }, {
          image: 'http://lorempixel.com/210/125/nature/?id=2',
          tooltip: 'Filter 2',
          text: 'Filter 2',
          query: 'Filter Query 2'
    }, {
          image: 'http://lorempixel.com/210/125/nature/?id=3',
          tooltip: 'Filter 3',
          text: 'Filter 3',
          query: 'Filter Query 3'
    }, {
          image: 'http://lorempixel.com/210/125/nature/?id=4',
          tooltip: 'Filter 4',
          text: 'Filter 4',
          query: 'Filter Query 4'
    }];
    $scope.doFilter = function(query) {
          window.alert(query.query);
    };
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
})();
