<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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

<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">
  <!--Detta skript är
  ursprungligen skrivet för CSIRO i Australien av Simon Pigot 2007 men är anpassat för den Svenska
  metadata-profilen Schematronvalidering av Nationell metadataprofil version 3.1.1 Geodataportalen
  Michael Östling 2013-->
  <!--
This work is licensed under the Creative Commons Attribution 2.5 License.
To view a copy of this license, visit
    http://creativecommons.org/licenses/by/2.5/au/

or send a letter to:

Creative Commons,
543 Howard Street, 5th Floor,
San Francisco, California, 94105,
USA.

-->
  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Nationell metadataprofil 3.1 för metadata inom Geodatasamverkan</sch:title>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <!-- INSPIRE metadata rules / START -->
  <!-- ############################################ -->


  <sch:pattern fpi="[Geodata.se:106h] OM resursen ingår i Geodatasamverkan är nyckelord obligatoriskt med värdet Geodatasamverkan ur nyckelordslexikonet Initiativ">
    <sch:title>[Geodata.se:106h] OM resursen ingår i Geodatasamverkan är nyckelord obligatoriskt med värdet Geodatasamverkan ur nyckelordslexikonet Initiativ</sch:title>
    <sch:rule
      context="//gmd:MD_DataIdentification|
			//*[@gco:isoType='gmd:MD_DataIdentification']|
			//srv:SV_ServiceIdentification|
			//*[@gco:isoType='srv:SV_ServiceIdentification']">
      <sch:let name="keywordValue_SDT"
               value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geodatasamverkan'"/>
      <sch:let name="thesaurus_name_SDT"
               value="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:title/*/text()='Initiativ'"/>
      <!--			<sch:assert test="$keywordValue_SDT">[Geodata.se:106h] Nyckelord är obligatoriskt för resurser inom Geodatasamverkan med värdet Geodatasamverkan i nyckelordslexikonet Initiativ</sch:assert>
      <sch:assert test="$thesaurus_name_SDT">[Geodata.se:106h] Nyckelord är obligatoriskt OM resursen ingår i Geodatasamverkan med värdet Geodatasamverkan i nyckelordslexikonet Initiativ </sch:assert>
-->
      <sch:assert test="$thesaurus_name_SDT and $keywordValue_SDT">[Geodata.se:106h] OM resursen ingår i Geodatasamverkan är nyckelord obligatoriskt med värdet Geodatasamverkan ur nyckelordslexikonet Initiativ</sch:assert>
      <!--	<sch:report test="$keywordValue_SDT">[Geodata.se:106h] OM resursen ingår i Geodatasamverkan är nyckelord obligatoriskt med ett värdet Geodatasamverkan ur nyckelordslexikonet Initiativ<sch:value-of select="$keywordValue_SDT"/></sch:report>
        <sch:report test="$thesaurus_name_SDT">[Geodata.se:106h] OM resursen ingår i Geodatasamverkan är nyckelord obligatoriskt med ett värdet Geodatasamverkan ur nyckelordslexikonet Initiativ<sch:value-of select="$thesaurus_name_SDT"/></sch:report>-->
    </sch:rule>
  </sch:pattern>
  <!-- TODO : add bbox is mandatory M41 -->

  <sch:pattern fpi="[Geodata.se:107] Referensdatum eller Temporal utsträckning  måste anges">

    <sch:rule context="//gmd:identificationInfo">
      <sch:let name="temporalExtentBegin" value="//gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition/text() | //srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition/text()"/>
      <sch:let name="temporalExtentEnd" value="//gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:endPosition/text() |  //srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:endPosition/text()"/>
      <sch:let name="publicationDate" value="//gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*"/>
      <sch:let name="creationDate" value="//gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*"/>
      <sch:let name="no_creationDate" value="count(gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*)"/>
      <sch:let name="revisionDate" value="//gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/*"/>
      <!-- assertions and report -->
      <!--	    <sch:report test="$temporalExtentBegin"> temporalExtentBegin found: <sch:value-of select="$temporalExtentBegin"/>	</sch:report>
          <sch:report test="$temporalExtentEnd"> temporalExtentEnd found: <sch:value-of select="$temporalExtentEnd"/>	</sch:report>
          <sch:report test="$publicationDate"> publicationDate found: <sch:value-of select="$publicationDate"/>	</sch:report>
          <sch:report test="$creationDate"> creationDate found: <sch:value-of select="$creationDate"/>	</sch:report>
          <sch:report test="$revisionDate"> revisionDate found: <sch:value-of select="$revisionDate"/>	</sch:report>
      -->		<sch:assert test="$no_creationDate &lt;= 1">Endast en förekomst av produktionsdatum får anges</sch:assert>
      <sch:assert test="$publicationDate or $creationDate or $revisionDate or $temporalExtentBegin or $temporalExtentEnd">[Geodata.se:107]  Referensdatum eller Temporal utsträckning krävs.</sch:assert>
    </sch:rule>
    <sch:rule context="//gmd:identificationInfo">
      <sch:assert
        test="(//gmd:citation/gmd:CI_Citation/gmd:date or //gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent)"
      >[Geodata.se:107b] Referensdatum eller Temporal utsträckning krävs</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern fpi="[Geodata.se:117] Kopplade resurser måste anges för en tjänst">
    <sch:rule context="//srv:SV_ServiceIdentification">
      <sch:assert test="(//srv:operatesOn)">[Geodata.se:117] Kopplade resurser måste anges för en tjänst</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- ========================================================================================== -->
  <!-- Abstract Patterns                                                                          -->
  <!-- ========================================================================================== -->

  <!-- Test that an element has a value or has a valid nilReason value -->
  <!-- <sch:pattern abstract="true" id="TypeNillablePattern">
    <sch:rule context="$context">
      <sch:assert test="(string-length(.) &gt; 0) or
        (@gco:nilReason = 'inapplicable' or
        @gco:nilReason = 'missing' or
        @gco:nilReason = 'template' or
        @gco:nilReason = 'unknown' or
        @gco:nilReason = 'withheld' or
        starts-with(@gco:nilReason, 'other:'))">
        Elementet <sch:name/> måste ha ett värde eller giltigt NIL-värde.
      </sch:assert>
    </sch:rule>
  </sch:pattern>
  -->
  <!-- Test that an element has a value - the value is not nillable -->
  <!--
  <sch:pattern abstract="true" id="TypeNotNillablePattern">
    <sch:rule context="$context">
      <sch:assert test="string-length(.) &gt; 0 and count(./@gco:nilReason) = 0">
        The <sch:name/> element is not nillable and shall have a value.
      </sch:assert>
    </sch:rule>
  </sch:pattern>
  -->

</sch:schema>
