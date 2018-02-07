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
  goog.provide('gn_resource_constraint_directive');

  var module = angular.module('gn_resource_constraint_directive', []);


  module.directive('gnResourceConstraint', ['$http', '$rootScope', '$filter', 'gnCurrentEdit',
    function($http, $rootScope, $filter, gnCurrentEdit) {

      return {
        restrict: 'A',
        replace: true,
        transclude: true,
        scope: {
          config: '=gnResourceConstraint',
          label: '@label',
          ref: '@ref'
        },
        templateUrl: '../../catalog/components/edit/resourceconstraint/partials/' +
        'resourceconstraint.html',
        link: function(scope, element, attrs) {

          // Assign gnCurrentEdit, otherwise tooltips doesn't work
          scope.gnCurrentEdit = gnCurrentEdit;

          scope.listValues = scope.config.values;
          scope.mode = scope.config.mode;
          scope.selectedValue = scope.config.value;
          var item = $filter('filter')(scope.listValues, {'id': scope.config.valueAttr});
          if (item.length > 0) {
            scope.selectedValueAttr = item[0];
          }

          scope.updateValue = function() {
            var items = $filter('filter')(scope.listValues, {'id':scope.selectedValueAttr.id});
            if (items.length > 0) {
              scope.selectedValue = items[0].value;
            }
          };

          var buildXmlSnippet =  function() {
            if (scope.mode == 'AccessConstraints') {
              scope.snippet= "<gmd:MD_LegalConstraints xmlns:gmd=\"http://www.isotc211.org/2005/gmd\"" +
                " xmlns:gmx=\"http://www.isotc211.org/2005/gmx\"" +
                " xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n" +
                "               <gmd:accessConstraints>\n" +
                "                  <gmd:MD_RestrictionCode codeList=\"http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode\"\n" +
                "                                          codeListValue=\"otherRestrictions\"/>\n" +
                "               </gmd:accessConstraints>\n" +
                "               <gmd:otherConstraints>\n" +
                "                  <gmx:Anchor xlink:href=\"" + scope.selectedValueAttr.id + "\">" + scope.selectedValue + "</gmx:Anchor>\n" +
                "               </gmd:otherConstraints>\n" +
                "            </gmd:MD_LegalConstraints>";
            } else {
              scope.snippet= "<gmd:MD_LegalConstraints xmlns:gmd=\"http://www.isotc211.org/2005/gmd\"" +
                " xmlns:gmx=\"http://www.isotc211.org/2005/gmx\"" +
                " xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n" +
                "               <gmd:useConstraints>\n" +
                "                  <gmd:MD_RestrictionCode codeList=\"http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode\"\n" +
                "                                          codeListValue=\"otherRestrictions\"/>\n" +
                "               </gmd:useConstraints>\n" +
                "               <gmd:otherConstraints>\n" +
                "                  <gmx:Anchor xlink:href=\"" + scope.selectedValueAttr.id + "\">" + scope.selectedValue + "</gmx:Anchor>\n" +
                "               </gmd:otherConstraints>\n" +
                "            </gmd:MD_LegalConstraints>";
            }

          };

          buildXmlSnippet();

          scope.$watch('selectedValue', buildXmlSnippet);

          scope.$watch('selectedValueAttr', buildXmlSnippet);

        }
      };
    }]);
})();
