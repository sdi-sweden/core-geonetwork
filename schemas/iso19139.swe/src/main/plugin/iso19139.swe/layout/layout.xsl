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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:java-xsl-util="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
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

  <!-- Readonly elements -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:hierarchyLevel">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="codelist"
                  select="gn-fn-metadata:getCodeListValues($schema,
                                  'gmd:MD_ScopeCode',
                                  $codelists,
                                  .)"/>

    <xsl:variable name="value" select="gmd:MD_ScopeCode/@codeListValue" />

    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="gn-fn-metadata:getLabel($schema, name(), $labels)/label"/>
      <xsl:with-param name="value" select="$codelist/entry[code = $value]/label"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="type" select="''"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
      <xsl:with-param name="listOfValues" select="''" />
    </xsl:call-template>

  </xsl:template>

  <!-- Readonly elements -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:metadataStandardName|gmd:metadataStandardVersion">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="gn-fn-metadata:getLabel($schema, name(), $labels)/label"/>
      <xsl:with-param name="value" select="gco:CharacterString"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="type" select="''"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
      <xsl:with-param name="listOfValues" select="''" />
    </xsl:call-template>

  </xsl:template>


  <!-- Language - Use restricted values defined as codelist in labels.xml -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:language">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="elementName" select="name()"/>

    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="codelist" select="$labelConfig/codelist"/>


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig/label"/>
      <xsl:with-param name="value" select="*/@codeListValue"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-iso19139:getCodeListType(name())"/>
      <xsl:with-param name="name"
                      select="if ($isEditing) then concat(*/gn:element/@ref, '_codeListValue') else ''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="$codelist"/>
      <xsl:with-param name="isFirst" select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Measure elements, gco:Distance, gco:Angle, gco:Scale, gco:Length, ... - Don't show measure type and make mandatory only 1st -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:distance[gco:*/@uom]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="refToDelete" select="gn:element" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>
    <xsl:variable name="labelMeasureType"
                  select="gn-fn-metadata:getLabel($schema, name(gco:*), $labels, name(), '', '')"/>


    <xsl:variable name="isRequired" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="count(../../preceding-sibling::gmd:spatialResolution[*/*[name() = 'gmd:distance']]) eq 0">
          <xsl:value-of select="true()"/>
        </xsl:when>
        <!--<xsl:when
                test="($refToDelete and $refToDelete/@min = 1 and $refToDelete/@max = 1) or
          (not($refToDelete) and gn:element/@min = 1 and gn:element/@max = 1)">
          <xsl:value-of select="true()"/>
        </xsl:when>-->
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <div class="form-group gn-field gn-title {if ($isRequired) then 'gn-required' else ''}"
         id="gn-el-{*/gn:element/@ref}"
         data-gn-field-highlight="">
      <label class="col-sm-2 control-label">
        <xsl:value-of select="$labelConfig/label"/>
        <!--<xsl:if test="$labelMeasureType != '' and
                      $labelMeasureType/label != $labelConfig/label">&#10;
          (<xsl:value-of select="$labelMeasureType/label"/>)
        </xsl:if>-->
      </label>
      <div class="col-sm-9 gn-value">
        <xsl:variable name="elementRef"
                      select="gco:*/gn:element/@ref"/>
        <xsl:variable name="helper"
                      select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>
        <div data-gn-measure="{gco:*/text()}"
             data-uom="{gco:*/@uom}"
             data-ref="{concat('_', $elementRef)}">
        </div>

        <textarea id="_{$elementRef}_config" class="hidden">
          <xsl:copy-of select="java-xsl-util:xmlToJson(
              saxon:serialize($helper, 'default-serialize-mode'))"/>
        </textarea>
      </div>
      <div class="col-sm-1 gn-control">
        <xsl:call-template name="render-form-field-control-remove">
          <xsl:with-param name="editInfo" select="*/gn:element"/>
          <xsl:with-param name="parentEditInfo" select="$refToDelete"/>
        </xsl:call-template>
      </div>
    </div>
  </xsl:template>


  <!--

   <gmd:spatialResolution>
            <gmd:MD_Resolution>
               <gmd:equivalentScale>
                  <gmd:MD_RepresentativeFraction>
                     <gmd:denominator>
                        <gco:Integer>10000</gco:Integer>
                     </gmd:denominator>
                  </gmd:MD_RepresentativeFraction>
               </gmd:equivalentScale>
            </gmd:MD_Resolution>
         </gmd:spatialResolution>

  -->

  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:denominator">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="refToDelete" select="gn:element" required="no"/>


    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>


    <xsl:variable name="isRequired" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="count(../../../../preceding-sibling::gmd:spatialResolution[*/*/*/*[name() = 'gmd:denominator']]) eq 0">
          <xsl:value-of select="true()"/>
        </xsl:when>
        <!--<xsl:when
                test="($refToDelete and $refToDelete/@min = 1 and $refToDelete/@max = 1) or
          (not($refToDelete) and gn:element/@min = 1 and gn:element/@max = 1)">
          <xsl:value-of select="true()"/>
        </xsl:when>-->
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="form-group gn-field gn-title {if ($isRequired) then 'gn-required' else ''}"
         id="gn-el-{*/gn:element/@ref}"
         data-gn-field-highlight="">
      <label class="col-sm-2 control-label">
        <xsl:value-of select="$labelConfig/label"/>
      </label>
      <div class="col-sm-9 gn-value">
        <xsl:variable name="elementRef"
                      select="gco:*/gn:element/@ref"/>
        <xsl:variable name="helper"
                      select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>


        <!-- Hidden as the helper directive manages to display a related custom control -->
        <input type="text" value="{./*}" class="form-control hidden" id="{concat('gn-field-', $elementRef)}" name="{concat('_', $elementRef)}" />

        <xsl:call-template name="render-form-field-helper">
          <xsl:with-param name="elementRef" select="concat('_', $elementRef)"/>
          <xsl:with-param name="listOfValues" select="$helper"/>
        </xsl:call-template>
      </div>

      <div class="col-sm-1 gn-control">
        <xsl:call-template name="render-form-field-control-remove">
          <xsl:with-param name="editInfo" select="*/gn:element"/>
          <xsl:with-param name="parentEditInfo" select="$refToDelete"/>
        </xsl:call-template>
      </div>
    </div>
  </xsl:template>

  <!-- Reference system -->
  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:referenceSystemInfo[1]/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier" priority="1000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>


    <xsl:variable name="refSystemXmlSnippet">
      <![CDATA[
         <gmd:referenceSystemInfo xmlns:gmd="http://www.isotc211.org/2005/gmd"
              xmlns:gco="http://www.isotc211.org/2005/gco">
            <gmd:MD_ReferenceSystem>
               <gmd:referenceSystemIdentifier>
                  <gmd:RS_Identifier>
                     <gmd:code>
                        <gco:CharacterString>{{editRow.code}}</gco:CharacterString>
                     </gmd:code>
                  </gmd:RS_Identifier>
               </gmd:referenceSystemIdentifier>
            </gmd:MD_ReferenceSystem>
        </gmd:referenceSystemInfo>
    ]]>
    </xsl:variable>

    <xsl:variable name="codexpath" select="gn-fn-metadata:getXPath(gmd:RS_Identifier/gmd:code)" />

    <xsl:variable name="refSystemTableModel">
      [
      {
      name: 'code',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:code', $labels, name(gmd:RS_Identifier), '', $codexpath)/label" />',
      codelist: false,
      }
      ]
    </xsl:variable>


    <xsl:variable name="refSystemModel">
      [
      <xsl:for-each select="../../../gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier">
        {
        'ref': '<xsl:value-of select="../../../gn:element/@ref" />',
        'refChildren': {
          'code': '<xsl:value-of select="gmd:RS_Identifier/gmd:code/gco:CharacterString/gn:element/@ref" />'
        },
        'code': '<xsl:value-of select="normalize-space(gmd:RS_Identifier/gmd:code/gco:CharacterString )" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <xsl:variable name="dialog-id" select="generate-id()" />

    <div class="form-group gn-field" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$refSystemModel}, {$refSystemTableModel}, '{$refSystemXmlSnippet}', {../../../gn:element/@ref}, '{local-name(../..)}', '#refsystem-popup-{$dialog-id}', '{$labelConfig/label}', '{$labelConfig/condition}', 'iso19139.swe|{name()}|{name(..)}')" >

      <div data-swe-editor-table-directive="" />

      <!-- Dialog to edit the ref. system -->
      <div data-gn-modal=""
           data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
           id="refsystem-popup-{$dialog-id}" class="gn-modal-lg gn-modal-lg-refsystem-popup">

        <div data-swe-date-dialog="">
          <div>
            <label class="col-sm-8 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:code', $labels, name(gmd:RS_Identifier), '', $codexpath)/label" />
            </label>

            <xsl:variable name="helper"
                          select="gn-fn-metadata:getHelper($schema, 'gmd:code', '/gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code', '')"/>

            <select class="" data-ng-model="editRow.code">
              <xsl:for-each select="$helper/option">
                <xsl:sort select="."/>
                <option value="{@value}" title="{normalize-space(.)}">
                  <xsl:value-of select="."/>
                </option>
              </xsl:for-each>
            </select>
          </div>


          <div class="">
            <button type="button" class="btn navbar-btn btn-success" data-ng-click="saveRow()">
              Spara
            </button>&#160;
            <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
              Stäng
            </button>

          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:referenceSystemInfo[position() &gt; 1]/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier" priority="1000" />

  <!-- Metadata dates -->
  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date[1]" priority="3000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>

    <xsl:variable name="dateXmlSnippet">
      <![CDATA[
      <gmd:date xmlns:gmd="http://www.isotc211.org/2005/gmd">
      <gmd:CI_Date>
      <gmd:date>
        <gco:Date xmlns:gco="http://www.isotc211.org/2005/gco">{{editRow.date}}</gco:Date>
      </gmd:date>
      <gmd:dateType>
      <gmd:CI_DateTypeCode codeListValue="{{editRow.datetype}}"
                            codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode"/>
        </gmd:dateType>
      </gmd:CI_Date>
    </gmd:date>
    ]]>
    </xsl:variable>

    <xsl:variable name="dateTableModel">
      [
      {
      name: 'date',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:date', $labels, name(..), '', '')/label" />',
      codelist: false,
      },
      {
      name: 'datetype',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:dateType', $labels, name(..), '', '')/label" />',
      codelist: true
      }
      ]
    </xsl:variable>

    <xsl:variable name="dateModel">
      [
      <xsl:for-each select="../gmd:date">
        {
        'ref': '<xsl:value-of select="gn:element/@ref" />',
        'refChildren': {
          'date': '<xsl:value-of select="gmd:CI_Date/gmd:date/*/gn:element/@ref" />',
          'datetype': '<xsl:value-of select="gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/gn:element/@ref" />',
        },
        'date': '<xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:DateTime|gmd:CI_Date/gmd:date/gco:Date)" />',
        'datetype': '<xsl:value-of select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <xsl:variable name="dialog-id" select="generate-id()" />

    <div class="form-group gn-field" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$dateModel},  {$dateTableModel}, '{$dateXmlSnippet}', {../gn:element/@ref}, '{local-name()}',  '#date-popup-{$dialog-id}', '{$labelConfig/label}', '{$labelConfig/condition}', 'iso19139.swe|{name()}|{name(..)}')" >

      <div data-swe-editor-table-directive="" />

      <!-- Dialog to edit the dates -->
      <div data-gn-modal=""
         data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
         id="date-popup-{$dialog-id}" class="gn-modal-lg gn-modal-lg-date-popup">

      <div data-swe-date-dialog="">
        <div>
          <label class="col-sm-2 control-label">
            Datum
          </label>
          <!--<input name="date" type="text" class="form-control" data-ng-model="selectedRow.date" />-->
          <div data-gn-date-picker="{{{{editRow.date}}}}"
               data-hide-time="true"
               data-hide-date-modes="false"
               data-label=""
               data-tag-name=""
               data-element-ref="datevalue">
          </div>
        </div>

        <div>
          <label class="col-sm-3 control-label">
            Händelse
          </label>

          <xsl:variable name="codelist"
                        select="gn-fn-metadata:getCodeListValues($schema,
                                  'gmd:CI_DateTypeCode',
                                  $codelists,
                                  .)"/>

          <select class="" data-ng-model="editRow.datetype">
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
            Spara
          </button>&#160;
          <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
            Stäng
          </button>

        </div>
      </div>

    </div>
    </div>

  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date[position() &gt; 1]" priority="3000" />

  <!-- Metadata contact,  Metadata point of contact, Distributor contact -->
  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:contact[1]|
                                            gmd:MD_Metadata/gmd:identificationInfo//gmd:pointOfContact[1]|
                                            gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact[1]" priority="3000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="elementName" select="name()"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>

    <xsl:variable name="contactXmlSnippet">
      <![CDATA[<]]><xsl:value-of select="$elementName" /><![CDATA[ xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
      <gmd:CI_ResponsibleParty>
         <gmd:individualName gco:nilReason="missing">
            <gco:CharacterString/>
         </gmd:individualName>
         <gmd:organisationName>
            <gco:CharacterString>{{editRow.organisation}}</gco:CharacterString>
         </gmd:organisationName>
         <gmd:positionName gco:nilReason="missing">
            <gco:CharacterString/>
         </gmd:positionName>
         <gmd:contactInfo>
            <gmd:CI_Contact>
               <gmd:phone>
                  <gmd:CI_Telephone>
                     <gmd:voice>
                        <gco:CharacterString>{{editRow.phone}}</gco:CharacterString>
                     </gmd:voice>
                     <gmd:facsimile gco:nilReason="missing">
                        <gco:CharacterString/>
                     </gmd:facsimile>
                  </gmd:CI_Telephone>
               </gmd:phone>
               <gmd:address>
                  <gmd:CI_Address>
                     <gmd:deliveryPoint gco:nilReason="missing">
                        <gco:CharacterString/>
                     </gmd:deliveryPoint>
                     <gmd:city gco:nilReason="missing">
                        <gco:CharacterString/>
                     </gmd:city>
                     <gmd:administrativeArea gco:nilReason="missing">
                        <gco:CharacterString/>
                     </gmd:administrativeArea>
                     <gmd:postalCode gco:nilReason="missing">
                        <gco:CharacterString/>
                     </gmd:postalCode>
                     <gmd:country gco:nilReason="missing">
                        <gco:CharacterString/>
                     </gmd:country>
                     <gmd:electronicMailAddress>
                        <gco:CharacterString>{{editRow.email}}</gco:CharacterString>
                     </gmd:electronicMailAddress>
                  </gmd:CI_Address>
               </gmd:address>
            </gmd:CI_Contact>
         </gmd:contactInfo>
         <gmd:role>
            <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_RoleCode"
                             codeListValue="{{editRow.role}}"/>
         </gmd:role>
      </gmd:CI_ResponsibleParty>
 </]]><xsl:value-of select="$elementName" /><![CDATA[>]]></xsl:variable>

    <xsl:variable name="contactTableModel">
      [
      {
        name: 'organisation',
        title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:organisationName', $labels, name(..), '', '')/label" />',
        codelist: false,
      },
      {
        name: 'role',
        title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:role', $labels, name(..), '', '')/label" />',
        codelist: true
      },
      {
        name: 'phone',
        title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:voice', $labels, name(..), '', '')/label" />',
        codelist: false
      },
      {
        name: 'email',
        title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:electronicMailAddress', $labels, name(..), '', '')/label" />',
        codelist: false
      }
      ]
    </xsl:variable>

    <!-- For gmd:contact role is fixed to pointOfContact -->
    <xsl:variable name="contactModel">
      [
      <xsl:for-each select="../*[name() = $elementName]">
        {
        'ref': '<xsl:value-of select="gn:element/@ref" />',
        'refChildren': {
          'organisation': '<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString/gn:element/@ref" />',
          'phone': '<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString/gn:element/@ref" />',
          'email': '<xsl:value-of     select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress /gco:CharacterString/gn:element/@ref" />',
          'role': '<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/gn:element/@ref" />'
        },
        'organisation': '<xsl:value-of select="normalize-space(gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString)" />',
        'phone': '<xsl:value-of select="normalize-space(gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString)" />',
        'email': '<xsl:value-of select="normalize-space(gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString)" />',
        'role': '<xsl:value-of select="if ($elementName = 'gmd:contact') then 'pointOfContact' else normalize-space(gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue)" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <xsl:variable name="mdType">
      <xsl:choose>
        <xsl:when test="count(//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification) > 0">dataset</xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName = 'other'">sds</xsl:when>
            <xsl:otherwise>service</xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="form-group gn-field" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$contactModel}, {$contactTableModel}, '{$contactXmlSnippet}', {../gn:element/@ref}, '{local-name()}', '#contact-popup-{local-name()}', '{$labelConfig/label}', '{$labelConfig/condition}', 'iso19139.swe|{name()}|{name(..)}', '{$mdType}')" >

      <div data-swe-editor-table-directive="" />

      <!-- Dialog to edit the dates -->
      <div data-gn-modal=""
           data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
           id="contact-popup-{local-name()}" class="gn-modal-lg gn-modal-lg-contact-popup">

        <div data-swe-date-dialog="">
			<div data-ng-show="showResourceContactDD">
        <label class="control-label" data-ng-translate="">
          <xsl:value-of select="$strings/selectResourceContact" />
        </label>

				<select class="form-control" data-ng-model="organisation" data-ng-change="populateContactFields(organisation)">
					<option data-ng-repeat="org in organisationNames.{local-name()}" title="{{org.displayValue}}" data-ng-value="org.fieldValue">
						{{org.displayValue}}
					</option>
				</select>
			</div>
          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:organisationName', $labels, name(..), '', '')/label" />
            </label>
            <input type="text" class="form-control" data-ng-model="editRow.organisation" />
          </div>

          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:voice', $labels, name(..), '', '')/label" />
            </label>

            <input type="text" class="form-control" data-ng-model="editRow.phone" />
          </div>


          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:electronicMailAddress', $labels, name(..), '', '')/label" />
            </label>

            <input type="text" class="form-control" data-ng-model="editRow.email" />
          </div>


          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:role', $labels, name(..), '', '')/label" />
            </label>

            <xsl:variable name="codelist"
                          select="gn-fn-metadata:getCodeListValues($schema,
                                  'gmd:CI_RoleCode',
                                  $codelists,
                                  .)"/>

            <xsl:choose>
              <xsl:when test="name() = 'gmd:contact'">
                <!-- Readonly role for gmd:contact -->
                <select class="" data-ng-model="editRow.role" data-ng-disabled="true">
                  <xsl:for-each select="$codelist/entry">
                    <xsl:sort select="label"/>
                    <option value="{code}" title="{normalize-space(description)}">
                      <xsl:if test="code = 'pointOfContact'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                      <xsl:value-of select="label"/>
                    </option>
                  </xsl:for-each>
                </select>
              </xsl:when>
              <xsl:otherwise>
                <select class="" data-ng-model="editRow.role" data-ng-disabled="mdType == 'sds' &amp;&amp; name == 'distributorContact'">
                  <xsl:for-each select="$codelist/entry">
                    <xsl:sort select="label"/>
                    <option value="{code}" title="{normalize-space(description)}">
                      <xsl:value-of select="label"/>
                    </option>
                  </xsl:for-each>
                </select>
              </xsl:otherwise>
            </xsl:choose>

          </div>


          <div class="">
            <button type="button" class="btn navbar-btn btn-success" data-ng-click="saveRow()">
              Spara
            </button>&#160;
            <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
              Stäng
            </button>

          </div>
        </div>

      </div>
    </div>

  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:contact[position() &gt; 1]|
                                            gmd:MD_Metadata/gmd:identificationInfo//gmd:pointOfContact[position() &gt; 1]|
                                            gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact[position() &gt; 1]" priority="3000" />

  <!-- Distributor format -->
  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorFormat[1]" priority="1000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>


    <xsl:variable name="formatXmlSnippet">
      <![CDATA[
          <gmd:distributorFormat xmlns:gmd="http://www.isotc211.org/2005/gmd"
              xmlns:gco="http://www.isotc211.org/2005/gco">
             <gmd:MD_Format>
                <gmd:name>
                   <gco:CharacterString>{{editRow.fname}}</gco:CharacterString>
                </gmd:name>
                <gmd:version>
                   <gco:CharacterString>{{editRow.version}}</gco:CharacterString>
                </gmd:version>
             </gmd:MD_Format>
          </gmd:distributorFormat>
    ]]>
    </xsl:variable>

    <xsl:variable name="formatTableModel">
      [
      {
      name: 'fname',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:name', $labels, name(gmd:MD_Format), '', '')/label" />',
      codelist: false,
      },
      {
      name: 'version',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:version', $labels, name(gmd:MD_Format), '', '')/label" />',
      codelist: false
      }
      ]
    </xsl:variable>


    <xsl:variable name="formatModel">
      [
      <xsl:for-each select="../gmd:distributorFormat">
        {
        'ref': '<xsl:value-of select="gn:element/@ref" />',
        'refChildren': {
        'fname': '<xsl:value-of select="gmd:MD_Format/gmd:name/gco:CharacterString/gn:element/@ref" />',
        'version': '<xsl:value-of select="gmd:MD_Format/gmd:version/gco:CharacterString/gn:element/@ref" />',
        },
        'fname': '<xsl:value-of select="normalize-space(gmd:MD_Format/gmd:name/gco:CharacterString )" />',
        'version': '<xsl:value-of select="normalize-space(gmd:MD_Format/gmd:version/gco:CharacterString)" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <xsl:variable name="dialog-id" select="generate-id()" />

    <div class="form-group gn-field distributorFormat" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$formatModel}, {$formatTableModel}, '{$formatXmlSnippet}', {../gn:element/@ref}, '{local-name()}', '#format-popup-{$dialog-id}', '{$labelConfig/label}', '{$labelConfig/condition}', 'iso19139.swe|{name()}|{name(..)}')" >

      <div data-swe-editor-table-directive="" />

      <!-- Dialog to edit the ref. system -->
      <div data-gn-modal=""
           data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
           id="format-popup-{$dialog-id}" class="gn-modal-lg gn-modal-lg-format-popup">

        <div data-swe-date-dialog="">
          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:name', $labels, name(gmd:MD_Format), '', '')/label" />
            </label>

            <xsl:variable name="helper"
                          select="gn-fn-metadata:getHelper($schema, 'gmd:name', 'gmd:MD_Format', '')"/>

            <select class="" data-ng-model="editRow.fname">
              <xsl:for-each select="$helper/option">
                <xsl:sort select="."/>
                <option value="{@value}" title="{normalize-space(.)}">
                  <xsl:value-of select="."/>
                </option>
              </xsl:for-each>
            </select>
          </div>

          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:version', $labels, name(gmd:MD_Format), '', '')/label" />
            </label>

            <input type="text" class="form-control" data-ng-model="editRow.version" />
          </div>

          <div class="">
            <button type="button" class="btn navbar-btn btn-success" data-ng-click="saveRow()">
              Spara
            </button>&#160;
            <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
              Stäng
            </button>

          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorFormat[position() &gt; 1]" priority="1000" />

   <!-- Thumbnails -->
  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:identificationInfo/*/gmd:graphicOverview[1]" priority="1000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>


    <xsl:variable name="thumbnailXmlSnippet">
      <![CDATA[
          <gmd:graphicOverview xmlns:gmd="http://www.isotc211.org/2005/gmd"
              xmlns:gco="http://www.isotc211.org/2005/gco">
              <gmd:MD_BrowseGraphic>
                 <gmd:fileName>
                    <gco:CharacterString>{{editRow.fname}}</gco:CharacterString>
                 </gmd:fileName>
                 <gmd:fileDescription>
                    <gco:CharacterString>{{editRow.fdescription}}</gco:CharacterString>
                 </gmd:fileDescription>
              </gmd:MD_BrowseGraphic>
          </gmd:graphicOverview>
    ]]>
    </xsl:variable>

    <xsl:variable name="thumbnailTableModel">
      [
      {
      name: 'fname',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:fileName', $labels, name(gmd:MD_BrowseGraphic), '', '')/label" />',
      codelist: false,
      },
      {
      name: 'fdescription',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:fileDescription', $labels, name(gmd:MD_BrowseGraphic), '', '')/label" />',
      codelist: false
      }
      ]
    </xsl:variable>


    <xsl:variable name="thumbnailModel">
      [
      <xsl:for-each select="../gmd:graphicOverview">
        {
        'ref': '<xsl:value-of select="gn:element/@ref" />',
        'refChildren': {
        'fname': '<xsl:value-of select="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString/gn:element/@ref" />',
        'fdescription': '<xsl:value-of select="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString/gn:element/@ref" />',
        },
        'fname': '<xsl:value-of select="normalize-space(gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString )" />',
        'fdescription': '<xsl:value-of select="normalize-space(gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString)" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <xsl:variable name="dialog-id" select="generate-id()" />

    <div class="form-group gn-field" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$thumbnailModel}, {$thumbnailTableModel}, '{$thumbnailXmlSnippet}', {../gn:element/@ref}, '{local-name()}', '#thumbnail-popup-{$dialog-id}', '{$labelConfig/label}', '{$labelConfig/condition}', 'iso19139.swe|{name()}|{name(..)}')" >

      <div data-swe-editor-table-directive="" />

      <!-- Dialog to edit the ref. system -->
      <div data-gn-modal=""
           data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
           id="thumbnail-popup-{$dialog-id}" class="gn-modal-lg gn-modal-lg-thumbnail-popup">

        <div data-swe-date-dialog="">
          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:fileName', $labels, name(gmd:MD_BrowseGraphic), '', '')/label" />
            </label>
            <input type="text" class="form-control" data-ng-model="editRow.fname" />
          </div>

          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:fileDescription', $labels, name(gmd:MD_BrowseGraphic), '', '')/label" />
            </label>

            <textarea class="form-control" data-ng-model="editRow.fdescription"></textarea>
          </div>

          <div class="">
            <button type="button" class="btn navbar-btn btn-success" data-ng-click="saveRow()">
              Spara
            </button>&#160;
            <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
              Stäng
            </button>

          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:identificationInfo/*/gmd:graphicOverview[position() &gt; 1]" priority="1000" />

  <!-- Distributor transfer options -->
  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]" priority="1000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')"/>


    <xsl:variable name="onlineResXmlSnippet">
      <![CDATA[
          <gmd:onLine xmlns:gmd="http://www.isotc211.org/2005/gmd"
                      xmlns:gco="http://www.isotc211.org/2005/gco">
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>{{editRow.url}}</gmd:URL>
              </gmd:linkage>
              <gmd:protocol>
                <gco:CharacterString>{{editRow.protocol}}</gco:CharacterString>
              </gmd:protocol>
              <gmd:name>
                <gco:CharacterString>{{editRow.fname}}</gco:CharacterString>
              </gmd:name>
              <gmd:description>
                <gco:CharacterString>{{editRow.description}}</gco:CharacterString>
              </gmd:description>
            </gmd:CI_OnlineResource>
          </gmd:onLine>
    ]]>
    </xsl:variable>

    <xsl:variable name="onlineResTableModel">
      [
      {
      name: 'url',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:linkage', $labels, name(gmd:CI_OnlineResource), '', '')/label" />',
      codelist: false,
      },
      {
      name: 'protocol',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:protocol', $labels, name(gmd:CI_OnlineResource), '', '')/label" />',
      codelist: false,
      },
      {
      name: 'fname',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:name', $labels, name(gmd:CI_OnlineResource), '', '')/label" />',
      codelist: false,
      },
      {
      name: 'description',
      title: '<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:description', $labels, name(gmd:CI_OnlineResource), '', '')/label" />',
      codelist: false
      }
      ]
    </xsl:variable>


    <xsl:variable name="onlineResModel">
      [
      <xsl:for-each select="../gmd:onLine">
        {
        'ref': '<xsl:value-of select="gn:element/@ref" />',
        'refChildren': {
        'url': '<xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL/gn:element/@ref" />',
        'protocol': '<xsl:value-of select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString/gn:element/@ref" />',
        'fname': '<xsl:value-of select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString/gn:element/@ref" />',
        'description': '<xsl:value-of select="gmd:CI_OnlineResource/gmd:description/gco:CharacterString/gn:element/@ref" />',
        },
        'url': '<xsl:value-of select="normalize-space(gmd:CI_OnlineResource/gmd:linkage/gmd:URL)" />',
        'protocol': '<xsl:value-of select="normalize-space(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString)" />',
        'fname': '<xsl:value-of select="normalize-space(gmd:CI_OnlineResource/gmd:name/gco:CharacterString)" />',
        'description': '<xsl:value-of select="normalize-space(gmd:CI_OnlineResource/gmd:description/gco:CharacterString)" />'
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>

    <xsl:variable name="dialog-id" select="generate-id()" />

    <xsl:variable name="mdType">
      <xsl:choose>
        <xsl:when test="count(//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification) > 0">dataset</xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName = 'other'">sds</xsl:when>
            <xsl:otherwise>service</xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--<xsl:message>$mdType: <xsl:value-of select="$mdType" /></xsl:message>-->
    <div class="form-group gn-field distributorOnlineKalla" data-ng-controller="SweEditorTableController"
         data-ng-init="init({$onlineResModel}, {$onlineResTableModel}, '{$onlineResXmlSnippet}', {../gn:element/@ref}, '{local-name()}', '#onlineres-popup-{$dialog-id}', '{$labelConfig/label}', '{$labelConfig/condition}', 'iso19139.swe|{name()}|{name(..)}', '{$mdType}')" >

      <div data-swe-editor-table-directive="" />

      <!-- Dialog to edit the ref. system -->
      <div data-gn-modal=""
           data-gn-popup-options="{{title:'{$labelConfig/label}'}}"
           id="onlineres-popup-{$dialog-id}" class="gn-modal-lg gn-modal-lg-onlineres-popup">

        <div data-swe-date-dialog="">


          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:linkage', $labels, name(gmd:CI_OnlineResource), '', '')/label" />
            </label>

            <input type="text" class="form-control" data-ng-model="editRow.url" />
          </div>

          <div>
            <label class="col-sm-2 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:protocol', $labels, name(gmd:CI_OnlineResource), '', '')/label" />
            </label>

            <xsl:variable name="helper"
                          select="gn-fn-metadata:getHelper($schema, 'gmd:protocol', '', '')"/>

            <select class="" data-ng-model="editRow.protocol">
              <xsl:for-each select="$helper/option">
                <xsl:sort select="."/>
                <option value="{@value}" title="{normalize-space(.)}">
                  <xsl:value-of select="."/>
                </option>
              </xsl:for-each>
            </select>
          </div>

          <div>
            <label class="col-sm-4 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:name', $labels, name(gmd:CI_OnlineResource), '', '')/label" />
            </label>
            <input type="text" class="form-control" data-ng-model="editRow.fname" />
          </div>

          <div data-ng-show="mdType != 'sds'">
            <label class="col-sm-6 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:description', $labels, name(gmd:CI_OnlineResource), '', '')/label" />
            </label>

            <textarea  class="form-control" data-ng-model="editRow.description"></textarea>
          </div>

          <div data-ng-show="mdType == 'sds'">
            <label class="col-sm-6 control-label">
              <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'gmd:description', $labels, name(gmd:CI_OnlineResource), '', '')/label" />
            </label>

            <textarea  class="form-control" data-ng-model="editRow.description"></textarea>

            <label class="col-sm-6 control-label">
              SDS service description (suggestions):
            </label>
            <select class="form-control" data-ng-model="editRow.description">
              <option value="accessPoint">Access Point</option>
              <option value="endPoint">End Point</option>
            </select>
          </div>

          <div class="">
            <button type="button" class="btn navbar-btn btn-success" data-ng-click="saveRow()">
              Spara
            </button>&#160;
            <button type="button" class="btn navbar-btn btn-default" data-ng-click="cancel()">
              Stäng
            </button>

          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[position() &gt; 1]" priority="1000" />

  <!-- Other constraints with gmx:Anchor -->
<!--  <xsl:template mode="mode-iso19139" priority="200" match="gmd:otherConstraints[$schema='iso19139.swe' and gmx:Anchor]">
    <xsl:variable name="name" select="name(.)"/>

    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, $name, $labels)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>


    <xsl:variable name="attributes">
      &lt;!&ndash; Create form for all existing attribute (not in gn namespace)
      and all non existing attributes not already present. &ndash;&gt;
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="
        gmx:Anchor/@*|
        gmx:Anchor/gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="gmx:Anchor/gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="gmx:Anchor/gn:element/@ref"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="$labelConfig/label"/>
      <xsl:with-param name="value" select="gmx:Anchor" />
      <xsl:with-param name="name" select="gmx:Anchor/gn:element/@ref" />
      <xsl:with-param name="cls" select="local-name()" />
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="editInfo" select="gmx:Anchor/gn:element" />
      <xsl:with-param name="isDisabled" select="false()" />
      <xsl:with-param name="attributesSnippet" select="$attributes" />
      <xsl:with-param name="listOfValues" select="$helper"/>
      &lt;!&ndash;<xsl:with-param name="forceDisplayAttributes" select="true()" />&ndash;&gt;

    </xsl:call-template>
  </xsl:template>-->


  <!-- limitationsPublicAccess -->
  <xsl:template mode="mode-iso19139"
                match="gmd:MD_DataIdentification-OLD/gmd:resourceConstraints[gmd:MD_LegalConstraints/gmd:accessConstraints]/gmd:MD_LegalConstraints/gmd:otherConstraints"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>
    <xsl:param name="refToDelete" required="no"/>

    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="xpath"
                  select="gn-fn-metadata:getXPathByRef(gn:element/@ref, $metadata, false())"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>

    <xsl:variable name="theElement" select="gco:CharacterString|gmx:Anchor"/>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="if ($overrideLabel != '') then $overrideLabel else $labelConfig/label"/>
      <xsl:with-param name="value" select="*"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <!--<xsl:with-param name="widget"/>
        <xsl:with-param name="widgetParams"/>-->
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type"
                      select="gn-fn-metadata:getFieldType($editorConfig, name(),
        name($theElement))"/>

      <xsl:with-param name="name" select="$theElement/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="$theElement/gn:element"/>
      <xsl:with-param name="parentEditInfo"
                      select="if ($refToDelete) then $refToDelete else gn:element"/>
      <!-- TODO: Handle conditional helper -->
      <xsl:with-param name="listOfValues" select="$helper"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Conditions for access and use -->
  <xsl:template mode="mode-iso19139"
                match="gmd:MD_DataIdentification-OLD/gmd:resourceConstraints[gmd:MD_LegalConstraints/gmd:useConstraints]/gmd:MD_LegalConstraints/gmd:otherConstraints"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>
    <xsl:param name="refToDelete" required="no"/>

    <!--<xsl:message>===== resourceConstraints directive</xsl:message>-->
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="xpath"
                  select="gn-fn-metadata:getXPathByRef(gn:element/@ref, $metadata, false())"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, 'conditionsForAccess', $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>

    <xsl:variable name="theElement" select="gco:CharacterString|gmx:Anchor"/>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="if ($overrideLabel != '') then $overrideLabel else $labelConfig/label"/>
      <xsl:with-param name="value" select="*"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <!--<xsl:with-param name="widget"/>
        <xsl:with-param name="widgetParams"/>-->
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type"
                      select="gn-fn-metadata:getFieldType($editorConfig, name(),
        name($theElement))"/>

      <xsl:with-param name="name" select="$theElement/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="$theElement/gn:element"/>
      <xsl:with-param name="parentEditInfo"
                      select="if ($refToDelete) then $refToDelete else gn:element"/>
      <!-- TODO: Handle conditional helper -->
      <xsl:with-param name="listOfValues" select="$helper"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="mode-iso19139" match="gmd:resourceConstraints[gmd:MD_LegalConstraints/gmd:otherConstraints]" priority="3000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <!--<xsl:message>========== gmd:resourceConstraints directive</xsl:message>-->

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (gmd:MD_LegalConstraints/gmd:otherConstraints/@gco:isoType) then gmd:MD_LegalConstraints/gmd:otherConstraints/@gco:isoType else ''"/>
    <!--<xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(gmd:MD_LegalConstraints/gmd:otherConstraints), $labels, name(gmd:MD_LegalConstraints), $isoType, $xpath)"/>-->

    <xsl:variable name="mode" select="if (count(gmd:MD_LegalConstraints[gmd:accessConstraints]) > 0) then
                'AccessConstraints'
              else
                'UseConstraints'" />


    <xsl:variable name="toolipValue" select="if (count(gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces')]) > 0) then
               'LimitationsOnPublicAcces'
              else if (count(gmd:MD_LegalConstraints[gmd:accessConstraints]) > 0) then
                'conditionsForAccess'
              else
                'conditionsForUse'" />


    <xsl:variable name="labelConfig" select="if (count(gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces')]) > 0) then
                gn-fn-metadata:getLabel($schema, 'LimitationsOnPublicAcces', $labels, name(gmd:MD_LegalConstraints), $isoType, $xpath)
              else if (count(gmd:MD_LegalConstraints[gmd:accessConstraints]) > 0) then
                gn-fn-metadata:getLabel($schema, 'conditionsForAccess', $labels, name(gmd:MD_LegalConstraints), $isoType, $xpath)
              else
                gn-fn-metadata:getLabel($schema, 'conditionsForUse', $labels, name(gmd:MD_LegalConstraints), $isoType, $xpath)" />

