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


  module.controller('SweEditorTableController', ['$scope', '$document',
    '$compile', function($scope, $document, $compile) {

      // Selected row index in the table
      $scope.selectedRowIndex = null;
      // Selected row in the table
      $scope.selectedRow = null;
      // Row info used in the edit dialogs
      $scope.editRow = null;


      $scope.init = function(rows, rowsModel, xmlSnippet, parent, 
                             name, dialog, title) {
        $scope.rows = rows;
        $scope.rowsModel = rowsModel;
        $scope.xmlSnippet = xmlSnippet;
        $scope.parent = parent;
        $scope.name = name;
        $scope.dialog = dialog;
        $scope.title = title;
      };

      /**
     * Selects a row in the table.
     *
     * @param {number} index Row index in the table.
       */
      $scope.setClickedRow = function(index) {
        $scope.selectedRowIndex = index;
        $scope.selectedRow = $scope.rows[index];
      };

      /**
     * Shows the edit dialog for the selected row.
     */
      $scope.editSelectedRow = function() {
        if ($scope.selectedRow == null) return;

        $scope.mode = 'edit';
        $scope.editRow = angular.copy($scope.selectedRow);

        $($scope.dialog).modal('show');
      };

      /**
     * Shows the new dialog to add a new row.
     */
      $scope.addRow = function() {
        $scope.mode = 'add';
        $scope.editRow = {ref: ''};

        $($scope.dialog).modal('show');
      };

      /**
     * Saves the current row edit.
     */
      $scope.saveRow = function() {
        // TODO: Move to a custom controller for the edit dialog
        $scope.editRow.date = document.getElementsByName('datevalue')[0].value;

        if ($scope.mode == 'add') {
          if ($scope.xmlSnippet != '') {
            var content = $compile($scope.xmlSnippet)($scope);

            $scope.editRow.xmlSnippet = content[0].innerHTML;
          }

          var template = $scope.xmlSnippet;
          for (var property in $scope.editRow) {
            if ($scope.editRow.hasOwnProperty(property)) {
              template = template.replace('{{editRow.' + property + '}}',
                  $scope.editRow[property]);
            }
          }
          $scope.editRow.xmlSnippet = template;

          $scope.selectedRow = angular.copy($scope.editRow);
          $scope.rows.push($scope.selectedRow);
        } else {
          $scope.selectedRow = angular.copy($scope.editRow);
          $scope.rows[$scope.selectedRowIndex] = $scope.selectedRow;
        }


        // TODO: Check, removes the element added
        //$scope.save(true);

        $($scope.dialog).modal('hide');
      };

      /**
     * Removes a row from the table and saves
     * the editor form to update the metadata.
     */
      $scope.removeRow = function() {
        $scope.remove($scope.selectedRow.ref, $scope.parent);
        $scope.rows.splice($scope.selectedRowIndex, 1);
        $scope.selectedRow = null;

        // TODO: Check, doesn't remove the element added
        //$scope.save(true);
      };

      /**
     * Filter to check if an item exists in the
     * metadata (not empty ref).
     */
      $scope.isExistingItem = function(item) {
        return item.ref != '';
      };

      /**
     * Filter to check if an item has to be added to the
     * metadata (empty ref).
     */
      $scope.isNewItem = function(item) {
        return item.ref === '';
      };

      /**
     * Cancels the edit of the current row, closing the edit form.
     */
      $scope.cancel = function() {
        $($scope.dialog).modal('hide');
      };

    }]);
})();
