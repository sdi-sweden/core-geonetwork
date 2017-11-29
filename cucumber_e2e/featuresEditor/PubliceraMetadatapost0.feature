@qa_dev
Feature: Publicera metadata poster i Metadata Editor
  @qa_dev
  Scenario: Skapa metadata post
    Given that the user is loged in
    And is in search page
    When the user clicks the button ny metadata
	  Then a form with templates are visible:
    | templates|
	  | yes |
	  | no |

# @qa_todo
	# Given that a post is open for editing
	# And the post is valid
	# When the user clicks the button to publish the post
  # Then a question is displayed asking if the user wants to make the post public
@qa_todo
  Scenario Outline: Publish valid post as public
    Given that a question is displayed to ask if user wants to make the post public
    When user selects <public_status>
    Then a message is displayed that metadata is updated
    And the post is visible in the result list as public <public_status>
    Examples: public or not
	| public_status |
	| yes |
	| no |
