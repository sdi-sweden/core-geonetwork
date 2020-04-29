<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gml="http://www.opengis.net/gml" xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="srv">

    <xsl:output method="xml" encoding="UTF-8"/>

    <!-- Template for Copy data -->
    <xsl:template name="copyData" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

<xsl:template match="gmd:MD_Metadata">
        <xsl:variable name="fid" select="gmd:fileIdentifier/gco:CharacterString/text()"/>
        <xsl:variable name="title" select="gmd:identificationInfo//gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()"/>
        <xsl:message>I FIXERRORS TITEL: <xsl:value-of select="$fid" />   ----- <xsl:value-of select="$title" /></xsl:message>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:copy-of select="namespace::*[not(name() = 'gse')]" />
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <!-- Templates for set Date and dateType = 'publication' according to different Thesaurus name -->
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:descriptiveKeywords">
        <xsl:copy>
            <gmd:MD_Keywords>
                <xsl:choose>
                    <xsl:when test="normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Initiativ'">
					<xsl:message>FIXERRORS:   ----- Initiativ</xsl:message>
					<xsl:call-template name="Thesaurus">
                            <xsl:with-param name="thesaurusName" select="'Initiativ'"/>
                            <xsl:with-param name="thesaurusDate" select="'2011-04-04'"/>
                       </xsl:call-template>

                    </xsl:when>
                    <xsl:when test="normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'GEMET - INSPIRE themes, version 1.0'">
                        <xsl:call-template name="Thesaurus">
                            <xsl:with-param name="thesaurusName" select="'GEMET - INSPIRE themes, version 1.0'"/>
                            <xsl:with-param name="thesaurusDate" select="'2008-06-01'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Tjänsteklassificering'">
                        <xsl:call-template name="Thesaurus">
                            <xsl:with-param name="thesaurusName" select="'KOMMISSIONENS FÖRORDNING (EG) nr 1205/2008 av den 3 december 2008 om genomförande av Europaparlamentets och rådets direktiv 2007/2/EG om metadata 2018-12-03'"/>
                            <xsl:with-param name="thesaurusDate" select="'2008-12-03'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="gmd:MD_Keywords/gmd:keyword"/>
                        <xsl:copy-of select="gmd:MD_Keywords/gmd:type"/>
                        <xsl:copy-of select="gmd:MD_Keywords/gmd:thesaurusName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </gmd:MD_Keywords>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="Thesaurus">
        <xsl:param name="thesaurusName"/>
        <xsl:param name="thesaurusDate"/>

        <xsl:copy-of select="gmd:MD_Keywords/gmd:keyword"/>
        <xsl:copy-of select="gmd:MD_Keywords/gmd:type"/>
        <xsl:message>FIXERRORS:   ----- Thesaurus</xsl:message>
        <gmd:thesaurusName>
            <gmd:CI_Citation>
                <gmd:title>
                    <gco:CharacterString>
                        <xsl:value-of select="$thesaurusName"/>
                    </gco:CharacterString>
                </gmd:title>
                <gmd:date>
                    <gmd:CI_Date>
                        <gmd:date>
                            <gco:Date>
                                <xsl:value-of select="$thesaurusDate"/>
                            </gco:Date>
                        </gmd:date>
                        <gmd:dateType>
                            <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                        </gmd:dateType>
                    </gmd:CI_Date>
                </gmd:date>
            </gmd:CI_Citation>
        </gmd:thesaurusName>
    </xsl:template>

    <!-- Templates for
        1. change XPath for 'gmd:DQ_CompletenessRedundancies' and 'gmd:DQ_AccuracyTimeMeasurements'
        2. change True or False to Lowercase in gco:Boolean element-->
    <xsl:template match="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="gmd:DQ_CompletenessRedundancies">
				    <xsl:message>I FIXERRORS  ----- gmd:DQ_CompletenessRedundancies </xsl:message>
                    <gmd:DQ_CompletenessCommission>
                        <xsl:for-each select="gmd:DQ_CompletenessRedundancies/node()">
                              <xsl:call-template name="qualityBooleanVal"/>
                        </xsl:for-each>
                    </gmd:DQ_CompletenessCommission>
                </xsl:when>
                <xsl:when test="gmd:DQ_AccuracyTimeMeasurements">
                    <gmd:DQ_AccuracyOfATimeMeasurement>
                        <xsl:for-each select="gmd:DQ_AccuracyTimeMeasurements/node()">
                            <xsl:call-template name="qualityBooleanVal"/>
                        </xsl:for-each>
                    </gmd:DQ_AccuracyOfATimeMeasurement>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('&lt;',name(./*[1]),'&gt;')" disable-output-escaping="yes"/>
                        <xsl:for-each select="*/node()">
                            <xsl:call-template name="qualityBooleanVal"/>
                        </xsl:for-each>
                    <xsl:value-of select="concat('&lt;/',name(./*[1]),'&gt;')" disable-output-escaping="yes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="qualityBooleanVal">
        <xsl:choose>
            <xsl:when test="name(.)='gmd:result'">
                <gmd:result>
                    <xsl:choose>
                        <xsl:when test="gmd:DQ_ConformanceResult">
                            <gmd:DQ_ConformanceResult>
                                <xsl:for-each select="gmd:DQ_ConformanceResult/node()">
                                    <xsl:choose>
                                        <xsl:when test="name(.) = 'gmd:pass'">
                                            <gmd:pass>
                                                <gco:Boolean>
                                                    <xsl:choose>
                                                        <xsl:when test="normalize-space(gco:Boolean/text()) = 'True'">
                                                            <xsl:value-of select="'true'"/>
                                                        </xsl:when>
                                                        <xsl:when test="normalize-space(gco:Boolean/text()) = 'False'">
                                                            <xsl:value-of select="'false'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="gco:Boolean/text()"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </gco:Boolean>
                                            </gmd:pass>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </gmd:DQ_ConformanceResult>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="node()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmd:result>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:EX_Extent[gmd:geographicElement/gmd:EX_GeographicBoundingBox[1]/gmd:westBoundLongitude[1]/gco:Decimal[1]='']">
     <xsl:message> Clean empty bounding box</xsl:message>
   </xsl:template>

    <!-- Templates for
        1. modify hierarchy of gmd:geographicElement
        2. add gml:id attribute to gml:Polygon and gml:LineString element  -->
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:EX_Extent/gmd:geographicElement">
        <xsl:choose>
            <xsl:when test="count(node()) &gt; 1">
                <xsl:if test="gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
                    <gmd:geographicElement>
                        <xsl:copy-of select="gmd:EX_GeographicDescription"/>
                    </gmd:geographicElement>
                </xsl:if>
                <xsl:if test="gmd:EX_BoundingPolygon">
  				 <xsl:choose>
                        <xsl:when
                            test="gmd:EX_BoundingPolygon/gmd:polygon[1]/gml:Polygon[1]/gml:exterior[1]/gml:Ring[1]/gml:curveMember[1]/gml:LineString[1]/gml:coordinates[1]">
                            <gmd:geographicElement>
                                <gmd:EX_BoundingPolygon>
                                    <gmd:polygon>
                                        <xsl:call-template name="coordinates2"/>
                                    </gmd:polygon>
                                </gmd:EX_BoundingPolygon>
                            </gmd:geographicElement>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="gmd:EX_GeographicBoundingBox">
                    <gmd:geographicElement>
                        <xsl:copy-of select="gmd:EX_GeographicBoundingBox"/>
                    </gmd:geographicElement>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="gmd:EX_BoundingPolygon">
                    <xsl:choose>
                            <xsl:when
                                test="gmd:EX_BoundingPolygon/gmd:polygon[1]/gml:Polygon[1]/gml:exterior[1]/gml:Ring[1]/gml:curveMember[1]/gml:LineString[1]/gml:coordinates[1]">
									    <xsl:message>I FIXERRORS  ----- fox coordinates </xsl:message>
                                <gmd:geographicElement>
                                    <gmd:EX_BoundingPolygon>
                                        <gmd:polygon>
                                            <xsl:call-template name="coordinates2"/>
                                        </gmd:polygon>
                                    </gmd:EX_BoundingPolygon>
                                </gmd:geographicElement>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
<xsl:template name="coordinates2">
        <gml:Polygon>
            <xsl:attribute name="gml:id">
                <xsl:value-of select="'GSE002'"/>
            </xsl:attribute>
            <gml:exterior>
                <gml:LinearRing>
                    <gml:posList>
                        <xsl:value-of
                            select="gmd:EX_BoundingPolygon/gmd:polygon/gml:Polygon/gml:exterior/gml:Ring/gml:curveMember/gml:LineString/gml:coordinates/text()"
                        />
                    </gml:posList>
                </gml:LinearRing>
            </gml:exterior>
        </gml:Polygon>
    </xsl:template>


    <xsl:template name="coordinates">
        <gml:Polygon>
            <xsl:attribute name="gml:id">
                <xsl:value-of select="'GSE002'"/>
            </xsl:attribute>
            <gml:exterior>
                <gml:Ring>
                    <gml:curveMember>
                        <gml:LineString>
                            <xsl:attribute name="gml:id">
                                <xsl:value-of select="'GSE001'"/>
                            </xsl:attribute>
                            <gml:coordinates>
                                <xsl:value-of
                                    select="gmd:EX_BoundingPolygon/gmd:polygon/gml:Polygon/gml:exterior/gml:Ring/gml:curveMember/gml:LineString/gml:coordinates/text()"
                                />
                            </gml:coordinates>
                        </gml:LineString>
                    </gml:curveMember>
                </gml:Ring>
            </gml:exterior>
        </gml:Polygon>
    </xsl:template>

    <!-- Templates for
        1. set Equivalent scale and Distance in two different "gmd:spatialResolution" tags
        2. Add uom="meter" attribute in gco:Distance tag -->
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution">
        <xsl:choose>
            <xsl:when test="gmd:MD_Resolution/gmd:distance and gmd:MD_Resolution/gmd:equivalentScale">
                <gmd:spatialResolution>
                    <xsl:call-template name="distance"/>
                </gmd:spatialResolution>
                <gmd:spatialResolution>
                    <gmd:MD_Resolution>
                        <xsl:copy-of select="gmd:MD_Resolution/gmd:equivalentScale"/>
                    </gmd:MD_Resolution>
                </gmd:spatialResolution>
            </xsl:when>
            <xsl:when test="gmd:MD_Resolution/gmd:distance/gco:Distance">
                <gmd:spatialResolution>
                    <xsl:call-template name="distance"/>
                </gmd:spatialResolution>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="distance">
        <xsl:choose>
            <xsl:when test="gmd:MD_Resolution/gmd:distance/gco:Distance">
                <gmd:MD_Resolution>
                    <gmd:distance>
                        <gco:Distance>
                            <xsl:attribute name="uom">
                                <xsl:value-of select="'meter'"/>
                            </xsl:attribute>
                            <xsl:value-of select="gmd:MD_Resolution/gmd:distance/gco:Distance/text()"/>
                        </gco:Distance>
                    </gmd:distance>
                </gmd:MD_Resolution>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Template for set Metadata date tag according to Date or datetime -->
    <xsl:template match="/gmd:MD_Metadata/gmd:dateStamp">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="contains(*/text(),'T')">
                    <gco:DateTime>
                        <xsl:value-of select="*/text()"/>
                    </gco:DateTime>
                </xsl:when>
                <xsl:otherwise>
                    <gco:Date>
                        <xsl:value-of select="*/text()"/>
                    </gco:Date>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

     <!-- Template for change XPath for Browse image element -->
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:graphicOverview">
        <xsl:choose>
            <xsl:when test="count(gmd:MD_BrowseGraphic) &gt; 1">
                <xsl:for-each select="gmd:MD_BrowseGraphic">
                    <gmd:graphicOverview>
                        <xsl:copy-of select="."/>
                    </gmd:graphicOverview>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="//mdSGU" />

</xsl:stylesheet>
