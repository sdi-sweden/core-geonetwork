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
  goog.provide('gn_fields_directive');

  goog.require('gn_metadata_manager_service');

  var module = angular.module('gn_fields_directive',
      []);

  /**
   * Note: ng-model and angular checks could not be applied to
   * the editor form as it would require to init the model
   * from the form content using ng-init for example.
   */
  module.directive('gnCheck',
      function() {
        return {
          restrict: 'A',
          link: function(scope, element, attrs) {

            // Required attribute
            if (attrs.required) {
              element.keyup(function() {
                if ($(this).get(0).value == '') {
                  $(attrs.gnCheck).addClass('has-error');
                } else {
                  $(attrs.gnCheck).removeClass('has-error');
                }
              });
              element.keyup();
            }
          }
        };
      });

  /**
   * @ngdoc directive
   * @name gn_fields.directive:gnMeasure
   * @function
   *
   * @description
   * Component to edit a measure type field composed
   * of a numberic value and a unit.
   */
  module.directive('gnMeasure',
      function() {
        return {
          restrict: 'A',
          templateUrl: '../../catalog/components/edit/partials/' +
              'measure.html',
          scope: {
            uom: '@',
            ref: '@'
          },
          link: function(scope, element, attrs) {
            scope.value = parseFloat(attrs['gnMeasure'], 10) || null;

            // Load the config from the textarea containing the helpers
            scope.config =
                angular.fromJson($('#' + scope.ref + '_config')[0].value);
            if (scope.config == null) {
              scope.config = {
                option: []
              };
            }
            // If only one option, convert to an array
            if (!$.isArray(scope.config.option)) {
              scope.config.option = [scope.config.option];
            }
            if (angular.isArray(scope.config)) {
              scope.config.option = scope.config;
            }
            scope.$watch('selected', function(n, o) {
              if (n && n !== o) {
                if (n['@value']) {
                  scope.value = parseFloat(n['@value'], 10);
                }
                if (n['@title']) {
                  scope.uom = n['@title'];
                }
              }
            });
          }
        };
      });
  /**
   * @ngdoc directive
   * @name gn_fields.directive:gnFieldTooltip
   * @function
   *
   * @description
   * Initialized field label or fieldset legend tooltip
   * based on the tooltip configuration.
   *
   * If the element is input or textarea, the event to open
   * the tooltip is on focus, if not, the event is on click.
   *
   * @param {string} gnFieldTooltip The tooltip configuration
   *  which identified the schema, the element name and optionally the
   *  element parent name and XPath. eg. 'iso19139|gmd:fileIdentifier'.
   *
   * @param {string} placement Tooltip placement. Default to 'bottom'
   * See {@link http://getbootstrap.com/javascript/#tooltips}
   *
   *
   * @example
  <example>
    <file name="index.html">
      <label for="gn-field-3"
         data-gn-field-tooltip="iso19139|gmd:fileIdentifier|gmd:MD_Metadata|
         /gmd:MD_Metadata/gmd:fileIdentifier"
         data-placement="left">File identifier</label>
   </file>
   </example>
   */
  module.directive('gnFieldTooltip',
    ['gnSchemaManagerService', 'gnCurrentEdit', '$compile', '$translate',
      function(gnSchemaManagerService, gnCurrentEdit, $compile, $translate) {

      var iconTemplate = "<a class='btn field-tooltip' " +
      "data-ng-show='gnCurrentEdit.displayTooltips'>" +
      "<span class='fa fa-question-circle-o'></span></a>";

      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          var isInitialized = false;
          var stopEventBubble = false;
          var tooltipIcon;
          var isField = element.is('input') || element.is('textarea') || element.is('select');
          var isDatePicker = 'gnDatePicker' in attrs;
          var tooltipIconCompiled = $compile(iconTemplate)(scope);

          var isTableEditor = element.siblings().length == 2 && element.siblings()[1].className == 'fixed-table-container';
          var createTooltipForDatePicker = function (el, tooltip) {

            // put the button before the datepicker, but after the sublabel
            el.before(tooltipIconCompiled);
          };
          if (isDatePicker) {
            createTooltipForDatePicker(element, tooltipIconCompiled);
          }
          var createTooltipForTableEditor = function (el, tooltip) {

            // put the button before the datepicker, but after the sublabel
            el.append(tooltipIconCompiled);
          };
          if (isTableEditor)  {
            createTooltipForTableEditor(element, tooltipIconCompiled);
          } else {
            if (isField && element.attr('type') !== 'hidden') {
              // try to find the label (with class 'control-label') that
              // is before this element in the DOM and append the tooltip
              // button to it.
              //
              //  If it's not found, place the button just before the element
              var asideCol = element.parent('div').prev();

              if (asideCol.hasClass('control-label')) {
                asideCol.append(tooltipIconCompiled);
              } else {
                element.before(tooltipIconCompiled);
              }

            }

            // if element is a fieldset legend
            if (element.is('legend')) {
              element.contents().first().after(tooltipIconCompiled);
              stopEventBubble = true;
            }
            if (element.is('label')) {
              element.parent().children('div').append(tooltipIconCompiled);
            }
          }

          tooltipIcon = tooltipIconCompiled;

          var closeTooltips = function() {
            // Close all tooltips/popovers (there still might be some open)
            $('.popover').popover('hide');
            // Less official way to hide
            $('.popover').hide();
          };

          var initTooltip = function(eventName, event) {
            // if (stopEventBubble) {
            //   event.stopPropagation();
            // }
            if (!isInitialized && gnCurrentEdit.displayTooltips) {
              // Retrieve field information (there is a cache)
              gnSchemaManagerService
               .getElementInfo(attrs.gnFieldTooltip).then(function(data) {
                var info = data;

                if (info.description && info.label) {
                  //if (info.description && info.description.length > 0) {
                  // Initialize tooltip when description returned
                  var html = '';

                  // TODO: externalize in a template.
                  if (angular.isArray(info.help)) {
                    angular.forEach(info.help, function(helpText) {
                      if (helpText['@for']) {
                        html += helpText['#text'];
                      } else {
                        html += helpText;
                      }
                    });
                  } else if (info.help) {
                    html += info.help;
                  }

                  // Add description to the body html
                  html += '<p>' + info.description + '</p>';

                  // Add @name to de body html
                  //html += '<p class="text-muted"><span class="title">' + $translate('elementName') + ': </span>' + info['@name'] + '</p>';

                  // Right same width as field
                  // For legend, popover is right
                  // Bottom is not recommended when typeahead
                  var placement = attrs.placement || 'right';

                  // TODO : improve. Here we fix the width
                  // to the remaining space between the element
                  // and the right window border.
                  var width = ($(window).width() -
                      tooltipIcon.offset().left -
                      tooltipIcon.outerWidth()) * .95;

                  tooltipIcon.popover({
                    title: info.label,
                    container: 'body',
                    content: html,
                    html: true,
                    placement: placement,
                    template: '<div class="popover gn-popover" ' +
                    'style="width:' + width + 'px"' +
                    '>' +
                    '<div class="arrow">' +
                    '</div><div class="popover-inner">' +
                    '<h3 class="popover-title"></h3>' +
                    '<div class="popover-content"><p></p></div></div></div>',
                    trigger: 'click'
                  });

                   closeTooltips();

                  tooltipIcon.on('shown.bs.popover', function(event) {

                    if ($('div.popover').css('top') && $('div.popover').css('top').charAt(0) === '-') {
                      // move popover under navbar.
                      var oldTopPopover = $('div.popover').position().top;
                      var newTopPopover =
                      $(".navbar:not('.ng-hide')").outerHeight() + 5;
                      var oldTopArrow = $('.popover>.arrow').position().top;
                      $('div.popover').css('top', newTopPopover);
                      $('.popover>.arrow').css('top',
                      oldTopArrow - newTopPopover + oldTopPopover);
                    }
                  });
                  tooltipIcon.on('$destroy', function() {
                    tooltipIcon.off();
                  });
                  tooltipIcon.popover('show');


                  isInitialized = true;
                }
              });
            }
          };

          tooltipIcon.click(function(event) {
            initTooltip();
          });
        }
      };
    }]);
  /**
   * @ngdoc directive
   * @name gn_fields.directive:gnEditorControlMove
   *
   * @description
   * Move an element up or down. If direction
   * is not defined, direction is down.
   */
  module.directive('gnEditorControlMove', ['gnEditor',
    function(gnEditor) {
      return {
        restrict: 'A',
        scope: {
          ref: '@gnEditorControlMove',
          domelementToMove: '@',
          direction: '@'
        },
        link: function(scope, element, attrs) {

          element.on('$destroy', function() {
            element.off();
          });

          $(element).click(function() {
            gnEditor.move(scope.ref, scope.direction || 'down',
                scope.domelementToMove);
          });
        }
      };
    }]);

  /**
   * @ngdoc directive
   * @name gn_fields.directive:gnFieldHighlightRemove
   *
   * @description
   * Add a danger class to the element about
   * to be removed by this action
   */
  module.directive('gnFieldHighlightRemove', [
    function() {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          var ref = attrs['gnFieldHighlightRemove'],
              target = $('#gn-el-' + ref);

          element.on('mouseover', function(e) {
            target.addClass('text-danger');
          });
          element.on('mouseout', function() {
            target.removeClass('text-danger');
          });
        }
      };
    }]);

  /**
   * @ngdoc directive
   * @name gn_fields.directive:gnFieldHighlight
   *
   * @description
   * Highlight an element by adding field-bg class
   * and looking for all remove button to make them
   * visible.
   */
  module.directive('gnFieldHighlight', [
    function() {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {

          element.on('mouseover', function(e) {
            e.stopPropagation();
            // TODO: This may need improvements
            // on touchscreen delete action will not be visible

            element.addClass('field-bg');
            element.find('a').has('.fa-times.text-danger')
                .css('visibility', 'visible');
          });
          element.on('mouseout', function() {
            element.removeClass('field-bg');
            element.find('a').has('.fa-times.text-danger')
                .css('visibility', 'hidden');
          });
        }
      };
    }]);

})();
