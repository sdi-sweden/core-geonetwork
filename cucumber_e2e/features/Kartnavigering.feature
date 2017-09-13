@qa_todo
Feature: Navigera i karta
@qa_todo
  Scenario: OppnaKarta
    Given that the map is minimized
	  When the user clicks on the button next to the map
	  Then the map is opened

@qa_todo
  Scenario: MinimeraKarta
  Given that the map is open
	When the user closes the map
	Then the map is minimized
@qa_todo
  Scenario: MaximeraKarta
    Given that the map is open
	When the user clicks on the maximera button next to the map
	Then the map is maximized
@qa_todo
  Scenario: ZoomaIn
    Given that the map is open
	When the user clicks on the zoom in button next to the map
	Then the map is zoomed in
@qa_todo
  Scenario: ZoomaUt
    Given that the map is open
	When the user clicks on the zoom out button next to the map
	Then the map is zoomed out
@qa_todo
  Scenario: VisaUrsprungligUtbredning
    Given that the map is open
	When the user clicks on the zoom to initial extent button next to the map
	Then the map is zoomed to initial extent
@qa_todo
  Scenario: ZoomaTillPosition
    Given that the map is open
	When the user clicks on the zoom to position button next to the map
	Then the map is zoomed to current position
@qa_todo
  Scenario: VisaRutnat
    Given that the map is open
	When the user clicks on the graticule button next to the map
	Then a graticule is displayed on the map
@qa_todo
  Scenario: DoljRutnat
    Given that the map is open
    And has a graticule
	When the user clicks on the graticule button next to the map
	Then the graticule is removed from the map
