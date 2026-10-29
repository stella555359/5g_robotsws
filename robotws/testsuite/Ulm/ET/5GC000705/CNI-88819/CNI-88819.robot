*** Settings ***
Documentation
...             author: VRF ULM 4
...             Team:  'MN RAN RD VRF ULM 4'
...             Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...             Description:
...             [88819][8806][TP] Improvement of TCs with 2 gNBs / left-shift activities of PRs
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource        CNI-88819_Keywords.robot

Suite Setup     Prepare TL
Suite Teardown  Sqd65 Common Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario


*** Test Cases ***

PR642370_Successful_Inter-gNB_NG_Handover_after_Handover_Preparation_Failures_with_VoNR
    [Documentation]  This test case verifies successful inter gNB NG Handover after previous Handover Preparation failures with VoNR call.
    [Tags]    PR642370
    Apply Config for PR642370
    Register UE
    Setup Voice Call
    Serving becomes worse than threshold
    FOR  ${loop}    IN RANGE  1  6
       Inter freq inter gNB NG HO      pass_regexp=Handover Preparation Failure Sent for Amf UE NGAP ID \\d+ with cause RAN not supported 5QI value
       Sleep                           2s
    END
    Enable VoNR                        bts_id=2    gnb_id=1
    Inter freq inter gNB NG HO

PR642964_two-way_NG_Handover
    [Documentation]  This test case verifies successful two way inter gNB NG Handover
    ...              w/o traffic verification
    [Tags]    PR642964
    Apply Config for PR642964
    Register UE
    Add Qosflows
    Intra freq inter gNB NG HO
    Sleep  2s
    Intra freq inter gNB NG HO         phycell_id=${NRBTS_1_NRCELL_1.physCellId}
    ...      pass_regexp=Inter-eNB handover from EXT_ENB-${NRBTS_2_NRCELL_2.ap_gnb_cell_id} to EXT_ENB-${NRBTS_1_NRCELL_1.ap_gnb_cell_id} performed

02554471_Successful_Inter-gNB_NG_Handover_interacts_with_target_gNB_RanSharing
    [Documentation]  This test case verifies successful two way inter gNB NG Handover.
    ...              w/o traffic verification
    [Tags]    02554471  CRT
    Apply Config for 02554471
    Register UE
    Add Qosflows
    Serving becomes worse than threshold
    Inter freq inter gNB NG HO
    Serving becomes worse than threshold  carrier_freq=${NRBTS_2_NRCELL_1.ssbFrequency}
    Inter freq inter gNB NG HO            phycell_id=${NRBTS_1_NRCELL_1.physCellId}
    ...      carrier_freq=${NRBTS_1_NRCELL_1.ssbFrequency}
    ...      pass_regexp=Inter-eNB handover from EXT_ENB-${NRBTS_2_NRCELL_1.ap_gnb_cell_id} to EXT_ENB-${NRBTS_1_NRCELL_1.ap_gnb_cell_id} performed

PR643936_NG_based_Handover_triggered_on_secondary_SA_PLMN
    [Documentation]  This test case verifies successful inter gNB HO procedure (inter or intra freq.),
    ...              when PLMN of source cell differs from target cell. (RAN Sharing and NG Handover enabled)
    [Tags]    PR643936  CRT
    Set Test Variable                     ${UE_ID}  3
    Apply Config for PR643936
    Register UE                           ue_id=${UE_ID}
    Serving becomes worse than threshold  ue_id=${UE_ID}
    Inter freq inter gNB NG HO            ue_id=${UE_ID}

PR648171_Intra-gNB_Inter-Freq_Handover_after_NG_Handover
    [Documentation]  This test case verifies successful intra gNB inter-freq HO on gNB-2,
    ...              after inter gNB inter/intra freq. HO from gNB-1 to gNB-2
    [Tags]    PR648171
    Set Test Variable                     ${UE_ID}  3
    Apply Config for PR643936
    Register UE                           ue_id=${UE_ID}
    Serving becomes worse than threshold  ue_id=${UE_ID}
    Inter freq inter gNB NG HO            ue_id=${UE_ID}
    Serving becomes worse than threshold  ue_id=${UE_ID}  carrier_freq=${NRBTS_2_NRCELL_1.ssbFrequency}
    Inter Freq intra gNB HO               ue_id=${UE_ID}
