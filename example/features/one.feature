Feature: Example
  Scenario: Dummy one
    Given I visit "/"
     When I set the search field with "Grace Hopper"
     When I click the google logo
     When I click the search button
     Then the 1st element of results collection should include "Hopper"
