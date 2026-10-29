*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    verify_UEContextModification.robot
Resource    ../../keywords/verify_ta_messaging/verify_messages_flow/ta_messaging_flow.robot

*** Keywords ***

Set expected A4 measurement based PSCell addition messages flows for UE${ue_id:\d+}, gNB${gnb_id:\d+}, AMF${amf_id:\d+} & ${ue_ctx:\d+}*UECtxMod
    Set expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=3    uECtxSet=2
        ...    uECtxMod=${ue_ctx}    rrcReconf=3    rrcReconfCompl=3    amf_id=${amf_id}    gnb_id=${gnb_id}    ue_id=${ue_id}

Verify expected A4 measurement based PSCell addition messages flows for UE${ue_id:\d+}, gNB${gnb_id:\d+}, AMF${amf_id:\d+} & ${ue_ctx:\d+}*UECtxMod
    Verify expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=3
        ...    uECtxSet=2    uECtxMod=${ue_ctx}    rrcReconf=3    rrcReconfCompl=3    amf_id=${amf_id}    gnb_id=${gnb_id}    ue_id=${ue_id}

Set expected messages flows for ICS of UE${ue_id:\d+} with 1 QoS flow for gNB${gnb_id:\d+}, AMF${amf_id:\d+}
    Set expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=1    uECtxSet=1
        ...    uECtxMod=4    rrcReconf=2    rrcReconfCompl=2    amf_id=${amf_id}    gnb_id=${gnb_id}    ue_id=${ue_id}

Verify expected messages flows for ICS of UE${ue_id:\d+} with 1 QoS flow for gNB${gnb_id:\d+}, AMF${amf_id:\d+}
    Verify expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=1    uECtxSet=1
        ...    uECtxMod=4    rrcReconf=2    rrcReconfCompl=2    amf_id=${amf_id}    gnb_id=${gnb_id}    ue_id=${ue_id}

Set expected A4 measurement based PSCell addition messages flows for UE${ue:\d+} gNB${gnb:\d+}
    Set expected message flow    bearerCtxMod=2    uECtxSet=1    uECtxMod=2    rrcReconf=1    rrcReconfCompl=1    gnb_id=${gnb}    ue_id=${ue}

Verify expected A4 measurement based PSCell addition messages flows for UE${ue:\d+} gNB${gnb:\d+}
    Verify expected message flow    bearerCtxMod=2    uECtxSet=1    uECtxMod=2    rrcReconf=1    rrcReconfCompl=1    gnb_id=${gnb}    ue_id=${ue}

Set expected messages flows for A4 measurement based PSCell addition for UE${ue:\d+}, gNB${gnb:\d+} and AMF${a:\d+} with 2-DRB & ${c:\d+}*UECtxMod
    Set expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    pduSessResMod=1    bearerCtxSet=1
        ...    bearerCtxMod=5    uECtxSet=2    uECtxMod=${c}    rrcReconf=4    rrcReconfCompl=4    amf_id=${a}    gnb_id=${gnb}
        ...    ue_id=${ue}

Verify expected messages flows for A4 measurement based PSCell addition for UE${ue:\d+}, gNB${gnb:\d+} and AMF${a:\d+} with 2-DRB & ${c:\d+}*UECtxMod
    Verify expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    pduSessResMod=1    bearerCtxSet=1
        ...    bearerCtxMod=5    uECtxSet=2    uECtxMod=${c}    rrcReconf=4    rrcReconfCompl=4    amf_id=${a}    gnb_id=${gnb}
        ...    ue_id=${ue}

#=============N#B2d - Buffered based SCell Addition enabled and buffer monitioring enabled============================
Set expected A4 measurement based PSCell Addition with buffer monitoring for SCell Addition for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    Set expected message flow    bearerCtxMod=2     F1APprivateMSg=2    uECtxSet=1    uECtxMod=1    rrcReconf=1    gnb_id=${gnb_id}    ue_id=${ue_id}
        ...    timeout=60

Verify expected A4 measurement based PSCell Addition with buffer monitoring for SCell Addition for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    Verify expected message flow    bearerCtxMod=2     F1APprivateMSg=2    uECtxSet=1    uECtxMod=1    rrcReconf=1    gnb_id=${gnb_id}
        ...    ue_id=${ue_id}    timeout=60

