<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="gmd xlink gco xsi gmx srv skos rdf">

  <!-- ================================================================= -->

  <xsl:param name="thesauriDir" />

  <xsl:variable name="inspire-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
  <xsl:variable name="inspire-theme" select="$inspire-thesaurus//skos:Concept"/>

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
        <gco:CharacterString>SS-EN-ISO-19115:2005-NMDP 4.0</gco:CharacterString>
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



  <!-- Change gmd:RS_Identifier to gmd:MD_Identifier as required by INSPIRE TG 2.0 -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier[gmd:RS_Identifier]">
    <xsl:copy>
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


  <xsl:template match="gmd:MD_DataIdentification">
    <xsl:copy>
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
      <xsl:apply-templates select="gmd:resourceSpecificUsage" />

      <!-- Process gmd:resourceConstraints for INSPIRE TG 2.0 -->
      <xsl:apply-templates select="." mode="process-resource-constraints" />

      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="gmd:spatialRepresentationType" />
      <xsl:apply-templates select="gmd:spatialResolution" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:topicCategory" />
      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />
      <xsl:apply-templates select="gmd:supplementalInformation" />

    </xsl:copy>
  </xsl:template>

  <xsl:template match="srv:SV_ServiceIdentification">
    <xsl:copy>
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
              <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode"
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
                      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode"
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
    <xsl:copy>
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
      <gco:CharacterString>GEMET - INSPIRE themes, version 1.0</gco:CharacterString>
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
                  <xsl:copy>
                    <xsl:copy-of select="@*" />

                    <xsl:for-each select="gmd:MD_Constraints">
                      <xsl:copy>
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
              <xsl:copy>
                <xsl:copy-of select="@*" />

                <xsl:for-each select="gmd:MD_LegalConstraints">
                  <xsl:copy>
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


  <!-- When importing records or opening records in editor remove transferoption -->
  <xsl:template match="gmd:transferOptions" />

  <!-- ================================================================= -->
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