<!--
    <xsl:message>========== gmd:resourceConstraints directive schema/ label: <xsl:value-of select="$schema" />/<xsl:value-of select="$labelConfig/label" /></xsl:message>
    <xsl:message>========== gmd:resourceConstraints directive value: <xsl:value-of select="gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor" /></xsl:message>
    <xsl:message>========== gmd:resourceConstraints directive value href: <xsl:value-of select="gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor/@xlink:href" /></xsl:message>
-->
    <xsl:variable name="helper"
                  select="gn-fn-metadata:getHelper($labelConfig/helper, gmd:MD_LegalConstraints/gmd:otherConstraints)"/>

    <!--<xsl:message>helper: <xsl:value-of select="$helper" /></xsl:message>-->

    <xsl:variable name="listOfValues">
      [
      <xsl:for-each select="$helper/option">
        {'id': '<xsl:value-of select="@title" />', 'value': '<xsl:value-of select="@value" />'}<xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>


    <xsl:variable name="directiveConfig">
      {
        'values': <xsl:value-of select="$listOfValues" />,
        'value': '<xsl:value-of select="gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor"/>',
        'valueAttr': '<xsl:value-of select="gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor/@xlink:href"/>',
        'mode': '<xsl:value-of select="$mode" />',
        'schema': '<xsl:value-of select="$schema" />',
        'elementTooltip': '<xsl:value-of select="$toolipValue" />'
      }
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig/label"/>
      <xsl:with-param name="value" select="$directiveConfig"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="directive" select="'gn-resource-constraint'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <!--<xsl:with-param name="parentEditInfo" select="gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor/gn:element"/>-->



    </xsl:call-template>

  </xsl:template>
</xsl:stylesheet>