# verification of RRC Reconfiguration Complete after receiving Buffer Overflow Notification
Set expected RRC Complete and UECntxMod for UE${ue_id:\d+}, gNB${gnb_id:\d+} after Private Message Received
    Set expected message flow    uECtxMod=1    rrcReconfCompl=1    gnb_id=${gnb_id}    ue_id=${ue_id}    timeout=60

Verify expected RRC Complete and UECntxMod for UE${ue_id:\d+}, gNB${gnb_id:\d+} after Private Message Received
    Verify expected message flow    uECtxMod=1    rrcReconfCompl=1    gnb_id=${gnb_id}    ue_id=${ue_id}    timeout=60

# ============================ N_B5a specific keywords ===========================
Set expected A4 measurement based PSCell addition messages flows for UE${ue_id:\d+} gNB${gnb_id:\d+} after FR1 CA Release
    Set expected message flow    bearerCtxMod=2   uECtxSet=1    uECtxMod=5    rrcReconf=2    rrcReconfCompl=2    gnb_id=${gnb_id}    ue_id=${ue_id}

Verify expected A4 measurement based PSCell addition messages flows for UE${ue_id:\d+} gNB${gnb_id:\d+} after FR1 CA Release
    Verify expected message flow   bearerCtxMod=2   uECtxSet=1    uECtxMod=5    rrcReconf=2    rrcReconfCompl=2    gnb_id=${gnb_id}    ue_id=${ue_id}
# ============================ END of N_B5a specific keywords ===========================

UE${ue_id:\d+} sends ${m:\S+} measurement id=${meas_id:\d+} for ${reason}
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC MeasurementReport

    Run Keyword If    (('${m}' == 'A1') and ('${reason}' == 'SCell Addition'))
    ...    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} srsrp_nr=80 event=A1

    ...    ELSE IF    '${m}' == 'A2'
    ...        Execute egate command
    ...        cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=1 scell_rsrp=30 event=A2

    ...    ELSE IF    '${m}' == 'A3'
    ...        Execute egate command
    ...        cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 phycell_id=51 nrsrp_nr=100

    ...    ELSE IF    '${m}' == 'A4'
    ...        Execute egate command
    ...        cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=52 nrsrp_nr=60 event=A4

    ...    ELSE IF    '${m}' == 'A6'
    ...        Execute egate command
    ...        cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=1 scell_rsrp=20 phycell_id=51 nrsrp_nr=90 event=A6

    ...    ELSE IF    (('${m}' == 'A1') and ('${reason}' == 'SCell Change'))
    ...        Execute egate command
    ...        cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} srsrp_nr=90 event=A1

    ...    ELSE
    ...        Fail   Lack of implementation

    Run Keyword If    ('${m}' == 'A1') or ('${m}' == 'A2') or ('${m}' == 'A4') or ('${m}' == 'A6')
    ...     PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC MeasurementReport
    Run Keyword If    ('${m}' == 'A1') or ('${m}' == 'A2') or ('${m}' == 'A4') or ('${m}' == 'A6')
    ...     Verify that MeasurementReport contains ${m} measurement results for UE${ue_id} and measId=${meas_id}

Expect Messages for NR-DC Bearer Takeback SN_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${SN_gnb_id}) as SN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${SN_gnb_id}) as SN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as SN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as SN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback SN_F1AP with known only MN_GNB_ID
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID ne ${MN_gnb_id}) as SN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID ne ${MN_gnb_id}) as SN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as SN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as SN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_2nd
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback ULRRCMessageTransfer
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_SCGFailureInformation as SCGFailureInformation_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1st
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback ULRRCMessageTransfer w/o Complete
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_SCGFailureInformation as SCGFailureInformation_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCRelease as RRCRelease_1
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP Interupted By Release
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP due to lack of NR-SCG-Response including NRDC setup
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as NRDC_Setup_MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as NRDC_Setup_MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as NRDC_Setup_MN_UEContextModificationRequest_2nd
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as NRDC_Setup_MN_UEContextModificationResponse_2nd
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_2nd
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP Lack NR-SCG-Response
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id})
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id})
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_2nd
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP Lack NR-SCG-Response No RRC Complete
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id})
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id})
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback E1AP including NRDC setup
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as NRDC_setup_BearerContextModificationRequest
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as NRDC_setup_BearerContextModificationResponse
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as NRDC_setup_BearerContextModificationRequest_2nd
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as NRDC_setup_BearerContextModificationResponse_2nd
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest_2nd
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback BearerContextModification
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest_2nd
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback BearerContextModification Interupted By Release
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_PDUSessionResourceModifyRequest as PDUSessionResourceModifyRequest
    ...     AMF${amf_id}:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback RRCReconfiguration
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1st
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback RRCReconfiguration including NRDC setup
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as NRDC_setup_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as NRDC_setup_RRCReconfigurationComplete
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1st
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Release After Lack Of RRCReconfigurationComplete_RRC
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     alias=${alias}    overall_timeout=180

