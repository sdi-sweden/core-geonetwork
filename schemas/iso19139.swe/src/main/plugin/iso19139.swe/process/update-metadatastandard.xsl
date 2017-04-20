<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xlink='http://www.w3.org/1999/xlink'
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
                  exclude-result-prefixes="gmd xlink gco xsi napec">

  <!-- ================================================================= -->

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:copy-of select="@*" />

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


  <!-- ================================================================= -->
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
