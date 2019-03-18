<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xlink='http://www.w3.org/1999/xlink'
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:gmx="http://www.isotc211.org/2005/gmx"
                  xmlns:srv="http://www.isotc211.org/2005/srv"
                  xmlns:uuid="java:java.util.UUID"
                  exclude-result-prefixes="gmd xlink gco xsi gmx srv uuid">

  <!-- ================================================================= -->

  <xsl:template match="/root">
    <xsl:apply-templates select="gmd:MD_Metadata"/>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:fileIdentifier" />
      <xsl:apply-templates select="gmd:language" />

      <xsl:if test="not(gmd:language)">
        <gmd:language>
          <gmd:LanguageCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#LanguageCode"
                            codeListValue="swe"/>
        </gmd:language>
      </xsl:if>

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


  <xsl:template match="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:title" />
      <xsl:apply-templates select="gmd:alternateTitle" />
      <xsl:apply-templates select="gmd:date" />
      <xsl:apply-templates select="gmd:edition" />
      <xsl:apply-templates select="gmd:editionDate" />

      <xsl:apply-templates select="gmd:identifier" />

      <!-- record of type dataset or dataset series are created we shall automatically add a UUID for resource-identfier -->
      <xsl:if test="(count(//gmd:hierarchyLevel[gmd:MD_ScopeCode/@codeListValue='dataset']) > 0) or
            (count(//gmd:hierarchyLevel[gmd:MD_ScopeCode/@codeListValue='series']) > 0)">

        <xsl:choose>
          <!-- Code doesn't exists - Add it -->
          <xsl:when test="not(gmd:identifier/gmd:MD_Identifier)">
            <xsl:variable name="uid" select="uuid:randomUUID()"/>

            <gmd:identifier>
              <gmd:MD_Identifier>
                <gmd:code>
                  <gco:CharacterString> <xsl:value-of select="$uid"/></gco:CharacterString>
                </gmd:code>
              </gmd:MD_Identifier>
            </gmd:identifier>
          </xsl:when>

          <!-- Do nothing -->
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates select="gmd:citedResponsibleParty" />
      <xsl:apply-templates select="gmd:presentationForm" />
      <xsl:apply-templates select="gmd:series" />
      <xsl:apply-templates select="gmd:otherCitationDetails" />
      <xsl:apply-templates select="gmd:collectiveTitle" />
      <xsl:apply-templates select="gmd:ISBN" />
      <xsl:apply-templates select="gmd:ISSN" />
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <xsl:template match="gmd:MD_DataIdentification">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:citation" />

      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />

      <xsl:if test="not(gmd:pointOfContact)">
        <gmd:pointOfContact>
          <gmd:CI_ResponsibleParty>
            <gmd:individualName>
              <gco:CharacterString/>
            </gmd:individualName>
            <gmd:organisationName>
              <gco:CharacterString/>
            </gmd:organisationName>
            <gmd:positionName>
              <gco:CharacterString/>
            </gmd:positionName>
            <gmd:contactInfo>
              <gmd:CI_Contact>
                <gmd:phone>
                  <gmd:CI_Telephone>
                    <gmd:voice>
                      <gco:CharacterString/>
                    </gmd:voice>
                    <gmd:facsimile>
                      <gco:CharacterString/>
                    </gmd:facsimile>
                  </gmd:CI_Telephone>
                </gmd:phone>
                <gmd:address>
                  <gmd:CI_Address>
                    <gmd:deliveryPoint>
                      <gco:CharacterString/>
                    </gmd:deliveryPoint>
                    <gmd:city>
                      <gco:CharacterString/>
                    </gmd:city>
                    <gmd:administrativeArea>
                      <gco:CharacterString/>
                    </gmd:administrativeArea>
                    <gmd:postalCode>
                      <gco:CharacterString/>
                    </gmd:postalCode>
                    <gmd:country>
                      <gco:CharacterString/>
                    </gmd:country>
                    <gmd:electronicMailAddress>
                      <gco:CharacterString/>
                    </gmd:electronicMailAddress>
                  </gmd:CI_Address>
                </gmd:address>
              </gmd:CI_Contact>
            </gmd:contactInfo>
            <gmd:role>
              <gmd:CI_RoleCode codeListValue="owner"
                               codeList="./resources/codeList.xml#CI_RoleCode"/>
            </gmd:role>
          </gmd:CI_ResponsibleParty>
        </gmd:pointOfContact>
      </xsl:if>

      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />
      <xsl:apply-templates select="gmd:descriptiveKeywords" />


      <xsl:if test="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Initiativ' or
                                                  gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmx:Anchor = 'Initiativ']) = 0">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <gmd:keyword>
              <gmx:Anchor xlink:href=""></gmx:Anchor>
            </gmd:keyword>
            <gmd:type>
              <gmd:MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_KeywordTypeCode" codeListValue="theme"/>
            </gmd:type>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title>
                  <gmx:Anchor xlink:href="https://resources.geodata.se/codelist/metadata/initiativ.xml">Initiativ</gmx:Anchor>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2017-01-01</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
                <gmd:identifier>
                  <gmd:MD_Identifier>
                    <gmd:code>
                      <gmx:Anchor xlink:href="{/root/env/url}/thesaurus.download?ref=external.theme.Initiativ">geonetwork.thesaurus.external.theme.Initiativ</gmx:Anchor>
                    </gmd:code>
                  </gmd:MD_Identifier>
                </gmd:identifier>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>

      <!--If GEMET Spatial themes exists or Initiativ=Inspire exists in XML then add Priority themes if not in in the metadata -->
      <xsl:variable name="hasPriorityDataset" select="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'INSPIRE priority data set']) > 0" />

      <xsl:if test="not($hasPriorityDataset)">
        <xsl:variable name="hasInitiativeAsInspire" select="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'Initiativ']/gmd:MD_Keywords/gmd:keyword/*[lower-case(text()) = 'inspire']) > 0" />

        <xsl:variable name="hasGEMETThesaurus" select="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text()= 'GEMET - INSPIRE themes, version 1.0']) > 0" />

        <xsl:if test="$hasInitiativeAsInspire or $hasGEMETThesaurus">
          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <gmx:Anchor xlink:href=""></gmx:Anchor>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode"
                                        codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/PriorityDataset">INSPIRE priority data set</gmx:Anchor>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2018-04-04</gco:Date>
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
                                    xlink:href="http://localhost:8080/geonetwork/srv/swe/thesaurus.download?ref=external.theme.PriorityDataset">geonetwork.thesaurus.external.theme.PriorityDataset</gmx:Anchor>
                      </gmd:code>
                    </gmd:MD_Identifier>
                  </gmd:identifier>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:if>

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />


      <!-- Add element for Use Limitation -->
      <xsl:if test="count(gmd:resourceConstraints[gmd:MD_Constraints/gmd:useLimitation]) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_Constraints>
            <gmd:useLimitation>
              <gco:CharacterString></gco:CharacterString>
            </gmd:useLimitation>
          </gmd:MD_Constraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <!-- Add element for Limitations on public access -->
      <xsl:if test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces')]) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:accessConstraints>
              <gmd:MD_RestrictionCode
                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"
                codeListValue="otherRestrictions"/>
            </gmd:accessConstraints>
            <gmd:otherConstraints>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations">Inga begränsningar för allmänhetens tillgång</gmx:Anchor>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <!-- Add element for Conditions for access and use -->
      <xsl:if test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[not(contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces'))]) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:accessConstraints>
              <gmd:MD_RestrictionCode
                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"
                codeListValue="otherRestrictions"/>
            </gmd:accessConstraints>
            <gmd:otherConstraints>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown">Villkor för åtkomst och användning okänd</gmx:Anchor>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <xsl:if test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints[gmd:useConstraints]/gmd:otherConstraints) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:useConstraints>
              <gmd:MD_RestrictionCode
                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"
                codeListValue="otherRestrictions"/>
            </gmd:useConstraints>
            <gmd:otherConstraints>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown">Villkor för åtkomst och användning okänd</gmx:Anchor>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="gmd:spatialRepresentationType" />

      <xsl:apply-templates select="gmd:spatialResolution" />

      <xsl:choose>
        <xsl:when test="count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale) = 0">
          <gmd:spatialResolution>
            <gmd:MD_Resolution>
              <gmd:equivalentScale>
                <gmd:MD_RepresentativeFraction>
                  <gmd:denominator>
                    <gco:Integer/>
                  </gmd:denominator>
                </gmd:MD_RepresentativeFraction>
              </gmd:equivalentScale>
            </gmd:MD_Resolution>
          </gmd:spatialResolution>
          <gmd:spatialResolution>
            <gmd:MD_Resolution>
              <gmd:equivalentScale>
                <gmd:MD_RepresentativeFraction>
                  <gmd:denominator>
                    <gco:Integer/>
                  </gmd:denominator>
                </gmd:MD_RepresentativeFraction>
              </gmd:equivalentScale>
            </gmd:MD_Resolution>
          </gmd:spatialResolution>
        </xsl:when>
        <xsl:when test="count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale) = 1">
          <gmd:spatialResolution>
            <gmd:MD_Resolution>
              <gmd:equivalentScale>
                <gmd:MD_RepresentativeFraction>
                  <gmd:denominator>
                    <gco:Integer/>
                  </gmd:denominator>
                </gmd:MD_RepresentativeFraction>
              </gmd:equivalentScale>
            </gmd:MD_Resolution>
          </gmd:spatialResolution>
        </xsl:when>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="count(gmd:spatialResolution/gmd:MD_Resolution/gmd:distance) = 0">
          <gmd:spatialResolution>
            <gmd:MD_Resolution>
              <gmd:distance>
                <gco:Distance uom=""></gco:Distance>
              </gmd:distance>
            </gmd:MD_Resolution>
          </gmd:spatialResolution>
          <gmd:spatialResolution>
            <gmd:MD_Resolution>
              <gmd:distance>
                <gco:Distance uom=""></gco:Distance>
              </gmd:distance>
            </gmd:MD_Resolution>
          </gmd:spatialResolution>
        </xsl:when>
        <xsl:when test="count(gmd:spatialResolution/gmd:MD_Resolution/gmd:distance) = 1">
          <gmd:spatialResolution>
            <gmd:MD_Resolution>
              <gmd:distance>
                <gco:Distance uom=""></gco:Distance>
              </gmd:distance>
            </gmd:MD_Resolution>
          </gmd:spatialResolution>
        </xsl:when>
      </xsl:choose>


      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:topicCategory" />
      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />
      <xsl:apply-templates select="gmd:supplementalInformation" />
    </xsl:copy>
  </xsl:template>

  <!-- Inflate organisation name and role if required -->
  <xsl:template match="gmd:CI_ResponsibleParty">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:individualName" />

      <xsl:apply-templates select="gmd:organisationName" />

      <xsl:if test="not(gmd:organisationName)">
        <gmd:organisationName gco:nilReason='missing'>
          <gco:CharacterString></gco:CharacterString>
        </gmd:organisationName>
      </xsl:if>

      <xsl:apply-templates select="gmd:positionName" />
      <xsl:apply-templates select="gmd:contactInfo" />

      <xsl:apply-templates select="gmd:role" />

      <xsl:if test="not(gmd:role)">
        <gmd:role>
          <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_RoleCode"
                           codeListValue=""/>
        </gmd:role>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:contactInfo/gmd:CI_Contact">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:phone" />
      <xsl:if test="not(gmd:phone)">
        <gmd:phone>
          <gmd:CI_Telephone>
            <gmd:voice gco:nilReason='missing'>
              <gco:CharacterString></gco:CharacterString>
            </gmd:voice>
          </gmd:CI_Telephone>
        </gmd:phone>
      </xsl:if>

      <xsl:apply-templates select="gmd:address" />
      <xsl:if test="not(gmd:address)">
        <gmd:address>
          <gmd:CI_Address>
            <gmd:electronicMailAddress gco:nilReason='missing'>
              <gco:CharacterString></gco:CharacterString>
            </gmd:electronicMailAddress>
          </gmd:CI_Address>
        </gmd:address>
      </xsl:if>

      <xsl:apply-templates select="gmd:onlineResource" />
      <xsl:apply-templates select="gmd:hoursOfService" />
      <xsl:apply-templates select="gmd:contactInstructions" />
    </xsl:copy>
  </xsl:template>

  <!-- Inflate electronic mail address if required -->
  <xsl:template match="gmd:address">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:for-each select="gmd:CI_Address">
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:apply-templates select="gmd:deliveryPoint" />
          <xsl:apply-templates select="gmd:city" />
          <xsl:apply-templates select="gmd:administrativeArea" />
          <xsl:apply-templates select="gmd:postalCode" />
          <xsl:apply-templates select="gmd:country" />
          <xsl:apply-templates select="gmd:electronicMailAddress" />

          <xsl:if test="not(gmd:electronicMailAddress)">
            <gmd:electronicMailAddress gco:nilReason='missing'>
              <gco:CharacterString></gco:CharacterString>
            </gmd:electronicMailAddress>
          </xsl:if>
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- Inflate voice phone if required -->
  <xsl:template match="gmd:phone">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:for-each select="gmd:CI_Telephone">
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:apply-templates select="gmd:voice" />

          <xsl:if test="not(gmd:voice)">
            <gmd:voice gco:nilReason='missing'>
              <gco:CharacterString></gco:CharacterString>
            </gmd:voice>
          </xsl:if>

          <xsl:apply-templates select="gmd:facsimile" />
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- Inflate format -->
  <xsl:template match="gmd:MD_Distributor">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:distributorContact" />
      <xsl:apply-templates select="gmd:distributionOrderProcess" />
      <xsl:apply-templates select="gmd:distributorFormat" />
      <xsl:if test="not(gmd:distributorFormat)">
        <gmd:distributorFormat>
          <gmd:MD_Format>
            <gmd:name gco:nilReason='missing'>
              <gco:CharacterString></gco:CharacterString>
            </gmd:name>
            <gmd:version gco:nilReason='missing'>
              <gco:CharacterString></gco:CharacterString>
            </gmd:version>
          </gmd:MD_Format>
        </gmd:distributorFormat>
      </xsl:if>
      <xsl:apply-templates select="gmd:distributorTransferOptions" />
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
      <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]/text() != 'Initiativ']" />

      <xsl:for-each select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Initiativ']">
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:for-each select="gmd:MD_Keywords">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:apply-templates select="gmd:keyword" />
              <xsl:apply-templates select="gmd:type" />

              <xsl:for-each select="gmd:thesaurusName">
                <xsl:copy>
                  <xsl:copy-of select="@*" />

                  <xsl:for-each select="gmd:CI_Citation">
                    <xsl:copy>
                      <xsl:copy-of select="@*" />

                      <xsl:apply-templates select="gmd:title" />
                      <xsl:apply-templates select="gmd:alternateTitle" />
                      <xsl:apply-templates select="gmd:date" />
                      <xsl:apply-templates select="gmd:edition" />
                      <xsl:apply-templates select="gmd:editionDate" />


                      <xsl:choose>
                        <!-- Add identifier section required by GeoNetwork -->
                        <xsl:when test="not(gmd:identifier)">
                          <gmd:identifier>
                            <gmd:MD_Identifier>
                              <gmd:code>
                                <gmx:Anchor xlink:href="{/root/env/url}/thesaurus.download?ref=external.theme.Initiativ">geonetwork.thesaurus.external.theme.Initiativ</gmx:Anchor>
                              </gmd:code>
                            </gmd:MD_Identifier>
                          </gmd:identifier>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:apply-templates select="gmd:identifier" />
                        </xsl:otherwise>
                      </xsl:choose>

                      <xsl:apply-templates select="gmd:citedResponsibleParty" />
                      <xsl:apply-templates select="gmd:presentationForm" />
                      <xsl:apply-templates select="gmd:series" />
                      <xsl:apply-templates select="gmd:otherCitationDetails" />
                      <xsl:apply-templates select="gmd:collectiveTitle" />
                      <xsl:apply-templates select="gmd:ISBN" />
                      <xsl:apply-templates select="gmd:ISSN" />

                    </xsl:copy>
                  </xsl:for-each>
                </xsl:copy>

              </xsl:for-each>
            </xsl:copy>
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>

      <xsl:if test="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Initiativ']) = 0">
        <gmd:descriptiveKeywords xmlns:gn="http://www.fao.org/geonetwork" xmlns:srv="http://www.isotc211.org/2005/srv">
          <gmd:MD_Keywords>
            <gmd:keyword>
              <gco:CharacterString></gco:CharacterString>
            </gmd:keyword>
            <gmd:type>
              <gmd:MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_KeywordTypeCode" codeListValue="theme"/>
            </gmd:type>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title>
                  <gco:CharacterString>Initiativ</gco:CharacterString>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2011-04-04</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
                <gmd:identifier>
                  <gmd:MD_Identifier>
                    <gmd:code>
                      <gmx:Anchor xlink:href="{/root/env/url}/thesaurus.download?ref=external.theme.Initiativ">geonetwork.thesaurus.external.theme.Initiativ</gmx:Anchor>
                    </gmd:code>
                  </gmd:MD_Identifier>
                </gmd:identifier>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>


      <!--If GEMET Spatial themes exists or Initiativ=Inspire exists in XML then add Priority themes if not in in the metadata -->
      <xsl:variable name="hasPriorityDataset" select="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'INSPIRE priority data set']) > 0" />
      <xsl:message>hasPriorityDataset: <xsl:value-of select="$hasPriorityDataset" /></xsl:message>

      <xsl:if test="not($hasPriorityDataset)">
        <xsl:variable name="hasInitiativeAsInspire" select="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'Initiativ']/gmd:MD_Keywords/gmd:keyword/*[lower-case(text()) = 'inspire']) > 0" />

         <xsl:variable name="hasGEMETThesaurus" select="count(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text()= 'GEMET - INSPIRE themes, version 1.0']) > 0" />

        <xsl:if test="$hasInitiativeAsInspire or $hasGEMETThesaurus">
          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <gmx:Anchor xlink:href=""></gmx:Anchor>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode"
                                        codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/PriorityDataset" >INSPIRE priority data set</gmx:Anchor>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2018-04-04</gco:Date>
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
                                    xlink:href="http://localhost:8080/geonetwork/srv/swe/thesaurus.download?ref=external.theme.PriorityDataset">geonetwork.thesaurus.external.theme.PriorityDataset</gmx:Anchor>
                      </gmd:code>
                    </gmd:MD_Identifier>
                  </gmd:identifier>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:if>


      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />

      <!-- Add element for Use Limitation -->
      <xsl:if test="count(gmd:resourceConstraints[gmd:MD_Constraints/gmd:useLimitation]) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_Constraints>
            <gmd:useLimitation>
              <gco:CharacterString></gco:CharacterString>
            </gmd:useLimitation>
          </gmd:MD_Constraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <!-- Add element for Limitations on public access -->
      <xsl:if test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces')]) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:accessConstraints>
              <gmd:MD_RestrictionCode
                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"
                codeListValue="otherRestrictions"/>
            </gmd:accessConstraints>
            <gmd:otherConstraints>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations">Inga begränsningar för allmänhetens tillgång</gmx:Anchor>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <!-- Add element for Conditions for access and use -->
      <xsl:if test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints[gmd:accessConstraints]/gmd:otherConstraints[not(contains(gmx:Anchor/@xlink:href, 'LimitationsOnPublicAcces'))]) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:accessConstraints>
              <gmd:MD_RestrictionCode
                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"
                codeListValue="otherRestrictions"/>
            </gmd:accessConstraints>
            <gmd:otherConstraints>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown">Villkor för åtkomst och användning okänd</gmx:Anchor>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <xsl:if test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints[gmd:useConstraints]/gmd:otherConstraints) = 0">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:useConstraints>
              <gmd:MD_RestrictionCode
                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"
                codeListValue="otherRestrictions"/>
            </gmd:useConstraints>
            <gmd:otherConstraints>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown">Villkor för åtkomst och användning okänd</gmx:Anchor>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

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

      <xsl:if test="not(srv:operatesOn)">
        <srv:operatesOn
                xlink:href="" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality">

    <xsl:variable name="isInspireMetadata" select="count(//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[*/text() = 'Inspire' and ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/*/text() = 'Initiativ']) > 0" />
    <xsl:variable name="isDataset" select="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset'" />
    <xsl:variable name="isService" select="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='service'" />

    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:scope" />
      <xsl:apply-templates select="gmd:report" />

      <!-- Conformance report check: add it if not available (dataset) -->
      <xsl:if test="$isInspireMetadata and
                    $isDataset and
                    count(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality[gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset']/gmd:report/gmd:DQ_DomainConsistency/gmd:result[starts-with(gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href, 'http://data.europa.eu/eli/reg')]) = 0">

        <xsl:message>dataset</xsl:message>
        <gmd:report>
          <gmd:DQ_DomainConsistency>
            <gmd:result>
              <gmd:DQ_ConformanceResult>
                <gmd:specification>
                  <gmd:CI_Citation>
                    <gmd:title>
                      <gmx:Anchor xlink:href="http://data.europa.eu/eli/reg/2010/1089">
                        KOMMISSIONENS FÖRORDNING (EU) nr 1089/2010 av den 23 november 2010 om genomförande av Europaparlamentets och rådets direktiv 2007/2/EG vad gäller interoperabilitet för rumsliga datamängder och datatjänster
                      </gmx:Anchor>
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

      </xsl:if>

      <!-- Conformance report check: add it if not available (service) -->
      <xsl:if test="$isInspireMetadata and
                    $isService and
                    count(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality[gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='service']/gmd:report/gmd:DQ_DomainConsistency/gmd:result[starts-with(gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href, 'http://data.europa.eu/eli/reg')]) = 0">

        <xsl:message>service</xsl:message>
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

      </xsl:if>

      <xsl:apply-templates select="gmd:lineage" />
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
