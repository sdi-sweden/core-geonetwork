<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gml32="http://www.opengis.net/gml/3.2" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:lst="http://www.lansstyrelsen.se"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gse="http://www.geodata.se/gse"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>

  <!-- Template for Copy data -->
  <xsl:template name="copyData" match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="gml32:*">
    <xsl:element name="{name()}" namespace="http://www.opengis.net/gml">
      <xsl:copy-of select="namespace::*[not(name() = 'gml')]" />

      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@gml32:*">
    <xsl:attribute name="{name()}" namespace="http://www.opengis.net/gml">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- remove namespace declaration of gse from root element -->
  <xsl:template match="gmd:MD_Metadata">
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select="namespace::*[not(name() = 'gse') and not(name() = 'gml')]" />
      <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
      <xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/>

      <!-- Fixed value for schemaLocation -->
      <xsl:attribute name="xsi:schemaLocation">http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd  http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20060504/gmx/gmx.xsd  http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd</xsl:attribute>
      <xsl:apply-templates select="@*[name() != 'xsi:schemaLocation']|node()"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="gmd:metadataStandardName">
    <gmd:metadataStandardName>
      <gco:CharacterString>SS-EN ISO 19115:2005-geodata.se</gco:CharacterString>
    </gmd:metadataStandardName>
  </xsl:template>

  <xsl:template match="gmd:metadataStandardVersion">
    <gmd:metadataStandardVersion>
      <gco:CharacterString>3.1.1</gco:CharacterString>
    </gmd:metadataStandardVersion>
  </xsl:template>



  <xsl:template match="gmd:MD_DataIdentification">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />
      <xsl:apply-templates select="gmd:descriptiveKeywords" />

      <xsl:if test="not(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'Spatial scope'])">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <gmd:keyword>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialScope/national">Nationell</gmx:Anchor>
            </gmd:keyword>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title>
                  <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialScope">Spatial scope</gmx:Anchor>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2019-05-22</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />

      <!-- Process gmd:resourceConstraints for INSPIRE TG 2.0 -->
      <xsl:apply-templates select="." mode="process-resource-constraints" />

      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="gmd:spatialRepresentationType" />
      <xsl:apply-templates select="gmd:spatialResolution" />
      <xsl:apply-templates select="gmd:language" />

      <!-- Some metadata misses this mandatory element -->
      <xsl:if test="not(gmd:language)">
        <gmd:language>
          <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="swe"/>
        </gmd:language>
      </xsl:if>

      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:topicCategory" />
      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />
      <xsl:apply-templates select="gmd:supplementalInformation" />

    </xsl:copy>
  </xsl:template>


  <!-- remove the parent of DQ_UsabilityElement, if DQ_UsabilityElement is present -->
  <xsl:template match="*[gmd:DQ_UsabilityElement]"/>

  <!-- remove all aggregateInformation -->
  <xsl:template match="gmd:aggregateInformation"/>

  <!-- remove all topic categories for service type records -->
  <xsl:template match="//gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:topicCategory"/>

  <!-- remove GeodataSe node with namespace gse and remove namespace gse declaration from metadata (see above) -->
  <xsl:template match="gse:GeodataSe"/>

  <!-- fix keyword value if value contains period character (.) -->
  <xsl:template match="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[contains(gco:CharacterString, '.')]">
    <xsl:variable name="keywordValue" select="gco:CharacterString" />
    <xsl:copy copy-namespaces="no">
      <gco:CharacterString><xsl:value-of select="substring-after($keywordValue,' ')" /></gco:CharacterString>
    </xsl:copy>
  </xsl:template>

  <!--  remove gmd:type node from gmd:MD_Keywords -->
  <xsl:template match="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type"/>


  <!--  remove gmd:function from gmd:onLine if present -->
  <xsl:template match="gmd:onLine/gmd:function"/>

  <!--  fix title for DQ_ConformanceResult -->
  <xsl:template match="gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title[gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2009/976' or
	      gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2010/1089']">
    <xsl:variable name="isService" select="count(//srv:SV_ServiceIdentification) > 0" />

    <xsl:copy copy-namespaces="no">
      <xsl:choose>
        <xsl:when test="$isService">
          <gco:CharacterString>Kommissionens förordning (EG) nr 976/2009 av den 19 oktober 2009 om genomförande av Europaparlamentets och rådets direktiv 2007/2/EG med avseende på nättjänster</gco:CharacterString>
        </xsl:when>
        <xsl:otherwise>
          <gco:CharacterString>Kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av Europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster</gco:CharacterString>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>


  <!--  fix date for DQ_ConformanceResult -->
  <xsl:template match="gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation[gmd:title/gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2009/976' or
	      lower-case(normalize-space(gmd:title/gco:CharacterString)) = 'kommissionens förordning (eg) nr 976/2009 av den 19 oktober 2009 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg med avseende på nättjänster' or
	      gmd:title/gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2010/1089' or
        lower-case(normalize-space(gmd:title/gco:CharacterString)) = 'kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster'
	      ]/gmd:date/gmd:CI_Date/gmd:date">
    <xsl:variable name="isService" select="count(//srv:SV_ServiceIdentification) > 0" />

    <xsl:copy copy-namespaces="no">
      <xsl:choose>
        <xsl:when test="$isService">
          <gco:Date>2009-10-20</gco:Date>
        </xsl:when>
        <xsl:otherwise>
          <gco:Date>2010-12-08</gco:Date>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>


  <!--  fix pass for DQ_ConformanceResult -->
  <xsl:template match="gmd:DQ_ConformanceResult[gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2009/976' or
	      lower-case(normalize-space(gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)) = 'kommissionens förordning (eg) nr 976/2009 av den 19 oktober 2009 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg med avseende på nättjänster' or
	      gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2010/1089' or
	      lower-case(normalize-space(gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)) = 'kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster']/gmd:pass">
    <gmd:pass>
      <gco:Boolean>true</gco:Boolean>
    </gmd:pass>
  </xsl:template>

  <!-- Remove old report for Kommissionens förordning nr 976/2009 avseende nättjänster, if the new report exists,
      otherwise replace it-->
  <xsl:template match="gmd:report[lower-case(normalize-space(gmd:DQ_CompletenessOmission/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)) = 'kommissionens förordning nr 976/2009 avseende nättjänster']">

    <xsl:variable name="existsNewReport" select="count(//gmd:report[gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2009/976' or
      lower-case(normalize-space(gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)) = 'kommissionens förordning (eg) nr 976/2009 av den 19 oktober 2009 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg med avseende på nättjänster']) > 0" />

    <xsl:choose>
      <!-- Remove it -->
      <xsl:when test="$existsNewReport = true()"></xsl:when>
      <!-- Replace it with correct entry -->
      <xsl:otherwise>
        <gmd:report>
          <gmd:DQ_DomainConsistency>
            <gmd:result>
              <gmd:DQ_ConformanceResult>
                <gmd:specification>
                  <gmd:CI_Citation>
                    <gmd:title>
                      <gmx:Anchor xlink:href="http://data.europa.eu/eli/reg/2009/976">
                        Kommissionens förordning (eg) nr 976/2009 av den 19 oktober 2009 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg med avseende på nättjänster
                      </gmx:Anchor>
                    </gmd:title>
                    <gmd:date>
                      <gmd:CI_Date>
                        <gmd:date>
                          <gco:Date>2009-10-20</gco:Date>
                        </gmd:date>
                        <gmd:dateType>
                          <gmd:CI_DateTypeCode
                            codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                            codeListValue="publication"/>
                        </gmd:dateType>
                      </gmd:CI_Date>
                    </gmd:date>
                  </gmd:CI_Citation>
                </gmd:specification>
                <gmd:explanation>
                  <gco:CharacterString>Enligt ovanstående specifikation</gco:CharacterString>
                </gmd:explanation>
                <gmd:pass>
                  <gco:Boolean>true</gco:Boolean>
                </gmd:pass>
              </gmd:DQ_ConformanceResult>
            </gmd:result>
          </gmd:DQ_DomainConsistency>
        </gmd:report>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Remove old report for Kommissionens förordning nr 1089/2009 vad gäller interoperabilitet för rumsliga datamängder och datatjänster, if the new report exists,
     otherwise replace it -->
  <xsl:template match="gmd:report[lower-case(normalize-space(gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)) = 'kommissionens förordning nr 1089/2009 vad gäller interoperabilitet för rumsliga datamängder och datatjänster']"
                priority="10">

    <xsl:variable name="existsNewReport" select="count(//gmd:report[gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2010/1089' or
      lower-case(normalize-space(gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)) = 'kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster']) > 0" />

    <xsl:choose>
      <!-- Remove it -->
      <xsl:when test="$existsNewReport = true()"></xsl:when>
      <!-- Replace it with correct entry -->
      <xsl:otherwise>
        <gmd:report>
          <gmd:DQ_DomainConsistency>
            <gmd:result>
              <gmd:DQ_ConformanceResult>
                <gmd:specification>
                  <gmd:CI_Citation>
                    <gmd:title>
                      <gco:CharacterString>Kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av Europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster</gco:CharacterString>
                    </gmd:title>
                    <gmd:date>
                      <gmd:CI_Date>
                        <gmd:date>
                          <gco:Date>2010-12-08</gco:Date>
                        </gmd:date>
                        <gmd:dateType>
                          <gmd:CI_DateTypeCode
                            codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                            codeListValue="publication"/>
                        </gmd:dateType>
                      </gmd:CI_Date>
                    </gmd:date>
                  </gmd:CI_Citation>
                </gmd:specification>
                <gmd:explanation>
                  <gco:CharacterString>https://www.geodata.se/globalassets/dokumentarkiv/regelverk/inspire/ir_interoperabilitet.pdf</gco:CharacterString>
                </gmd:explanation>
                <gmd:pass>
                  <gco:Boolean>true</gco:Boolean>
                </gmd:pass>
              </gmd:DQ_ConformanceResult>
            </gmd:result>
          </gmd:DQ_DomainConsistency>
        </gmd:report>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--  remove spatial resolution if gco:Distance is not present or is empty -->
  <xsl:template match="gmd:spatialResolution[
							gmd:MD_Resolution/gmd:distance/gco:Distance[. = '']
							or
							normalize-space(gmd:MD_Resolution/gmd:distance/gco:Distance)='']" />

  <!-- ensure codespace always comes after code -->
  <xsl:template match="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="gmd:code"/>
      <xsl:apply-templates select="gmd:codeSpace"/>
    </xsl:copy>
  </xsl:template>

  <!-- rename element gmd:AbstractDQ_Completeness to gmd:DQ_CompletenessOmission -->
  <xsl:template match="gmd:AbstractDQ_Completeness">
    <gmd:DQ_CompletenessOmission>
      <xsl:apply-templates select="@*|node()"/>
    </gmd:DQ_CompletenessOmission>
  </xsl:template>

  <!-- remove following elements -->
  <xsl:template match="mdSGU" />
  <xsl:template match="gmd:applicationSchemaInfo" />

  <!-- Remove descriptiveKeywords if thesaurus title starts with 'SGU' text. -->
  <xsl:template match="gmd:descriptiveKeywords[starts-with(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString, 'SGU')]" priority="10"/>

  <!-- end of InspireCSWProxy rules -->


  <!-- Additional rules which are not in InspireCSWProxy -->


  <!-- example of timeperiod
  <gml:TimePeriod gml:id="Temporal">
    <gml:beginPosition>1968</gml:beginPosition>
    <gml:endPosition />
  </gml:TimePeriod>-->

  <!-- add attribute @gml:id to gml:timeperiod if missing -->
  <xsl:template match="gml:TimePeriod[not(@gml:id) or normalize-space(@gml:id)='' or normalize-space(@gml:id)='Temporal']">
    <xsl:element name="gml:TimePeriod" namespace="http://www.opengis.net/gml">
      <xsl:choose>
        <xsl:when test="normalize-space(@gml:id)='' or normalize-space(@gml:id)='Temporal'">
          <xsl:attribute name="gml:id">
            <xsl:value-of select="generate-id(gml:TimePeriod)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@gml:id"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="gml:beginPosition"/>
      <xsl:copy-of select="gml:endPosition"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="gml32:TimePeriod[not(@gml32:id) or normalize-space(@gml32:id)='' or normalize-space(@gml32:id)='Temporal']">
    <xsl:element name="gml:TimePeriod" namespace="http://www.opengis.net/gml">
      <xsl:choose>
        <xsl:when test="normalize-space(@gml32:id)='' or normalize-space(@gml32:id)='Temporal'">
          <xsl:attribute name="gml:id">
            <xsl:value-of select="generate-id(gml32:TimePeriod)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="gml:id">
            <xsl:value-of select="@gml32:id"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="gml32:beginPosition"/>
      <xsl:apply-templates select="gml32:endPosition"/>
    </xsl:element>
  </xsl:template>

  <!-- remove online at this place -->
  <!-- Comment for testing -->
  <!--<xsl:template match="//gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine" />-->

  <!-- delete environmentDescription element -->
  <xsl:template match="//gmd:environmentDescription"/>

  <!-- extents correction -->
  <xsl:template match="gmd:geographicElement/gmd:EX_GeographicBoundingBox">
    <xsl:variable name="westValue" select="gmd:westBoundLongitude/gco:Decimal" as="xs:float" />
    <xsl:variable name="eastValue" select="gmd:eastBoundLongitude/gco:Decimal" as="xs:float" />
    <xsl:variable name="southValue" select="gmd:southBoundLatitude/gco:Decimal" as="xs:float" />
    <xsl:variable name="northValue" select="gmd:northBoundLatitude/gco:Decimal" as="xs:float"/>
    <xsl:copy copy-namespaces="no">
      <gmd:westBoundLongitude>
        <gco:Decimal><xsl:value-of select="format-number($westValue, '#.00')"/></gco:Decimal>
      </gmd:westBoundLongitude>
      <gmd:eastBoundLongitude>
        <xsl:choose>
          <xsl:when test="$westValue eq $eastValue">
            <gco:Decimal><xsl:value-of select="format-number($eastValue + 0.0001, '#.00')"/></gco:Decimal>
          </xsl:when>
          <xsl:otherwise>
            <gco:Decimal><xsl:value-of select="format-number($eastValue, '#.00')"/></gco:Decimal>
          </xsl:otherwise>
        </xsl:choose>
      </gmd:eastBoundLongitude>
      <gmd:southBoundLatitude>
        <gco:Decimal><xsl:value-of select="format-number($southValue, '#.00')"/></gco:Decimal>
      </gmd:southBoundLatitude>
      <gmd:northBoundLatitude>
        <xsl:choose>
          <xsl:when test="$southValue eq $northValue">
            <gco:Decimal><xsl:value-of select="format-number($northValue + 0.0001, '#.00')"/></gco:Decimal>
          </xsl:when>
          <xsl:otherwise>
            <gco:Decimal><xsl:value-of select="format-number($northValue, '#.00')"/></gco:Decimal>
          </xsl:otherwise>
        </xsl:choose>
      </gmd:northBoundLatitude>
    </xsl:copy>
  </xsl:template>

  <!-- end of additional rules -->


  <!-- 1. If metadata type is service, then
  (a) remove exisiting gmd:identificationInfo/srv:SV_ServiceIdentification/srv:couplingType
  (b) remove existing gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations
  (c) create new element as <srv:couplingType gco:nilReason='missing'> and add it at proper place as follows:
    (c.1) If gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn is present, add srv:couplingType just before srv:operatesOn
    (c.2) If srv:operatesOn is missing, add srv:couplingType as last child of srv:SV_ServiceIdentification
  (d) create new element as <srv:containsOperations gco:nilReason='missing'> and add it at proper place as follows:
    (d.1) If gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn is present, add srv:containsOperations after srv:couplingType and before srv:operatesOn
    (d.2) If srv:operatesOn is missing, add srv:containsOperations as last child of srv:SV_ServiceIdentification -->
  <xsl:template match="gmd:MD_Metadata[gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue = 'service']/gmd:identificationInfo/srv:SV_ServiceIdentification">
    <xsl:copy copy-namespaces="no">
      <!--<xsl:apply-templates select="node()[not(self::srv:couplingType)][not(self::srv:containsOperations)][not(self::srv:operatesOn)][not(self::gmd:topicCategory)]"/>-->

      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />
      <!-- Don't copy gmd:topicCategory -->
      <!--<xsl:apply-templates select="gmd:topicCategory" />-->

      <xsl:apply-templates select="gmd:descriptiveKeywords" />

      <xsl:if test="not(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'Spatial scope'])">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <gmd:keyword>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialScope/national">Nationell</gmx:Anchor>
            </gmd:keyword>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title>
                  <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialScope">Spatial scope</gmx:Anchor>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2019-05-22</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />

      <!-- Process gmd:resourceConstraints for INSPIRE TG 1.3 (backport) -->
      <xsl:apply-templates select="." mode="process-resource-constraints" />

      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="srv:serviceType" />
      <xsl:apply-templates select="srv:serviceTypeVersion" />
      <xsl:apply-templates select="srv:accessProperties" />
      <xsl:apply-templates select="srv:restrictions" />
      <xsl:apply-templates select="srv:keywords" />
      <xsl:apply-templates select="srv:extent" />
      <xsl:apply-templates select="srv:coupledResource" />
      <!-- Don't copy srv:couplingType, srv:containsOperations, srv:operatesOn -->
      <!--<xsl:apply-templates select="srv:couplingType" />
      <xsl:apply-templates select="srv:containsOperations" />
      <xsl:apply-templates select="srv:operatesOn" />-->

      <xsl:choose>
        <xsl:when test="srv:operatesOn">
          <srv:couplingType>
            <xsl:attribute name="gco:nilReason">
              <xsl:value-of select="'missing'"/>
            </xsl:attribute>
          </srv:couplingType>

          <srv:containsOperations>
            <xsl:attribute name="gco:nilReason">
              <xsl:value-of select="'missing'"/>
            </xsl:attribute>
          </srv:containsOperations>

          <xsl:apply-templates select="srv:operatesOn"/>
        </xsl:when>
        <xsl:otherwise>
          <srv:couplingType>
            <xsl:attribute name="gco:nilReason">
              <xsl:value-of select="'missing'"/>
            </xsl:attribute>
          </srv:couplingType>
          <srv:containsOperations>
            <xsl:attribute name="gco:nilReason">
              <xsl:value-of select="'missing'"/>
            </xsl:attribute>
          </srv:containsOperations>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--2. If gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions is missing, then
  (a) for each gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor,
    (a.1) create a clone(copy) of element gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions
    (a.2) create a new element gmd:transferOptions and add the cloned gmd:MD_DigitalTransferOptions under it.
  (b) Add all newly created gmd:transferOptions as children of gmd:distributionInfo/gmd:MD_Distribution (add after all existing children of gmd:MD_Distribution).-->
  <xsl:template match="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution">
    <xsl:variable name="isDownloadService" select="count(//srv:serviceType[gco:LocalName = 'download']) > 0" as="xs:boolean" />

    <xsl:variable name="addtransferOptions">
      <xsl:for-each select="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/*/gmd:distributorTransferOptions">

        <xsl:for-each select="gmd:MD_DigitalTransferOptions">
          <!-- Copy only only resources with url and protocol -->
          <xsl:variable name="onlineResources">
            <xsl:for-each select="gmd:onLine">
              <xsl:variable name="linkageValue" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
              <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/*/text()" />

              <xsl:if test="string(normalize-space($linkageValue)) and string(normalize-space($protocolValue))">
                <xsl:copy-of select="." copy-namespaces="no" />
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>

          <!-- Only add container if has valid online resources -->
          <xsl:if test="count($onlineResources/*) > 0">
            <xsl:choose>
              <xsl:when test="$isDownloadService = true() and count($onlineResources/*) > 1">

                <xsl:variable name="hasDownloadLinkWfs" select="count($onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:OGC:WFS']) > 0" />
                <xsl:variable name="hasDownloadLinkAtom" select="count($onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:Nedladdning:Atom']) > 0" />

                <gmd:transferOptions>
                  <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*" />
                    <xsl:copy-of select="gmd:unitsOfDistribution" copy-namespaces="no"/>
                    <xsl:copy-of select="gmd:transferSize" copy-namespaces="no"/>

                    <xsl:choose>
                      <xsl:when test="$hasDownloadLinkWfs = true()">
                        <xsl:copy-of select="$onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:OGC:WFS']" />
                      </xsl:when>
                      <xsl:when test="$hasDownloadLinkAtom = true()">
                        <xsl:copy-of select="$onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:Nedladdning:Atom']" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="$onlineResources" />
                      </xsl:otherwise>
                    </xsl:choose>

                    <xsl:copy-of select="gmd:offLine" copy-namespaces="no"/>
                  </xsl:copy>
                </gmd:transferOptions>

              </xsl:when>

              <xsl:otherwise>
                <gmd:transferOptions>
                  <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*" />
                    <xsl:copy-of select="gmd:unitsOfDistribution" copy-namespaces="no"/>
                    <xsl:copy-of select="gmd:transferSize" copy-namespaces="no"/>

                    <xsl:copy-of select="$onlineResources" />

                    <xsl:copy-of select="gmd:offLine" copy-namespaces="no"/>
                  </xsl:copy>
                </gmd:transferOptions>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="addformatsOptions">
      <xsl:for-each select="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/*/gmd:distributorFormat">
        <xsl:variable name="nameValue" select="gmd:MD_Format/gmd:name/gco:CharacterString" />
        <xsl:variable name="versionValue" select="gmd:MD_Format/gmd:version/gco:CharacterString" />

        <xsl:if test="string(normalize-space($nameValue)) and string(normalize-space($versionValue))">
          <gmd:distributionFormat>
            <xsl:copy-of select="gmd:MD_Format" copy-namespaces="no"/>
          </gmd:distributionFormat>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="$addformatsOptions"/>

      <xsl:apply-templates select="gmd:distributor"/>

      <xsl:copy-of select="$addtransferOptions"/>
    </xsl:copy>
  </xsl:template>



  <!-- 3. Remove non-digits from temporal dates -->
  <!-- Set indeterminatePosition to now on end date if begindate as value an enddate is empty -->
  <!-- Verify that GML ID has proper value -->
  <xsl:template match="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
    <xsl:element name="gml:TimePeriod" namespace="http://www.opengis.net/gml">
      <xsl:copy-of select="@*" />

      <xsl:if test="not(string(@gml:id))">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:variable name="newBeginPosition" select="translate(gml:beginPosition/text(), translate(.,'0123456789-',''), '')"/>
      <xsl:variable name="newEndPosition" select="translate(gml:endPosition/text(), translate(.,'0123456789-',''), '')"/>

      <xsl:variable name="newBeginPosition2">
        <xsl:choose>
          <!-- Handle year-month format not allowed in INSPIRE validator (requires YYYY-MM-DD) -->
          <xsl:when test="string-length($newBeginPosition) = 7">
            <xsl:value-of select="$newBeginPosition"/>-01
          </xsl:when>

          <!-- Handle year format not allowed in INSPIRE validator (requires YYYY) -->
          <xsl:when test="string-length($newBeginPosition) = 4">
            <xsl:value-of select="$newBeginPosition"/>-01-01
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$newBeginPosition"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="newEndPosition2">
        <xsl:choose>
          <!-- Handle year-month format not allowed in INSPIRE validator (requires YYYY-MM-DD) -->
          <xsl:when test="string-length($newEndPosition) = 7">
            <xsl:variable name="newEndPositionAsString" select="concat($newEndPosition, '-01')" />

            <xsl:choose>
              <xsl:when test="$newEndPositionAsString castable as xs:date">
                <xsl:variable name="dtNewEndPosition" as="xs:date" select="xs:date($newEndPositionAsString)"/>
                <xsl:variable name="finalDate" select="xs:date($dtNewEndPosition) - xs:dayTimeDuration(concat('P', day-from-date($dtNewEndPosition) - 1, 'D')) + xs:yearMonthDuration('P1M') - xs:dayTimeDuration('P1D')" />
                <xsl:value-of select="$finalDate" />
              </xsl:when>

              <xsl:otherwise>
                <!-- Keep original value: will not validate as the original date will not be valid. Will require manual fixing -->
                <xsl:value-of select="$newEndPosition" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <!-- Handle year format not allowed in INSPIRE validator (requires YYYY) -->
          <xsl:when test="string-length($newEndPosition) = 4">
            <xsl:value-of select="$newEndPosition" />-12-31
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$newEndPosition"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <gml:beginPosition>
        <xsl:value-of select="$newBeginPosition2"/>
      </gml:beginPosition>
      <gml:endPosition>
        <xsl:if test="not(string($newEndPosition2))">
          <xsl:attribute name="indeterminatePosition">now</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$newEndPosition2"/>
      </gml:endPosition>
    </xsl:element>
  </xsl:template>

  <xsl:template match="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml32:TimePeriod">
    <xsl:message>1</xsl:message>
    <xsl:element name="gml:TimePeriod" namespace="http://www.opengis.net/gml">

      <xsl:choose>
        <xsl:when test="normalize-space(@gml32:id)='' or normalize-space(@gml32:id)='Temporal'">
          <xsl:attribute name="gml:id">
            <xsl:value-of select="generate-id(gml32:TimePeriod)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="gml:id">
            <xsl:value-of select="@gml32:id"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:variable name="newBeginPosition" select="translate(gml32:beginPosition/text(), translate(.,'0123456789-',''), '')"/>
      <xsl:variable name="newEndPosition" select="translate(gml32:endPosition/text(), translate(.,'0123456789-',''), '')"/>

       <xsl:variable name="newBeginPosition2">
        <xsl:choose>
          <!-- Handle year-month format not allowed in INSPIRE validator (requires YYYY-MM-DD) -->
          <xsl:when test="string-length($newBeginPosition) = 7">
            <xsl:value-of select="$newBeginPosition"/>-01
          </xsl:when>

          <!-- Handle year format not allowed in INSPIRE validator (requires YYYY) -->
          <xsl:when test="string-length($newBeginPosition) = 4">
            <xsl:value-of select="$newBeginPosition"/>-01-01
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$newBeginPosition"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

       <xsl:variable name="newEndPosition2">
        <xsl:choose>
          <!-- Handle year-month format not allowed in INSPIRE validator (requires YYYY-MM-DD) -->
          <xsl:when test="string-length($newEndPosition) = 7">
            <xsl:variable name="newEndPositionAsString" select="concat($newEndPosition, '-01')" />

            <xsl:choose>
              <xsl:when test="$newEndPositionAsString castable as xs:date">
                <xsl:variable name="dtNewEndPosition" as="xs:date" select="xs:date($newEndPositionAsString)"/>
                <xsl:variable name="finalDate" select="xs:date($dtNewEndPosition) - xs:dayTimeDuration(concat('P', day-from-date($dtNewEndPosition) - 1, 'D')) + xs:yearMonthDuration('P1M') - xs:dayTimeDuration('P1D')" />
                <xsl:value-of select="$finalDate" />
              </xsl:when>

              <xsl:otherwise>
                <!-- Keep original value: will not validate as the original date will not be valid. Will require manual fixing -->
                <xsl:value-of select="$newEndPosition" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <!-- Handle year format not allowed in INSPIRE validator (requires YYYY) -->
          <xsl:when test="string-length($newEndPosition) = 4">
            <xsl:value-of select="$newEndPosition" />-12-31
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$newEndPosition"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <gml:beginPosition>
        <xsl:value-of select="$newBeginPosition2"/>
      </gml:beginPosition>
      <gml:endPosition>
        <xsl:if test="not(string($newEndPosition2))">
          <xsl:attribute name="indeterminatePosition">now</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$newEndPosition2"/>
      </gml:endPosition>
    </xsl:element>
  </xsl:template>

  <!-- 4. For each gco:Date element, remove non-digits from date value -->
  <xsl:template match="gco:Date">
    <xsl:copy copy-namespaces="no">
      <xsl:variable name="newDate" select="translate(text(), translate(.,'0123456789-',''), '')"/>

      <xsl:choose>
        <!-- Handle year-month format not allowed in INSPIRE validator (requires YYYY-MM-DD) -->
        <xsl:when test="string-length($newDate) = 7">
          <xsl:value-of select="$newDate"/>-01
        </xsl:when>

        <!-- Handle year format not allowed in INSPIRE validator (requires YYYY) -->
        <xsl:when test="string-length($newDate) = 4">
          <xsl:value-of select="$newDate"/>-01-01
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of select="$newDate"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- 5. Remove temporal extent if empty beginPosition and endPosition -->
  <xsl:template match="gmd:temporalElement[gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition]">
    <xsl:choose>
      <xsl:when test="not(string(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition))  and
                      not(string(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition))">
        <!-- Remove element if empty values in beginPosition and endPosition -->
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="*" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gmd:temporalElement[gmd:EX_TemporalExtent/gmd:extent/gml32:TimePeriod/gml32:beginPosition]">
    <xsl:choose>
      <xsl:when test="not(string(gmd:EX_TemporalExtent/gmd:extent/gml32:TimePeriod/gml32:beginPosition))  and
        not(string(gmd:EX_TemporalExtent/gmd:extent/gml32:TimePeriod/gml32:endPosition))">
        <!-- Remove element if empty values in beginPosition and endPosition -->
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="*" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 6. Verify that GML ID has a proper value -->
  <xsl:template match="@gml:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@gml32:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="gml:id">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Identifier change from Anchor to CharacterString -->
  <xsl:template match="gmd:identifier[gmd:MD_Identifier/gmd:code/gmx:Anchor]/gmd:MD_Identifier/gmd:code">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <gco:CharacterString><xsl:value-of select="gmx:Anchor/@xlink:href" /></gco:CharacterString>
    </xsl:copy>
  </xsl:template>


  <!-- Fixed values for GEMET thesaurus name. Date type requires text value also -->
  <xsl:template match="gmd:thesaurusName[gmd:CI_Citation/gmd:title/*/text() = 'GEMET - INSPIRE themes, version 1.0']">
    <gmd:thesaurusName>
      <gmd:CI_Citation>
        <gmd:title>
          <gmx:Anchor xlink:href="http://www.eionet.europa.eu/gemet/inspire_themes">GEMET - INSPIRE themes, version 1.0</gmx:Anchor>
        </gmd:title>
        <gmd:date>
          <gmd:CI_Date>
            <gmd:date>
              <gco:Date>2008-06-01</gco:Date>
            </gmd:date>
            <gmd:dateType>
              <gmd:CI_DateTypeCode codeListValue="publication" codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode">publication</gmd:CI_DateTypeCode>
            </gmd:dateType>
          </gmd:CI_Date>
        </gmd:date>
      </gmd:CI_Citation>
    </gmd:thesaurusName>
  </xsl:template>


  <xsl:template match="gmd:MD_DataIdentification|srv:SV_ServiceIdentification" mode="process-resource-constraints">

    <!-- Step 1) Remove use limitation, ignore gmd:resourceConstraints[gmd:MD_Constraints/gmd:useLimitation] and create it from access restrictions and use constraints  -->

    <!-- Step 1.1) Move access restrictions and use constraints to use Limitation -->
    <xsl:variable name="countAccessRestrictions" select="count(gmd:resourceConstraints[gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[not(contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces'))]])" />
    <xsl:variable name="countUseConstraints" select="count(gmd:resourceConstraints[gmd:MD_LegalConstraints[gmd:useConstraints]/gmd:otherConstraints])" />

    <xsl:if test="($countAccessRestrictions + $countUseConstraints) > 0">
      <xsl:variable name="useLimitationsValue">
        <xsl:for-each select="gmd:resourceConstraints[gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[not(contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces'))]]">
          <xsl:value-of select="gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[not(contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces'))]/gmx:Anchor" />
          <xsl:if test="position() > 1">
            ###################
          </xsl:if>
        </xsl:for-each>

        <xsl:if test="$countAccessRestrictions = 1 and $countUseConstraints > 0">
          ###################
        </xsl:if>

        <xsl:for-each select="gmd:resourceConstraints[gmd:MD_LegalConstraints[gmd:useConstraints]/gmd:otherConstraints]">
          <xsl:value-of select="gmd:MD_LegalConstraints[gmd:useConstraints]/gmd:otherConstraints/gmx:Anchor" />
          <xsl:if test="position() > 1">
            ###################
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <gmd:resourceConstraints>
        <gmd:MD_Constraints>
          <gmd:useLimitation>
            <gco:CharacterString>
              <xsl:value-of select="$useLimitationsValue" />
            </gco:CharacterString>
          </gmd:useLimitation>
        </gmd:MD_Constraints>
      </gmd:resourceConstraints>
    </xsl:if>

    <!-- Step 2) Copy Limitations on public access: LimitationsOnPublicAccess, removing the Anchor -->
    <xsl:for-each select="gmd:resourceConstraints[gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces')]]">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />

        <xsl:for-each select="gmd:MD_LegalConstraints">
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" />

            <xsl:apply-templates select="gmd:accessConstraints" />

            <gmd:otherConstraints>
              <gco:CharacterString><xsl:value-of select="gmd:otherConstraints/gmx:Anchor" /></gco:CharacterString>
            </gmd:otherConstraints>
          </xsl:copy>
        </xsl:for-each>
      </xsl:copy>
    </xsl:for-each>

    <!-- Step 3) Copy gmd:resourceConstraints[gmd:MD_SecurityConstraints] -->
    <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_SecurityConstraints]" />
  </xsl:template>

  <!-- Remove gmd:verticalElement in no valid values -->
  <xsl:template match="gmd:verticalElement">
    <xsl:variable name="minimumValue" select="gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real" />
    <xsl:variable name="maximumValue" select="gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real" />

    <xsl:variable name="validMinimumValue" select="$minimumValue castable as xs:double" />
    <xsl:variable name="validMaximumValue" select="$maximumValue castable as xs:double" />
    <xsl:variable name="validVerticalCRS" select="count(gmd:EX_VerticalExtent/gmd:verticalCRS/*) > 0 or
  		(string(gmd:EX_VerticalExtent/gmd:verticalCRS/@xlink:title) and gmd:EX_VerticalExtent/gmd:verticalCRS/@xlink:title != '{{vertical_crs_datum}}')" />

    <xsl:if test="$validMinimumValue and $validMaximumValue and $validVerticalCRS">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="*" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Remove gmd:distributorFormat in no valid values -->
  <xsl:template match="gmd:distributorFormat">
    <xsl:variable name="nameValue" select="gmd:MD_Format/gmd:name/gco:CharacterString" />
    <xsl:variable name="versionValue" select="gmd:MD_Format/gmd:version/gco:CharacterString" />

    <xsl:if test="string(normalize-space($nameValue)) and string(normalize-space($versionValue))">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="*" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Remove gmd:distributionFormat in no valid values -->
  <xsl:template match="gmd:distributionFormat">
    <xsl:variable name="nameValue" select="gmd:MD_Format/gmd:name/gco:CharacterString" />
    <xsl:variable name="versionValue" select="gmd:MD_Format/gmd:version/gco:CharacterString" />

    <xsl:if test="string(normalize-space($nameValue)) and string(normalize-space($versionValue))">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="*" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Remove gmd:distributorTransferOptions if no online resources with valid values: url  and protocol should be filled,
       and only copy filled online resources -->
  <xsl:template match="gmd:distributorTransferOptions">
    <xsl:variable name="onlineResources">
      <xsl:for-each select="gmd:MD_DigitalTransferOptions">
        <xsl:for-each select="gmd:onLine">
          <xsl:variable name="linkageValue" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
          <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/*/text()" />

          <xsl:if test="string(normalize-space($linkageValue)) and string(normalize-space($protocolValue))">
            <xsl:copy-of select="." copy-namespaces="no" />
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <!-- Only add container if has  valid online resources -->
    <xsl:if test="count($onlineResources/*) > 0">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />

        <xsl:for-each select="gmd:MD_DigitalTransferOptions">
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" />
            <xsl:copy-of select="gmd:unitsOfDistribution" copy-namespaces="no" />
            <xsl:copy-of select="gmd:transferSize" copy-namespaces="no" />

            <xsl:copy-of select="$onlineResources" />

            <xsl:copy-of select="gmd:offLine" copy-namespaces="no" />
          </xsl:copy>
        </xsl:for-each>
      </xsl:copy>
    </xsl:if>

  </xsl:template>

  <!-- Remove gmd:transferOptions if no online resources with valid values: url and protocol should be filled,
      and only copy filled online resources -->
  <xsl:template match="gmd:transferOptions">
    <xsl:variable name="isDownloadService" select="count(//srv:serviceType[gco:LocalName = 'download']) > 0" as="xs:boolean" />

    <xsl:variable name="onlineResources">
      <xsl:for-each select="gmd:MD_DigitalTransferOptions">
        <xsl:for-each select="gmd:onLine">
          <xsl:variable name="linkageValue" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
          <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/*/text()" />

          <xsl:if test="string(normalize-space($linkageValue)) and string(normalize-space($protocolValue))">
            <xsl:copy-of select="." copy-namespaces="no" />
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <!-- Only add container if has  valid online resources -->
    <xsl:if test="count($onlineResources/*) > 0">
      <xsl:choose>
        <xsl:when test="$isDownloadService = true() and count($onlineResources/*) > 1">

          <xsl:variable name="hasDownloadLinkWfs" select="count($onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:OGC:WFS']) > 0" />
          <xsl:variable name="hasDownloadLinkAtom" select="count($onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:Nedladdning:Atom']) > 0" />

          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" />

            <xsl:for-each select="gmd:MD_DigitalTransferOptions">
              <xsl:copy copy-namespaces="no">
                <xsl:copy-of select="@*" />
                <xsl:copy-of select="gmd:unitsOfDistribution" copy-namespaces="no" />
                <xsl:copy-of select="gmd:transferSize" copy-namespaces="no" />

                <xsl:choose>
                  <xsl:when test="$hasDownloadLinkWfs = true()">
                    <xsl:copy-of select="$onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:OGC:WFS']" />
                  </xsl:when>
                  <xsl:when test="$hasDownloadLinkAtom = true()">
                    <xsl:copy-of select="$onlineResources/*[gmd:CI_OnlineResource/gmd:protocol/*/text() = 'HTTP:Nedladdning:Atom']" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$onlineResources" />
                  </xsl:otherwise>
                </xsl:choose>

                <xsl:copy-of select="gmd:offLine" copy-namespaces="no" />
              </xsl:copy>
            </xsl:for-each>
          </xsl:copy>

        </xsl:when>

        <xsl:otherwise>
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" />

            <xsl:for-each select="gmd:MD_DigitalTransferOptions">
              <xsl:copy copy-namespaces="no">
                <xsl:copy-of select="@*" />
                <xsl:copy-of select="gmd:unitsOfDistribution" copy-namespaces="no" />
                <xsl:copy-of select="gmd:transferSize" copy-namespaces="no" />

                <xsl:copy-of select="$onlineResources" />

                <xsl:copy-of select="gmd:offLine" copy-namespaces="no" />
              </xsl:copy>
            </xsl:for-each>

          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

  </xsl:template>


  <!-- Remove gmd:pointOfContact details if ALL (organisation name, email, phone and role) are empty -->
  <xsl:template match="gmd:pointOfContact">
    <xsl:variable name="organisationNameValue" select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString" />
    <xsl:variable name="electronicMailAddressValue" select="gmd:CI_ResponsibleParty/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString" />
    <xsl:variable name="phoneValue" select="gmd:CI_ResponsibleParty/gmd:contactInfo/*/gmd:phone/*/gmd:electronicMailAddress/gco:CharacterString" />
    <xsl:variable name="roleValue" select="gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue" />

    <xsl:if test="string(normalize-space($organisationNameValue)) or
                  string(normalize-space($phoneValue)) or
                  string(normalize-space($electronicMailAddressValue)) or
                  string(normalize-space($roleValue))">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="*" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:resourceMaintenance">
    <xsl:choose>
      <!-- Remove gmd:resourceMaintenance if placeholder of empty -->
      <xsl:when test="gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode[not(@codeListValue) or @codeListValue='' or @codeListValue='{{maintenance_frequency}}']">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*|node()" mode="resourceMaintenance"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="gmd:maintenanceNote" mode="resourceMaintenance">
    <xsl:choose>
      <xsl:when test="string-length(normalize-space(gco:CharacterString))=0
				or normalize-space(gco:CharacterString)='{{maintenance_note}}'">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@*|node()" mode="resourceMaintenance">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()" mode="resourceMaintenance"/>
    </xsl:copy>
  </xsl:template>

  <!-- Some metadata has empty distributor contact (cardinality is 1:1). Remove empty element -->
  <xsl:template match="gmd:distributor/gmd:MD_Distributor">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <xsl:choose>
        <xsl:when test="count(gmd:distributorContact) > 1">
          <xsl:variable name="distributorContacts">
            <xsl:for-each select="gmd:distributorContact">
              <xsl:variable name="organisationNameValue" select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString" />
              <xsl:variable name="electronicMailAddressValue" select="gmd:CI_ResponsibleParty/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString" />
              <xsl:variable name="phoneValue" select="gmd:CI_ResponsibleParty/gmd:contactInfo/*/gmd:phone/*/gmd:electronicMailAddress/gco:CharacterString" />
              <xsl:variable name="roleValue" select="gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue" />

              <xsl:if test="string(normalize-space($organisationNameValue)) or
                  string(normalize-space($phoneValue)) or
                  string(normalize-space($electronicMailAddressValue)) or
                  string(normalize-space($roleValue))">
                <xsl:copy-of select="." copy-namespaces="no" />
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>

          <xsl:choose>
            <xsl:when test="count($distributorContacts/*) > 0">
              <!-- Keep first with filled information -->
              <xsl:copy-of select="$distributorContacts[1]" copy-namespaces="no"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="gmd:distributorContact" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:distributorContact" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gmd:distributionOrderProcess" />
      <xsl:apply-templates select="gmd:distributorFormat" />
      <xsl:apply-templates select="gmd:distributorTransferOptions" />

    </xsl:copy>
  </xsl:template>


  <!-- Remove gmd:report with empty values in gmd:result -->
  <xsl:template match="gmd:report[gmd:DQ_DomainConsistency]">
    <xsl:variable name="specificationTitle" select="gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:title/*/text()" />
    <xsl:variable name="specificationDate" select="gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date/*/gmd:date/*/text()" />

    <xsl:if test="string(normalize-space($specificationTitle)) and
			  	  string(normalize-space($specificationDate))
                  ">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="*" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Add missing gmd:explanation (mandatory element) for metadata missing it in gmd:DQ_ConformanceResult -->
  <xsl:template match="gmd:DQ_ConformanceResult[not(gmd:explanation)]">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:specification" />
      <gmd:explanation gco:nilReason='missing'>
        <gco:CharacterString></gco:CharacterString>
      </gmd:explanation>

      <xsl:apply-templates select="gmd:pass" />
    </xsl:copy>
  </xsl:template>

  <!-- Fix invalid gco:DateTime -->
  <xsl:template match="gco:DateTime">
    <xsl:variable name="value" select="." />

    <xsl:choose>
      <xsl:when test="string-length($value) &lt; 11">
        <gco:Date><xsl:value-of select="." /></gco:Date>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." copy-namespaces="no" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Remove invalid lst namespace elements -->
  <xsl:template match="lst:*" />


  <!-- Remove non existing gmd:hierarchyLevelDescription that is defined in some metadata -->
  <xsl:template match="gmd:hierarchyLevelDescription" />

  <!-- Remove point of contact with invalid role value informationOwner  -->
  <xsl:template match="gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'informationOwner']" />

  <!-- Replace serviceType ogc:wfs as valid value for INSPIRE: download -->
  <xsl:template match="srv:serviceType[lower-case(gco:LocalName) = 'ogc:wfs']/gco:LocalName">
    <gco:LocalName>download</gco:LocalName>
  </xsl:template>

  <!-- Replace serviceType ogc:wms as valid value for INSPIRE: view -->
  <xsl:template match="srv:serviceType[lower-case(gco:LocalName) = 'ogc:wms']/gco:LocalName">
    <gco:LocalName>view</gco:LocalName>
  </xsl:template>

  <!-- Fix invalid characterset value: 004 -->
  <xsl:template match="gmd:MD_CharacterSetCode[@codeListValue = '004']">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*[name() != 'codeListValue']" />
      <xsl:attribute name="codeListValue">utf8</xsl:attribute>

      <xsl:value-of select="." />
    </xsl:copy>
  </xsl:template>

  <!-- Some metadata has invalid gmd:RS_Identifier in gmd:referenceSystemInfo, without gmd:code - remove the element -->
  <xsl:template match="gmd:referenceSystemInfo[not(gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code)]" />

  <!-- Remove gmd:descriptiveKeywords without any gmd:keyword with values -->
  <xsl:template match="gmd:descriptiveKeywords">
    <xsl:variable name="countNonEmptyKeywords" select="count(gmd:MD_Keywords/gmd:keyword[normalize-space(*/text()) != ''])"/>

    <xsl:if test="$countNonEmptyKeywords > 0">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />

        <xsl:apply-templates select="*" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
