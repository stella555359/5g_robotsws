*** Settings ***
Force Tags    CLOUD_5G_I_LPQ_AP_LOO    PY36    CONFIGURED    CRT    RAN_5G    SBTS00
...           NoResUsage

Documentation   :copyright: Nokia
...             :author/s: alexandru.goman@nokia.com
...             :contact/s: alexandru.goman@nokia.com
...             :description: Testing Full L3 Call with LPQ_AP_LOO in FDD and TDD configuration

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     L3call_Variables_And_Keywords.robot

#Suite Setup    Run Keywords    Trigger Site Reset
#...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
Suite Setup    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
LPQ_AP_LOO_Full_L3_Call

    Reach Onair    lua_cfg=${CURDIR}/config/LPQ_AP_LOO.cfg   check_edaemon_port=True
    Sleep    20
    Perform SANSA call    sa_ue=1   nsa_ue=11   target_cell=1   target_gnb=2
    Perform SANSA call    sa_ue=2   nsa_ue=12   target_cell=2   target_gnb=2
    Perform SANSA call    sa_ue=3   nsa_ue=13   target_cell=3   target_gnb=2
    Perform SANSA call    sa_ue=4   nsa_ue=14   target_cell=4   target_gnb=2
    Perform SANSA call    sa_ue=5   nsa_ue=15   target_cell=5   target_gnb=2
    Perform SANSA call    sa_ue=6   nsa_ue=16   target_cell=6   target_gnb=2
