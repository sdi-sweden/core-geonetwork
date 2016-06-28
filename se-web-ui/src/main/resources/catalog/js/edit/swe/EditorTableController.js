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
  goog.provide('swe_editor_table_controller');

  var module = angular.module('swe_editor_table_controller',
    []);

  module.controller('SweEditorTableController', ['$scope', '$document', function($scope, $document) {
    $scope.selectedRowIndex = null;
    $scope.selectedRow = null;


    $scope.init = function(rows, parent, dialog) {
      $scope.rows= rows;
      $scope.parent = parent;
      $scope.dialog = dialog;
    };

    $scope.setClickedRow = function(index){
      $scope.selectedRowIndex = index;
      $scope.selectedRow = $scope.rows[index];
    };

    $scope.editRow = function(){
      $scope.mode = 'edit';
      $($scope.dialog).modal('show');
    };

    $scope.addRow = function(){

      $scope.mode = 'add';
      $scope.selectedRow = {ref: '', date: '', datetype: ''};

      $($scope.dialog).modal('show');
    };

    $scope.saveRow = function(){
      $scope.selectedRow.date = document.getElementsByName("datevalue")[0].value;

      if ($scope.mode == 'add') {
        $scope.selectedRow.xmlSnippet = "<gmd:date xmlns:gmd=\"http://www.isotc211.org/2005/gmd\">" +
          "<gmd:CI_Date>" +
        "<gmd:date>" +
        "<gco:Date xmlns:gco=\"http://www.isotc211.org/2005/gco\">" + $scope.selectedRow.date + "</gco:Date>" +
        "</gmd:date>" +
        "<gmd:dateType>" +
        "<gmd:CI_DateTypeCode codeListValue=\"" + $scope.selectedRow.datetype + "\"" +
        " codeList=\"http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode\"/>" +
        "  </gmd:dateType>" +
        "</gmd:CI_Date>" +
        "</gmd:date>";

        $scope.rows.push($scope.selectedRow);
        // TODO: Check, removes the element added
        //$scope.save(true);
      }


      // Update the hidden field for the date
      //var id = "#_" + $scope.selectedRow.refdate;
      //var el = angular.element(id);
      //el.val($scope.selectedRow.date);

      // Update the hidden field for the date type
      //id = "#_" + $scope.selectedRow.refdatetype + "_codeListValue";
      //var el = angular.element(id);
      //el.val($scope.selectedRow.datetype);

      $($scope.dialog).modal('hide');
    };

    $scope.removeRow = function() {
      $scope.remove($scope.selectedRow.ref, $scope.parent);
      $scope.rows.splice( $scope.selectedRowIndex, 1 );
      $scope.selectedRow = null;
    };

    $scope.isExistingItem = function (item) {
      return item.ref != '';
    };

    $scope.isNewItem = function (item) {
      return item.ref === '';
    };

    $scope.cancel = function() {
      $($scope.dialog).modal('hide');
    }

  }]);


  module.directive('SweDateDialog', [
    function() {
      return {
        restrict: 'A',
        link: function(scope, elem) {
          alert("hi");
        }
      };
    }
  ]);
})();
