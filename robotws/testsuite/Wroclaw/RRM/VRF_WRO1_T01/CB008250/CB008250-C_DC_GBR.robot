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
    ...       AND    Enable Plmn Spid And Resource Groups
    ...       AND    Set 5qis And Their Discard Timers
    ...       AND    Enable Actdcgbrservice And Set Admission Conrol
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
CB008250-C_Interaction_between_Plmn_Aware_Scheduler_With_Dc_Gbr
    Register 4 Ues With Dc Gbr Per Plmn
    Start High Dc Gbr Dl And Ul Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Wait For Next Full Pm Interval
    Check If Resource Groups Have Incremented Pm Counters
    Check If All Plmns Have Incremented Pm Counters
    Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl

*** Keywords ***
Display Ue Statistics
    Display Qfi stats    ue_id=${1}    qfi_id=2    pdu_id=1
    Display Qfi stats    ue_id=${2}    qfi_id=2    pdu_id=1
    Display Qfi stats    ue_id=${5}    qfi_id=2    pdu_id=1
    Display Qfi stats    ue_id=${10}    qfi_id=2    pdu_id=1
    Display Qfi stats    ue_id=${1}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${2}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${3}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${5}    qfi_id=1    pdu_id=1
    Display Qfi stats    ue_id=${10}    qfi_id=1    pdu_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl
    Wait For Next Full Pm Interval
    Check If Values Of Counters Covers Set Target Share
    Check If Values Of Counters Covers Set Target Share    pm_counter_numerator=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    pm_counter_denumerator=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}


