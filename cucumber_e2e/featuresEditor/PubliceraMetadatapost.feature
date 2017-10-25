@qa_todo
Feature: Publicera metadata poster i Metadata Editor
  @qa_todo
  Scenario: Skapa metadata post från mall
    Given that the user is loged in
    And is in search page
    When the user clicks the button ny metadata
    Then a form with templates are visible
    | templates|
    | ---Metadata för datamängd mall 3.1.1 |
    | ---Metadata för tjänst - mall 3.1.1 |

    @qa_todo
    Scenario Outline: Skapa metadatjkhjöjhda post från mall
      Given that the user has clicked on ny metadata
      When the user select a <template>
      Then the editor opens whit selected "<template>"
      Examples:
      |template|
      |datamängd|
      |tjänst|
