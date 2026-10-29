*** Settings ***
Force Tags    SBTS00    CONFIGURED    RAN_5G_FDD    RAN_5G_TDD    RAN_5G    PY310
...           CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource     CB012113_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_CB012113.lua
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_fallback_activation.json
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_fallback_activation.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB012113_3_Successful_Voice_Fallback_To_LTE_Via_Redirection_Initial_Context_Setup_During_Registration_Procedure
    [Documentation]   This test case checks gNB behaviour during fallback procedure to LTE when voice call (5QI 1 + 5QI 5) is initiated
    ...               via Initial Context Setup Request.
    ...               Test case requires following flags to be added to default config:
    ...               - actNormVCFallback set to True
    ...               - actNormVCFallbackEnh set to True
    ...               - actRedirect set to True
    ...               - voiceFBMode set to redirection
    ...               - redirFreqEutra set to LTE cell frequency (here 68586)
    ...               - redirPrio set to 1
    ...               - reditRat set to eutra
    ...               During test execution Initial Context Setup Request is triggered with 5QI 1 + 5QI 5. gNB is configured to support redirection,
    ...               so gNB initiates a voice fallback procedure using redirection method.
    ...               QoS flow setup is rejected with cause "IMS voice EPS fallback or RAT fallback triggered". It is possible to check
    ...               inside Initial Context Setup Response message.
    ...               Due to flag actNormVCFallbackEnh set to True, after Initial Context Setup Response, gNB should send NAS PDU to the UE.
    ...               gNB triggers UE Context Setup Release on 5G side and sends RRC Release message with redirectedCarrierInfo IE to indicate the
    ...               LTE carrier on which the UE must try to select a cell. Value should be equal to redirFreqEutra from SCF.
    ...               UE Context Release procedure should be successfull.
    ...               5G_RAN_USR_RRM_21181

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Turn Off Sending Registration Request
        ...    AND             Add NAS PDU IE To Inital Context Setup Request
        ...    AND             Activate Additional 5QI

    Attach UE    ue_id=1
    Turn Voice Fallback On
    Establish PDU Session Without Confirmation    ue_id=1    pdu_id=1    gw_id=1
    Verify Ngap Messages    packet_filter=${INITIAL_CONTEXT_SETUP_RESPONSE_FALLBACK}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    Verify Ngap Messages    packet_filter=${TRANSMITTED_NAS_PDU}
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_EUTRA_FREQUENCY}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=1    relation_symbol= >=
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C02501   +1    NNGCC_UE_CTXT_STP_REQ_RECD
    ...    M55125C02502   +1    NNGCC_UE_CTXT_STP_RESP_SENT
    ...    M55124C02501   +1    NR_RRC_RELEASE_REDIR_VFB_LTE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Reset SMF
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB012113_4_Unsuccessful_Setup_Of_Voice_Over_NR_Call_With_ICSRequest_VoNR_Not_Supported_By_UE
    [Documentation]   This test case checks gNB behaviour during fallback procedure to LTE when voice call (5QI 1 + 5QI 5) is initiated
    ...               via Initial Context Setup Request. Fallback is initiated due to lack of the UE capability to establish VoNR call.
    ...               Test case requires following flags to be added to default config:
    ...               - actVoNR set to True
    ...               - actNormVCFallback set to True
    ...               - actNormVCFallbackEnh set to True
    ...               - actRedirect set to True
    ...               - voiceFBMode set to redirection
    ...               - redirFreqEutra set to LTE cell frequency (here 68586)
    ...               - redirPrio set to 1
    ...               - reditRat set to eutra
    ...               During test execution Initial Context Setup Request is triggered with 5QI 1 + 5QI 5. gNB is configured to support redirection,
    ...               so gNB initiates a voice fallback procedure using redirection method.
    ...               QoS flow setup is rejected with cause "IMS voice EPS fallback or RAT fallback triggered". It is possible to check
    ...               inside Initial Context Setup Response message.
    ...               Due to flag actNormVCFallbackEnh set to True, after Initial Context Setup Response, gNB should send NAS PDU to the UE.
    ...               gNB triggers UE Context Setup Release on 5G side and sends RRC Release message with redirectedCarrierInfo IE to indicate the
    ...               LTE carrier on which the UE must try to select a cell. Value should be equal to redirFreqEutra from SCF.
    ...               UE Context Release procedure should be successfull.
    ...               5G_RAN_USR_RRM_21181;5G_RAN_USR_RRM_2238;5G_CP_OTH_2776;5G_RAN_USR_RRM_2237

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Turn Off Sending Registration Request
        ...    AND             Add NAS PDU IE To Inital Context Setup Request
        ...    AND             Activate Additional 5QI

    Attach UE    ue_id=2
    Turn Voice Fallback On
    Establish PDU Session Without Confirmation    ue_id=2    pdu_id=2    gw_id=2
    Verify Ngap Messages    packet_filter=${INITIAL_CONTEXT_SETUP_RESPONSE_FALLBACK}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    Verify Ngap Messages    packet_filter=${TRANSMITTED_NAS_PDU}
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_EUTRA_FREQUENCY}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister Ue Without Confirmation   ue_id=2
        ...       AND             Reset SMF
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
