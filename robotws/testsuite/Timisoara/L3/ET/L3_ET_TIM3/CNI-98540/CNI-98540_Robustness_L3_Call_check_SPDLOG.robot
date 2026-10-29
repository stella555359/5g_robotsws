*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_FDD    CRT    RAN_5G    SBTS00
...           NoResUsage

Documentation   :copyright: Nokia
...             :author/s: eduard.lungu@nokia.com, alexandru.tancau@nokia.com
...             :contact/s: eduard.lungu@nokia.com, alexandru.tancau@nokia.com
...             :description: Perform basic L3 Call scenario and expect the SPDLOG not to be visible in syslog

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     CNI-98540_Variables_and_Keywords.robot
Resource     ../L3call/L3call_Variables_And_Keywords.robot


Suite Setup    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs
*** Variables ***
${syslog_regex_SPDLOG}    SPDLOG

*** Test Cases ***

CNI-98540_Robustness_L3_Call_check_SPDLOG
    Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa.lua   check_edaemon_port=True
    Perform SANSA call    sa_ue=1   nsa_ue=11   target_cell=1   target_gnb=2
    Change Ue Location    ue_id=2    dst_enb=2    dst_cell=2
    Perform SANSA call    sa_ue=2   nsa_ue=12   target_cell=2   target_gnb=2
    Syslog should not contain SPDLOG messages    SPDLOG_regex=${syslog_regex_SPDLOG}
