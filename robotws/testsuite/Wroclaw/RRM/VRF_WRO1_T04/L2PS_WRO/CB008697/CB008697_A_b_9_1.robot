*** Settings ***
#Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/4RU_2TDD_2FDD/iphy_and_scfc.yaml
#...    CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS22R3    SBTS22R4

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     CB008697_variables.robot
Library      CB008697_keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_4c_CA.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs
*** Variables ***
${ue_id_1}   ${1}
${ue_id_4}   ${31}

*** Test Cases ***
CB008697_A_b_9_1_TDD_TDD_2xFDD_OAI_RLQ_Index_based_deactivation_of_subset_configured_and_active_SCells_and_no_reactivation_check
    Set Internal Traffic Type    ue_id=${ue_id_1}    pdu_id=1
    Attach Ue    ue_id=${ue_id_1}
    Establish Pdu Session    ue_id=${ue_id_1}    pdu_id=1    gw_id=1
    Create Csi Profile    profile_id=10    cqi=2
    Add Scells    ue_id=${ue_id_1}
    Sleep    5s
    Start Big Data Dl    ue_id=${ue_id_1}    pdu_id=1    trf_id1=1    trf_id2=2
    Sleep    10s
    Verify All Scells Are Added    ue_id=${ue_id_1}
    Sleep    5s
    Verify Tput For 4CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${True}    cc2_tput=${True}    cc3_tput=${True}
    Activate Csi Profile For    ue_id=${ue_id_1}    profile_id=10    scell=1
    Sleep    5s
    Set Ue In Overheated State With Max Cc    ue_id=${ue_id_1}    cc=2
    Sleep    5s
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_2}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_2}
    Verify All Scells Are Added    ue_id=${ue_id_1}
    Sleep    5s
    Verify Tput For 4CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}    cc2_tput=${True}    cc3_tput=${True}
    Set Ue In Overheated State With Max Cc    ue_id=${ue_id_1}    cc=1
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_1}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_1}
    Sleep    5s
    Verify Tput For 4CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}    cc2_tput=${True}    cc3_tput=${False}
    Stop All Data Transfer For Ue    ue_id=${ue_id_1}    pdu_id=1
    Start Big Data Dl    ue_id=${ue_id_1}    pdu_id=1    trf_id1=3    trf_id2=4
    Sleep    5s
    Verify Tput For 4CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}    cc2_tput=${True}    cc3_tput=${False}
    Sleep    5s
    Stop All Data Transfer For Ue    ue_id=${ue_id_1}    pdu_id=1
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55316C12001
    ...    value=2
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS}
    Execute Egate Command And Wait For Data    cmd=ue_deregister id=${ue_id_1} ue_deregister_type=switch_off
