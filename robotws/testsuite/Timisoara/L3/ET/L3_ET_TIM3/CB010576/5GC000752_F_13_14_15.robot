*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_FDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Pawel Gniewek
...              :contact: pawel.gniewek@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Start Default Logging And Reach Onair    lua_cfg_filepath=${CURDIR}/../resources/egate_2c_tdd_sansa_FR2_n257.lua
    ...        AND             Set Counter Collecting Interval To Five Minutes
    ...        AND             Wait For Next Full Pm Interval
    ...        AND             Stop Default Logging

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs
*** Variables ***
${PDU_SESSION_RES_SETUP_RESP}=   ngap.PDUSessionResourceSetupResponse_element
${PDU_SETUP_LIST_FAILED}=   ngap.PDUSessionResourceFailedToSetupListSURes == 1
${PDU_SESSION_RESOURCE_SETUP_RESPONSE_PDU_FAILED}=   ${PDU_SESSION_RES_SETUP_RESP} && ${PDU_SETUP_LIST_FAILED}
*** Test Cases ***
5GC000752-F_13_Unsuccessful_ICS_752-D_4_USBasicCall-D_EC17_PM_Counters
    Configure Rule For SecurityModeCommand Messages    ue_id=1    rule=failure
    Attach Ue    ue_id=1
    Establish Pdu Session Without Confirmation    ue_id=1    pdu_id=1    gw_id=1
    Verify Tcpdump Log       packet_filter=${SECURITY_MODE_FAILURE}    continue_on_failure=${False}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55125C02503    +1    NNGCC_UE_CTXT_STP_FAIL_SENT
        ...    M55124C03005    +1    NRRCC_SEC_MOD_FAIL_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

5GC000752-F_14_Unsuccessful_ICS_752-D_5_USBasicCall-D_EC18_PM_Counters
    Configure Rule For SecurityModeCommand Messages    ue_id=2    rule=drop
    Attach Ue    ue_id=2
    Establish Pdu Session Without Confirmation    ue_id=2    pdu_id=2    gw_id=2
    Verify Ngap Messages       packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE}    continue_on_failure=${False}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55125C02503    +1    NNGCC_UE_CTXT_STP_FAIL_SENT
        ...    M55124C03007    +1    NRRCC_SEC_MOD_CMP_TMR
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

5GC000752-F_15_Unsuccessful_PDU_Session_Resource_Setup_752-D_6_USBasicCall-D_EC26_PM_Counters
    Attach Ue    ue_id=3
    Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=3
    Trigger Dropping Rrc Reconfiguration During Pdu Session Setup
    Establish Pdu Session Without Confirmation    ue_id=3    pdu_id=4    gw_id=4
    Verify Ngap Messages       packet_filter=${PDU_SESSION_RESOURCE_SETUP_RESPONSE_PDU_FAILED}    continue_on_failure=${False}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55124C03006    +1    NRRCC_RRC_RECONF_CMP_TMR
        ...    M55125C02506    +1    NNGCC_PDU_SES_STP_NACK_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

*** Keywords ***
Trigger Dropping Rrc Reconfiguration During Pdu Session Setup
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop
