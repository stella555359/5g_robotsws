*** Settings ***


Documentation   This is a Robot Test Suite for feature 5GC000707 'InterRat HO LTE' testing
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

5GC000707_B_Successful_InterRAT_HO_based_on_B2_Measurements
    [Documentation]  5GC000707_B_B1
    [Tags]   B_B1  CRT
    Register UE            pdu_id=2               # WA: pdu not useable after HO anymore
    Wait until the next Measurement Period starts
    InterRAT HO
    Verify PM Counters     B_B1

5GC000707_B_no_Target_Cell_selected_in_B2_Measurement_due_to_unknown_PCI
    [Documentation]  5GC000707_B_B2
    [Tags]   B_B2  CRT
    Register UE
    InterRAT HO with unknown PCI
    Verify PM Counters    B_B2

5GC000707_B_Config_of_InterRAT_B2_Meas_when_UE_is_Config_with_A2_Meas_with_DRX_Interaction
    [Documentation]  5GC000707_B_B3
    ...              Since GMC: DRX enabled by default
    [Tags]   B_B3  CRT
    Activate DRX
    Register UE
    Serving becomes worse than Threshold
    Verify DRX Values
    Verify PM Counters     B_B3

5GC000707_B_Successful_Removal_of_InterRAT_B2_Measurements_with_DRX_Interaction
    [Documentation]  5GC000707_B_B4
    ...              Since GMC: DRX enabled by default
    [Tags]   B_B4
    Activate DRX
    Register UE
    Serving becomes worse than Threshold
    Sleep    1
    Serving becomes better than Threshold
    Verify PM Counters     B_B4

5GC000707_B_A1_Report_Received_Subsequent_to_a_HO_Decision
    [Documentation]  5GC000707_B_EC1
    ...              instance #1: A1 report received while handover is in preparation phase
    [Tags]   B_EC1  CRT
    Set NG HO Preparation Timer  5000   # 5s
    Register UE
    InterRAT HO Preparation
    InterRAT HO Cancelled by A1
    Verify PM Counters    B_EC1
    Set NG HO Preparation Timer  2000  # default val.

5GC000707_B_InterRAT_HO_Preparation_Failure
    [Documentation]  5GC000707_B_EC3
    [Tags]   B_EC3  CRT
    Register UE
    InterRAT HO Preparation Failure        cause=RN_radio_resources_not_available
    Serving becomes better than Threshold
    InterRAT HO Preparation Failure        cause=RN_cell_not_available
    Verify PM Counters                     B_EC3

5GC000707_B_InterRAT_HO_Preparation_Failure_due_to_Timeout
    [Documentation]  5GC000707_B_EC4
    [Tags]   B_EC4  CRT
    Activate InterRAT HO Failure   action=no_response           # preparation failure
    Register UE
    InterRAT HO                    pass_regexp=Received Handover Cancel from GNB-2 with Cause: RAN tngrelocprep expiry
    Verify PM Counters             B_EC4
    Activate InterRAT HO Failure   reset

5GC000707_B_InterRAT_HO_Execution_Failure
    [Documentation]  5GC000707_B_EC5
    [Tags]   B_EC5  CRT
    Set NG Overall HO Procedure Timer   100     # ms
    Register UE
    InterRAT HO                         pass_regexp=Received UE Context Release Complete from GNB-\\d
    Verify PM Counters                  B_EC5
    Verify UE Context Release Cause
    Set NG Overall HO Procedure Timer   2000   # reset to default val.

03558215_To_increase_tNgRelocOverall_value_form_existing_5sec_to_15sec
    [Documentation]  03558215:[RJIO-NPO] To increase tNgRelocOverall value form existing 5sec to 15sec
    ...              https://jiradc.ext.net.nokia.com/browse/MNRCA-71617
    ...              https://jiradc.ext.net.nokia.com/browse/FCA_VRF_RRM-2111
    [Tags]   CNI-112742     03558215  CRT
    Set NG Overall HO Procedure Timer                     15000   # ms
    Delay AMF initiated NGAP UE Context Release Command   10000   # ms
    Setup VoNR Call                                       ue_id=3
    Wait until the next Measurement Period starts
    InterRAT HO                                           ue_id=3   timeout=20s
    ...                                                   fail_regexp=Received UE CONTEXT RELEASE REQUEST from GNB-\\d
    ...                                                   pass_regexp=(?s)IRAT Handover from NR to EUTRA completed.*UE CONTEXT RELEASE COMPLETE
    Verify PM Counters                                    CNI-112742
