
	@qa_ready
	﻿Feature: Sokning i enkel vy
	@qa_readymm
	Scenario: Search with fritext on titel
    Given that the user is in Enkel vy
		When the user enters the text "Testpost_1_ämne_fritext_titel_Geodatasamverkan" in the fritext field
		Then "Testpost_1_ämne_fritext_titel_Geodatasamverkan" is listed

	@qa_ready
	Scenario: Search with fritext on alternativ titel
    Given that the user is in Enkel vy
		When the user enters the text "Testpost_1_amne_fritext_titel_geodatasamverkan_alternativ_titel" in the fritext field
		Then "Testpost_1_ämne_fritext_titel_Geodatasamverkan" is listed

	@qa_ready
	Scenario: Search with fritext on sammanfattning
    Given that the user is in Enkel vy
		When the user enters the text "Testpost_fritext_fält_Samman_fattning_Geodatasamverkan" in the fritext field
		Then "Testpost_fritext_fält_Samman_fattning_Geodatasamverkan" is listed

	@qa_todo
	Scenario: Search with fritext on tva ord in the titel
    Given that the user is in Enkel vy
		When the user enters the text "Testpost_fritext_titel_tva_ord exakt_Geodatasamverkan" in the fritext field
		Then "Testpost_fritext_titel_tva_ord exakt_Geodatasamverkan" is listed

	@qa_ready
	Scenario: Search with amne
    Given that the user is in Enkel vy
    When the user select amne "EKONOMI"
    Then "Testpost_amne_lista_fritext_Geodatasamverkan" is listed

	@qa_ready
	Scenario: Search with amne and fritext
    Given that the user is in Enkel vy
    When the user combine amne "EKONOMI" with entering the text "Testpost_referensdatum_till_Geodatasamverkan" in the fritext field
    Then "Testpost_referensdatum_till_Geodatasamverkan" is listed

	@qa_ready
	Scenario: Change Amne
		Given that the user is in Enkel vy
		And the user has clicked Amne "GEOVETENSKAP"
		Then "Testpost_1_ämne_Inspire" is listed
		When the user deselects Amne "GEOVETENSKAP"
		And clicks Amne "EKONOMI"
		Then "Testpost_referensdatum_till_Geodatasamverkan" is listed

	@qa_todo
	Scenario: Search with 2 Amnen
	  Given that the user is in Enkel vy
	  And filter is shown
		When the user selects Amne "BIOLOGI OCH EKOLOGI"
	  And the user selects Amne "KUST OCH HAV"
	  Then "Testpost_2_Amnen_Geodatasamverkan" and "Testpost_2_Amnen_Oppna_data, Testpost_2_Amnen_Inspire" is listed

	@qa_todo
	Scenario: Search with fritext on alternativ titel
	  Given that the user is in Enkel vy
		When the user enters the text "Geodatasamverkan_Alternativtitel" in the fritext field
		Then "Testpost_fritext_fält_alternativ_titel_Geodatasamverkan" is listed

	@qa_todo
	Scenario: Search with fritext on sammanfattning
	  Given that the user is in Enkel vy
		When the user enters the text "Testpost_fritext_fAlt_sammanfattning_Geodatasamverkan" in the fritext field
		Then "Testpost_fritext_fAlt_sammanfattning_Geodatasamverkan" is listed
	@qa_todo
	Scenario: Search with fritext on exactly 1 word in the titel
	  Given that the user is in Enkel vy
		When the user enters the text "Testpost_fritext_titel_1_ord_exakt_Geodatasamverkan" in the fritext field
		Then "Testpost_fritext_titel_1_ord_exakt_Geodatasamverkan" is listed

  @qa_todo
	Scenario: Search with fritext on 2 words in the titel
	  Given that the user is in Enkel vy
		When the user enters the text "Testpost_fritext_titel _2_ord_exakt_Geodatasamverkan" in the fritext field
		Then "Testpost_fritext_titel_2_ord_exakt_Geodatasamverkan" is listed
