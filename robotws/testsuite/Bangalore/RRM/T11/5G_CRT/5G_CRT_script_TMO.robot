*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author:
...              :contact:
...
...             INTRODUCTION:     This user scenario describes the  verification of Interface message with feature flag during
...                               1. cell setup, 2.Bearer setup,parameter range and PDL rule validations
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/ECEcommon/common_setup_teardown.robot
Resource         ./resources/common_Resource.robot
Resource         ./resources/common_keywords.robot
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Resource         ../../../resources/robot/configuration_id.robot

Suite Setup         Run Keyword and Ignore Error      Suite setup from scratch

*** Test Cases ***
CB008227-EA#B1_TC64_NBR_congestion_handling_IWK_with_CB008954_3BWP
    [Documentation]   This user scenario describes NBR allocations exceed UE's NBR Resource limit.
    [Setup]      Testcase setup with delta Commissioning   ${TC1_act_json_file}   ${wts_cfg_file}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   NBR_Cong_mBWP_PsBWP
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
#1 TC64 congestion handling with multiple dedicated BWPs
    log to console   TC64 congestion handling with multiple dedicated BWPs
    Wait until the next Measurement Period starts
    Attach Multi-UE and trigger nNBR/NBR data
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    #Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1800  SA_DU_DRB_NBR_DL
    ...  M55300C12010  > 200  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  > 200  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID3}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   ${start_ue_id} 	${end_ue_id}-1
#2 TC55 congestion handling with multiple dedicated BWPs with power saving BWP
    log to console   TC55 congestion handling with multiple dedicated BWPs with power saving BWP
    Wait until the next Measurement Period starts
    Start Log    btslog
    Attach Multi-UE and trigger nNBR/VoNR/NBR data
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03509  2100  SA_DU_DRB_NBR_DL
    ...  M55300C12010  > 100  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID4}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   ${start_ue_id4}    ${end_ue_id4}
#3 TC40_NBR congestion detection and handling with PDCCH DL only SANSA
    Send Delta Commissioning    ${Disable_congweightjson}
    log to console   Wait for next PM stats
    Wait until the next Measurement Period starts
    Start Log    btslog   cprt
    X2AP Link Should be UP
    Multiple NSA UEs Register with NBR traffic   ${nsa_ue_id1}    ${nsa_ue_id2}
    Send Delta Commissioning    ${Enable_congweight_json}
    sleep   5s
    Multiple NSA UEs Register with NBR traffic   ${nsa_ue_id3}    ${nsa_ue_id4}
    Stop Log    cprt
    log to console   Wait for next PM to stop
    Wait until the current Measurement Period stops
    ${pm_counter_file2}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/NSA_PDCCH_Cong
    Verify Any Counters In File
    ...  M55115C03509  2400  NSA_DU_DRB_NBR_DL
    ...  M55300C12010  > 100  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID10}
    ...  file_path=${pm_counter_file2}
    Multiple NSA UE Detach   ${nsa_ue_id1}    ${nsa_ue_id4}
    Stop Log    btslog
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...             AND    Send Delta Commissioning     ${TC1_deact_json_file}


CB008227-C#B5_TC32_CB008227-A#B4_TC15_CB013233-A#IWK101
    [Documentation]
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour for Admission control
    ...                               of NBR Non GBR DRB when NBR bearers Exceed Cell’s NBR max amount
    ...                               Limitation for Intra-DU PSCell change procedure (NSA)
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   xxxxx
    [Setup]     Run Keywords
    ...         Start Log   btslog
    ...         AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC32}
    ${TEST_NAME}    Set Variable   C_B5_TC32_A_B4_TC15
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Log to console     "sleeping for 100s....."
    sleep    100s
### TC32 Start here on cell-1
    TC32_Support_NBR_nonGBR_bearers_for_Intra-DU_PSCell_change_procedure_NSA
### TC15 Start here on cell-2
    TC15_Support_NBR_nonGBR_bearers_setup_with_SgNB_Modification_NSA_both_UL_DL
### CB013233-A#IWK101_1 starts here on cell-7 FDD
    Successful_early_DRX_setup_for_UE_in_SA_mode_during_RRC_Inactive_to_RRC_Connected_transition_FDD
    [Teardown]      Run Keywords
    ...             Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    ...             AND    Send Delta Commissioning     ${TC32_revert_delta}
    ...             AND    Send Delta Commissioning     ${CB013233_revert_delta}
    ...             AND    Multiple NSA UE Detach    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}
    ...             AND    Multiple NSA UE Detach    ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id4}
    ...             AND    UE Deregister should be Successful    ${CB013233_sa_ue_id1}
    ...             AND    Stop Log   btslog    snapshot    sosreport
    ...             AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

