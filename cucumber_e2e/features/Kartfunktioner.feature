@qa_ready
Feature: Hantera kartfunktioner

  Scenario: SokPlats
    Given that the map is open
	When the user enters a place in the search place field above the map
  And selects the place in the list under the search place field
	Then the map is zoomed to that place

  Scenario: OpenLaggTillLagerWindow
	 Given that the map is open
	When the user clicks on the add layers next to the map
	Then the add layer window is opened

  Scenario: LaggTillLager
   Given that the add layer window is open
  When the user what?
  Then what?

  Scenario: OpenHanteraLagerWindow
	 Given that the map is open
	When the user clicks on the manage layers button next to the map
	Then the manage layer window is opened

  Scenario: HanteraLager
	 Given that the manage layer window is open
	When the user what?
	Then what?

  Scenario: OpenFiltreraDataWindow
   Given that the map is open
  When the user clicks on the filtrera data button next to the map
  Then the filter data window is opened

  Scenario: FiltreraData
   Given that the filter data window is open
  When the user what?
  Then what?

  Scenario: OpenHanteraKartorWindow
	 Given that the map is open
  When the user clicks on the print maps button next to the map
  Then the map context window is opened

  Scenario: HanteraKartorLaddaUppDefault
   Given that the map context window is open
  When the user clicks on the button to load default map
  Then the map window is updated with the default map

  Scenario: HanteraKartorLaddaUppKarta
   Given that the map context window is open
  When the user clicks on the button to load a map
  And selects a map file
  Then the map is updated with the selected map

  Scenario: HanteraKartorLaddaNedKarta
   Given that the map context window is open
  When the user clicks on the button to download current map
  Then a xml file is saved

  Scenario: OpenSkrivUtKartaWindow
   Given that the map is open
	When the user clicks on the print button next to the map
  Then the printing window is opened

  Scenario: SkrivUtKarta
   Given that the printing window is open
  When the user specifies alternatives for the print out
	And clicks on the print button
	Then the map is printed

  Scenario: OpenHanteraMatningWindow
	 Given that the map is open
  When the user clicks on the measure button next to the map
  Then the measuring window is opened

   Scenario: HanteraMatning
    Given that the measures window is open
   When the user creates a measuring sketch in the map
	 Then the measurement is displayed

  Scenario: OpenHanteraTexterWindow
   Given that the map is open
	When the user clicks on the text button next to the map
	Then the annotations widow is opened

  Scenario: HanteraTexterLaggTill
   Given that the annotations window is open
  When the user adds a symbol
  And clicks in the map
  Then a symbol is created in the map

  Scenario: HanteraTexterModifiera
   Given that the annotations window is open
   And a symbol has been created in the map
  When the user modifies the symbol in the map
  Then the a symbol is created in the map

  Scenario: HanteraTexterSave
   Given that the annotations window is open
  When the user specifies a symbol
  And clicks the save button
  Then a file is saved
  what is saved?

  Scenario: HanteraTexterLoad
   Given that the annotations window is open
  When the user clicks the load button
  Then a file is loaded
  with what?
