@qa_dev1
Feature: VisaResultat
@qa_ready
  Scenario: VisaAllaResurser
    Given that the user has selected some fiters
	  When the user clicks the button to visa alla resurser
	  Then all filters are removed
	  And all posts are shown
@qa_todo
  Scenario: VisaResultatLista
    Given that the list does not contains any metadata posts
	  When the user enters a search criteria
	  Then the result is displayed in the result list
 @qa_ready
   Scenario: VisaAntalTraffar
    Given that the result list contains metadata poster
	  When the user add a searchcriteria
	  Then the number of posts in the result lists is reduced
@qa_ready
  Scenario: VisaResultatExpanderadLista
    Given that the result list contains metadata poster
     And the list is collapsed
	 When the user clicks the button to show the result list expanded
	 Then the result list is expanded
@qa_dev
  Scenario: VisaResultatKomprimeradLista
    Given that the result list contains metadata poster
    And the result list is expanded
	  When the user clicks the button to show the result list collapsed
	  Then the result list is collapsed
@qa_todo
  Scenario: SorteraResultatLista
    Given that the result list contains metadata poster
    When the user clicks the button to sortera efter A-Ö
	Then the result list is sorterad A-Ö
@qa_todo
  Scenario: SorteraResultatLista
    Given that the result list contains metadata poster
    When the user clicks the button to sortera efter Ö-A
	Then the result list is sorterad Ö-A
@qa_todo
  Scenario: VisaTackningsYta
    Given that the result list contains metadata poster
    When the user clicks the button to visa tackningsyta for a post
    Then the map is shown
    And in the map the tackningsyta is shown
@qa_todo
  Scenario: MerInformation
    Given that the result list contains metadata poster
    When the user clicks the button to show Mer information
    Then what?
@qa_todo
  Scenario: VisaPaKarta
    Given that the result list contains metadata poster
    When the user clicks the button to visa pa karta for a post
    Then the map is shown
    And in the map the metadata post is shown
@qa_todo
  Scenario: VisaRekommenderadeDatasamlingar
    Given that there are rekommenderade datasamlingar
    When the user clicks a picture with rekommenderade datasamlingar
    Then the rekommenderade datasamlingar for the picture is shown
@qa_todo
  Scenario: VisaNastaSida
    Given that the result list contains more than 100 posts
    When the user clicks the button to fetch more
    Then the list is updated to show next page with results
@qa_todo
  Scenario: HamtaDatamangd
    Given that the result list contains metadata poster
    When the user clicks the button to hamta datamangd for a post
    Then what?
