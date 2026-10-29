*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           CRT  RAN_5G_FDD   RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Michal Fluder
...              :contact: michal.fluder@nokia.com

Resource    ../../resources/5G_SW_WRO_Keywords.robot
Library    ta5g_tshark
Library    ta5g_pm_counters

Variables    ta5g_global_var

Suite Setup       Run Keywords    Start Default Logging And Reach Onair
...                               lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...                               output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...               AND             Set Counter Collecting Interval To Five Minutes
...               AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs and Compress Logs

*** Variables ***
${NGAP_UE_CONTEXT_RELEASE_COMMAND_NAS_AUTHENTICATION_FAILURE}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${AUTHENTICATION_FAILURE}
${F1AP_UE_CONTEXT_RELEASE_COMMAND_AMF_INITIATED_ABNORMAL_RELEASE}=    ${F1AP_UE_CONTEXT_RELEASE_COMMAND} && ${AMF_INITIATED_ABNORMAL_RELEASE}

*** Test Cases ***
5GC000728_W_14_Verify_Ue_Is_Released_With_Cause_AMF_Abnormal_Release
    [Setup]    Run Keywords    Wait For Next Full Pm Interval
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Ue Nas Param    ue_id=1    autn_action=fail
    Attach Ue Without Confirmation    ue_id=1
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND_NAS_AUTHENTICATION_FAILURE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND_AMF_INITIATED_ABNORMAL_RELEASE}
    Verify Tcpdump Log   packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Ngap Messages   packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C00501    +1    NNGCC_UE_CTXT_REL_CMD_RECD
    ...    M55125C00502    +1    NNGCC_UE_CTXT_REL_CMP_SENT
    ...    M55124C00001    +1    NRRCC_RRC_RELEASE_SENT
    ...    M55113C01009    +1    NF1CC_UECTXT_REL_CMDSENT
    ...    M55113C01010    +1    NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55117C01010    +1    NF1CD_UECTXT_REL_CMPSENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}
