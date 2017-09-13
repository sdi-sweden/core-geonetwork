@qa_ready
Feature: Hantera favoriter
  @qa_readynot
  Scenario: Create favorit
    Given that the user has a search result
    When the user clicks the star next to the post "Testpost_referensdatum_till_Geodatasamverkan" that does not have a star
    Then the post is added as a favorit
  @todo
  Scenario: Ta bort favorit
    Given that the user has a search result
    And the post "Testpost_referensdatum_till_Geodatasamverkan" is a favorite
    When the user clicks the yellow star next to the post "Testpost_referensdatum_till_Geodatasamverkan"
    Then the post is removed as a favorit
