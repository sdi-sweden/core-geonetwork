<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:gmlOld="http://www.opengis.net/gml"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
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

  <xsl:template match="gmlOld:*">
    <xsl:message>name: <xsl:value-of select="name()"/></xsl:message>
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
      <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode"
                           codeListValue="publication">publication</gmd:CI_DateTypeCode>
    </gmd:dateType>
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

      <xsl:apply-templates select="gmd:resourceConstraints" />

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
	        				<xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" />
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

	        					<xsl:copy-of select="gmd:unitsOfDistribution" />
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
    <xsl:message>Case 3</xsl:message>
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
			<xsl:value-of select="$newDate"/>
		</xsl:copy>
	</xsl:template>

  <!-- 5. Remove temporal extent if empty beginPosition and endPosition -->
  <xsl:template match="gmd:temporalElement[gmd:EX_TemporalExtent/gmd:extent/gmlOld:TimePeriod/gmlOld:beginPosition]">
    <xsl:message>Case 5</xsl:message>
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
	          <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" />
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

            <xsl:copy-of select="gmd:unitsOfDistribution" />
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
	          <xsl:variable name="protocolValue" select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" />
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

            <xsl:copy-of select="gmd:unitsOfDistribution" />
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
</xsl:stylesheet>