
  <sch:pattern fpi="[Geodata.se:106c] OM resursen ingår i Inspire är nyckelord obligatoriskt med ett värde ur nyckelordslexikonet GEMET">
    <sch:title>[Geodata.se:106c]OM resursen ingår i Inspire är nyckelord obligatoriskt med ett värde ur nyckelordslexikonet GEMET</sch:title>
    <sch:rule context="//gmd:MD_DataIdentification|
			//*[@gco:isoType='gmd:MD_DataIdentification']|
			//srv:SV_ServiceIdentification|
			//*[@gco:isoType='srv:SV_ServiceIdentification']">
      <sch:let name="keywordValue_INSPIRE"
               value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Inspire'"/>
      <sch:let name="inspire-thesaurus" value="document('../../../../config/codelist/external/thesauri/theme/inspire-theme.rdf')"/>
      <sch:let name="inspire-theme" value="$inspire-thesaurus//skos:Concept"/>
      <!-- Visa fel om inte Inspire Thesaurs visas. -->
      <sch:assert test="count($inspire-theme) > 0"> INSPIRE Themes saknas. Installationen är ej
        korrekt filen </sch:assert>
      <sch:let name="keyword"
               value="gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString"/>
      <sch:let name="inspire-theme-found"
               value="count($inspire-thesaurus//skos:Concept[skos:prefLabel = $keyword])"/>
      <sch:assert test="not($keywordValue_INSPIRE) or $inspire-theme-found > 0"
      >[Geodata.se:106c] Om resursen ingår i Inspire är nyckelord obligatoriskt med ett
        värde ur nyckelordslexikonet GEMET</sch:assert>
      <!--<sch:report test="$inspire-theme-found > 0">
        <sch:value-of select="$inspire-theme-found"/> report <sch:value-of select="$keyword"
        />
      </sch:report>-->
    </sch:rule>
  </sch:pattern>

  <sch:pattern fpi="[Geodata.se:106d] Nyckelord tjänsteklassificering är obligatoriskt för tjänster">
    <sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']">
      <sch:let name="keywordValue" value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
      <sch:let name="keywordValue_INS" value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Inspire'"/>
      <sch:let name="keywordValue_SDT"
               value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanInteractionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanCatalogueViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSpreadsheetViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanServiceEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanChainDefinitionEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanWorkflowEnactmentManager' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicFeatureEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSymbolEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanFeatureGeneralizationEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicDataStructureViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoManagementService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoMapAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCoverageAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoSensorDescriptionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoProductAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureTypeService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCatalogueService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoRegistryService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoGazetteerService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoOrderHandlingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoStandingOrderService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='taskManagementService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='chainDefinitionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='workflowEnactmentService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='subscriptionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateTransformationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoverageVectorConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageCoordinateConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRectificationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialOrthorectificationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSensorGeometryModelAdjustmentService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageGeometryModelConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSubsettingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSamplingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialTilingChangeService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialDimensionMeasurementService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureManipulationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureMatchingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureGeneralizationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRouteDeterminationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialPositioningService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProximityAnalysisService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGoparameterCalculationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicClassificationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicFeatureGeneralizationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSubsettingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSpatialCountingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicChangeDetectionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeographicInformationExtractionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicReducedResolutionGenerationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageManipulationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageUnderstandingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageSynthesisService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicMultibandImageManipulationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicObjectDetectionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeoparsingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeocodingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalReferenceSystemTransformationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSubsettingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSamplingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProximityAnalysisService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataStatisticalCalculationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataGeographicAnnotationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comEncodingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comTransferService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicCompressionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicFormatConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comMessagingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comRemoteFileAndExecutableManagement'"/>
      <!-- assertions and report -->
      <!-- Ändrad text 2013-08-21-->
      <sch:assert test="$keywordValue_SDT or not($keywordValue_INS)">[Geodata.se:106d] Nyckelord tjänsteklassificering är obligatoriskt för tjänster som ingår i Inspire.</sch:assert>
      <!--<sch:report test="$keywordValue">Nyckelordsvärde funnet: <sch:value-of
          select="$keywordValue"/>
      </sch:report>-->
    </sch:rule>
  </sch:pattern>


  <sch:pattern	fpi="[Geodata.se:106g] OM resursen ingår i Inspire är nyckelord obligatoriskt med värdet Inspire ur nyckelordslexikonet Initiativ">
    <sch:title>[Geodata.se:106g] OM resursen ingår i Inspire är nyckelord obligatoriskt med värdet Inspire ur nyckelordslexikonet Initiativ</sch:title>
    <sch:rule
      context="//gmd:MD_DataIdentification|
			//*[@gco:isoType='gmd:MD_DataIdentification']|
			//srv:SV_ServiceIdentification|
			//*[@gco:isoType='srv:SV_ServiceIdentification']">
      <sch:let name="keywordValue_SDT"
               value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Inspire'"/>
      <sch:let name="thesaurus_name_SDT"
               value="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:title/*/text()='Initiativ'"/>
      <!--			<sch:assert test="$keywordValue_SDT">[Geodata.se:106g] Nyckelord är obligatoriskt för Inspire resurser med värdet Inspire i nyckelordslexikonet Initiativ</sch:assert>
      <sch:assert test="$thesaurus_name_SDT">[Geodata.se:106g] Nyckelord är obligatoriskt för Inspire resurser med värdet Inspire i nyckelordslexikonet Initiativ</sch:assert>
      -->
      <sch:assert test="$thesaurus_name_SDT and $keywordValue_SDT">[Geodata.se:106g] OM resursen ingår i Inspire är nyckelord obligatoriskt med värdet Inspire ur nyckelordslexikonet Initiativ</sch:assert>
      <!--         <sch:report test="$keywordValue_SDT">[Geodata.se:106g] Nyckelord är obligatoriskt för Inspire resurser med värdet Inspire i nyckelordslexikonet Initiativ<sch:value-of select="$keywordValue_SDT"/></sch:report>
      <sch:report test="$thesaurus_name_SDT">[Geodata.se:106g] Nyckelord är obligatoriskt för Inspire resurser med värdet Inspire i nyckelordslexikonet Initiativ<sch:value-of select="$thesaurus_name_SDT"/></sch:report>
-->
    </sch:rule>
  </sch:pattern>

  <sch:pattern fpi="[Geodata.se:113b] Metadatakontakt måste ha epostadress och organisation eller person angiven">
    <sch:rule context="//gmd:MD_Metadata">
      <sch:assert
        test="(((gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName) or (gmd:contact/gmd:CI_ResponsibleParty/gmd:individualName)) and (gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress))"
      >[Geodata.se:113b] Metadatakontakt måste ha epostadress och organisation eller person angiven</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- INSPIRE metadata rules / END -->
  <!-- Kontroller för Geodata.se -->
  <!-- Kontrollera att fileidentifier finns med-->

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
