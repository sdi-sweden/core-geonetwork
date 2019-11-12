<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gmlOld="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gse="http://www.geodata.se/gse"
                xmlns:lst="http://www.lansstyrelsen.se"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="thesauriDir"></xsl:param>

  <xsl:variable name="inspire-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
  <xsl:variable name="inspire-theme" select="$inspire-thesaurus//skos:Concept"/>




  <!-- Template for Copy data -->
  <xsl:template name="copyData" match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmlOld:*">
    <xsl:element name="{name()}" namespace="http://www.opengis.net/gml/3.2">
      <xsl:copy-of select="namespace::*[not(name() = 'gml')]" />

      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@gmlOld:*">
    <xsl:attribute name="{name()}" namespace="http://www.opengis.net/gml/3.2">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="gmd:LanguageCode">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="codeList">http://www.loc.gov/standards/iso639-2/</xsl:attribute>
      <xsl:copy-of select="@*[not(name() = 'codeList')]" />

      <xsl:apply-templates select="*" />
    </xsl:copy>
  </xsl:template>

  <!--<xsl:template match="*[@codeListValue]">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <xsl:choose>
        <xsl:when test="string(.)"><xsl:value-of select="."/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@codeListValue"/></xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>-->

  <!-- remove namespace declaration of gse from root element -->
  <xsl:template match="gmd:MD_Metadata">
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select="namespace::*[not(name() = 'gse') and not(name() = 'gml')]" />
      <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
      <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>

      <!-- Fixed value for schemaLocation -->
      <xsl:attribute name="xsi:schemaLocation">http://www.isotc211.org/2005/gmd https://inspire.ec.europa.eu/draft-schemas/inspire-md-schemas-temp/apiso-inspire/apiso-inspire.xsd</xsl:attribute>
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
      <gco:CharacterString>4.0</gco:CharacterString>
    </gmd:metadataStandardVersion>
  </xsl:template>

  <!-- INSPIRE Validator requires publication date -->
  <xsl:template match="gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType">
    <gmd:dateType>
      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode"
                           codeListValue="publication">publication</gmd:CI_DateTypeCode>
    </gmd:dateType>
  </xsl:template>


  <!-- Change gmd:RS_Identifier to gmd:MD_Identifier as required by INSPIRE TG 2.0 -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier[gmd:RS_Identifier]">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />
      <gmd:MD_Identifier>
        <xsl:copy-of select="gmd:RS_Identifier/gmd:authority" />
        <xsl:copy-of select="gmd:RS_Identifier/gmd:code" />
      </gmd:MD_Identifier>
    </xsl:copy>
  </xsl:template>

  <!-- Change specification title to an Anchor if pointing to the INSPIRE spec -->
  <xsl:template match="gmd:specification">
    <xsl:variable name="title" select="gmd:CI_Citation/gmd:title/gco:CharacterString" />

    <xsl:copy copy-namespaces="no">
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

      <xsl:if test="not(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/text() = 'Spatial scope'])">
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

      <!-- If only utf8 remove it, otherwise the interoperability tests fail as consider that is default and should not be added -->
      <xsl:if test="count(gmd:characterSet) > 0">
        <xsl:variable name="countUtf8" select="count(gmd:characterSet[*/@codeListValue = 'utf8']) " />
        <xsl:variable name="countNonUtf8" select="count(gmd:characterSet[*/@codeListValue != 'utf8' and */@codeListValue != '']) " />

        <xsl:choose>
          <!-- Remove gmd:characterSet as not required to specify utf8 (default value) -->
          <xsl:when test="($countUtf8 > 0) and ($countNonUtf8 = 0)"></xsl:when>

          <!-- Copy the elements -->
          <xsl:otherwise>
            <xsl:apply-templates select="gmd:characterSet[*/@codeListValue != '']" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates select="gmd:topicCategory" />
      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />
      <xsl:apply-templates select="gmd:supplementalInformation" />

    </xsl:copy>
  </xsl:template>


  <xsl:template match="srv:SV_ServiceIdentification">
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

      <!-- Convert invalid gmd:topicCategory in services to related keywords in a vocabulary -->
      <xsl:if test="gmd:topicCategory">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
              <gmd:keyword>
                <gco:CharacterString><xsl:value-of select="." /></gco:CharacterString>
              </gmd:keyword>
            </xsl:for-each>
            <gmd:type>
              <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                                      codeListValue="theme"/>
            </gmd:type>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title>
                  <gco:CharacterString>Amnesomrade</gco:CharacterString>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2008-04-17</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode"
                                           codeListValue="publication"/>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
                <gmd:identifier>
                  <gmd:MD_Identifier>
                    <gmd:code>
                      <gmx:Anchor xmlns:gmx="http://www.isotc211.org/2005/gmx"
                                  xlink:href="http://localhost:8080/geonetwork/srv/swe/thesaurus.download?ref=external.theme.Initiativ">geonetwork.thesaurus.external.theme.topic-categories</gmx:Anchor>
                    </gmd:code>
                  </gmd:MD_Identifier>
                </gmd:identifier>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>

      <xsl:apply-templates select="gmd:descriptiveKeywords" />
      <xsl:apply-templates select="gmd:resourceSpecificUsage" />

      <!-- Process gmd:resourceConstraints for INSPIRE TG 2.0 -->
      <xsl:apply-templates select="." mode="process-resource-constraints" />

      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="srv:serviceType" />
      <xsl:apply-templates select="srv:serviceTypeVersion" />
      <xsl:apply-templates select="srv:accessProperties" />
      <xsl:apply-templates select="srv:restrictions" />
      <xsl:apply-templates select="srv:keywords" />
      <xsl:apply-templates select="srv:extent" />
      <xsl:apply-templates select="srv:coupledResource" />
      <xsl:apply-templates select="srv:couplingType" />
      <xsl:apply-templates select="srv:containsOperations" />
      <xsl:apply-templates select="srv:operatesOn" />

    </xsl:copy>
  </xsl:template>

  <!-- Fix invalid INSPIRE themes title in some metadata, should contain a , character -->
  <xsl:template match="gmd:thesaurusName/gmd:CI_Citation/gmd:title[gco:CharacterString = 'GEMET - INSPIRE themes version 1.0']">
    <gmd:title>
      <gco:CharacterString>GEMET - INSPIRE themes, version 1.0</gco:CharacterString>
    </gmd:title>
  </xsl:template>

  <!-- Convert GEMET keywords to Anchors -->
  <xsl:template match="gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'GEMET - INSPIRE themes, version 1.0' or
                                   ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'GEMET - INSPIRE themes version 1.0']">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <xsl:choose>
        <xsl:when test="gco:CharacterString">
          <xsl:variable name="value" select="lower-case(gco:CharacterString)" />
          <xsl:variable name="key" select="$inspire-theme[skos:prefLabel[@xml:lang='sv' and lower-case(text()) = $value]]/@rdf:about" />

          <gmx:Anchor xlink:href="{$key}"><xsl:value-of select="gco:CharacterString" /></gmx:Anchor>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>



  <!-- Fix -->
  <xsl:template match="gmd:thesaurusName/gmd:CI_Citation/gmd:title[gco:CharacterString = 'Tjänsteklassificering']">
    <gmd:title>
      <gco:CharacterString>kommissionens förordning (eu) nr 1089/2010 av den 23 november 2010 om genomförande av europaparlamentets och rådets direktiv 2007/2/eg vad gäller interoperabilitet för rumsliga datamängder och datatjänster</gco:CharacterString>
    </gmd:title>
  </xsl:template>


  <!-- Template to process gmd:resourceConstraints to upgrade them to TG 2.0.

      - Step 1) If the metadata has gmd:resourceConstraints "without" gmd:MD_LegalConstraints/gmd:otherConstraints ->  gmd:resourceConstraints are just copied.

      - Step 2) Otherwise process the gmd:resourceConstraints like:

          - Step 2.1) Exists gmd:resourceConstraints[gmd:MD_Constraints]
              - Copy all gmd:resourceConstraints[gmd:MD_Constraints]
              - In the first gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitations:
                  - copy the values from all gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString
                    (separated by ##### block) ONLY if the value is not related to an INSPIRE constraint (See variable "restrictions")

          - Step 2.2) Doesn't exist gmd:resourceConstraints[gmd:MD_Constraints]
               - Create a block gmd:resourceConstraints[gmd:MD_Constraints]
               - Proceed with same steps as Case 2.1)

      - Step 3) Copy gmd:resourceConstraints/gmd:MD_LegalConstraints without gmd:otherConstraints

      - Step 4) Copy gmd:resourceConstraints/gmd:MD_LegalConstraints MD_LegalConstraints with gmd:otherConstraints/gmx:Anchor

      - Step 5) Process gmd:resourceConstraints/gmd:MD_LegalConstraints with gmd:otherConstraints/gco:CharacterString
             - If gmd:otherConstraints/gco:CharacterString is related to INSPIRE constraint (See variable "restrictions"), change it to a gmx:Anchor
             - Otherwise remove the gmd:resourceConstraints block

      - Step 6) Copy gmd:resourceConstraints[gmd:MD_SecurityConstraints]

      - Step 7) Use Limitation = "inga tillämpliga villkor" -> Add gmd:useConstraints with No conditions apply to access and use (if not defined already)
