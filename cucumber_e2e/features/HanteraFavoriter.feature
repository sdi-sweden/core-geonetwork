
Feature: Hantera favoriter
  @qa_ready2
  Scenario: Create favorit
    Given that the user has a search result
    When the user clicks the star next to the post "Testpost_referensdatum_till_Geodatasamverkan" that does not have a star
    Then the post is added as a favorit
  @qa_ready
  Scenario: Ta bort favorit
    Given that the user has a search result
    And the user clicks the star next to the post "Testpost_referensdatum_till_Geodatasamverkan" that does not have a star
    When the user clicks the yellow star next to the post "Testpost_referensdatum_till_Geodatasamverkan"
    Then the post is removed as a favorit
