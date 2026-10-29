*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    12_18_UTE5GL3TIM3TL001
...           CONFIGURED    CRT    RAN_5G    SBTS00
...           NoResUsage

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     L3call_Variables_And_Keywords.robot


#Suite Setup    Run Keywords    Trigger Site Reset
#...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
Suite Setup    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND              Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup     Run Keywords        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...            AND                 Configure DCAP Session
...            AND                 Create DCAP BTS
...            AND                 Start DCAP Tracing

Test Teardown   Run Keywords       Stop DCAP
...             AND                Get DCAP Results     output_dirpath=${OUTPUT_DIR}/DCAP_Traces
...             AND                Delete DCAP BTS

Suite Teardown  Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...             AND             Run  docker stop $(docker ps -a -q)

*** Test Cases ***
LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_Full_L3_Call
    Reach Onair    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa.lua
    Perform SA call      ue_id=1   target_cell=1   target_gnb=2