Expect Messages for NR-DC Release After Lack Of RRCReconfigurationComplete_NGAP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}
    Expect Message Flow
    ...     gNB${gnb_id}:NGAP_UEContextReleaseCommand as NGAP_UEContextReleaseCommand
    ...     gNB${gnb_id}:NGAP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=180

Expect Messages for NR-DC Release After Lack Of RRCReconfigurationComplete_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=180

Expect Messages for NR-DC Bearer Takeback RLF SN_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequired (GNB-CU-UE-F1AP-ID eq ${SN_gnb_id}) as SN_UEContextModificationRequired
    ...     gNB${gnb_id}:F1AP_UEContextModificationConfirm (GNB-CU-UE-F1AP-ID eq ${SN_gnb_id}) as SN_UEContextModificationConfirm
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback BearerCtxRel
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}  ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:E1AP_BearerContextReleaseCommand as BearerCtxReleaseCommand
    ...     gNB${gnb_id}:E1AP_BearerContextReleaseComplete as BearerCtxReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP CTX
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback BearerCtxMod
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback UEContexRelease Cause_NGAP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:NGAP_UEContextReleaseRequest as MN_UECtxReleaseRequest
    ...     gNB${gnb_id}:NGAP_UEContextReleaseCommand as NGAP_UEContextReleaseCommand
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback UEContexRelease Cause_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand_2
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback RRCRecon
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCRelease as RRCRelease_1
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback RRCRecon With Complete
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1st
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback UECtxRelease with Cause
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as MN_UEContextReleaseComplete

    ...     alias=${alias}    overall_timeout=60


Expect Messages for NR-DC Bearer Takeback UEContexRelease_NGAP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:NGAP_UEContextReleaseRequest as MN_UECtxReleaseRequest
    ...     gNB${gnb_id}:NGAP_UEContextReleaseCommand as MN_UEContextReleaseCommand_2
    ...     gNB${gnb_id}:NGAP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback UEContexRelease_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback PDUSessResModifyRes
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback UEContexRelease With Additional Release NGAP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:NGAP_UEContextReleaseRequest as MN_UECtxReleaseRequest
    ...     gNB${gnb_id}:NGAP_UEContextReleaseCommand as MN_UEContextReleaseCommand_2
    ...     gNB${gnb_id}:NGAP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=80

Expect Messages for NR-DC Bearer Takeback UEContexRelease With Additional Release F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as MN_UEContextReleaseComplete
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as MN_UEContextReleaseCommand2
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as MN_UEContextReleaseComplete2
    ...     alias=${alias}    overall_timeout=80

Successfull NR-DC Takeback By Addition Of QoSFlow
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${UeCtxModReq_id}
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_${UeCtxModReq_id} out of 6 for gNB2
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}     alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Trigger PDU Session Modify Procedure
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Successfull NR-DC Takeback By Addition Of QoSFlow Interupted By Release
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${UeCtxModReq_id}
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_${UeCtxModReq_id} out of 6 for gNB2
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP Interupted By Release
    ...   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}     alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification Interupted By Release
    ...   ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Release After Lack Of RRCReconfigurationComplete_RRC     ue_id=1    gnb_id=2    alias=RRC_UECtxRelComm
    Expect Messages for NR-DC Release After Lack Of RRCReconfigurationComplete_NGAP    ue_id=1    gnb_id=2    alias=NGAP_UECtxRelComm
    Expect Messages for NR-DC Release After Lack Of RRCReconfigurationComplete_F1AP    ue_id=1    gnb_id=2    alias=F1AP_UECtxRelComm

    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any delay=5s
    Trigger PDU Session Modify Procedure
    Sleep  2s
    Execute Egate Command     cmd=ue_ng_ctx_release by=amf cause=RN_CauseRadioNetwork_unspecified id=1
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=RRC_UECtxRelComm
    Flow Occurred As Expected    alias=NGAP_UECtxRelComm
    Flow Occurred As Expected    alias=F1AP_UECtxRelComm

