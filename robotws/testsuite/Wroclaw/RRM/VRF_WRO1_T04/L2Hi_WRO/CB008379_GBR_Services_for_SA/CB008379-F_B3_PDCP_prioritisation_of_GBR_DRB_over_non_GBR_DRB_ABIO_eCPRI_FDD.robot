*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CB008379.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN
...    release: 22R3

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Enable ActPdcpRlcBufCongestionMechsm
    ...       AND    Enable Vonr And Rohc
    ...       AND    Enable ActNonVoNRGbrService
    ...       AND    Add Profiles For GBR 5QI
    ...       AND    Set Discard Timer To 1500ms For Gbr
    ...       AND    Disable Uplane Ciphering
    ...       AND    Increase dlQam256PowerBackoff
    ...       AND    Choose Lue File Based On Detected Configuration And Reach Onair
    ...              lua_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              lua_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs
Test Teardown     Run Keywords    Deregister Ue   ue_id=1
   ...        AND   Sleep    3s   Waiting for deregister
   ...        AND   Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   30s

*** Test Cases ***
CB008379-F_B3_1_PDCP_prioritisation_of_GBR_DRB_5QI3_over_non_GBR_DRB
    Attach Ue With Gbr Um 5QI 3 FDD ORAN
    Start 210Mbps In Dl For Non Gbr Bearer
    Sleep    60s   Waiting for packets buffering
    Check Non Gbr Traffic Statistic
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Check Non Gbr Traffic Statistic    expected_throughput_mbps=180

*** Keywords ***
Start 30Mbps In Dl and Ul For Gbr
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=30

Start 210Mbps In Dl For Non Gbr Bearer
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=110 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=2