*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_5GC002637.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mmariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R3

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...         AND    Enable Tput Counters

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs

Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
5GC002637-A-B1-4_Check_throughput_counters_thresholds_for_volume_and_duration
    Register Ue With Default Pdu Session
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl period_ms=30 size=60
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul period_ms=30 size=60
    All Thput Counters Should Be Equal To 0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl period_ms=30 size=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul period_ms=30 size=150
    All Thput Counters Should Be Equal To 0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl kbps=10000
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=10000
    Check Throughput Counters For Sa Ue    dl_tput=10000    ul_tput=11000
    Deregister Ue    ue_id=1


