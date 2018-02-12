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
    '$compile', 'gnHttp', 'Metadata', function($scope, $document, $compile, gnHttp, Metadata) {

      // Selected row index in the table
      $scope.selectedRowIndex = null;
      // Selected row in the table
      $scope.selectedRow = null;
      // Row info used in the edit dialogs
      $scope.editRow = null;


      $scope.init = function(rows, rowsModel, xmlSnippet, parent,
                             name, dialog, title, mandatory, tooltip, mdType) {
        $scope.rows = rows;
        $scope.rowsModel = rowsModel;
        $scope.xmlSnippet = xmlSnippet;
        $scope.parent = parent;
        $scope.name = name;
        $scope.dialog = dialog;
        $scope.title = title;
        $scope.mandatory = mandatory;
        $scope.tooltip = tooltip;
        console.log("mdType:" + mdType);
        $scope.mdType = mdType;

		//$scope.organisationNames = null;
		//if(name === 'distributorContact' || name === 'contact' || name === 'pointOfContact') {
		if(name === 'pointOfContact' || name === 'contact' || name === 'distributorContact') {
			var userIdInScope = $scope.user.id;
			var userGroupArray = [];
			var userGrpUrl = '../api/0.1/users/' + userIdInScope + '/groups';
			gnHttp.callService(userGrpUrl).success(function(data) {
				if(data) {
					for(var prop in data) {
						var node = data[prop];
						if(node) {
							var idNode = node.id;
							if(idNode) {
								var userId = idNode.userId + ''; // userId fetch is number i.e typeof number
								if(userId === userIdInScope) { // userIdInScope is string i.e typeof string
									var groupId = idNode.groupId;
									if(userGroupArray.indexOf(groupId) === -1) {
										userGroupArray.push(groupId);
									}
								}
							}
						}
					}
					// Now call "q" service.
					$scope.organisationNames = [];
					$scope.showResourceContactDD = true;
					var params = [];
					params['resultType'] = 'swe-details';
					params['fast'] = 'index';
					params['_content_type'] = 'json';
					params['buildSummary'] = 'false';
					for(var prop in userGroupArray) {
						params['_groupOwner'] = userGroupArray[prop]; // Populate groupOwners here
					}
					gnHttp.callService('search',params).success(function(data) {
						var organisationsArray = [];
						var uiMetaDataArray = [];
						if(data && data.metadata) {
							if(data.metadata.length) {
								for(var i = 0; i < data.metadata.length; i++) {
									uiMetaDataArray.push(data.metadata[i]);
								}
							} else {
								uiMetaDataArray.push(data.metadata);
							}
						}
						if(uiMetaDataArray) {
							for (var i = 0; i < uiMetaDataArray.length; i++) {
								var metadata = new Metadata(uiMetaDataArray[i]);
								if(metadata) {
									var allContacts = metadata.getAllContacts();
									if(allContacts) {
										var contacts = null;
										if(name === 'pointOfContact') {
											contacts = allContacts.resource;
										} else if(name === 'distributorContact') {
											contacts = allContacts.distribution;
										} else if(name === 'contact') {
											contacts = allContacts.metadata;
										}
										if(contacts) {
											for(var j = 0; j < contacts.length; j++) {
												var contact = contacts[j];
												var ctcFieldValue = contact.org + '~' + contact.email + '~' + contact.phone; // ~ is used as a separator
												var ctcDisplayValue = '( ' +contact.org + ' ) - ( ' + contact.email + ' ) - ( ' + contact.phone + ' )';// - is used as a separator
												if(ctcFieldValue && ctcFieldValue.trim().length > 2) {// 2 for 2 tilde
													var valueArr = organisationsArray.map(function(item){ return item.fieldValue });
													if(valueArr && valueArr.indexOf(ctcFieldValue) == -1) {
														var organisation = {};
														organisation['fieldValue'] = ctcFieldValue;
														organisation['displayValue'] = ctcDisplayValue;
														organisationsArray.push(organisation);
													}
												}
											}
										}
									}
								}
							}
						}
						if(name === 'pointOfContact') {
							$scope.organisationNames.pointOfContact = organisationsArray;
						} else if(name === 'contact') {
							$scope.organisationNames.contact = organisationsArray;
						} else if(name === 'distributorContact') {
							$scope.organisationNames.distributorContact = organisationsArray;
						}
					});
				}
			});

		}
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

        if (($scope.mdType === 'sds') && ($scope.name === 'distributorContact')) {
          $scope.editRow = {ref: '', role: 'custodian'};
        } else {
          $scope.editRow = {ref: ''};
        }

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

	  /**
     * Put the selected record from drop down into table-grid.
     */
	  $scope.populateContactFields = function(selectedOrganisation) {

	    var role = '';
      //$scope.mode = 'add'; // set the mode to 'add' always.
      // Role is always empty (except in SDS distributor, keep the value)
      if(($scope.mdType === 'sds') && ($scope.name === 'distributorContact')) {
        role = $scope.editRow.role;
      }

      $scope.editRow = {ref: ''}; // reset the editRow reference.
      $scope.editRow.organisation = selectedOrganisation.split('~')[0]; // 0 always org
      $scope.editRow.email = selectedOrganisation.split('~')[1]; // 1 always email
      $scope.editRow.phone = selectedOrganisation.split('~')[2]; // 2 always phone
      $scope.editRow.role = role; // Role is always empty (except in SDS distributor, keep the value)


		//$scope.saveRow(); // Put the selected record from drop down into table-grid
	  };

    }]);
})();
