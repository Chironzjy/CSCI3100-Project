Feature: Search and map
  As a buyer
  I want to search and view nearby sellers
  So that I can discover suitable items quickly

  Scenario: Search items and open map view
    Given a demo user exists
    And demo marketplace items exist
    And I log in with valid credentials
    When I search for "iPad"
    Then I should see search results containing "Demo iPad"
    When I go to the nearby sellers map
    Then I should see the nearby sellers page
