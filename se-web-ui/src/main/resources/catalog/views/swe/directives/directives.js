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


  var module = angular.module('swe_directives', []);

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
  module.directive('sweSortbyCombo', ['$translate', 'hotkeys',
    function($translate, hotkeys) {
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
        scope: { dialog: '@dialog' },
        link: function(scope, elem) {
          elem.on('click', function() {
            angular.element(scope.dialog).addClass('show');
            scope.$emit('body:class:add', 'show-overlay');
          });
        }
      };
    }
  ]);

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
            var e = (scope.element !== undefined)?scope.element:elem;

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

}());
