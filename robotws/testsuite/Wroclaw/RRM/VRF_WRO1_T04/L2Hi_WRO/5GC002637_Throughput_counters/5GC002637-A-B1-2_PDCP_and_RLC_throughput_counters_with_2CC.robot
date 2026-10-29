*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_5GC002637.py
Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mmariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R3

Suite Setup     Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/../resources/config/sansa_tdd_and_fdd_cmWv/Airphone_Config_2CC.xml
    ...         AND    Reset Airphone
    ...         AND    Enable Carrier Aggregation With Blind Scell Activation
    ...         AND    Enable Syslog Info Level Prints
    ...         AND    Enable Tput Counters

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD_2CC}
    ...              cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_2CC}
    ...       AND    Set Internal Traffic Type To UEs

Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
5GC002637-A-B1-2_PDCP_and_RLC_throughput_counters_with_2CC
    Attach Ue With 2CC Capabilities
    Start 500Mbps In Dl
    Check Throughput Counters For Sa Ue    dl_tput=500000    ul_tput=0

*** Keywords ***
Attach Ue With 2CC Capabilities
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_FOR_2CC}
    Register Ue With Default Pdu Session

Start 500Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=1
    Wait For Next Full Pm Interval
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=1 seconds=120s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2 seconds=120s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150 trf_id=3 seconds=120s
    Sleep    10s
    Display Traffic Stats
    Sleep    120s    Waiting for traffic stops
    Deregister Ue    ue_id=1

Display Traffic Stats
    Display Qfi stats    qfi_id=1
    Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1
    Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0,1
