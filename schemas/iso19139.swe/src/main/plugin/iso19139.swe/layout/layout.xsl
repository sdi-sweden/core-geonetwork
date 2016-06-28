<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->


<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="#all">

  <xsl:include href="utility-tpl.xsl"/>

  <!-- Visit all XML tree recursively -->
  <xsl:template mode="mode-iso19139.swe" match="*|@*">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:referenceSystemInfo[1]/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier" priority="1000">
    <div class="geo-data-toolbar-cont" style="width:100%">
      <div class="toolbar-right-list tool-bar-list">
        <div class="link-cont ng-scope">
          <a class="-label-link" href=""><span class="icon-pencil"></span>Lägg till</a>
        </div>
        <div class="link-cont ng-scope">
          <a class="-label-link" href=""><span class="icon-pencil"></span>Ta bort</a>
        </div>
        <div class="link-cont ng-scope">
          <a class="-label-link" href=""><span class="icon-pencil"></span>Redigera</a>
        </div>
      </div>
    </div>

    <div class="fixed-table-container">
      <table class="table" style="background-color: #ffffff">
        <thead>
          <tr>
            <th style="display:none"></th>
            <th><div class="th-inner ">Code</div></th>
            <th><div class="th-inner ">Codespace</div></th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="../../../gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
          <tr>
            <td style="display:none"><xsl:value-of select="position()" /></td>
            <td><xsl:value-of select="gmd:code/gco:CharacterString" /></td>
            <td><xsl:value-of select="gmd:codeSpace/gco:CharacterString" /></td>
          </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>

  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:referenceSystemInfo[position() &gt; 1]/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier" priority="1000" />

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date[1]" priority="3000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>
    <xsl:variable name="labelMeasureType"
                  select="gn-fn-metadata:getLabel($schema, name(gco:*), $labels, name(), '', '')"/>
    <xsl:variable name="isRequired" select="gn:element/@min = 1 and gn:element/@max = 1"/>


    <xsl:variable name="dateModel">
      [
      <xsl:for-each select="../gmd:date">
        {
        'ref': '<xsl:value-of select="gn:element/@ref" />',
        'refdate': '<xsl:value-of select="gmd:CI_Date/gmd:date/*/gn:element/@ref" />',
        'refdatetype': '<xsl:value-of select="gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/gn:element/@ref" />',
        'date': '<xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:DateTime|gmd:CI_Date/gmd:date/gco:Date)" />',
        'datetype': '<xsl:value-of select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <!--<xsl:for-each select="../gmd:date">
      <input type="hidden" id="_{gmd:CI_Date/gmd:date/*/gn:element/@ref}"
             name="_{gmd:CI_Date/gmd:date/*/gn:element/@ref}"
             value="{gmd:CI_Date/gmd:date/*}" />
    </xsl:for-each>

    <xsl:for-each select="../gmd:date">
    <input type="hidden" id="_{gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/gn:element/@ref}_codeListValue"
           name="_{gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/gn:element/@ref}_codeListValue"
           value="{gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue}" />
    </xsl:for-each>-->

    <div class="form-group gn-field" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$dateModel}, {../gn:element/@ref}, '#date-popup')" >
      <label class="col-sm-2 control-label">
        <xsl:value-of select="$labelConfig/label"/>
        <xsl:if test="$labelMeasureType != '' and
                        $labelMeasureType/label != $labelConfig/label">&#10;
          (<xsl:value-of select="$labelMeasureType/label"/>)
        </xsl:if>

        <!--<div class="help-icn-cont other-filter-help-icn">
          <div class="help-icn-circle"><span class="icon-help"></span></div>
          <div class="tool-tip-cont">
            <div class="tool-tip">
              <span class="triangle"></span>
              <h2>Sökning på ämnesområden</h2>
              <p>Markera ett eller flera ämnesområden du vill söka geodata inom.</p>
              <p>Kan kombineras med fritextsökning.</p>
            </div>
          </div>
        </div>-->
      </label>

      <div class="geo-data-toolbar-cont col-sm-10">
        <div class="toolbar-right-list tool-bar-list">
          <div class="link-cont ng-scope">
            <a class="-label-link" href="" data-ng-click="addRow()" ><span class="icon-pencil"></span>Lägg till</a>
          </div>
          <div class="link-cont ng-scope">
            <a class="-label-link" href="" data-ng-class="{{'not-active':selectedRowIndex == null}}" data-ng-click="removeRow()" ><span class="icon-pencil"></span>Ta bort</a>
          </div>
          <div class="link-cont ng-scope">
            <a class="-label-link" href="" data-ng-class="{{'not-active':selectedRowIndex == null}}" data-ng-click="editRow()" ><span class="icon-pencil"></span>Redigera</a>
          </div>
        </div>
      </div>

      <input type="hidden" data-ng-repeat="row in rows | filter: isExistingItem" data-ng-value="row.date" name="_{{{{row.refdate}}}}" />
      <input type="hidden" data-ng-repeat="row in rows | filter: isExistingItem" data-ng-value="row.datetype" name="_{{{{row.refdatetype}}}}_codeListValue" />

      <input type="hidden" data-ng-repeat="row in rows | filter: isNewItem" data-ng-value="row.xmlSnippet" name="_X{{{{parent}}}}_gmdCOLONdate" />

      <div class="fixed-table-container">
        <table class="table table-hover table-bordered" style="background-color: #ffffff">
          <thead>
            <tr>
              <th><div class="th-inner "><xsl:value-of select="gn-fn-metadata:getLabel($schema, name(gmd:CI_Date/gmd:date), $labels, name(..), '', '')/label" /></div></th>
              <th><div class="th-inner "><xsl:value-of select="gn-fn-metadata:getLabel($schema, name(gmd:CI_Date/gmd:dateType), $labels, name(..), '', '')/label" /> Date Type</div></th>
            </tr>
          </thead>
          <tbody>
              <tr data-ng-repeat="row in rows" data-ng-class="{{'selected':$index == selectedRowIndex}}" data-ng-click="setClickedRow($index)">
                <td>{{row.date}}</td>
                <td>{{row.datetype}}</td>
              </tr>

            <!--<xsl:for-each select="../gmd:date">
              <xsl:variable name="pos" select="position()" />
              <tr data-ng-click="setClickedRow(this)">
                <td style="display:none"><xsl:value-of select="position()" /></td>
                <td><xsl:value-of select="gmd:CI_Date/gmd:date/*" /></td>
                <td><xsl:value-of select="gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue" /></td>
              </tr>
            </xsl:for-each>-->
          </tbody>
        </table>
      </div>

      <!-- Dialog to edit the dates -->
      <div data-gn-modal=""
         data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
         id="date-popup" class="gn-modal-lg">

      <div data-swe-date-dialog="">
        <div>
          <label class="col-sm-2 control-label">
            Date
          </label>
          <!--<input name="date" type="text" class="form-control" data-ng-model="selectedRow.date" />-->
          <div data-gn-date-picker="{{selectedRow.date}}"
               data-label=""
               data-tag-name=""
               data-element-ref="datevalue">>
          </div>

        </div>

        <div>
          <label class="col-sm-2 control-label">
            Date type
          </label>

          <xsl:variable name="codelist"
                        select="gn-fn-metadata:getCodeListValues($schema,
                                  'gmd:CI_DateTypeCode',
                                  $codelists,
                                  .)"/>

          <select class="" data-ng-model="selectedRow.datetype">
            <xsl:for-each select="$codelist/entry">
              <xsl:sort select="label"/>
              <option value="{code}" title="{normalize-space(description)}">
                <xsl:value-of select="label"/>
              </option>
            </xsl:for-each>
          </select>
          <!--<input name="datetype" type="text" class="form-control" data-ng-model="selectedRow.datetype" />-->
        </div>

        <div class="">
          <button type="button" class="btn navbar-btn btn-success" data-ng-click="saveRow()">
            Save
          </button>&#160;
          <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
            Cancel
          </button>

        </div>
      </div>

    </div>
    </div>

  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date[position() &gt; 1]" priority="3000" />

</xsl:stylesheet>
