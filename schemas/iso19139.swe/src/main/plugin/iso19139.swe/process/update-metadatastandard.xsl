<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xlink='http://www.w3.org/1999/xlink'
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmx="http://www.isotc211.org/2005/gmx"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  exclude-result-prefixes="gmd xlink gco xsi gmx">

  <!-- ================================================================= -->

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <!-- Remove schemaLocation, usually doesn't have gmx namespace. Let GeoNetwork add it from schema-ident.xml -->
      <xsl:copy-of select="@*[not(name()= 'xsi:schemaLocation')]" />
      <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>

      <xsl:apply-templates select="gmd:fileIdentifier" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:parentIdentifier" />
      <xsl:apply-templates select="gmd:hierarchyLevel" />
      <xsl:apply-templates select="gmd:hierarchyLevelName" />
      <xsl:apply-templates select="gmd:contact" />
      <xsl:apply-templates select="gmd:dateStamp" />

      <gmd:metadataStandardName>
        <gco:CharacterString>SS-EN ISO 19115:2005-se 4.0</gco:CharacterString>
      </gmd:metadataStandardName>
      <gmd:metadataStandardVersion>
        <gco:CharacterString>4.0</gco:CharacterString>
      </gmd:metadataStandardVersion>

      <xsl:apply-templates select="gmd:dataSetURI" />
      <xsl:apply-templates select="gmd:locale" />
      <xsl:apply-templates select="gmd:spatialRepresentationInfo" />
      <xsl:apply-templates select="gmd:referenceSystemInfo" />
      <xsl:apply-templates select="gmd:metadataExtensionInfo" />
      <xsl:apply-templates select="gmd:identificationInfo" />
      <xsl:apply-templates select="gmd:contentInfo" />
      <xsl:apply-templates select="gmd:distributionInfo" />
      <xsl:apply-templates select="gmd:dataQualityInfo" />
      <xsl:apply-templates select="gmd:portrayalCatalogueInfo" />
      <xsl:apply-templates select="gmd:metadataConstraints" />
      <xsl:apply-templates select="gmd:applicationSchemaInfo" />
      <xsl:apply-templates select="gmd:metadataMaintenance" />
      <xsl:apply-templates select="gmd:series" />
      <xsl:apply-templates select="gmd:describes" />
      <xsl:apply-templates select="gmd:propertyType" />
      <xsl:apply-templates select="gmd:featureType" />
      <xsl:apply-templates select="gmd:featureAttribute" />
    </xsl:copy>
  </xsl:template>

  <!-- Requested to remove the gmd:resourceConstraints when updating to iso19139.swe, as are old ones and require
       to be handle for INSPIRE TG 2.0 in the metadata editor -->
  <xsl:template match="gmd:resourceConstraints" />


  <!-- Change specification title to an Anchor if pointing to the INSPIRE spec -->
  <xsl:template match="gmd:specification">
    <xsl:variable name="title" select="gmd:CI_Citation/gmd:title/gco:CharacterString" />

    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:choose>
        <xsl:when test="lower-case($title) = 'kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster'">
          <gmd:CI_Citation>
            <gmd:title>
              <gmx:Anchor xlink:href="http://data.europa.eu/eli/reg/2010/1089">
                <xsl:value-of select="$title" />
              </gmx:Anchor>
            </gmd:title>
            <xsl:apply-templates select="gmd:CI_Citation/gmd:alternateTitle" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:date" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:edition" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:editionDate" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:identifier" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:citedResponsibleParty" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:presentationForm" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:series" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:otherCitationDetails" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:collectiveTitle" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:ISBN" />
            <xsl:apply-templates select="gmd:CI_Citation/gmd:ISSN" />
          </gmd:CI_Citation>
        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="gmd:CI_Citation" />
        </xsl:otherwise>
      </xsl:choose>

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
