@qa_dev
Feature: Avancerad sokning
@qa_dev
  Scenario: Search with ansvarig
    Given that the user is in Avancerad sokning
    When the user select ansvarig "TESTORGANISATION"
    Then "Testpost_ansvarig_lista_Öppna_data" is listed in AdvanceView
