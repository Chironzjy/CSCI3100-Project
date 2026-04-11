Feature: Authentication
  As a CUHK Mart user
  I want to log in
  So that I can access the marketplace

  Scenario: User logs in successfully
    Given a demo user exists
    When I log in with valid credentials
    Then I should see the browse page
