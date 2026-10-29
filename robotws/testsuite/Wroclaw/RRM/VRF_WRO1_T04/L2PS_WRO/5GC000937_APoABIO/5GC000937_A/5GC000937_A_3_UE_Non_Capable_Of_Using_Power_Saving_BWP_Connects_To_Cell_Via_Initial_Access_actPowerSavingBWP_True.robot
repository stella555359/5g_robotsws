*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/LO_APoABIO/1_CELL_SA_TDD_5GC000937_ACTIVATED/iphy_and_scfc.yaml
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS22R4    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000937_variables.robot
Library      ../../resources/Python/webem_alarms.py
Library      5GC000937_keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_1c_non_ps.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000937_A_3_UE_Non_Capable_Of_Using_Power_Saving_BWP_Connects_To_Cell_Via_Initial_Access_actPowerSavingBWP_True
    Attach Ue    ue_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=1 ue=1 gw=1
    ...    fail_regexp=BandwidthpartIndicator: 2((.|\s)*)bandwidthPartIndicator 2
    Check Regexp Presence    syslog_path=${OUTPUT_DIR}/${TEST_NAME}/enb/default_syslog_iphyNone.log    regexp=BandwidthpartIndicator: 1
    Check Regexp Presence    syslog_path=${OUTPUT_DIR}/${TEST_NAME}/enb/default_syslog_iphyNone.log    regexp=bandwidthPartIndicator 1
#   Check Regexp is a temporary solution till AP delivery of egate regexp checking
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}
