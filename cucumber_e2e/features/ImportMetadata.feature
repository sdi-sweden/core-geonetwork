@qa_ready
Feature: Import metadata

Scenario: Import file through URL
  Given that the user is in contribute view
	When the user clicks the button "importera nya poster"
	And the user selects radiobutton "Ladda upp en fil via URL"
	When the user adds information in the import form
	And the user clicks the button "Import"
	Then metadata "xxx" is visible in contribute view (includes deleting post afterwards)

Scenario: Import file through copy and paste
  Given that the user is in contribute view
	When the user clicks the button "importera nya poster"
	And the user selects radiobutton "Kopiera/Klistra in"
	When the user adds information in the copy/paste form
	And the user clicks the button "Import"
	Then metadata "xxx" is visible in contribute view (includes deleting post afterwards)
