@qa_ready
Feature: Filter metadata

Scenario: Show only my posts
  Given that the user is in contribute view
  When the user clicks "show only my posts"
  Then only metadata belonging to the user should be displayed

Scenario Outline:  Filter on service type
  Given that the user is in contribute view
  When the user clicks "<servicetype>"
  Then only "<servicetype>" should be diplayed
  
  Examples:
    |servicetype|
    | Datamängd |
    |   Serie   |
    |  Tjänst   |
