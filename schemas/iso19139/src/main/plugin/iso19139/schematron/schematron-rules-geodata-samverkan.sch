

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
