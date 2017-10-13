@qa_dev
Feature: Administrate metadata

Scenario: Validate metadata
 When the users validates metadata
 Then the metadata is validated 
 
Scenario: Publish metadata
 Given that the user has permission to edit selected metadata with title "xxx" (put in before hook)
 And that the metadata is valid
 When the user publishes metadata
 Then the metadata is publised (depublish after)
 
Scenario: Depublish metadata
 Given that the metadata is published
 When the user depublishes metadata
 Then the metadata is depublised 
 
Scenario: Delete metadata
 Given that the metadata is created
 When the users deletes metadata
 Then the metadata is deleted
