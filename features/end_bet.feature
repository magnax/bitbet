Feature: Ending (settling) bets
	
	As an admin
	I want to end bet

	Background: Logged in and with bet
	  Given I have a published bet


  	Scenario: Settle bet with bids on both sides
  	  And I am logged as admin
	  And I choose to end bet as positive on settle page
	  Given I have a users with amounts:
	  |Maniek|2.0|
	  |Sid|1.0|
	  |Ella|1.2|
	  And I have bids like:
	  |Maniek|1.0|true|
	  |Sid|0.5|true|
	  |Ella|1.0|false|
	  Then I should have this bet closed
      And I should have "0.05" on "fees" account
	  And I should have users with amounts:
	  |Maniek|2.6|
	  |Sid|1.3|
	  |Ella|0.2|