Successfull NR-DC Takeback RLF
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback RLF SN_F1AP    ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP_2
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    RLF Profile Activation Trigger Takeback
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_SN_F1AP_2
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Successfull NR-DC Takeback By Deletion of QoS Flow
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${UeCtxModReq_id}
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_${UeCtxModReq_id} out of 8 for gNB2
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}     alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Trigger PDU Session Modify Procedure By Deletion of QoS Flow
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration


NR-DC Takeback RLF With Delay In Sending RRCReconfigurationComplete
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback RLF SN_F1AP    ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP_2
    Expect Messages for NR-DC Bearer Takeback MN_F1AP CTX   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerCtxMod  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback RRCRecon  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Expect Messages for NR-DC Bearer Takeback BearerCtxRel   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_BearerCtxRel
    Expect Messages for NR-DC Bearer Takeback UEContexRelease_F1AP  ue_id=1    gnb_id=2    amf_id=1  SN_gnb_id=${SN_gnb_id}   alias=F1AP_UECtxRelComm
    Expect Messages for NR-DC Bearer Takeback UEContexRelease_NGAP  ue_id=1    gnb_id=2    amf_id=1  SN_gnb_id=${SN_gnb_id}   alias=NGAP_UECtxRelComm
    Activation RLF With Delay
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_SN_F1AP_2
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration
    Flow Occurred As Expected    alias=takeback_BearerCtxRel
    Flow Occurred As Expected    alias=F1AP_UECtxRelComm
    Flow Occurred As Expected    alias=NGAP_UECtxRelComm


Prep Successfull NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP Lack NR-SCG-Response
    ...    ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration

Successfull NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Set expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP with known only MN_GNB_ID
        ...    ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP due to lack of NR-SCG-Response including NRDC setup
        ...    ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback E1AP including NRDC setup
        ...    ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration including NRDC setup
        ...    ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration

Verify expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Prepare unsuccessful NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_5 out of 7 for gNB2
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP Lack NR-SCG-Response No RRC Complete
    ...    ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerCtxMod  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback RRCRecon  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Expect Messages for NR-DC Bearer Takeback BearerCtxRel
    ...    ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_BearerCtxRel
    Expect Messages for NR-DC Bearer Takeback UEContexRelease With Additional Release NGAP
    ...    ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}   alias=NGAP_UECtxRelComm
    Expect Messages for NR-DC Bearer Takeback UEContexRelease With Additional Release F1AP
    ...    ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}   alias=F1AP_UECtxRelComm

Unsuccessful NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration
    Flow Occurred As Expected    alias=takeback_BearerCtxRel
    Flow Occurred As Expected    alias=NGAP_UECtxRelComm
    Flow Occurred As Expected    alias=F1AP_UECtxRelComm


NR-DC Takeback By Adding QoS With Drop RRC Message
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP CTX   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerCtxMod  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Bearer Takeback RRCRecon  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Expect Messages for NR-DC Bearer Takeback PDUSessResModifyRes  ue_id=1    gnb_id=2    amf_id=1
    ...     SN_gnb_id=${SN_gnb_id}     alias=takeback_PDUSessionResourceModifyFailed
    Expect Messages for NR-DC Bearer Takeback BearerCtxRel   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}
    ...     alias=takeback_BearerCtxRel
    Expect Messages for NR-DC Bearer Takeback UEContexRelease Cause_NGAP  ue_id=1    gnb_id=2    amf_id=1
    ...        SN_gnb_id=${SN_gnb_id} MN_gnb_id=${MN_gnb_id}   alias=NGAP_UECtxRelComm
    Expect Messages for NR-DC Bearer Takeback UEContexRelease Cause_F1AP    ue_id=1    gnb_id=2    amf_id=1
    ...        SN_gnb_id=${SN_gnb_id} MN_gnb_id=${MN_gnb_id}   alias=F1AP_UECtxRelComm
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModifyFailed
    Flow Occurred As Expected    alias=takeback_BearerCtxRel
    Flow Occurred As Expected    alias=NGAP_UECtxRelComm
    Flow Occurred As Expected    alias=F1AP_UECtxRelComm


#N_B1a
Set expected messages flow for A4 and A1 meas activation for UE${ue_id:\d+}, gNB${gnb_id:\d+}, AMF${amf_id:\d+} & ${ue_ctx:\d+}*UECtxMod
    EXPECT FLOW[timeout=60]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP ${ue_ctx}*uEContextModification

