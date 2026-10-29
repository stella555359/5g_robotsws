*** Settings ***
Force Tags    CRT    GQC_PLAN:DESIGNER:egodlews    RAN_5G    SBTS23R1    NoResUsage
    ...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    ...    CONFIGS_Wroclaw/RAN_L3_SW_WRO_2/5GC001167_3_FDD_n66_3A.yaml

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Library     ta5g_pm_counters
Library     ta5g_admin_operations
Library     ta5g_cell_operations
Library     ta5g_iphy

Suite Setup       Disable L1Bypass
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SCELL_PHYSCELL_ID}=                               51
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=                 ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && f1ap.SCell_ToBeSetupMod_List == 1
${F1AP_SCELL_TO_ADD_MOD_LIST}=                      ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.sCellToAddModList == 1
    ...                                             && (nr-rrc.physCellId == ${SCELL_PHYSCELL_ID}) && !(nr-rrc.drx_Config == 1)
${F1AP_DRX_CONFIG_SETUP}=                           ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && (nr-rrc.drx_Config == 1)
${F1AP_RESET_FROM_CU_WITH_TWO_UES}=                 ${F1AP_RESET} && (f1ap.partOfF1_Interface == 2)
${F1AP_RESET_ACKNOWLEDGE_FROM_DU_WITH_TWO_UES}=     ${F1AP_RESET_ACKNOWLEDGE} && f1ap.UE_associatedLogicalF1_ConnectionListResAck == 2

*** Test Cases ***
5GC001167-C-c_SCell_lock_triggered_bulk_UE_released
    [Setup]    Run Keywords    Trigger Site Reset
      ...         AND          Check Radios Availability
      ...         AND          Start Default Logging    output_dirpath=${OUTPUT_DIR}
      ...         AND          Reach Onair    lua_cfg=${CURDIR}/config/5GC001167-C/basic_fs_sa_call_fdd_cmwv_3CC_n66_3A.cfg

    Register UEs And Establish Pdu Sessions
    Verify Successful 2CC On NGAP And F1AP Messages
    Verify DRX Profile Setup for UEs
    Send Data Traffic For Ue And Display Bearer Statistic   ue_id=${CA_UE_ID1}
    Send Data Traffic For Ue And Display Bearer Statistic   ue_id=${CA_UE_ID2}
    Lock Single Cell    cell_id=2
    Verify Partial Reset
     [Teardown]    Run Keywords    Stop Default Logging

*** Keywords ***
Register UEs And Establish Pdu Sessions
    [Arguments]    ${PCELL1_ID}=1    ${PCELL2_ID}=3    ${PDU1_ID}=1    ${PDU2_ID}=2    ${GW1_ID}=1     ${GW2_ID}=2
    Attach UE And Start Data Traffic    ue_id=${CA_UE_ID1}    cell_id=${PCELL1_ID}    pdu_id=${PDU1_ID}    gw_id=${GW1_ID}
    Attach UE And Start Data Traffic    ue_id=${CA_UE_ID2}    cell_id=${PCELL2_ID}    pdu_id=${PDU2_ID}    gw_id=${GW2_ID}

Verify Successful 2CC On NGAP And F1AP Messages
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}     number_of_messages=2
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}         number_of_messages=2
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}              number_of_messages=4

Verify DRX Profile Setup for UEs
    Verify Tcpdump Log      packet_filter=${F1AP_DRX_CONFIG_SETUP}    number_of_messages=4

Verify Partial Reset
    Verify Tcpdump Log      packet_filter=${F1AP_RESET_FROM_CU_WITH_TWO_UES}
    Verify Tcpdump Log      packet_filter=${F1AP_RESET_ACKNOWLEDGE_FROM_DU_WITH_TWO_UES}
    Verify Ngap Messages    packet_filter=${NGAP_RESET_ACKNOWLEDGE}
