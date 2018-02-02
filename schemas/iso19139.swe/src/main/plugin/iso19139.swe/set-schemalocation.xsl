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
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                version="1.0" exclude-result-prefixes="gmd srv gmx">


  <!-- ================================================================= -->

  <xsl:template match="/root">
    <xsl:apply-templates select="*[name() != 'env']"/>
  </xsl:template>

  <!-- ================================================================= -->

  <!-- Fix schemaLocation if not complete -->
  <xsl:template match="@xsi:schemaLocation">

    <xsl:variable name="isService" select="count(//srv:SV_ServiceIdentification) > 0" />

    <xsl:variable name="schemaLocationInfo">
      <xsl:choose>
        <xsl:when test="not(contains(., 'http://www.isotc211.org/2005/gmd')) or
                        not(contains(., 'http://www.isotc211.org/2005/gmx')) or
                        ($isService and not(contains(., 'http://www.isotc211.org/2005/srv')))">

          <xsl:if test="not(contains(., 'http://www.isotc211.org/2005/gmd'))"><xsl:text> </xsl:text>http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmd/gmd.xsd</xsl:if>
          <xsl:if test="not(contains(., 'http://www.isotc211.org/2005/gmx'))"><xsl:text> </xsl:text>http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd</xsl:if>
          <xsl:text> </xsl:text><xsl:value-of select="." />
          <xsl:if test="($isService and not(contains(., 'http://www.isotc211.org/2005/srv')))"><xsl:text> </xsl:text>http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd</xsl:if>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string(normalize-space($schemaLocationInfo))">
        <xsl:attribute name="xsi:schemaLocation"><xsl:value-of select="normalize-space($schemaLocationInfo)" /></xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

</xsl:stylesheet>