Verify expected messages flow for A4 and A1 meas activation for UE${ue_id:\d+}, gNB${gnb_id:\d+}, AMF${amf_id:\d+} & ${ue_ctx:\d+}*UECtxMod
    PASS FLOW[timeout=60]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP ${ue_ctx}*uEContextModification


NR-DC Takeback By Adding QoS by AMF Partial RAC failure
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Bearer Takeback RRCRecon With Complete  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Expect Messages for NR-DC Bearer Takeback UECtxRelease with Cause  ue_id=1    gnb_id=2    amf_id=1
    ...        SN_gnb_id=${SN_gnb_id} MN_gnb_id=${MN_gnb_id}   alias=F1AP_UECtxRelComm
    Modify PDU Session with adding 2 Qos
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=F1AP_UECtxRelComm

NR-DC Takeback By Adding QoS by AMF Partial RAC failure with 2 Qos Flow
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1
    ...          alias=takeback_PDUSessionResourceModifyFailed
    Modify PDU Session with adding 2 Qos
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModifyFailed

#N_B2c
Set expexted messages flow for NR-DC rollback when A4&A1meas were configured on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+} & ${ue_ctx:\d+}*UECtxMod
    EXPECT FLOW[timeout=60]: AMF${amf} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP ${ue_ctx}*uEContextModification
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 3*bearerContextModification

Verify expexted messages flow for NR-DC rollback when A4&A1meas were configured on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+} & ${ue_ctx:\d+}*UECtxMod
    PASS FLOW[timeout=60]: AMF${amf} NGAP initialContextSetup
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} F1AP ${ue_ctx}*uEContextModification
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 3*bearerContextModification

#NB6b
Set expected A4 measurement based PSCell addition messages flows for UE${ue_id:\d+} gNB${gnb_id:\d+}, A1 and A4 meas deconfig
    EXPECT FLOW[timeout=30]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected A4 measurement based PSCell addition messages flows for UE${ue_id:\d+} gNB${gnb_id:\d+}, A1 and A4 meas deconfig
    PASS FLOW[timeout=30]: gNB${gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected flow for starting DL data buffer monitoring for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP privateMessage

Verify expected flow for starting DL data buffer monitoring for gNB${gnb_id:\d+}
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP privateMessage

Successfull Expiry Random Access Problem
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=${ue_id}    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP   ue_id=${ue_id}     gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification
    ...    ue_id=${ue_id}     gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback ULRRCMessageTransfer  ue_id=${ue_id}   gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Triggered RRC By Random Access Problem
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Error case NR-DC Bearer Takeback Triggered Due To Reception Of RRC
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${UeCtxModReq_id}
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_${UeCtxModReq_id} out of 6 for gNB2
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP CTX   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerCtxMod  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback ULRRCMessageTransfer w/o Complete   ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Expect Messages for NR-DC Bearer Takeback BearerCtxRel   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}    alias=takeback_BearerCtxRel
    Expect Messages for NR-DC Bearer Takeback UEContexRelease_NGAP    ue_id=1  gnb_id=2  amf_id=1    SN_gnb_id=${SN_gnb_id}   alias=NGAP_UECtxRelComm
    Expect Messages for NR-DC Bearer Takeback UEContexRelease_F1AP    ue_id=1  gnb_id=2  amf_id=1    SN_gnb_id=${SN_gnb_id}   alias=F1AP_UECtxRelComm
    Triggered RRC By Random Access Problem
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration
    Flow Occurred As Expected    alias=takeback_BearerCtxRel
    Flow Occurred As Expected    alias=NGAP_UECtxRelComm
    Flow Occurred As Expected    alias=F1AP_UECtxRelComm

Expect Messages for RRCReconfiguration in NR-DC Bearer Takeback followed by FR1 SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_2
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_2
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback Followed By Scell Addition MN_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_4
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_4
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_5
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_5
    ...     alias=${alias}    overall_timeout=60

#JB_B7a
Set expected messages flow for A4 measurement configuration and deconfiguration for UE1, gNB2, AMF1
    Set expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=1
        ...    uECtxSet=1    uECtxMod=6    rrcReconf=3    rrcReconfCompl=3    timeout=300
    EXPECT FLOW[timeout=300]: gNB${gnb_id} F1AP 8*uEContextModification
    EXPECT FLOW[timeout=300]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    EXPECT FLOW[timeout=300]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete

