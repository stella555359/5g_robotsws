*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Resource    CB008250_keywords.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Library     keywords_CB008250.py
Documentation
...    author: Pawel Konieczny
...    maintainer:
...    testline:
...    release:

Suite Setup    Enable Syslog Info Level Prints

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...              cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Change Tdd Cells To 50 Mhz
    ...       AND    Disable Actrat1alloc
    ...       AND    Set Minrcellutilperplmn And Nrg To 5min
    ...       AND    Enable Slice Aware Scheduler
    ...       AND    Enable Plmn Aware Scheduler
    ...       AND    Enable Actslicenumext
    ...       AND    Enable Multiple Bwps
    ...       AND    Enable Plmn Spid And Resource Groups
    ...       AND    Enable Fdd Tdd Ca
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
CB008250-E_Interaction_Between_Plmn_Aware_Scheduler_And_Multiple_Bwps
    Register Ca Ues For Different Bwps
    Start High Dl And Ul Data Traffic For Ca
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Wait For Next Full Pm Interval
    Check If Resource Groups On Cell 1 And Cell 3 Have Incremented Pm Counters
    Check If All Plmns Have Incremented Pm Counters
    Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl
    Check If All Plmns Have Incremented Pm Counters On Cell3
    Check If Thanks To Ca Target Share On Cell3 Was Achieved

*** Keywords ***
Enable Multiple Bwps
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_multiple_BWp_set_bwpChBw_Dedicated2_to_15_MHz_Cells_1_to_4.json

Register Ca Ues For Different Bwps
    Add Nr Cappa    last_ue_id=16
    Register 4 Ues Per Plmn

Display Ue Statistics
    Display Qfi stats    ue_id=${1}     qfi_id=1
    Display Qfi stats    ue_id=${5}     qfi_id=1
    Display Qfi stats    ue_id=${9}     qfi_id=1
    Display Qfi stats    ue_id=${13}    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check If Resource Groups On Cell 1 And Cell 3 Have Incremented Pm Counters
    Check If Resource Groups Have Incremented Pm Counters
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=1
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=5
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=9
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=15
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3

Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl
    Wait For Next Full Pm Interval
    Check If Values Of Counters Covers Set Target Share
    Check If Values Of Counters Covers Set Target Share    pm_counter_numerator=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    pm_counter_denumerator=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}

Check If All Plmns Have Incremented Pm Counters On Cell3
    Check If Plmn Pm Counters Have Incremented Values    MCC=311    MNC=489
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Plmn Pm Counters Have Incremented Values    MCC=555    MNC=10
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Plmn Pm Counters Have Incremented Values    MCC=450    MNC=06
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Plmn Pm Counters Have Incremented Values    MCC=450    MNC=05
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3

Check If Thanks To Ca Target Share On Cell3 Was Achieved
    Check If Values Of Counters Covers Set Target Share    target_share=0.31
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Check If Values Of Counters Covers Set Target Share    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    pm_counter_numerator=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    pm_counter_denumerator=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}
