<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2019 Food and Agriculture Organization of the
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
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:srv="http://www.isotc211.org/2005/srv" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:gml="http://www.opengis.net/gml" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gts="http://www.isotc211.org/2005/gts" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:util="java:org.fao.geonet.util.XslUtil" 
    xmlns:uuid="java:java.util.UUID" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" 
    xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd 
    http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20060504/gmx/gmx.xsd 
    http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd">
    
    <xsl:import href="process-utility.xsl"/>
    
    
    
    
    
    
    <!-- Do a copy of every nodes and attributes -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Always remove geonet:* elements. -->
    <xsl:template match="geonet:*" priority="2"/>
    
    
    <xsl:template match="gmd:identificationInfo/*/gmd:citation/
        gmd:CI_Citation" priority="2">
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="gmd:title|
                gmd:alternateTitle|
                gmd:date|
                gmd:edition|
                gmd:editionDate"/>
            
            <xsl:variable name="updatedIdentifier">
                <xsl:choose>
                    <xsl:when test="not(gmd:identifier/gmd:RS_Identifier)">
                        <xsl:message>
                            2) metadata doesn't have gmd:identifier with gmd:RS_Identifier
                        </xsl:message>
                        <xsl:choose>
                            <xsl:when test="count(gmd:identifier/gmd:MD_Identifier/gmd:code[normalize-space(gco:CharacterString)!='{{code}}' and normalize-space(gco:CharacterString)!='']) != 0">
                                <xsl:message>
                                    2.1) If any gmd:identifier with gmd:MD_Identifier with value in gmd:code/gco:CharacterString and it's not the placeholder {{code}} --> Keep it and remove the rest of gmd:identifier
                                </xsl:message>
                                <xsl:variable name="identifierNotPlaceholder" select="gmd:identifier[not(gmd:MD_Identifier/gmd:code[normalize-space(gco:CharacterString)='{{code}}' or normalize-space(gco:CharacterString)=''])]"/>
                                <xsl:copy-of select="$identifierNotPlaceholder"/> 
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>
                                    2.2) Otherwise create one using &lt;xsl:value-of select="uuid:randomUUID()"/&gt; and remove the rest of gmd:identifier with gmd:MD_Identifier
                                </xsl:message>
                                <xsl:variable name="newUuid" select="uuid:randomUUID()"/>
                                <gmd:identifier>
                                    <gmd:MD_Identifier>
                                        <gmd:code>
                                            <gco:CharacterString>
                                                <xsl:value-of select="$newUuid"/>
                                            </gco:CharacterString>
                                        </gmd:code>
                                    </gmd:MD_Identifier>
                                </gmd:identifier>
                                <xsl:copy-of select="gmd:identifier[not(gmd:MD_Identifier)]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="count(gmd:identifier[string(gmd:RS_Identifier/gmd:code/gco:CharacterString/text())]) > 0 and count(gmd:identifier[string(gmd:MD_Identifier/gmd:code/gco:CharacterString/text())]) > 0">
                        <xsl:message>
                            3) If metadata has gmd:identifier with gmd:RS_Identifier and also has other gmd:identifier with gmd:MD_Identifier don't do any processing
                        </xsl:message>
                        <!-- just copy these gmd:identiers -->
                        <xsl:copy-of select="gmd:identifier"/>
                    </xsl:when>
                    <xsl:when test="count(gmd:identifier[string(gmd:RS_Identifier/gmd:code/gco:CharacterString/text())]) > 0 and count(gmd:identifier[string(gmd:MD_Identifier/gmd:code/gco:CharacterString/text())]) = 0">
                        <xsl:message>
                            4) If metadata has gmd:identifier with gmd:RS_Identifier and also has NO other gmd:identifier with gmd:MD_Identifier
                        </xsl:message>
                        <xsl:apply-templates select="gmd:identifier" mode="transform_RS_Identifier_into_MD_Identifier" />
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            
            
            <!-- place for gmd:identifier -->
            <xsl:copy-of select="$updatedIdentifier"/>
            
            <xsl:copy-of select="gmd:citedResponsibleParty|
                gmd:presentationForm|
                gmd:series|
                gmd:otherCitationDetails|
                gmd:collectiveTitle|
                gmd:ISBN|
                gmd:ISSN"/>
            
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="gmd:identifier" mode="transform_RS_Identifier_into_MD_Identifier">
        <xsl:message>
            Transforming RS_Identifier in MD_Identifier
        </xsl:message>
        <xsl:variable name="rsIdentifierContent" select="./gmd:RS_Identifier/*"/>
        <gmd:identifier>
            <gmd:MD_Identifier>
                <xsl:copy-of select="$rsIdentifierContent"/>
            </gmd:MD_Identifier>
        </gmd:identifier>
    </xsl:template>
    
    
    
</xsl:stylesheet>
