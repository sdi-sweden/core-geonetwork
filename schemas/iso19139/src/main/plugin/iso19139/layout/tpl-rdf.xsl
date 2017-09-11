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
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:ogc="http://www.opengis.net/rdf#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:iso19139="http://geonetwork-opensource.org/schemas/iso19139"
                version="2.0"
                extension-element-prefixes="saxon" exclude-result-prefixes="#all">

  <xsl:import href="tpl-rdf-default.xsl" />
  <xsl:import href="tpl-rdf-inspire.xsl" />


  <!-- TODO : add Multilingual metadata support
    See http://www.w3.org/TR/2004/REC-rdf-syntax-grammar-20040210/#section-Syntax-languages

    TODO : maybe some characters may be encoded / avoid in URIs
    See http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#dfn-URI-reference
  -->

  <!--
    Create reference block to metadata record and dataset to be added in dcat:Catalog usually.
  -->
  <!-- FIME : $url comes from a global variable. -->
  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']" mode="record-reference">
    <xsl:choose>
      <xsl:when test="$inspireEnabled = true()">
        <xsl:apply-templates select="." mode="record-reference-inspire" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="record-reference-default" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--
    Convert ISO record to DCAT
    -->
  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']" mode="to-dcat">

    <xsl:choose>
      <xsl:when test="$inspireEnabled = true()">
        <xsl:apply-templates select="." mode="to-dcat-inspire" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="to-dcat-default" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <!-- Create all references for ISO19139 record (if rdf.metadata.get) or records (if rdf.search) -->
  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']" mode="references">

    <xsl:choose>
      <xsl:when test="$inspireEnabled = true()">
        <xsl:apply-templates select="." mode="references-inspire" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="references-default" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Service
    Create a simple rdf:Description. To be improved.

    xpath: //srv:SV_ServiceIdentification||//*[contains(@gco:isoType, 'SV_ServiceIdentification')]
  -->
  <xsl:template
    match="srv:SV_ServiceIdentification|*[contains(@gco:isoType, 'SV_ServiceIdentification')]"
    mode="to-dcat">
    <xsl:choose>
      <xsl:when test="$inspireEnabled = true()">
        <xsl:apply-templates select="." mode="to-dcat-inspire" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="to-dcat-default" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--
    Get resource (dataset or service) identifier if set and return metadata UUID if not.
  -->
  <xsl:function name="iso19139:getResourceCode" as="xs:string">
    <xsl:param name="metadata" as="node()"/>

    <xsl:value-of select="if ($metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString!='')
      then $metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString
      else $metadata/gmd:fileIdentifier/gco:CharacterString"/>
  </xsl:function>


  <!--
    Get thesaurus identifier, otherCitationDetails value, citation @id or thesaurus title.
  -->
  <xsl:function name="iso19139:getThesaurusCode" as="xs:string">
    <xsl:param name="thesaurusName" as="node()"/>

    <xsl:value-of select="if ($thesaurusName/*/gmd:otherCitationDetails/*!='') then $thesaurusName/*/gmd:otherCitationDetails/*
      else if ($thesaurusName/gmd:CI_Citation/@id!='') then $thesaurusName/gmd:CI_Citation/@id!=''
      else encode-for-uri($thesaurusName/*/gmd:title/gco:CharacterString)"/>
  </xsl:function>

  <!--
    Get contact identifier (for the time being = email and node generated identifier if no email available)
  -->
  <xsl:function name="iso19139:getContactId" as="xs:string">
    <xsl:param name="responsibleParty" as="node()"/>

    <xsl:value-of select="if ($responsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString!='')
      then $responsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString
      else generate-id($responsibleParty)"/>
  </xsl:function>

</xsl:stylesheet>
