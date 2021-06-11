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

<!--
Stylesheet used to update metadata for a service and
attached it to the metadata for data.
-->
<xsl:stylesheet xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0"
>

  <!-- ============================================================================= -->

  <!-- Check if the uuidref is a file identifier, trying to retrieve the related resource identifier:
          * If not empty: assume uuidref it's a file identifier and replace it with resource identifier retrieved,
          * If empty: assume uuidref it's the resource identifier and keep it.
  -->
  <xsl:template match="srv:operatesOn">
    <xsl:variable name="uuidref"><xsl:value-of select="@uuidref" /></xsl:variable>

    <xsl:variable name="finaluuidref">
        <xsl:variable name="baseUrl" select="''"/>
        <xsl:variable name="resourcerefAux" select="java:getIndexField($baseUrl, $uuidref, 'identifier', 'en')"/>
        <xsl:variable name="resourceref" select="if (string($resourcerefAux)) then $resourcerefAux else $uuidref"/>


        <xsl:choose>
          <xsl:when test="string($resourceref)">
            <xsl:value-of select="$resourceref" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$uuidref" />
          </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@xlink:href" />
      <xsl:attribute name="uuidref" select="$finaluuidref" />
    </xsl:copy>
  </xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>
</xsl:stylesheet>
