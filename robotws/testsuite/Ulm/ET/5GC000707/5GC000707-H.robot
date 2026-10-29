*** Settings ***

Documentation   This is a Robot Test Suite for feature 5GC000707 'InterRat HO LTE' testing
...             This feature has 3 subfeatures itemized from A to E which support the full chain of InterRat Handover LTE.
...             Link to Test Strategy: https://nokia.sharepoint.com/:w:/r/sites/MN5GSCProductization/Shared%20Documents/General/
...                                    5G%26SC%20Collaborator/5GC000600%E2%80%935GC000799/5GC000707/5GC000707_Feature_Test_Strategy.docx
...                                    ?d=w5d3c577623544040aa955e7c98eeb3b4&csf=1&web=1&e=Et8mkt
...             Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...             Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource        5GC000707_Keywords.robot

Suite Setup     Prepare TL for 5GC000707
Suite Teardown  Sqd65 Common Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario

*** Test Cases ***

5GC000707_H_Successful_Config_of_InterRAT_B2_Meas_for_MFBI
    [Tags]    CIT
    [Documentation]   It verifies the gNB behavior, when RRC_CONNECTED UE sends an A2 measurement report to gNB
    ...               with activated Multi Frequency Band Indication (MFBI)
    Apply Config for 5GC000707-H
    Register UE
    Serving becomes worse than threshold
    Verify Eutra Measurement Object
