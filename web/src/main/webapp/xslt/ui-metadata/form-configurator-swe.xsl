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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon"
                exclude-result-prefixes="#all" version="2.0">
  <!--
    Build the form from the schema plugin form configuration.
    -->


  <!-- Create a fieldset in the editor with custom
    legend if attribute name is defined or default
    legend according to the matching element. -->
  <xsl:template mode="form-builder" match="section[@name]|fieldset" priority="2000">
    <xsl:param name="base" as="node()"/>

    <xsl:variable name="sectionName" select="@name"/>

    <xsl:variable name="display">
      <xsl:choose>
        <xsl:when test="string(@displayIfRecord)">
          <saxon:call-template name="{concat('evaluate-', $schema, '-boolean')}">
            <xsl:with-param name="base" select="$metadata"/>
            <xsl:with-param name="in" select="concat('/../', @displayIfRecord)"/>
          </saxon:call-template>
        </xsl:when>
        <xsl:otherwise>  <xsl:value-of select="true()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$display = true()">
      <xsl:choose>
        <xsl:when test="$sectionName">
          <!-- Use panels instead of fieldsets for editor sections -->
          <div class="panel panel-default" data-gn-field-highlight="">
            <div class="panel-heading" data-gn-slide-toggle="" data-gn-field-tooltip="{$schema}|{@tooltip}">
              <span class="ng-scope">
                <xsl:value-of
                        select="if (contains($sectionName, ':'))
                  then gn-fn-metadata:getLabel($schema, $sectionName, $labels)/label
                  else $strings/*[name() = $sectionName]"
                />
              </span>
            </div>
            <div class="panel-body">
              <xsl:apply-templates mode="form-builder" select="@*[name() != 'displayIfRecord' and name() != 'tooltip']|*">
                <xsl:with-param name="base" select="$base"/>
              </xsl:apply-templates>
            </div>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="form-builder" select="@*[name() != 'displayIfRecord']|*">
            <xsl:with-param name="base" select="$base"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>