*** Settings ***
Documentation    This File is used for the All keywords specific to the Feature CB008159
Library         OperatingSystem
Library         taf.sw.syslog       WITH NAME   slog
Library         ta5g_pm_counters
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.wts.runner    WITH NAME    wtsrunner
Library         ute_fsmaccess
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${PDU_SESSION_MOD_PATTERN}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${PDU_SESSION_QOS_PATTERN}      PDU SESSION RESOURCE MODIFY RESPONSE
${LTE_NR_DUAL_CONNECTIVITY_RELEASE_PATTERN}      Bearer-type change from SCG-split to MCG
${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_MENB_WITH_MISC_UNSPECIFIED_PATTERN}      Cause : misc : unspecified
${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_SGNB_WITH_RADIONETWORK_TDCOVERALL_EXPIRY_PATTERN}      Cause : radioNetwork : tDCoverall-expiry
${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_SGNB_WITH_RADIONETWORK_USER_INACTIVITY_PATTERN}      Cause : radioNetwork : user-inactivity
${SGNBADDITIONREQUESTREJECT_WITH_RADIONETWORK_UNSPECIFIED_PATTERN}      Cause : radioNetwork : unspecified
${SGNB_ADDITION_REQUEST_REJECT_PATTERN}      SgNBAdditionRequestReject
${RADIO_CONN_RELEASE}    UE CONTEXT RELEASE COMPLETE
${PDUSESSION_RELEASE}    PDU SESSION RESOURCE RELEASE RESPONSE
${PDUSESSION_RELEASE_SUCCESS}    Successfully released PDU Session with ID 1
${WTS_WORKING_DIR}             /opt/iphy/latest
${GNB_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USERNAME}     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASSWORD}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${TOPOLOGY}             CLOUD_5G_I_LO_AP_LO
${DELTA_CONF_DIR}       ${CURDIR}/../../config/scf
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts


*** Keywords ***
UE Modification Should Be Successful
	[Documentation]		This keyword to check if UE modification is succesful
    [Arguments]     ${UE_ID}    ${Pdu_session_ID}    ${qosflows_to_add}=${QOS_ADD}
    wtsrunner.Ue Pdu Session Modify     ue=${UE_ID}     pdu=${Pdu_session_ID}    qosflows_to_add=${qosflows_to_add}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${PDU_SESSION_QOS_PATTERN}     timeout=20
    Print Matching Lines From Output File    ${output}    ${PDU_SESSION_MOD_PATTERN}
    Log To Console  ${PDU_SESSION_MOD_PATTERN}

Trigger VoNR Data
	[Documentation]		This keyword shall be used to start DL and UL rtp data
	[Arguments]    ${ue_id}   ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
	Log To Console    \nRunning VoNR DL/UL Traffic for ${rtp_codec}...
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=dl    trf_id=${trf_id}    rtp_codec=${rtp_codec}
	${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Downlink Internal traffic Receiver*
    ...    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=ul    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Uplink Internal traffic*
    ...      timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_UL_traffic_data_is_started_successfully

Trigger LTE-NR Dual Connectivity Release From MeNB With Misc Unspecified Cause
    [Documentation]        This Keyword used for LTE Dual connectivity Release.
    [Arguments]     ${UE_ID}
    wtsrunner.Enb Ue Dc Release     ue=${UE_ID}     by=enb    cause=MISC_CauseMisc_unspecified
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_PATTERN}     timeout=20
    Print Matching Lines From Output File    ${output}    ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_MENB_WITH_MISC_UNSPECIFIED_PATTERN}
    Log To Console  ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_MENB_WITH_MISC_UNSPECIFIED_PATTERN}

Force MeNB To Not Send SGNBReconfigurationComplete Upon Receiving SGNBAdditionRequestAcknowledge From SGNB
    [Documentation]     This keyword shall be Gnb Reconfiguration
    [Arguments]     ${MeNB_ID}
    wtsrunner.Enb Endc Param     id=${MeNB_ID}     menb_failure_scenario=dont_send_sgnb_reconf_complete

Verify SGnb Addition Failed With Cause TDCoverallexpiry
    [Documentation]     This keyword shall be GNB Addion failed with TDCoverallexpiry
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}
    wtsrunner.Enb Ue Dc Start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_PATTERN}     timeout=20
    Print Matching Lines From Output File    ${output}    ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_SGNB_WITH_RADIONETWORK_TDCOVERALL_EXPIRY_PATTERN}
    Log To Console  ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_SGNB_WITH_RADIONETWORK_TDCOVERALL_EXPIRY_PATTERN}

Trigger ENDC Connection And Verify SGNB Releasing ENDC Connection With Cause Userinactivity
    [Documentation]     This keyword shall be connection Release
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}
    wtsrunner.Enb Ue Dc Start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_PATTERN}     timeout=80
    Print Matching Lines From Output File    ${output}    ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_SGNB_WITH_RADIONETWORK_USER_INACTIVITY_PATTERN}
    Log To Console  ${LTE_NR_DUAL_CONNECTIVITY_RELEASE_BY_SGNB_WITH_RADIONETWORK_USER_INACTIVITY_PATTERN}

