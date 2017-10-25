@qa_ready
Feature: Create metadata post
  
  Scenario Outline: Select template for dataset
  Given that the user is in contribute view
	When the user clicks the button lägg till en ny post 
	Then a view for selecting tempate is displayed
	When the user selects <servicetype>
	Then the template <examplemetadata1> and <examplemetadata2> is visible
	When the user select <examplemetadata1>
	Then the title <examplemetadata1> is displayed
	When the user select <examplemetadata2>
	Then the title <examplemetadata2> is displayed
	
	Examples:
    |   servicetype    |                   examplemetadata1                  |           examplemetadata2             |
    |   datamängd      |  Exempelmetadata -  dtatamängd för Geodatasamverkan |  Exempelmetadata - dataset för Inspire |
    |   tjänst         |  Exempelmetadata -  tjänst för Geodatasamverkan     |  Exempelmetadata -  tjänst för Inspire |
 

  Scenario Outline: Create metadata post from template
  Given that the user has selected template <examplemetadata1>
  And clicks on the button "Skapa"
  Then the template is opened with the tag xxx contains "dataset" and tag intitiativ contains "geodatasamverkan"
  When the user adds metadata information <title>
  And clicks on the button "Spara"
  Then metadata <title> is visible in contribute view (remember to delete post after)
  
  	Examples:
    |                   examplemetadata1                  |           title                          |
    |  Exempelmetadata -  dtatamängd för Geodatasamverkan |  nån verifiering                         |
    |  Exempelmetadata -  tjänst för Geodatasamverkan     |                                          |
    |  Exempelmetadata - dataset för Inspire              |                                          |
    |  Exempelmetadata -  tjänst för Inspire              |
 
  