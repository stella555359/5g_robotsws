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
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN
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
5GC002637-A-B1-1_PDCP_and_RLC_throughput_counters_with_SA_UE
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_BAND_1}
    Register Ue With Default Pdu Session
    Start Data Traffic 150Mbps In Dl And 50Mbps In Ul
    Check Throughput Counters For Sa Ue    dl_tput=150000    ul_tput=50000

*** Keywords ***
Start Data Traffic 150Mbps In Dl And 50Mbps In Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=1
    Wait For Next Full Pm Interval
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl kbps=150000 seconds=120s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=50000 seconds=120s
    Sleep    10s
    Display Qfi stats    qfi_id=1
    Sleep    120s    Waiting for traffic stops
    Deregister Ue    ue_id=1
