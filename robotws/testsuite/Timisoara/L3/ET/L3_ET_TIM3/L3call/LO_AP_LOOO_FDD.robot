*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD    PY36    CONFIGURED    RAN_5G_FDD    CRT    RAN_5G    SBTS00
...           NoResUsage

Documentation   :copyright: Nokia
...             :author/s: alexandru.tancau@nokia.com, bianca.malaescu@nokia.com
...             :contact/s: alexandru.tancau@nokia.com, bianca.malaescu@nokia.com
...             :description: Testing Full L3 Call with LO_AP_LOOO in FDD configuration

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     L3call_Variables_And_Keywords.robot

#Suite Setup    Run Keywords    Trigger Site Reset
#...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
Suite Setup    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
LO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD_Full_L3_Call
#    Reach Onair    lua_cfg=${CURDIR}/config/wts_config_LO_AP_LOOO_FDD_CPRI_cmwv_SANSA_FS.lua
#    Perform SA call      ue_id=1   target_cell=1   target_gnb=2
#    Change Ue Location   ue_id=2    dst_enb=2    dst_cell=2
#    Perform SA call      ue_id=2   target_cell=2   target_gnb=2
#    Change Ue Location   ue_id=3    dst_enb=2    dst_cell=3
#    Perform SA call      ue_id=3   target_cell=3   target_gnb=2
#    Perform NSA call     ue_id=11   target_cell=1   target_gnb=2
#    Perform NSA call     ue_id=12   target_cell=2   target_gnb=2
#    Perform NSA call     ue_id=13   target_cell=3   target_gnb=2

    Reach Onair    lua_cfg=${CURDIR}/config/LO_AP_LOOO.cfg   check_edaemon_port=True
    Perform SANSA call    sa_ue=1   nsa_ue=11   target_cell=1   target_gnb=2
    Perform SANSA call    sa_ue=2   nsa_ue=12   target_cell=2   target_gnb=2
    Perform SANSA call    sa_ue=3   nsa_ue=13   target_cell=3   target_gnb=2
