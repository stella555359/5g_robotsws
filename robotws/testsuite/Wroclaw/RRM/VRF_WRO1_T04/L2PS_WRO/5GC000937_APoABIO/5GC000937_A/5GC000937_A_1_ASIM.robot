*** Settings ***
Force Tags    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/CB007425/5GC000937_A/iphy_and_scfc.yaml
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000937_variables.robot
Library      ../../resources/Python/webem_alarms.py
Library      5GC000937_keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000937_A_1_UE_Capable_Of_Using_Power_Saving_BWP_Connects_To_Cell_Via_Initial_Access_ActPowerSavingBWP_True
    Attach Ue    ue_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...    pass_regexp=BandwidthpartIndicator: 2((.|\s)*)bandwidthPartIndicator 2
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}
    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}
	Execute Egate Command And Wait For Data    cmd=ue_deregister id=1 ue_deregister_type=switch_off
