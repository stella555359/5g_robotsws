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

CB006966_E_Successful_Config_of_InterRAT_B2_Meas_with_Frequency_Offset_and_Cell_Individual_Offset_for_EUTRAN_Cells
    [Documentation]  CB006966_E_B1
    ...              This user scenario describes the gNB behavior to configure B2 measurement in the UE
    ...              (including Frequency Offset and Cell Individual Offset for E-UTRAN cells),
    ...              when an RRC_CONNECTED UE sends an A2 measurement report to gNB
    [Tags]   E_B1
    Apply Config for CB006966-E-B1
    Register UE
    Serving becomes worse than threshold
    Verify Eutra Measurement Object E-B1


CB006966_E_no_target_cell_selected_in_B2_measurement
    [Documentation]  CB006966_E_B3
    ...              This user scenario describes the gNB behavior, when an UE for which inter-Rat B2 measurements have been configured,
    ...              sends a B2 measurement report and no target cell can be selected.
    ...              (-> 5GC000707_B_no_Target_Cell_selected_in_B2_Measurement_due_to_wrong_radio_quality,
    ...              using Cell Individual Offset and Frequency Offset not equal 0  and  rsrqCombined)
    [Tags]   E_B3  CDRT  SBTS22R2
    Apply Config For CB006966-E-B3
    Register UE
    Sleep                  10s
    InterRAT HO With Low RSRP
    Verify PM Counters     E_B3