-->
  <xsl:template match="gmd:MD_DataIdentification|srv:SV_ServiceIdentification" mode="process-resource-constraints">

    <!-- Restrictions related to INSPIRE -->
    <xsl:variable name="restrictions">
      <restrictions>
        <restriction value="Sekretess som omfattar offentliga myndigheters förfaranden, då sådan sekretess föreskrivs enligt lag" code="INSPIRE_Directive_Article13_1a" description="Sekretess som omfattar offentliga myndigheters förfaranden, då sådan sekretess föreskrivs enligt lag.(INSPIRE_Directive_Article13_1b)" URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1a"/>
        <restriction value="Internationella förbindelser, allmän säkerhet eller nationellt försvar" code="INSPIRE_Directive_Article13_1b" description="Internationella förbindelser, allmän säkerhet eller nationellt försvar (INSPIRE_Directive_Article13_1b)" URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1b"/>
        <restriction value="Domstolsförfaranden, personers möjlighet att få en rättvis rättegång eller en offentlig myndighets möjligheter att genomföra en undersökning av straffrättslig eller disciplinär art." code="INSPIRE_Directive_Article13_1c" description="Domstolsförfaranden, personers möjlighet att få en rättvis rättegång eller en offentlig myndighets möjligheter att genomföra en undersökning av straffrättslig eller disciplinär art (INSPIRE_Directive_Article13_1c)." URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1c"/>
        <restriction value="Sekretess som omfattar kommersiell eller industriell information, där sådan sekretess föreskrivs i nationell lagstiftning eller gemenskapslagstiftning i syfte att skydda legitima ekonomiska intressen, inbegripet det allmänna intresset att upprätthålla sekretess för statistiska uppgifter och skattesekretess" code="INSPIRE_Directive_Article13_1d" description="Sekretess som omfattar kommersiell eller industriell information, där sådan sekretess föreskrivs i nationell lagstiftning eller gemenskapslagstiftning i syfte att skydda legitima ekonomiska intressen, inbegripet det allmänna intresset att upprätthålla sekretess för statistiska uppgifter och skattesekretess (INSPIRE_Directive_Article13_1d)" URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1d"/>
        <restriction value="Immateriella rättigheter" code="INSPIRE_Directive_Article13_1e" description="Immateriella rättigheter (INSPIRE_Directive_Article13_1e)." URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1e"/>
        <restriction value="Sekretess som omfattar personuppgifter och/eller akter om en fysisk person, om denna person inte har gett sitt medgivande till att informationen lämnas ut till allmänheten, om sådan sekretess föreskrivs i nationell lagstiftning eller gemenskapslagstiftning" code="INSPIRE_Directive_Article13_1f" description="Sekretess som omfattar personuppgifter och/eller akter om en fysisk person, om denna person inte har gett sitt medgivande till att informationen lämnas ut till allmänheten, om sådan sekretess föreskrivs i nationell lagstiftning eller gemenskapslagstiftning (INSPIRE_Directive_Article13_1f)" URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1f"/>
        <restriction value="En persons intressen eller skyddet av en person, om denne frivilligt tillhandahållit den begärda informationen utan att vara skyldig att göra detta enligt lag eller utan att kunna tvingas att göra detta enligt lag, såvida inte denna person gett sitt medgivande till att informationen lämnas ut." code="INSPIRE_Directive_Article13_1g" description="En persons intressen eller skyddet av en person, om denne frivilligt tillhandahållit den begärda informationen utan att vara skyldig att göra detta enligt lag eller utan att kunna tvingas att göra detta enligt lag, såvida inte denna person gett sitt medgivande till att informationen lämnas ut.(INSPIRE_Directive_Article13_1g)" URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1g"/>
        <restriction value="Skydd av den miljö som informationen avser, exempelvis lokalisering av sällsynta arter" code="INSPIRE_Directive_Article13_1h" description="Skydd av den miljö som informationen avser, exempelvis lokalisering av sällsynta arter.(INSPIRE_Directive_Article13_1h)" URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1h"/>
        <restriction value="Inga begränsningar i publik åtkomst" code="noLimitations" description="There are no limitations on public access to spatial data sets and services." URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations"/>
        <restriction value="Inga begränsningar" code="noLimitations" description="There are no limitations on public access to spatial data sets and services." URL="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations"/>
      </restrictions>
    </xsl:variable>


    <xsl:choose>

      <!-- Step 1) Copy gmd:resourceConstraints as they are defined when no gmd:MD_LegalConstraints/gmd:otherConstraints -->
      <xsl:when test="count(gmd:resourceConstraints[gmd:MD_LegalConstraints/gmd:otherConstraints]) = 0">
        <xsl:apply-templates select="gmd:resourceConstraints" />
      </xsl:when>

      <!-- Step 2) Otherwise process the gmd:resourceConstraints -->
      <xsl:otherwise>
        <xsl:choose>
          <!-- Step 2.1) Exists gmd:resourceConstraints[gmd:MD_Constraints] -->
          <xsl:when test="gmd:resourceConstraints[gmd:MD_Constraints]">
            <!-- Copy gmd:MD_LegalConstraints/gmd:otherConstraints to first gmd:MD_Constraints/gmd:useLimitation -->
            <xsl:for-each select="gmd:resourceConstraints[gmd:MD_Constraints]">
              <xsl:choose>
                <xsl:when test="position() = 1">
                  <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*" />

                    <xsl:for-each select="gmd:MD_Constraints">
                      <xsl:copy copy-namespaces="no">
                        <xsl:copy-of select="@*" />

                        <gmd:useLimitation>
                          <gco:CharacterString>
                            <xsl:variable name="currentUseLimitation" select="gmd:useLimitation/gco:CharacterString"/>
                            <xsl:value-of select="gmd:useLimitation/gco:CharacterString" />

                            <xsl:for-each select="//gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints[string(gco:CharacterString)]">
                              <xsl:variable name="currentValue" select="gco:CharacterString" />

                              <!-- If the value is is the same as the current use limitations, don't copy it -->
                              <xsl:if test="$currentValue != $currentUseLimitation">
                                <xsl:choose>
                                  <!-- Is the text related to INSPIRE -> DON'T COPY IT -->
                                  <xsl:when test="string($restrictions/restrictions/restriction[lower-case(@value) = lower-case($currentValue)]/@value)">

                                  </xsl:when>
                                  <!-- Otherwise copy it -->
                                  <xsl:otherwise>
                                    ###################
                                    <xsl:value-of select="gco:CharacterString" />
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:if>
                            </xsl:for-each>

                          </gco:CharacterString>
                        </gmd:useLimitation>
                      </xsl:copy>
                    </xsl:for-each>
                  </xsl:copy>
                </xsl:when>
                <xsl:otherwise>

                  <xsl:apply-templates select="." />
                </xsl:otherwise>
              </xsl:choose>

            </xsl:for-each>

          </xsl:when>

          <!-- Step 2.2) Doesn't exist gmd:resourceConstraints[gmd:MD_Constraints] -> Create it -->
          <xsl:otherwise>
            <gmd:resourceConstraints>
              <gmd:MD_Constraints>
                <gmd:useLimitation>
                  <gco:CharacterString>
                    <!-- Copy gmd:MD_LegalConstraints/gmd:otherConstraints -->
                    <xsl:for-each select="//gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints[string(gco:CharacterString)]">

                      <xsl:variable name="currentValue" select="gco:CharacterString" />

                      <xsl:choose>
                        <!-- Is the text related to INSPIRE -> DON'T COPY IT -->
                        <xsl:when test="string($restrictions/restrictions/restriction[@value = $currentValue]/@value)">

                        </xsl:when>
                        <!-- Otherwise copy it -->
                        <xsl:otherwise>
                          <xsl:value-of select="gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString" />
                          ###################
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </gco:CharacterString>
                </gmd:useLimitation>
              </gmd:MD_Constraints>
            </gmd:resourceConstraints>

          </xsl:otherwise>
        </xsl:choose>

        <!-- Step 3) Copy gmd:resourceConstraints/gmd:MD_LegalConstraints without gmd:otherConstraints -->
        <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_LegalConstraints and not(gmd:MD_LegalConstraints/gmd:otherConstraints)]" />

        <!-- Step 4) Copy gmd:resourceConstraints/gmd:MD_LegalConstraints with gmd:otherConstraints/gmx:Anchor -->
        <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_LegalConstraints and
                                      gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor and
                                      not(gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString)]" />

        <!-- Step 5) Process gmd:resourceConstraints/MD_LegalConstraints with gmd:otherConstraints/gco:CharacterString -->
        <xsl:for-each select="gmd:resourceConstraints[gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString]">
          <xsl:variable name="hasOtherConstraintsRelatedToInspire"
                        select="count(gmd:MD_LegalConstraints/gmd:otherConstraints[gco:CharacterString = $restrictions/restrictions/restriction/@value ]) > 0" />
           <xsl:choose>
            <xsl:when test="$hasOtherConstraintsRelatedToInspire">
              <!-- If has any gmd:otherConstraints related to INSPIRE copy the gmd:resourceConstraints block and change
                   gmd:useConstraints to an Anchor -->
              <xsl:copy copy-namespaces="no">
                <xsl:copy-of select="@*" />

                <xsl:for-each select="gmd:MD_LegalConstraints">
                  <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*" />

                    <xsl:apply-templates select="gmd:useLimitation" />
                    <xsl:apply-templates select="gmd:accessConstraints" />
                    <xsl:apply-templates select="gmd:useConstraints" />

                    <xsl:apply-templates select="gmd:otherConstraints[gmx:Anchor]" />

                    <xsl:for-each select="gmd:otherConstraints[gco:CharacterString]">
                      <xsl:variable name="currentValue" select="gco:CharacterString" />
                      <xsl:choose>
                        <!-- Is the text related to INSPIRE -> Fill the anchor with the related INSPIRE restriction -->
                        <xsl:when test="string($restrictions/restrictions/restriction[lower-case(@value) = lower-case($currentValue)]/@value)">
                          <xsl:variable name="res" select="$restrictions/restrictions/restriction[lower-case(@value) = lower-case($currentValue)]" />

                          <gmd:otherConstraints>
                            <gmx:Anchor xlink:href="{$res/@URL}"><xsl:value-of select="$currentValue" /></gmx:Anchor>
                          </gmd:otherConstraints>
                        </xsl:when>
                        <!-- Otherwise don't copy it -->
                        <xsl:otherwise>

                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>

                  </xsl:copy>
                </xsl:for-each>
              </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
              <!-- Remove the gmd:resourceConstraints block -->
            </xsl:otherwise>
          </xsl:choose>


        </xsl:for-each>

        <!-- Step 6) Copy gmd:resourceConstraints[gmd:MD_SecurityConstraints] -->
        <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_SecurityConstraints]" />
      </xsl:otherwise>
    </xsl:choose>


    <!-- Step 7) Use Limitation = "inga tillämpliga villkor" -> Add gmd:useConstraints with No conditions apply to access and use (if not defined already) -->
    <xsl:if test="(count(gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation[lower-case(gco:CharacterString) = 'inga tillämpliga villkor'] ) > 0) and
      (count(//gmd:resourceConstraints[gmd:MD_LegalConstraints[gmd:useConstraints and gmd:otherConstraints/gmx:Anchor='inga tillämpliga villkor']]) = 0)">

      <gmd:resourceConstraints>
        <gmd:MD_LegalConstraints>
          <gmd:useConstraints>
            <gmd:MD_RestrictionCode
              codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_RestrictionCode"
              codeListValue="otherRestrictions" />
          </gmd:useConstraints>
          <gmd:otherConstraints>
            <gmx:Anchor
              xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/noConditionsApply">inga tillämpliga villkor</gmx:Anchor>
          </gmd:otherConstraints>
        </gmd:MD_LegalConstraints>
      </gmd:resourceConstraints>
    </xsl:if>

  </xsl:template>


  <!-- Remove gmd:aggregationInfo as not used and some records identifier with invalid content in gmd:aggregateDataSetIdentifier, causing the metadata failing the indexing/display -->
  <xsl:template match="gmd:aggregationInfo" />






  <!-- remove the parent of DQ_UsabilityElement, if DQ_UsabilityElement is present -->
  <xsl:template match="*[gmd:DQ_UsabilityElement]"/>

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
  <xsl:template match="gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date[gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2009/976' or
	      gmx:Anchor/@xlink:href='http://data.europa.eu/eli/reg/2010/1089']">
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


  <!--  remove spatial resolution if gco:Distance is not present or is empty -->
  <xsl:template match="gmd:spatialResolution[
							gmd:MD_Resolution/gmd:distance/gco:Distance[. = '']
							or
							normalize-space(gmd:MD_Resolution/gmd:distance/gco:Distance)='']" />


  <!-- Set gco:Distance in spatial resolution as float (2 decimals -->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance[string(normalize-space(gco:Distance))]/gco:Distance">
    <xsl:variable name="value" select="." as="xs:float" />

    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" />

      <xsl:value-of select="format-number($value, '#.00')"/>
    </xsl:copy>
  </xsl:template>

  <!-- ensure codespace always comes after code -->
  <xsl:template match="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="gmd:code"/>
      <xsl:copy-of select="gmd:codeSpace"/>
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
  <xsl:template match="gmd:descriptiveKeywords[starts-with(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString, 'SGU')]" />

  <!-- end of InspireCSWProxy rules -->


  <!-- Additional rules which are not in InspireCSWProxy -->


  <!-- example of timeperiod
  <gml:TimePeriod gml:id="Temporal">
    <gml:beginPosition>1968</gml:beginPosition>
    <gml:endPosition />
  </gml:TimePeriod>-->

  <!-- add attribute @gml:id to gml:timeperiod if missing -->
  <xsl:template match="gmlOld:TimePeriod[not(@gmlOld:id) or normalize-space(@gmlOld:id)='' or normalize-space(@gmlOld:id)='Temporal']">
    <xsl:element name="gml:TimePeriod" namespace="http://www.opengis.net/gml/3.2">
      <xsl:choose>
        <xsl:when test="normalize-space(@gmlOld:id)='' or normalize-space(@gmlOld:id)='Temporal'">
          <xsl:attribute name="gml:id">
            <xsl:value-of select="generate-id(gmlOld:TimePeriod)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="gml:id">
            <xsl:value-of select="@gmlOld:id"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="gmlOld:beginPosition"/>
      <xsl:apply-templates select="gmlOld:endPosition"/>
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

      <xsl:if test="not(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/text() = 'Spatial scope'])">
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

          <xsl:copy-of select="srv:operatesOn"/>
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
    <xsl:variable name="addtransferOptions">
      <xsl:for-each select="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/*/gmd:distributorTransferOptions">

        <xsl:for-each select="gmd:MD_DigitalTransferOptions">
          <!-- Copy only only resources with url, name and protocol -->
          <xsl:variable name="onlineResources">
            <xsl:for-each select="gmd:onLine">
              <xsl:variable name="linkageValue" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
              <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/*/text()" />
              <xsl:variable name="nameValue" select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" />

              <xsl:if test="string(normalize-space($linkageValue)) and string(normalize-space($protocolValue)) and
	        					string(normalize-space($nameValue))">
                <xsl:copy-of select="." />
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>

          <!-- Only add container if has valid online resources -->
          <xsl:if test="count($onlineResources/*) > 0">
            <gmd:transferOptions>
              <xsl:copy copy-namespaces="no">
                <xsl:copy-of select="@*" />
                <xsl:copy-of select="gmd:unitsOfDistribution" />
                <xsl:copy-of select="gmd:transferSize" />

                <xsl:copy-of select="$onlineResources" />

                <xsl:copy-of select="gmd:offLine" />
              </xsl:copy>
            </gmd:transferOptions>
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
            <xsl:copy-of select="gmd:MD_Format"/>
          </gmd:distributionFormat>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:copy copy-namespaces="no">
      <xsl:choose>
        <xsl:when test="not(gmd:distributionFormat)"><xsl:copy-of select="$addformatsOptions"/></xsl:when>
        <xsl:otherwise><xsl:apply-templates select="gmd:distributionFormat"/></xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gmd:distributor"/>

      <xsl:choose>
        <xsl:when test="not(gmd:transferOptions)"><xsl:copy-of select="$addtransferOptions"/></xsl:when>
        <xsl:otherwise><xsl:apply-templates select="gmd:transferOptions"/></xsl:otherwise>
      </xsl:choose>

    </xsl:copy>
  </xsl:template>



  <!-- 3. Remove non-digits from temporal dates -->
  <!-- Set indeterminatePosition to now on end date if begindate as value an enddate is empty -->
  <!-- Verify that GML ID has proper value -->
  <xsl:template match="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gmlOld:TimePeriod">

    <xsl:element name="gml:TimePeriod" namespace="http://www.opengis.net/gml/3.2">
      <xsl:choose>
        <xsl:when test="normalize-space(@gmlOld:id)='' or normalize-space(@gmlOld:id)='Temporal'">
          <xsl:attribute name="gml:id">
            <xsl:value-of select="generate-id(gmlOld:TimePeriod)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="gml:id">
            <xsl:value-of select="@gmlOld:id"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:variable name="newBeginPosition" select="translate(gmlOld:beginPosition/text(), translate(.,'0123456789-',''), '')"/>
      <xsl:variable name="newEndPosition" select="translate(gmlOld:endPosition/text(), translate(.,'0123456789-',''), '')"/>

      <gml:beginPosition>

        <xsl:value-of select="$newBeginPosition"/>
      </gml:beginPosition>
      <gml:endPosition>
        <xsl:if test="not(string($newEndPosition))">
          <xsl:attribute name="indeterminatePosition">now</xsl:attribute>
        </xsl:if>

        <xsl:value-of select="$newEndPosition"/>
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
  <xsl:template match="gmd:temporalElement[gmd:EX_TemporalExtent/gmd:extent/gmlOld:TimePeriod/gmlOld:beginPosition]">
    <xsl:choose>
      <xsl:when test="not(string(gmd:EX_TemporalExtent/gmd:extent/gmlOld:TimePeriod/gmlOld:beginPosition))  and
                      not(string(gmd:EX_TemporalExtent/gmd:extent/gmlOld:TimePeriod/gmlOld:endPosition))">
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
  <xsl:template match="@gmlOld:id">
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

  <!-- Remove gmd:distributorTransferOptions if no online resources with valid values: url, name and protocol should be filled,
       and only copy filled online resources -->
  <xsl:template match="gmd:distributorTransferOptions">
    <xsl:variable name="onlineResources">
      <xsl:for-each select="gmd:MD_DigitalTransferOptions">
        <xsl:for-each select="gmd:onLine">
          <xsl:variable name="linkageValue" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
          <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/*/text()" />
          <xsl:variable name="nameValue" select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" />

          <xsl:if test="string(normalize-space($linkageValue)) and string(normalize-space($protocolValue)) and
		        					string(normalize-space($nameValue))">
            <xsl:copy-of select="." />
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
            <xsl:copy-of select="gmd:unitsOfDistribution" />
            <xsl:copy-of select="gmd:transferSize" />

            <xsl:copy-of select="$onlineResources" />

            <xsl:copy-of select="gmd:offLine" />
          </xsl:copy>
        </xsl:for-each>
      </xsl:copy>
    </xsl:if>

  </xsl:template>

  <!-- Remove gmd:transferOptions if no online resources with valid values: url, name and protocol should be filled,
       and only copy filled online resources -->
  <xsl:template match="gmd:transferOptions">
    <xsl:variable name="onlineResources">
      <xsl:for-each select="gmd:MD_DigitalTransferOptions">
        <xsl:for-each select="gmd:onLine">
          <xsl:variable name="linkageValue" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
          <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/*/text()" />
          <xsl:variable name="nameValue" select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" />

          <xsl:if test="string(normalize-space($linkageValue)) and string(normalize-space($protocolValue)) and
		        					string(normalize-space($nameValue))">
            <xsl:copy-of select="." />
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
            <xsl:copy-of select="gmd:unitsOfDistribution" />
            <xsl:copy-of select="gmd:transferSize" />

            <xsl:copy-of select="$onlineResources" />

            <xsl:copy-of select="gmd:offLine" />
          </xsl:copy>
        </xsl:for-each>

      </xsl:copy>
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


  <!-- Some metadata has empty distributor contact (cardinality is 1:1). Remove empty element -->
  <xsl:template match="gmd:distributor/gmd:MD_Distributor">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />

      <xsl:choose>
        <xsl:when test="count(gmd:distributorContact) > 1">
          <!-- Keep first with filled information -->
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
                <xsl:copy-of select="." />
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

  <!-- Remove invalid lst namespace elements -->
  <xsl:template match="lst:*" />


  <!-- Remove non existing gmd:hierarchyLevelDescription that is defined in some metadata -->
  <xsl:template match="gmd:hierarchyLevelDescription" />

  <!-- Remove point of contact with invalid role value informationOwner  -->
  <xsl:template match="gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'informationOwner']" />

  <!-- Update url in codeList -->
  <xsl:template match="*[@codeList and name() != 'gmd:LanguageCode']" priority="100">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*[name() != 'codeList']" />
      <xsl:attribute name="codeList">http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#<xsl:value-of select="tokenize(@codeList, '#')[2]"/></xsl:attribute>

      <xsl:value-of select="." />
    </xsl:copy>
  </xsl:template>

  <!-- Fix invalid characterset value: 004 or empty -->
  <xsl:template match="gmd:MD_CharacterSetCode[@codeListValue = '004' or @codeListValue = '']" priority="200">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*[name() != 'codeListValue' and name() != 'codeList']" />
      <xsl:attribute name="codeList">http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#<xsl:value-of select="tokenize(@codeList, '#')[2]"/></xsl:attribute>

      <xsl:attribute name="codeListValue">utf8</xsl:attribute>

      <xsl:value-of select="." />
    </xsl:copy>
  </xsl:template>

  <!-- Split gmd:resourceConstraints having gmd:MD_Constraints and gmd:MD_SecurityConstraints.
       Some metadata has the 2 elements in 1 gmd:resourceConstraints, what is invalid -->
  <xsl:template match="gmd:resourceConstraints[gmd:MD_Constraints and gmd:MD_SecurityConstraints]">
    <gmd:resourceConstraints>
      <xsl:copy-of select="gmd:MD_Constraints" copy-namespaces="no" />
    </gmd:resourceConstraints>

    <gmd:resourceConstraints>
      <xsl:copy-of select="gmd:MD_SecurityConstraints" copy-namespaces="no" />
    </gmd:resourceConstraints>
  </xsl:template>
</xsl:stylesheet>
