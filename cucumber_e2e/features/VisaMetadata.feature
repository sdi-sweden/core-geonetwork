@qa_ready
Feature: Visa metadata
@qa_ready
  Scenario: VisaMetadataSomAnvandare
   	Given that the user has searched for "350aff6f-a9d6-4113-8527-3e7f23ff5411"
		And the post "Jordarter 1:750 000, Mittnorden (visningstjänst) 2" is listet in resulttable
		When the user clickes on the link to visa metadata
 	  Then metadata on the chosen tab is displayed
@qa_todo
	Scenario: VisaMetadataSomPublicerare
	 	Given that the user has opened a post to redigera
	  When the user clicks on a link at the top
		Then metadata on the chosen tab is displayed
