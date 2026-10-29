*** Settings ***
Documentation
...   Test suite for regression testing of CNI-124674
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Library      resources/python_keywords.py
Resource     ./resources/robot_keywords.robot

Suite Setup          Suite Setup
Test Setup           Test Setup
Test Teardown        Test Teardown
Suite Teardown       Suite Teardown

*** Test Cases ***
[1]CNI-124674_10_Exploratory_testing
     BuiltIn.Sleep    120s
     ${Power_1}=    Get RMOD Power
     Update lbpsPeriodList With Current Time
     Update actNrLBRTXPowerSaving    true
     Wait For EnergySavingState Update
     Validate Cell Energy Saving    reducedEnergySaving
     ${Power_2}=    Get RMOD Power
     ${Power_Difference}=    Evaluate    ${Power_1} - ${Power_2}
     Should Be True    ${Power_Difference} >= 0.5    Power1 - Power2 is not greater than 0.5
     Update actNrLBRTXPowerSaving    false
     Wait For EnergySavingState Update
     Validate Cell Energy Saving    notEnergySaving
     Wait Until Keyword Succeeds     300 sec     5 sec    gnb_cells.Verify All Cells Are Onair
