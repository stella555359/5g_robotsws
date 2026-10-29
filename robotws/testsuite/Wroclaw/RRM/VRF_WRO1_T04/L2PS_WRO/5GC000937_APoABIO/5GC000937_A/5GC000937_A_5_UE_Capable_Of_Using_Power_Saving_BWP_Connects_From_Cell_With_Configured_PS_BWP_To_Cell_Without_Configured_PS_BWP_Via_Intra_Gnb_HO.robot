*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/LO_APoABIO/2_CELL_1_RU/iphy_and_scfc.yaml
...           CONFIGURED    RAN_5G_TDD    RAN_5G
...           SBTS23R1__WITH__CIT

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000937_variables.robot
Library      ../../resources/Python/webem_alarms.py
Library      5GC000937_keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    ...          AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000937_A_5_UE_Capable_Of_Using_Power_Saving_BWP_Connects_From_Cell_With_Configured_PS_BWP_To_Cell_Without_Configured_PS_BWP_Via_Intra_Gnb_HO
    Attach Ue    ue_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...    pass_regexp=BandwidthpartIndicator: 2((.|\s)*)bandwidthPartIndicator 2
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}
    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}
    Send Custom UE Measurement NR  event=A3 srsrp_nr=17 phycell_id=51 nrsrp_nr=125 id=1 meas_id=1
    ...  pass_regexp=BandwidthpartIndicator: 1((.|\s)*)bandwidthPartIndicator 1((.|\s)*)Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...  timeout=10
    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}    number_of_messages=1
    Send Custom UE Measurement NR  event=A3 srsrp_nr=17 phycell_id=50 nrsrp_nr=125 id=1 meas_id=1
    ...  pass_regexp=(BandwidthpartIndicator: 2).|\s.*(bandwidthPartIndicator 2).|\s.*(Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed)
    ...  timeout=10
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}
    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${RRC_RECONF}    number_of_messages=3
