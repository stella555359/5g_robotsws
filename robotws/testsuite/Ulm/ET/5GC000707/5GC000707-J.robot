*** Settings ***

Documentation   This is a Robot Test Suite for feature 5GC000707 'InterRat HO LTE' testing
...             This feature has 3 subfeatures itemized from A to E which support the full chain of InterRat Handover LTE.
...             Link to Test Strategy: https://nokia.sharepoint.com/:w:/r/sites/MN5GSCProductization/Shared%20Documents/General/
...                                    5G%26SC%20Collaborator/5GC000600%E2%80%935GC000799/5GC000707/5GC000707_Feature_Test_Strategy.docx
...                                    ?d=w5d3c577623544040aa955e7c98eeb3b4&csf=1&web=1&e=Et8mkt
...             Team: 'MN RAN RD VRF ULM 4'
...             Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource        5GC000707_Keywords.robot

Suite Setup     Prepare TL for 5GC000707
Suite Teardown  Sqd65 Common Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario

*** Test Cases ***

5GC000707_J_Successful_Inter-RAT_HO_based_on_B2_Meas
    [Documentation]  5GC000707_J_B1
    ...              Counters per slice
    [Tags]    J_B1
    Register UE
    InterRAT HO
    Verify PM Counters     J_B1
