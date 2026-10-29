*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO  VARIANT_SA_FS_ECPRI_MMWV_TDD    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :maintainer: Maciej Katra


Resource     5GC0001944_WA_Keywords.robot
Library      ta5g_tshark
Library      ta5g_setups_and_teardowns
Variables    ta5g_global_var

Suite Setup                    Reach Onair And Collect Logs
...                        lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa_FR2_n257.lua
...                        output_dirpath=${OUTPUT_DIR}/suite_setup_logs


Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...         AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_ueretentionenabled_ngUeRetentionTmr_300.json

Test Teardown    Run Keywords    Find Scfc and Send Delta Commissioning    scfc_filename=delta_ueretention_default.json
...         AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NG_SETUP_REQUEST_WITH_UE_RETENTION}=    ((ngap.NGSetupRequest_element)&&(ngap.UERetentionInformation == 0))
${NG_SETUP_RESPONSE_WITHOUT_UE_RETENTION}=    ((ngap.NGSetupResponse_element)&&(ngap.protocolIEs == 5))
${SCTP_ABORT}=    sctp.abort_t_bit

*** Test Cases ***
5GC0001944_WA_3_NGSetupResponse_Without_IE_UERetentionInformation
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC0001944_WA_2_NgUeRetentionTmr_Expiration_UE_Retention_Enabled
    ...               Requirement ID  : 5G_RAN_USR_11840

    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Perform Action And Wait For Given Tshark Message Number
        ...    packet_filter=${SCTP_ABORT}
        ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
        ...    action=Invoke Sctp Failure On Ng Interface   by=amf:1    to=gnb:2
        ...    waiting_timeout=300
    Perform Action And Wait For Given Tshark Message Number
        ...    packet_number=1
        ...    packet_filter=${NG_SETUP_RESPONSE_WITHOUT_UE_RETENTION}
        ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
        ...    action=Bring Up Sctp On Ng Interface
        ...    waiting_timeout=300
    Verify Tcpdump Log       packet_filter=${F1AP_RESET}
    Verify Tcpdump Log       packet_filter=${E1AP_RESET}

