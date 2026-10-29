*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CONFIGURED
...           CRT  RAN_5G_FDD    RAN_5G    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Alok Shastri, Michal Fluder
...              :contact: alok.shastri@nokia.com, michal.fluder@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Library      ta5g_tshark
Library      ta5g_pm_counters

Variables    ta5g_global_var

Suite Setup       Run Keywords    Start Default Logging And Reach Onair
...                               lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...                               output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...               AND             Set Counter Collecting Interval To Five Minutes
...               AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...               AND             Wait For Next Full Pm Interval

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Test Cases ***
5GC000728_A_04_Verify_Successful_UE_Detach_Triggered_By_UE_With_More_Than_1_DRB_And_RLC_Ack_Received_For_RRC_Release
    [Documentation]     This testcase covers following legacy scenarios:
    ...     5GC000728_A_06_Verify_Successful_UE_Detach_Triggered_By_UE_Without_DRB_And_RLC_Ack_Not_Received_For_RRC_Release
    ...     Requirement ID: 5G_RAN_USR_4135
    [Template]   Verify That UE Detach Will Be Successful When The Detach Is Triggered
    UE_ID=1    PDU_ID=1    DETACHED_BY=ue    DETACH_TYPE=switch_off

5GC000728_A_05_Verify_Successful_UE_Detach_Triggered_By_Network_With_More_Than_1_DRB_And_RLC_Ack_Received_For_RRC_Release
    [Template]   Verify That UE Detach Will Be Successful When The Detach Is Triggered
    UE_ID=2    PDU_ID=3    DETACHED_BY=amf    DETACH_TYPE=normal

*** Keywords ***
Verify That UE Detach Will Be Successful When The Detach Is Triggered
    [Arguments]    ${UE_ID}    ${PDU_ID}    ${DETACHED_BY}    ${DETACH_TYPE}
    Attach Ue    ue_id=${UE_ID}
    Establish Pdu Session    ue_id=${UE_ID}    pdu_id=${PDU_ID}    gw_id=${PDU_ID}
    Establish Pdu Session    ue_id=${UE_ID}    pdu_id=${${PDU_ID}+1}    gw_id=${${PDU_ID}+1}
    Deregister Ue    ue_id=${UE_ID}    by=${DETACHED_BY}    ue_deregister_type=${DETACH_TYPE}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Ngap Messages       packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Ngap Messages       packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ngap.AMF_UE_NGAP_ID == ${UE_ID}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55125C00501    1    NNGCC_UE_CTXT_REL_CMD_RECD
    ...    M55125C00502    1    NNGCC_UE_CTXT_REL_CMP_SENT
    ...    M55124C00001    1    NRRCC_RRC_RELEASE_SENT
    ...    M55113C01009    1    NF1CC_UECTXT_REL_CMDSENT
    ...    M55113C01010    1    NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}
    Verify Last Counters In File
    ...    M55117C01010    1    NF1CD_UECTXT_REL_CMPSENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${PM_COUNTERS}
    Verify Last Counters In File
    ...    M55133C00001    1    NE1US_CTXT_REL_CMD_RECD
    ...    M55133C00002    1    NE1US_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTERS}