Verify expected messages flow for A4 measurement configuration and deconfiguration for UE1, gNB2, AMF1
    Verify expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=1
        ...    uECtxSet=1    uECtxMod=6    rrcReconf=3    rrcReconfCompl=3    timeout=300
    FAIL FLOW[timeout=300]: gNB${gnb_id} F1AP 8*uEContextModification
    FAIL FLOW[timeout=300]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    FAIL FLOW[timeout=300]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete

Set expected messages flow for A4 measurement configuration for UE1, gNB2, AMF1
    Set expected message flow    uECtxMod=2    rrcReconf=1    rrcReconfCompl=1    timeout=200

Verify expected messages flow for A4 measurement configuration for UE1, gNB2, AMF1
    Verify expected message flow    uECtxMod=2    rrcReconf=1    rrcReconfCompl=1    timeout=200

#N_B8a
Set expected messages flows for A1 measurement based SCell Addition for FWA UE${ue_id1:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue_id1} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=60]: UE_${ue_id1} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP 7*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue_id1} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id1} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows for A1 measurement based SCell Addition for FWA UE${ue_id1:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=60]: UE_${ue_id1} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=60]: UE_${ue_id1} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP 7*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue_id1} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id1} NR-RRC 3*RRCReconfigurationComplete

Set expected messages flows for A1 measurement based SCell Addition for non FWA UE${ue_id2:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue_id2} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=60]: UE_${ue_id2} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP 5*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue_id2} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id2} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: UE_${ue_id2} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id2} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows for A1 measurement based SCell Addition for non FWA UE${ue_id2:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=60]: UE_${ue_id2} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=60]: UE_${ue_id2} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP 5*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue_id2} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id2} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=60]: UE_${ue_id2} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=60]: UE_${ue_id2} NR-RRC 3*RRCReconfigurationComplete

#N_41d
Set expexted messages flow for NR-DC rollback after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 3*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification

Verify expexted messages flow for NR-DC rollback after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 3*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification

Set expected messages flows for FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+} triggered by sending A4 measurement
    EXPECT FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP 8*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextRelease


Verify expected messages flows for FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+} triggered by sending A4 measurement
    PASS FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP 8*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    FAIL FLOW[timeout=60]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextRelease

#N_B41a
Set expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 5*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification

Verify expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 5*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
	PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification

#N_42a
Set Expexted Messages Flows For NRDC Setup After FR1 SCell Release After A1 CA On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 8*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup

Verify Expexted Messages Flows For NRDC Setup After FR1 SCell Release After A1 CA On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 8*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup

#N_42c
Set Expexted Messages Flows For Unsuccesfull FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 4*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC RRCRelease
    EXPECT FLOW[timeout=60]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextRelease
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP bearerContextRelease


Verify Expexted Messages Flows For Unsuccesfull FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf_id:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 4*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    FAIL FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC RRCRelease
    PASS FLOW[timeout=60]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextRelease
    PASS FLOW[timeout=60]: gNB${gnb} E1AP bearerContextRelease

Expect Messages for NR-DC Bearer Takeback Followed By Buffered Based Scell Addition MN_F1AP
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}    ${amf_id}    ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_2
    ...     gNB${gnb_id}:F1AP_PrivateMessage as PrivateMessage_1
    ...     gNB${gnb_id}:F1AP_PrivateMessage as PrivateMessage_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_4
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_4
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_5
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_5
    ...     alias=${alias}    overall_timeout=60

#N_B4.2d & 4.2f
Set expected messages for A1 SCell Addition after NR-DC rollback and FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP 13*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 5*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 5*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP 3*bearerContextModification

Verify expected messages for A1 SCell Addition after NR-DC rollback and FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP 13*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 5*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 5*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP 3*bearerContextModification

#N_41f
Set expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 5*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP privateMessage

Verify expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 5*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    FAIL FLOW[timeout=60]: gNB${gnb} F1AP privateMessage

#N_B42e
Set Expexted Messages Flows For Rejecting Unbuffered CA Procedures after NR-DC Setup On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*MeasurementReport
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 3*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification

Verify Expexted Messages Flows For Rejecting Unbuffered CA Procedures after NR-DC Setup On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf_id:\d+}
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*MeasurementReport
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 3*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification

Expect Messages for Blind FR1 CA After Bearer Takeback
    [Arguments]    ${ue_id}    ${gnb_id}    ${alias}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_1
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_4
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_4
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_2
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_2
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_5
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_5
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_6
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_6
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_3
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_3
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_7
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_7
    ...     alias=${alias}    overall_timeout=60

