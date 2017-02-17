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

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!-- This formatter render an ISO19139 record based on the
  editor configuration file.


  The layout is made in 2 modes:
  * render-field taking care of elements (eg. sections, label)
  * render-value taking care of element values (eg. characterString, URL)

  3 levels of priority are defined: 100, 50, none

  -->


  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/gmd:MD_Metadata"/>




  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="gmd:MD_Metadata">
    <xsl:variable name="value"
                  select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
    <xsl:value-of select="$value/gco:CharacterString"/>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="gmd:MD_Metadata">
    <xsl:variable name="value"
                  select="gmd:identificationInfo/*/gmd:abstract"/>
    <xsl:value-of select="$value/gco:CharacterString"/>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="gmd:MD_Metadata">
  </xsl:template>


  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
                match="*[gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|
       gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gmd:PT_FreeText|gml:beginPosition|gml:endPosition|
       gco:Date|gco:DateTime|*/@codeListValue]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*|*/@codeListValue"/>
        <xsl:apply-templates mode="render-value" select="@*"/>
      </dd>
    </dl>
  </xsl:template>

  <!-- Case to handle gco.LocalName: start -->
  <xsl:template mode="render-field"
                match="*[gco:LocalName]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*|*/@codeListValue"/>
      </dd>
    </dl>
  </xsl:template>
  <!-- Case to handle gco.LocalName: end -->
  <!-- Some elements are only containers so bypass them -->
  <xsl:template mode="render-field"
                match="*[count(gmd:*) = 1]"
                priority="50">
    <xsl:param name="tabName" select="''" as="xs:string"/>

    <xsl:apply-templates mode="render-value" select="@*"/>
    <xsl:apply-templates mode="render-field" select="*">
      <xsl:with-param name="tabName" select="$tabName"/>
    </xsl:apply-templates>
  </xsl:template>


  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
                match="*[name() = $configuration/editor/fieldsWithFieldset/name
    or @gco:isoType = $configuration/editor/fieldsWithFieldset/name]|
      gmd:report/*|
      gmd:result/*|
      gmd:extent[name(..)!='gmd:EX_TemporalExtent']|
      *[$isFlatMode = false() and gmd:* and not(gco:CharacterString) and not(gmd:URL)]">

    <xsl:param name="tabName" select="''" as="xs:string"/>

    <div class="entry name">
      <h3>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:apply-templates mode="render-value"
                             select="@*"/>
      </h3>
      <div class="target">
        <xsl:apply-templates mode="render-field" select="*">
          <xsl:with-param name="tabName" select="$tabName"/>
        </xsl:apply-templates>
      </div>
    </div>
  </xsl:template>


  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="gmd:EX_GeographicBoundingBox[
          gmd:westBoundLongitude/gco:Decimal != '']">
		  
		  
	<xsl:variable name="west">
		<xsl:value-of select="xs:double(gmd:westBoundLongitude/gco:Decimal)"/>
	</xsl:variable>
	<xsl:variable name="north">
		<xsl:value-of select="xs:double(gmd:northBoundLatitude/gco:Decimal)"/>
	</xsl:variable>
	<xsl:variable name="east">
		<xsl:value-of select="xs:double(gmd:eastBoundLongitude/gco:Decimal)"/>
	</xsl:variable>
	<xsl:variable name="south">
		<xsl:value-of select="xs:double(gmd:southBoundLatitude/gco:Decimal)"/>
	</xsl:variable>

	<xsl:if test="$west != 0 and $north != 0 and $east != 0 and $south != 0">
		<xsl:copy-of select="gn-fn-render:bbox(
                            xs:double(gmd:westBoundLongitude/gco:Decimal),
                            xs:double(gmd:southBoundLatitude/gco:Decimal),
                            xs:double(gmd:eastBoundLongitude/gco:Decimal),
                            xs:double(gmd:northBoundLatitude/gco:Decimal))"/>
	</xsl:if>
	<xsl:apply-templates mode="render-field" select="gmd:westBoundLongitude"/>
	<xsl:apply-templates mode="render-field" select="gmd:eastBoundLongitude"/>
	<xsl:apply-templates mode="render-field" select="gmd:southBoundLatitude"/>
	<xsl:apply-templates mode="render-field" select="gmd:northBoundLatitude"/>
  </xsl:template>


  <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_ResponsibleParty]"
                priority="100">
    <xsl:variable name="email">
      <xsl:apply-templates mode="render-value"
                           select="*/gmd:contactInfo/
                                      */gmd:address/*/gmd:electronicMailAddress"/>
    </xsl:variable>

    <!-- Display name is <org name> - <individual name> (<position name> -->
    <xsl:variable name="displayName">
      <xsl:choose>
        <xsl:when
                test="normalize-space(*/gmd:organisationName) != '' and normalize-space(*/gmd:individualName) != ''">
          <!-- Org name may be multilingual -->
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:organisationName"/>
          -
          <xsl:value-of select="*/gmd:individualName"/>
          <xsl:if test="normalize-space(*/gmd:positionName) != ''">
            (<xsl:apply-templates mode="render-value"
                                  select="*/gmd:positionName"/>)
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*/gmd:organisationName|*/gmd:individualName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <dl class="gn-contact">
      <dt>
        <!-- <xsl:apply-templates mode="render-value"
                             select="*/gmd:role/*/@codeListValue"/> -->
		<xsl:variable name="parentNodeNameForCI_ResponsibleParty">
			<xsl:value-of select="name(.)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($parentNodeNameForCI_ResponsibleParty) = 'gmd:contact'">
				<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'metadataContactView')"/>
			</xsl:when>
			<xsl:when test="normalize-space($parentNodeNameForCI_ResponsibleParty) = 'gmd:distributorContact'">
				<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'distributorContactView')"/>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:apply-templates mode="render-value" select="*/gmd:role/*/@codeListValue"/>
			</xsl:otherwise>
		</xsl:choose>
      </dt>
      <dd>
        <div class="col-md-6">
          <address>
            <strong>
              <xsl:choose>
                <xsl:when test="normalize-space($email) != ''">
                  <i class="fa fa-envelope"></i>
                  <a href="mailto:{normalize-space($email)}"><xsl:value-of select="$displayName"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$displayName"/>
                </xsl:otherwise>
              </xsl:choose>
            </strong>
            <xsl:for-each select="*/gmd:contactInfo/*">
              <xsl:for-each select="gmd:address/*/(
                                          gmd:deliveryPoint|gmd:city|
                                          gmd:administrativeArea|gmd:postalCode|gmd:country)">
                <xsl:apply-templates mode="render-value" select="."/>
              </xsl:for-each>
            </xsl:for-each>
          </address>
        </div>
        <div class="col-md-6">
          <address>
            <xsl:for-each select="*/gmd:contactInfo/*">
              <xsl:for-each select="gmd:phone/*/gmd:voice[normalize-space(.) != '']">
                <xsl:variable name="phoneNumber">
                  <xsl:apply-templates mode="render-value" select="."/>
                </xsl:variable>
                <i class="fa fa-phone"></i>
                <a href="tel:{$phoneNumber}">
                  <xsl:value-of select="$phoneNumber"/>
                </a>
              </xsl:for-each>
              <xsl:for-each select="gmd:phone/*/gmd:facsimile[normalize-space(.) != '']">
                <xsl:variable name="phoneNumber">
                  <xsl:apply-templates mode="render-value" select="."/>
                </xsl:variable>
                <i class="fa fa-fax"></i>
                <a href="tel:{normalize-space($phoneNumber)}">
                  <xsl:value-of select="normalize-space($phoneNumber)"/>
                </a>
              </xsl:for-each>

			  <xsl:variable name="website">
					<xsl:apply-templates mode="render-value"
                           select="gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
			  </xsl:variable>
			  <xsl:if test="$website !=''">
				-
				<a href="http://{$website}" target="_blank">
					<xsl:value-of select="normalize-space($website)"/>
				</a>
			  </xsl:if>	
              <xsl:apply-templates mode="render-field"
                                   select="gmd:hoursOfService|gmd:contactInstructions"/>
              <xsl:apply-templates mode="render-field"
                                   select="gmd:onlineResource"/>

            </xsl:for-each>
          </address>
        </div>
      </dd>
    </dl>
  </xsl:template>
  <!-- LI_Lineage part -->
  <xsl:template mode="render-field" 
				match="gmd:lineage/gmd:LI_Lineage" 
				priority="100">
	<dl>
		<dt>
			<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'LI_LineageView')"/>
		</dt>
		<dd>
			<xsl:apply-templates mode="render-value" select="gmd:statement"/>
		</dd>
	</dl>
  </xsl:template>
  <!-- A Resursetyp is displayed with its translated codeListValue -->
  <xsl:template mode="render-field"
                match="gmd:hierarchyLevel"
                priority="100">
    <dl class="gn-contact">
      <dt>
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'hierarchyLevel')"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
                             select="gmd:MD_ScopeCode/@codeListValue"/>
        
      </dd>
    </dl>
  </xsl:template>
  
  <!-- A Resurskontakt is displayed with its role=owner -->
  <xsl:template mode="render-field"
                match="gmd:pointOfContact"
                priority="100">
	<xsl:param name="tabName" select="''" as="xs:string"/>
	<xsl:variable name="role" select="gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue"/>
	<xsl:if test="$role='owner'">
		<dl class="gn-contact">
		  <dt>
			<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'pointOfContact')"/>
		  </dt>
		  <dd>
			 <dl class="gn-contact">
				<xsl:variable name="orgName">
					<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
				</xsl:variable>
				<xsl:variable name="email">
					<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/>
				</xsl:variable>
				<address>
					<strong>
						<xsl:value-of select="$orgName"/>, 
						<i class="fa fa-envelope"></i>
						<a href="mailto:{normalize-space($email)}">
							<xsl:value-of select="$email"/>
						</a>
					</strong>
				</address>

				<!-- <table border="1" style="width:100%" bordercolor="#D3D3D3">
					<tr>
						<th style="padding-left:15px">
							<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'organisationName')"/>
						</th>
						<td style="padding-left:15px">
							<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
						</td>
					</tr>
					<tr>
						<th style="padding-left:15px">
							<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'roleLabel')"/>
						</th>
						<td style="padding-left:15px">
							<xsl:apply-templates mode="render-value"
								 select="gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue"/>
						</td>
					</tr>
					<tr>
						<th style="padding-left:15px">
							<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'electronicMailAddress')"/>
						</th>
						<td style="padding-left:15px">
							<xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/>
						</td>
					</tr>
				</table> -->
			</dl>
		  </dd>
		</dl>
		
	</xsl:if>
  </xsl:template>
  
  <!-- A Restriktioner:MD_Constraints is displayed -->
  <xsl:template mode="render-field"
                match="gmd:MD_Constraints"
                priority="100">
	<xsl:param name="tabName" select="''" as="xs:string"/>
	<xsl:for-each select="gmd:useLimitation">    
		<dl class="gn-contact">
		  <dt>
			<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'useLimitation')"/>
		  </dt>
		  <dd>		  
			<xsl:value-of select="gco:CharacterString"/>		
		  </dd>
		</dl>
	</xsl:for-each>
  </xsl:template>
  <!-- A Restriktioner:MD_LegalConstraints is displayed -->
  <xsl:template mode="render-field"
                match="gmd:MD_LegalConstraints"
                priority="100">
	<xsl:param name="tabName" select="''" as="xs:string"/>
	<xsl:for-each select="gmd:otherConstraints">
		<dl class="gn-contact">
		  <dt>
			<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'otherConstraints')"/>
		  </dt>
		  <dd>		  
			<xsl:value-of select="gco:CharacterString"/>		
		  </dd>
		</dl>
	</xsl:for-each>
	<xsl:for-each select="gmd:accessConstraints">
		<dl class="gn-contact">
		  <dt>
			<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'accessConstraints')"/>
		  </dt>
		  <dd>		  
			<xsl:value-of select="gco:CharacterString"/>
			<xsl:apply-templates mode="render-value" select="gmd:MD_RestrictionCode/@codeListValue"/>			
		  </dd>
		</dl>
	</xsl:for-each>
  </xsl:template>
  
  <!-- Metadata linkage -->
  <xsl:template mode="render-field"
                match="gmd:fileIdentifier"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*"/>
        <xsl:apply-templates mode="render-value" select="@*"/>

        <a class="btn btn-link" href="xml.metadata.get?id={$metadataId}">
          <i class="fa fa-file-code-o fa-2x"></i>
          <span data-translate="">metadataInXML</span>
        </a>
      </dd>
    </dl>
  </xsl:template>

  <!-- Linkage -->
  <!-- <xsl:template mode="render-field"
                match="*[gmd:CI_OnlineResource and */gmd:linkage/gmd:URL != '']"
                priority="100">
    <dl class="gn-link">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:variable name="linkDescription">
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:description"/>
        </xsl:variable>
        <a href="{*/gmd:linkage/gmd:URL}">
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:name"/>
        </a>
        <p>
          <xsl:value-of select="normalize-space($linkDescription)"/>
        </p>
      </dd>
    </dl>
  </xsl:template> -->
  
  <xsl:template mode="render-field"
                match="gmd:onLine[1]"
                priority="100">
	
		<dl class="gn-link">
			<dt>
				<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'onLinkLinks')"/>
			</dt>
			<dd>
				<table class="view-metadata-table">
					<tr>
						<th class="view-metadata-table-th-1">
							<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'onLineLinkProtocol')"/>
						</th>
						<th class="view-metadata-table-th-2">
							<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'onLineLinkName')"/>
						</th>
						<th class="view-metadata-table-th-3">
							<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'onLineLinkUrl')"/>
						</th>
					</tr>
					<xsl:for-each select="parent::node()/gmd:onLine">
						<xsl:variable name="protocol">
							<xsl:apply-templates mode="render-value" select="*/gmd:protocol"/>
						</xsl:variable>
						<xsl:variable name="aliasProtocol">
							<xsl:choose>
								<xsl:when test="normalize-space($protocol) = 'HTTP:OGC:WFS'">
									<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'http_ogc_wfs')"/>
								</xsl:when>
								<xsl:when test="normalize-space($protocol) = 'HTTP:OGC:WMS'">
									<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'http_ogc_wms')"/>
								</xsl:when>
								<xsl:when test="normalize-space($protocol) = 'HTTP:Information'">
									<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'http_information')"/>
								</xsl:when>
								<xsl:when test="normalize-space($protocol) = 'HTTP:Nedladdning'">
									<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'http_nedladdning')"/>
								</xsl:when>
								<xsl:when test="normalize-space($protocol) = 'HTTP:Nedladdning:ATOM'">
									<xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings, 'http_nedladdning_atom')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$protocol"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="name">
							<xsl:apply-templates mode="render-value" select="*/gmd:name"/>
						</xsl:variable>
						<xsl:variable name="url">
							<xsl:apply-templates mode="render-value" select="*/gmd:linkage/gmd:URL"/>
						</xsl:variable>
						<tr>
							<td class="view-metadata-table-td-1">
								<xsl:value-of select="normalize-space($aliasProtocol)"/>
							</td>
							<td class="view-metadata-table-td-2">
								<xsl:value-of select="normalize-space($name)"/>
							</td>
							<td class="view-metadata-table-td-3">
								<xsl:choose>
									<xsl:when test="normalize-space($protocol) = 'HTTP:Information'">
										<a href="{$url}" target="_blank">
											<xsl:value-of select="normalize-space($url)"/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space($url)"/>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</xsl:for-each>	
				</table>				
			</dd>
		</dl>
  </xsl:template>

  <xsl:template mode="render-field" match="gmd:onLine[position() > 1]" priority="100"/>
  
  <!-- Identifier -->
  <xsl:template mode="render-field"
                match="*[(gmd:RS_Identifier or gmd:MD_Identifier) and
                  */gmd:code/gco:CharacterString != '']"
                priority="100">
    <dl class="gn-code">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>

        <!-- <xsl:if test="*/gmd:codeSpace">
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:codeSpace"/>
          /
        </xsl:if> -->
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:code"/>
        <!-- <xsl:if test="*/gmd:version">
          / <xsl:apply-templates mode="render-value"
                                 select="*/gmd:version"/>
        </xsl:if>
        <p>
          <xsl:apply-templates mode="render-field"
                               select="*/gmd:authority"/>
        </p> -->
      </dd>
    </dl>
  </xsl:template>


  <!-- Display thesaurus name and the list of keywords -->
  <xsl:template mode="render-field"
                match="gmd:descriptiveKeywords[*/gmd:thesaurusName/gmd:CI_Citation/gmd:title]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*"/>

        <xsl:if test="*/gmd:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <div>
          <ul>
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:keyword/*"/>
            </li>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="gmd:descriptiveKeywords[not(*/gmd:thesaurusName/gmd:CI_Citation/gmd:title)]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:value-of select="$schemaStrings/noThesaurusName"/>
        <xsl:if test="*/gmd:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <div>
          <ul>
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:keyword/*"/>
            </li>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>

  <!-- Display all graphic overviews in one block -->
  <xsl:template mode="render-field"
                match="gmd:graphicOverview[1]"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul style="list-style-type: none;padding-left:2px;">
          <xsl:for-each select="parent::node()/gmd:graphicOverview">
            <xsl:variable name="label">
              <xsl:apply-templates mode="localised"
                                   select="gmd:MD_BrowseGraphic/gmd:fileDescription"/>
            </xsl:variable>
            <li>
              <img src="{gmd:MD_BrowseGraphic/gmd:fileName/*}"
                   alt="{$label}"
                   class="img-thumbnail"/>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="gmd:graphicOverview[position() > 1]"
                priority="100"/>


  <xsl:template mode="render-field"
                match="gmd:distributionFormat[1]"
                priority="100">
    <dl class="gn-format">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/gmd:distributionFormat">
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:name"/>
              (<xsl:apply-templates mode="render-value"
                                    select="*/gmd:version"/>)
              <p>
                <xsl:apply-templates mode="render-field"
                                     select="*/(gmd:amendmentNumber|gmd:specification|
                              gmd:fileDecompressionTechnique|gmd:formatDistributor)"/>
              </p>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="gmd:distributionFormat[position() > 1]"
                priority="100"/>

  <!-- Date -->
  <!-- <xsl:template mode="render-field"
                match="gmd:date"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:if test="*/gmd:dateType/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:dateType/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:date/*"/>
      </dd>
    </dl>
  </xsl:template>
  -->
  <xsl:template mode="render-field"
                match="gmd:date[1]"
                priority="100">
				
	  <xsl:param name="tabName" select="''" as="xs:string"/>
	  <xsl:choose>
		  <xsl:when test="$tabName = 'introduction'">
			  <xsl:variable name="dates">
				<xsl:for-each select="parent::node()/gmd:date">
					<xsl:value-of  select="*/gmd:date/gco:Date[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]"/>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
			  </xsl:variable>
			  <xsl:variable name="dateList" select="tokenize(normalize-space($dates), ',')" />
			  <xsl:variable name="latestDate" select="max($dateList)" />
			  <xsl:for-each select="parent::node()/gmd:date[gmd:CI_Date/gmd:date/gco:Date=$latestDate]">
					<dl class="gn-date">
					  <dt>
						<xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
						  (<xsl:apply-templates mode="render-value"	select="*/gmd:dateType/*/@codeListValue"/>)
					  </dt>
					  <dd>
						<xsl:apply-templates mode="render-value" select="*/gmd:date/*"/>
					  </dd>
					</dl>
			  </xsl:for-each>
		  </xsl:when>
          <xsl:otherwise>
			  <xsl:for-each select="parent::node()/gmd:date">
					<dl class="gn-date">
					  <dt>
						<xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
						  (<xsl:apply-templates mode="render-value"	select="*/gmd:dateType/*/@codeListValue"/>)
					  </dt>
					  <dd>
						<xsl:apply-templates mode="render-value" select="*/gmd:date/*"/>
					  </dd>
					</dl>
			  </xsl:for-each>
          </xsl:otherwise>
	  </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-field" match="gmd:date[position() > 1]" priority="100"/>
  
  <!-- Enumeration -->
  <xsl:template mode="render-field"
                match="gmd:topicCategory[1]|gmd:obligation[1]|gmd:pointInPixel[1]"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul style="list-style-type: none;padding-left:2px;">
          <xsl:for-each select="parent::node()/(gmd:topicCategory|gmd:obligation|gmd:pointInPixel)">
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*"/>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="gmd:topicCategory[position() > 1]|
                        gmd:obligation[position() > 1]|
                        gmd:pointInPixel[position() > 1]"
                priority="100"/>


  <!-- Link to other metadata records -->
  <xsl:template mode="render-field"
                match="*[@uuidref]"
                priority="100">
    <xsl:variable name="nodeName" select="name()"/>

    <!-- Only render the first element of this kind and render a list of
    following siblings. -->
    <xsl:variable name="isFirstOfItsKind"
                  select="count(preceding-sibling::node()[name() = $nodeName]) = 0"/>
    <xsl:if test="$isFirstOfItsKind">
      <dl class="gn-md-associated-resources">
        <dt>
          <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        </dt>
        <dd>
          <ul>
            <xsl:for-each select="parent::node()/*[name() = $nodeName]">
              <li><a href="#uuid={@uuidref}">
                <i class="fa fa-link"></i>
                <xsl:value-of select="gn-fn-render:getMetadataTitle(@uuidref, $language)"/>
              </a></li>
            </xsl:for-each>
          </ul>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field"
                match="*">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>







  <!-- ########################## -->
  <!-- Render values for text ... -->
  <xsl:template mode="render-value"
                match="gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gml:beginPosition|gml:endPosition">

    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')"/>

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/><xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Case to handle gco.LocalName: start -->
	<xsl:template mode="render-value" match="gco:LocalName">
		<xsl:variable name="localNameValue">
			<xsl:value-of select="normalize-space(.)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$localNameValue = 'download'">
				Nedladdning
			</xsl:when>
			<xsl:when test="$localNameValue = 'view'">
				Visning
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$localNameValue"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  <!-- Case to handle gco.LocalName: end -->
  
  <xsl:template mode="render-value"
                match="gmd:PT_FreeText">
    <xsl:apply-templates mode="localised" select="../node()">
      <xsl:with-param name="langId" select="$language"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value"
                match="gmd:URL">
    <a href="{.}"><xsl:value-of select="."/></a>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive  -->
  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="MMM YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY-MM-DD"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:DateTime[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY-MM-DD hh:mm"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date|gco:DateTime">
    <span data-gn-humanize-time="{.}" data-format="YYYY-MM-DD"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gmd:language/gco:CharacterString">
    <span data-translate=""><xsl:value-of select="."/></span>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value"
                match="@codeListValue">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}"><xsl:value-of select="$codelistTranslation"/></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Enumeration -->
  <xsl:template mode="render-value"
                match="gmd:MD_TopicCategoryCode|
                        gmd:MD_ObligationCode|
                        gmd:MD_PixelOrientationCode">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            local-name(), $id)"/>
        <span title="{$codelistDesc}"><xsl:value-of select="$codelistTranslation"/></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@gco:nilReason[. = 'withheld']"
                priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}"></i>
  </xsl:template>
  <xsl:template mode="render-value"
                match="@*"/>

  <xsl:template mode="render-field"
                match="gmd:abstract"
                priority="100">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                              then $fieldName
                              else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <p><xsl:value-of select="gco:CharacterString"/><xsl:apply-templates mode="render-value" select="@*"/></p>
      </dd>
   </dl>
 </xsl:template>

</xsl:stylesheet>