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
#Suite Teardown  Sqd65 Common Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario


*** Test Cases ***


5GC000707_D_no_target_Cell_selected_in_B2_Meas_due_to_Blacklist
    [Documentation]  5GC000707_D_B1
    ...              This user scenario describes the gNB behavior, when a UE for which inter-Rat B2 measurements have been configured
    ...              sends a B2 measurement report and no target cell can be selected (target LTE cell is blacklisted)
    [Tags]    D_B1
    Register UE
    Serving becomes worse than threshold
    Set Target Cell as blacklisted
    PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    ...         fail_regexp=rrcConnectionReconfigurationComplete   pass_regexp=None
    Verify Measurement is configured   B2
    Verify Measurement is configured   A1
    Verify PM Counters                 D_B1
    [Teardown]  Run Keywords    Unset Target Cell as blacklisted    AND
    ...                         Perform Postconditions of Test Scenario


5GC000707_D_Successful_Config_of_InterRAT_B2_Meas_with_Blacklist
    [Documentation]  5GC000707_D_B2
    ...              This user scenario describes the gNB behavior, when a RRC_CONNECTED UE sends an A2 measurement report to gNB.
    [Tags]    D_B2
    Set Target Cell as blacklisted
    Register UE
    Serving becomes worse than threshold
    Verify Black Cell Config
    Verify PM Counters                 D_B2
    [Teardown]  Run Keywords    Unset Target Cell as blacklisted    AND
    ...                         Perform Postconditions of Test Scenario


5GC000707_D_no_target_Cell_selected_in_B2_Meas_due_to_Mobility_Restriction_List
    [Documentation]  5GC000707_D_B3
    ...              This user scenario describes the gNB behavior, when a UE for which inter-Rat B2 measurements have been configured
    ...              sends a B2 measurement report and no target cell can be selected due to RAT Restrictions
    [Tags]    D_B3
    ${mob_restrict_cmd}=  Catenate
    ...                amf_mobility_restriction_list_param id=1
    ...                sa_plmn=${sa_plmn['mcc']}:${sa_plmn['mnc']}
    ...                equiv_plmn=${equiv_plmn['mcc']}:${equiv_plmn['mnc']}
    ...                restricted_plmn=${equiv_plmn['mcc']}:${equiv_plmn['mnc']}
    ...                restricted_rat=eutra

    Set Mobility Restriction  mobility_restriction=${mob_restrict_cmd}
    Register UE
    Serving becomes worse than threshold
    Sleep  1
    PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    ...         b2_meas_values=phycell_id=${LTE_PCI_2} ${B2_MEAS_VALUES}  fail_regexp=rrcConnectionReconfigurationComplete   pass_regexp=${None}
    Verify Measurement is configured   B2
    Verify Measurement is configured   A1
    Verify PM Counters                 D_B3
    [Teardown]  Run Keywords    Unset Mobility Restriction    AND
    ...                         Perform Postconditions of Test Scenario


5GC000707_D_Successful_Config_of_InterRAT_B2_Meas_when_UE_configured_with_A2_Meas
    [Documentation]  5GC000707_D_B4
    ...              This user scenario describes the gNB behavior, when a RRC_CONNECTED UE sends an A2 measurement report to gNB.
    ...              EGATE verification missing
    ...              instance #2+3 done by SyVe
    [Tags]    D_B4
    Register UE
    Serving becomes worse than threshold
    Verify Config Values
    Verify PM Counters                 D_B2


5GC000707_D_Cell_With_bad_Strength_Signal_Selected_In_B2_Meas_Rather_Than_One_with_Good_Signal_Due_To_Mobility_Restriction_List
    [Documentation]  5GC000707_D_B31
    ...              Test case describes the gNB behavior, when a UE for which inter-Rat B2 measurements have been configured
    ...              sends a B2 measurement report and no target cell can be selected due to RAT Restrictions.
    ...              In others words we need to verify, if among the two cells, the one, which has good strength signal (and good signal quality)
    ...              is not selected just because it belongs to Mobility restriction list and the one which doesnt have any restriction is selected
    ...              despite of its poor signal level (compare to other one).
    [Tags]    D_B31  CRT
    ${mob_restrict_cmd}=  Catenate
    ...                amf_mobility_restriction_list_param id=1
    ...                sa_plmn=${sa_plmn['mcc']}:${sa_plmn['mnc']}
    ...                equiv_plmn=${equiv_plmn1['mcc']}:${equiv_plmn1['mnc']}
    ...                equiv_plmn=${equiv_plmn2['mcc']}:${equiv_plmn2['mnc']}
    ...                restricted_plmn=${equiv_plmn1['mcc']}:${equiv_plmn1['mnc']}
    ...                restricted_rat=eutra

    Apply Config for 5GC000707-D-B31
    Set Mobility Restriction  mobility_restriction=${mob_restrict_cmd}
    Register UE
    Wait until the next Measurement Period starts
    Serving becomes worse than threshold
    Sleep  1
    PCell becomes worse than threshold1 and inter RAT neighbor becomes better than threshold2
    ...   b2_meas_values=phycell_id=${LTE_PCI_1} ${B2_MEAS_VALUES} phycell_id=${LTE_PCI_2} nrsrp_nr=20 nrsrq_nr=16
    Verify Target Cell ID  0x00001202
    Verify PM Counters     B_B1  target_cell=${LTE_LCI_2}  target_mcc=${equiv_plmn2['mcc']}  target_mnc=${equiv_plmn2['mnc']}
    [Teardown]  Run Keywords    Unset Mobility Restriction    AND
    ...                         Perform Postconditions of Test Scenario