Successfull NR-DC Takeback By Addition Of QoSFlow followed by FR1 CA
    [Arguments]    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP   ue_id=1    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP   ue_id=1    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}     alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration  ue_id=1    gnb_id=2    amf_id=1    alias=takeback_RRCReconfiguration
    Expect Messages for Blind FR1 CA After Bearer Takeback  ue_id=1    gnb_id=2    alias=blind_FR1_CA_after_bearer_takeback
    Trigger PDU Session Modify Procedure
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration
    Flow Occurred As Expected    alias=blind_FR1_CA_after_bearer_takeback

#N_B7b
Set Expexted Messages Flows Avoiding FR1 SCellRel In Dequeued NRDC Setup After Unsuccessful SCell Add UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*MeasurementReport

Verify Expexted Messages Flows Avoiding FR1 SCellRel In Dequeued NRDC Setup After Unsuccessful SCell Add UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 2*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*MeasurementReport

#N_B7f
Set Expexted Messages Flows For NRDC Setup After SCell Swap And FR1 SCell Release On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 8*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup

Verify Expexted Messages Flows For NRDC Setup After SCell Swap And FR1 SCell Release On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 8*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup

#N_B5c
Set expexted messages flow for NR-DC setup after FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=120]: gNB${gnb_id} F1AP 7*uEContextModification
    EXPECT FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=120]: gNB${gnb_id} E1AP 2*bearerContextModification

Verify expexted messages flow for NR-DC setup after FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=120]: gNB${gnb_id} F1AP 7*uEContextModification
    PASS FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    PASS FLOW[timeout=120]: gNB${gnb_id} E1AP 2*bearerContextModification

Set expexted messages flow for Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup

Verify expexted messages flow for Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback, gNB${gnb_id:\d+}
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup


#N_B7c
Set Expexted Messages Flows For NRDC Setup After FR1 SCell Release Triggered By A2 Measurement On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 8*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup

Verify Expexted Messages Flows For NRDC Setup After FR1 SCell Release Triggered By A2 Measurement On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 8*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 3*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup

#N_B7d
Set Expected Messages Flows For SCell Rele After SCell Change From TDD2CC To FDD1CC for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    #Set expected message flow    bearerCtxMod=2    uECtxSet=1    uECtxMod=2    rrcReconf=1    rrcReconfCompl=1    gnb_id=${gnb_id}    ue_id=${ue_id}
    EXPECT FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP 2*uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP 15*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 6*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC 6*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb_id} E1AP 2*bearerContextModification

Verify Expected Messages Flows For SCell Rele After SCell Change From TDD2CC To FDD1CC for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=300]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP 2*uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP 15*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 6*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC 6*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb_id} E1AP 2*bearerContextModification


#NB3a
Set expexted messages flow NR-DC A4 meas activation after PDU Session establish proc for UE${ue:\d+}, gNB${gnb:\d+} and AMF${amf:\d+}
    Set expected message flow    iniCtxSet=1    uECtxMod=7    rrcReconf=3    rrcReconfCompl=3    gnb_id=${gnb}    ue_id=${ue}    amf_id=${amf}

Verify expexted messages flow NR-DC A4 meas activation after PDU Session establish proc for UE${ue:\d+}, gNB${gnb:\d+} and AMF${amf:\d+}
    Verify expected message flow    iniCtxSet=1    uECtxMod=7    rrcReconf=3    rrcReconfCompl=3    gnb_id=${gnb}    ue_id=${ue}    amf_id=${amf}

#N_B1c
Set expected messages flow for RRCReestablishment with A1 & A4 after retry timer meas activation for UE1, gNB2
    Set expected message flow    uECtxMod=7    rrcReconf=3    rrcReconfCompl=3    rrcReestablishment=1    rrcReestablishmentReq=1
        ...        rrcReestablishmentComplete=1    gnb_id=${gnb_id}    ue_id=${ue_id}

Verify expected messages flow for RRCReestablishment with A1 & A4 after retry timer meas activation for UE1, gNB2
    Verify expected message flow    uECtxMod=7    rrcReconf=3    rrcReconfCompl=3    rrcReestablishment=1    rrcReestablishmentReq=1
        ...        rrcReestablishmentComplete=1    gnb_id=${gnb_id}    ue_id=${ue_id}
