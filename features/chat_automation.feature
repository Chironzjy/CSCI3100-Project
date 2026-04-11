Feature: Chat and automation
  As a marketplace user
  I want to chat and rely on automation workflows
  So that transactions can continue smoothly

  Scenario: Open chat and run automation jobs
    Given a demo user exists
    And a demo seller exists
    And a reserved item exists for automation
    And I log in with valid credentials
    When I open chat with the seller
    Then I should see the conversation page
    When automation jobs are executed
    Then the reserved item should be auto-completed
