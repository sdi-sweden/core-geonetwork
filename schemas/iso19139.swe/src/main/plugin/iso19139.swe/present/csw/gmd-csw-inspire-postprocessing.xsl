<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gml="http://www.opengis.net/gml" xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gse="http://www.geodata.se/gse"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">
	
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <!-- Template for Copy data -->
    <xsl:template name="copyData" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
	
	<!-- InspireCSWProxy rules are copied here -->
	
	<!-- remove namespace declaration of gse from root element -->
	<xsl:template match="gmd:MD_Metadata">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:copy-of select="namespace::*[not(name() = 'gse')]" />
			<xsl:apply-templates select="@*|node()"/>
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
		<xsl:copy>
			<gco:CharacterString><xsl:value-of select="substring-after($keywordValue,' ')" /></gco:CharacterString>
		</xsl:copy>
	</xsl:template>
	
	<!--  remove gmd:type node from gmd:MD_Keywords -->
	<xsl:template match="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type"/>	
	
	<!-- Remove "distributorFormat" from metadata if "version" node not present or version value emtpy -->
	<xsl:template match="gmd:distributorFormat[
							gmd:MD_Format/gmd:version[. = ''] 
							or
							normalize-space(gmd:MD_Format/gmd:version/gco:CharacterString)='']"/>
							
	<!--  remove gmd:function from gmd:onLine if present -->
	<xsl:template match="gmd:onLine/gmd:function"/>	
	
	<!--  fix title for DQ_ConformanceResult -->
	<xsl:template match="DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title">	
		<gmd:title>
			<gco:CharacterString>KOMMISSIONENS FÖRORDNING (EU) nr 1089/2010 av den 23 november 2010 om genomförande av Europaparlamentets och rådets direktiv 2007/2/EG vad gäller interoperabilitet för rumsliga datamängder och datatjänster</gco:CharacterString>
		</gmd:title>
	</xsl:template>
	
	<!--  remove spatial resolution if gco:Distance is not present or is empty -->
	<xsl:template match="gmd:spatialResolution[
							gmd:MD_Resolution/gmd:distance/gco:Distance[. = '']
							or
							normalize-space(gmd:MD_Resolution/gmd:distance/gco:Distance)='']" />
							
	<!-- remove whole vertical element if both min and max values are empty or not present -->
	<xsl:template match="gmd:extent/gmd:EX_Extent/gmd:verticalElement">
		<xsl:choose>
			<xsl:when test="gmd:EX_VerticalExtent/gmd:minimumValue[. = '']
							and
							gmd:EX_VerticalExtent/gmd:maximumValue[. = '']"></xsl:when>
			<xsl:when test="gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real = ''
							and
							gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real = ''"></xsl:when>
			<xsl:otherwise>
				<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="gmd:verticalElement[. = '']" />
	
	<!-- If gmd:EX_VerticalExtent/gmd:minimumValue is empty, remove it -->
	<xsl:template match="gmd:EX_VerticalExtent/gmd:minimumValue[. = '' or gco:Real = '']" />
	<!-- If gmd:EX_VerticalExtent/gmd:maximumValue is empty, remove it -->
	<xsl:template match="gmd:EX_VerticalExtent/gmd:maximumValue[. = '' or gco:Real = '']" />
	
	
	<!-- ensure codespace always comes after code -->
	<xsl:template match="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
		<xsl:copy>
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
	<xsl:template match="gml:TimePeriod[not(@gml:id) or normalize-space(@gml:id)='' or normalize-space(@gml:id)='Temporal']">        
        <gml:TimePeriod>
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
		</gml:TimePeriod>
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
		<xsl:copy>
			<xsl:copy-of select="gmd:westBoundLongitude"/>			
			<gmd:eastBoundLongitude>
				<xsl:choose>
					<xsl:when test="$westValue eq $eastValue">
						<gco:Decimal><xsl:value-of select="$eastValue + 0.0001"/></gco:Decimal>
					</xsl:when>
					<xsl:otherwise>
						<gco:Decimal><xsl:value-of select="$eastValue"/></gco:Decimal>				
					</xsl:otherwise>	
				</xsl:choose>					
			</gmd:eastBoundLongitude>			
			<xsl:copy-of select="gmd:southBoundLatitude"/>			
			<gmd:northBoundLatitude>
				<xsl:choose>
					<xsl:when test="$southValue eq $northValue">
						<gco:Decimal><xsl:value-of select="$northValue + 0.0001"/></gco:Decimal>
					</xsl:when>
					<xsl:otherwise>
						<gco:Decimal><xsl:value-of select="$northValue"/></gco:Decimal>				
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
		<xsl:copy>
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
	<xsl:template match="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution[not(gmd:transferOptions)]">
		<xsl:copy>
			<xsl:copy-of select="gmd:distributor"/>
			<xsl:copy-of select="$addtransferOptions"/>	
		</xsl:copy>
    </xsl:template>
	
	<xsl:param name="addtransferOptions">
		<xsl:for-each select="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor">						
			<gmd:transferOptions>
				<xsl:copy-of select="gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions"/>	
			</gmd:transferOptions>
		</xsl:for-each>
	</xsl:param>

	<!-- 3. Remove non-digits from temporal dates -->
  <!-- Set indeterminatePosition to now on end date if begindate as value an enddate is empty -->
  <!-- Verify that GML ID has proper value -->
	<xsl:template match="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
		<xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:if test="not(string(@gml:id))">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:if>

			<xsl:variable name="newBeginPosition" select="translate(gml:beginPosition/text(), translate(.,'0123456789-',''), '')"/>
			<xsl:variable name="newEndPosition" select="translate(gml:endPosition/text(), translate(.,'0123456789-',''), '')"/>
			
      <gml:beginPosition>

				<xsl:value-of select="$newBeginPosition"/>
      </gml:beginPosition>
      <gml:endPosition>
        <xsl:if test="not(string($newEndPosition))">
          <xsl:attribute name="indeterminatePosition">now</xsl:attribute>
        </xsl:if>

				<xsl:value-of select="$newEndPosition"/>
      </gml:endPosition>
		</xsl:copy>
	</xsl:template>
	
	<!-- 4. For each gco:Date element, remove non-digits from date value -->
	<xsl:template match="gco:Date">
		<xsl:copy>
			<xsl:variable name="newDate" select="translate(text(), translate(.,'0123456789-',''), '')"/>
			<xsl:value-of select="$newDate"/>
		</xsl:copy>
	</xsl:template>

  <!-- 5. Remove temporal extent if empty beginPosition and endPosition -->
  <xsl:template match="gmd:temporalElement[gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition]">
    <xsl:choose>
      <xsl:when test="not(string(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition)) and
                      not(string(gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition))">
        <!-- Remove element if empty values in beginPosition and endPosition -->
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy>
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
	  <xsl:copy>
	    <xsl:copy-of select="@*" />

	  	<xsl:for-each select="gmd:MD_LegalConstraints">
	  	  <xsl:copy>
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
</xsl:stylesheet>