Trigger TCP Data
    [Documentation]     This keyword shall be used to start DL and UL tcp data
    [Arguments]    ${ue_id}   ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}     ${qfi_id}=${QFI_ID}
    Log To Console    \nRunning IMS Signalling to establish VoNR call...
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=dl    trf_id=${trf_id}    protocol=tcp
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Downlink Internal traffic Receiver*
    ...    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    TCP DL TRF:    partial_match=${TRUE}
    Log To Console    ${output} IMS Signalling_for_VoNR_in_DL_direction_is_started_successfully
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=ul    trf_id=${trf_id}    protocol=tcp
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Uplink Internal traffic*
    ...      timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    TCP UL TRF:    partial_match=${TRUE}
    Log To Console    ${output} IMS Signalling_for_VoNR_in_UL_direction_is_started_successfully

Trigger ENDC Connection For Multiple Non-GBR Bearers And Verify SgNB Rejecting It With Cause RadioNetwork Unspecified
    [Documentation]    Multiple Non Gbr Beares and verification.
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}
    wtsrunner.Enb Ue Dc Start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=2,3    type=split_scg
    ${output}    Read WTS Output Until Pattern Matches    ${SGNBADDITIONREQUESTREJECT_WITH_RADIONETWORK_UNSPECIFIED_PATTERN}     timeout=80
    Print Matching Lines From Output File    ${output}    ${SGNB_ADDITION_REQUEST_REJECT_PATTERN}
    Log To Console  ${SGNB_ADDITION_REQUEST_REJECT_PATTERN}

Radio Connection Ue Lost By AMF
    [Documentation]    This Keyword is used for UE lost By AMF.
    [Arguments]     ${UE_ID}
    wtsrunner.Ue Ng Ctx Release    id=${UE_ID}    by=amf    cause=RN_radio_connection_with_ue_lost
    ${output}    Read WTS Output Until Pattern Matches    ${RADIO_CONN_RELEASE}    timeout=20
    Print Matching Lines From Output File    ${output}    ${RADIO_CONN_RELEASE}
    Log To Console    ${RADIO_CONN_RELEASE}

Release QoS Flow Using PDUSessionResourceReleaseCommand With Normal Cause
    [Documentation]    This is For Release Qos Flow using PDU Session Resource release.
    [Arguments]     ${UE_ID}
    wtsrunner.Amf Ue Pdu Release Param    id=1    ue=${UE_ID}    cause=NAS_normal_release

Release PDUsession By AMF
    [Documentation]    PDU session Release By AMF
    [Arguments]     ${UE_ID}
    wtsrunner.Ue Pdu Session Release    ue=${UE_ID}    pdu=1    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${PDUSESSION_RELEASE}    timeout=20
    Print Matching Lines From Output File    ${output}    ${PDUSESSION_RELEASE_SUCCESS}
    Log To Console    ${PDUSESSION_RELEASE_SUCCESS}

Common Test Teardown For 8159
    [Documentation]    Common Tear Down For CB008159 where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_CB008159.zip
    Collect Logs For The Test       ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012464_TC1.zip ${LOG_PATH}
    Link SCOUT SCF To Configuration ID For Reporting
    Teardown Edaemon And Egate process
    RAT Block Unblock

Common Test Teardown For MP AP LO
    Collect Logs For The Test       ${Log_Path}
    Link SCOUT SCF To Configuration ID For Reporting
    Teardown Edaemon And Egate process
    RAT Block Unblock

Make SA Call
    [Documentation]    This is SA Call Specific to this testcase.
    [Arguments]    ${SAUE_ID}=${SAUE_ID}    ${gw_ID}=${gw_ID}
    Enable Internal TG   1  1
    Sleep   20s
    wtsrunner.Ue Register   id=${SAUE_ID}
    Sleep   30s
    wtsrunner.Ue Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${SAUE_ID}
    ...    nwslice=${nwslice_ID}       gw=${gw_ID}
    Sleep   30s

Register And Establish GBR And Non-GBR Calls
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls
    Enable Internal TG   1  1
    UE Register should be Successful for SA
    Sleep   10s
    Traffic Should Be Successful For SA
    Sleep   10s
    UE Modification Should Be Successful    1   1   2
    Sleep   10s
    Trigger TCP Data   1   1   3   2
    Sleep   10s
    UE Modification Should Be Successful    1   1   3
    Sleep   20s
    Trigger VoNR Data   1   1   3   3   amr_wb_18_25

Make ENDC Call
    [Documentation]    This Keyword is specific for this Test Case.
    [Arguments]    ${NSA_UE}=11
    LTE Attach Should Be Successful For NSA     ${NSA_UE}
    UE Attach Should Be Successful For NSA      ${NSA_UE}     1
