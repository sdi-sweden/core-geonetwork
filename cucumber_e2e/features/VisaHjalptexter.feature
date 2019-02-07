
Feature: Visa hjalptexter

  @qa_todo
  Scenario: Visa hjalptexter
    Given that the user is in search vy
    When the user clicks the button Hjalp
    Then a page with hjalptexter is opened
  