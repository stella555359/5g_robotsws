*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/LO_APoASOE/1_CELL_SA_TDD_5GC000937_ACTIVATED/iphy_and_scfc.yaml
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS22R4    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000937_variables.robot
Library      ../../resources/Python/webem_alarms.py
Library      5GC000937_keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_1c.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000937_A_8_Counter_M55351C01001_MAX_UE_CONFIG_2BWP
    Wait For Next Full Pm Interval
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Attach Ue    ue_id=3
    Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=3
    Attach Ue    ue_id=4
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=4
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}    number_of_messages=4
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}    number_of_messages=4
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    ${COUNTERS}    Calculate And Return Ue Config Bwp Counters Values
    ...    alias1=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter1=(f1ap.UEContextSetupRequest_element && nr-rrc.bwp_SwitchingDelay == 0) && (f1ap.PDUSessionID == 1)
    ...    filter2=(f1ap.UEContextSetupRequest_element && nr-rrc.bwp_SwitchingDelay == 0) && (f1ap.PDUSessionID == 2)
    ...    filter3=(f1ap.UEContextSetupRequest_element && nr-rrc.bwp_SwitchingDelay == 0) && (f1ap.PDUSessionID == 3)
    ...    filter4=(f1ap.UEContextSetupRequest_element && nr-rrc.bwp_SwitchingDelay == 0) && (f1ap.PDUSessionID == 4)
    ...    output_pdml_filepath1=${OUTPUT_DIR}/${TEST_NAME}/bwp_SwitchingDelay_ue1.pdml
    ...    output_pdml_filepath2=${OUTPUT_DIR}/${TEST_NAME}/bwp_SwitchingDelay_ue2.pdml
    ...    output_pdml_filepath3=${OUTPUT_DIR}/${TEST_NAME}/bwp_SwitchingDelay_ue3.pdml
    ...    output_pdml_filepath4=${OUTPUT_DIR}/${TEST_NAME}/bwp_SwitchingDelay_ue4.pdml
    ...    pcap_file_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap
    ${COUNTER_MAX_UE_CONFIG_2BWP}    Return Counter M55351C01001    counters=${COUNTERS}
    ${COUNTER_AVG_UE_CONFIG_2BWP}    Return Counter M55351C01002    counters=${COUNTERS}
    Verify Any Counters In File
    ...    M55351C01001     ${COUNTER_MAX_UE_CONFIG_2BWP}    MAX_UE_CONFIG_2BWP
    ...    M55351C01002     ${COUNTER_AVG_UE_CONFIG_2BWP}    AVG_UE_CONFIG_2BWP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}
