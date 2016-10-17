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
  goog.provide('gn_predefinedmaps_controller');

  var module = angular.module('gn_predefinedmaps_controller',
    []);


  /**
   * GnPredefinedMapsController provides all necessary operations
   * to manage predefined maps.
   */
  module.controller('GnPredefinedMapsController', [
    '$scope', '$routeParams', '$http', '$rootScope',
    '$translate', '$timeout',
    function($scope, $routeParams, $http, $rootScope,
             $translate, $timeout) {

      $scope.predefinedMaps = null;
      $scope.predefinedMapSelected = {id: $routeParams.mapId};

      $scope.predefinedMapUpdated = false;

      $scope.uploadScope = angular.element('#predefinedmap-file').scope();

      /** Upload management */
      var uploadImgDone = function(evt, data) {
        $scope.importing = false;
        $scope.unselectPredefinedMap();
        loadPredefinedMaps();
      };
      var uploadImgError = function(evt, data, o) {
        $scope.importing = false;

        $rootScope.$broadcast('StatusUpdated', {
          title: $translate('predefinedMapUpdateError'),
          error: data.jqXHR.responseJSON,
          timeout: 0,
          type: 'danger'});
      };

      // upload directive options
      $scope.mdImportUploadOptions = {
        autoUpload: false,
        done: uploadImgDone,
        fail: uploadImgError
      };


      $scope.selectPredefinedMap = function(c) {
        $scope.action = '../api/0.1/predefinedmaps/' + c.id;
        $scope.predefinedMapUpdated = false;
        $scope.predefinedMapSelected = c;
        $timeout(function() {
          $('#predefinedmapname').focus();
        }, 100);
      };


      /**
       * Delete a predefined map
       */
      $scope.deletePredefinedMap = function(id) {
        $http.delete('../api/0.1/predefinedmaps/' +
          id)
          .success(function(data) {
            $scope.unselectPredefinedMap();
            loadPredefinedMaps();
          })
          .error(function(data) {
            $rootScope.$broadcast('StatusUpdated', {
              title: $translate('predefinedMapDeleteError'),
              error: data,
              timeout: 0,
              type: 'danger'});
          });
      };

      /**
       * Save a predefined map
       */
      $scope.savePredefinedMap = function(id) {
        $scope.uploadScope.submit();

        /*$http.post('../api/0.1/predefinedmaps/' + id,
            $scope.predefinedMapSelected)
          .success(function(data) {
            $scope.unselectPredefinedMap();
            loadPredefinedMaps();
            $rootScope.$broadcast('StatusUpdated', {
              msg: $translate('predefinedMapUpdated'),
              timeout: 2,
              type: 'success'});
          })
          .error(function(data) {
            $rootScope.$broadcast('StatusUpdated', {
              title: $translate('predefinedMapUpdateError'),
              error: data,
              timeout: 0,
              type: 'danger'});
          });*/
      };

      $scope.addPredefinedMap = function() {
        var position = ( $scope.predefinedMaps?
          $scope.predefinedMaps.length + 1: 1);
        $scope.unselectPredefinedMap();
        $scope.predefinedMapSelected = {
          id: '',
          name: '',
          position: position,
          description: '',
          map: '',
          enabled: true,
          image: ''
        };

        $scope.action = '../api/0.1/predefinedmaps';

        $timeout(function() {
          $('#predefinedmapname').focus();
        }, 100);
      };

      $scope.unselectPredefinedMap = function() {
        $scope.predefinedMapSelected = {};
      };
      $scope.updatingPredefinedMap= function() {
        $scope.predefinedMapUpdated = true;
      };


      $scope.deleteImage = function() {
        $scope.predefinedMapSelected.image = null;
      };

      function loadPredefinedMaps() {
        $http.get('../api/0.1/predefinedmaps/').success(function(data) {
          $scope.predefinedMaps = data;
        }).error(function(data) {
          // TODO
        });
      }

      loadPredefinedMaps();
    }]);

})();
