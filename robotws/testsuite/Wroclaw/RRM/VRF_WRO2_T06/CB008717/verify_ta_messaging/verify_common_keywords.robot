*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    verify_UEContextModification.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/verify_ta_messaging/verify_messages_flow/ta_messaging_flow.robot

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
    [Arguments]    ${gnb_id}    ${alias}    ${SN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${SN_gnb_id}) as SN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${SN_gnb_id}) as SN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextReleaseCommand as SN_UEContextReleaseCommand
    ...     gNB${gnb_id}:F1AP_UEContextReleaseComplete as SN_UEContextReleaseComplete
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback MN_F1AP
    [Arguments]     ${gnb_id}    ${alias}   ${MN_gnb_id}
    Expect Message Flow
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse
    ...     gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationRequest_2nd
    ...     gNB${gnb_id}:F1AP_UEContextModificationResponse (GNB-CU-UE-F1AP-ID eq ${MN_gnb_id}) as MN_UEContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback BearerContextModification
    [Arguments]    ${gnb_id}    ${alias}
    Expect Message Flow
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse
    ...     gNB${gnb_id}:E1AP_BearerContextModificationRequest as BearerContextModificationRequest_2nd
    ...     gNB${gnb_id}:E1AP_BearerContextModificationResponse as BearerContextModificationResponse_2nd
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify
    [Arguments]    ${alias}    ${amf_id}
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_PDUSessionResourceModifyRequest as PDUSessionResourceModifyRequest
    ...     AMF${amf_id}:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...     alias=${alias}    overall_timeout=60

Expect Messages for NR-DC Bearer Takeback RRCReconfiguration
    [Arguments]    ${ue_id}    ${alias}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1st
    ...     alias=${alias}    overall_timeout=60

Successfull NR-DC Takeback By Deletion of QoS Flow
    [Arguments]    ${UeCtxModReq_id}
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_${UeCtxModReq_id} out of 9 for gNB2
    Expect Messages for NR-DC Bearer Takeback SN_F1AP    gnb_id=2    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP    gnb_id=2    MN_gnb_id=${MN_gnb_id}     alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification     gnb_id=2    alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify    amf_id=1    alias=takeback_PDUSessionResourceModify
    Expect Messages for NR-DC Bearer Takeback RRCReconfiguration  ue_id=1    alias=takeback_RRCReconfiguration
    Trigger PDU Session Modify Procedure By Deletion of QoS Flow
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_PDUSessionResourceModify
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Verify expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

Unsuccessful NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration
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

NR-DC Takeback By Adding QoS by AMF Partial RAC failure with 2 Qos Flow
    Expect Messages for NR-DC Bearer Takeback PDUSessionResourceModify    amf_id=1    alias=takeback_PDUSessionResourceModifyFailed
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

Successfull Expiry Random Access Problem
    [Arguments]    ${ue_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback SN_F1AP     gnb_id=2     SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback MN_F1AP     gnb_id=2     MN_gnb_id=${MN_gnb_id}    alias=takeback_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification
    ...    gnb_id=2     alias=takeback_bearerContextModification
    Expect Messages for NR-DC Bearer Takeback ULRRCMessageTransfer  ue_id=${ue_id}    alias=takeback_RRCReconfiguration
    Triggered RRC By Random Access Problem
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_RRCReconfiguration

#JB_B7a
Set expected messages flow for A4 measurement configuration and deconfiguration for UE1, gNB2, AMF1
    Set expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=1
        ...    uECtxSet=1    uECtxMod=8    rrcReconf=4    rrcReconfCompl=4    timeout=300
    EXPECT FLOW[timeout=300]: gNB${gnb_id} F1AP 9*uEContextModification
    EXPECT FLOW[timeout=300]: UE_${ue_id} NR-RRC 5*RRCReconfiguration
    EXPECT FLOW[timeout=300]: UE_${ue_id} NR-RRC 5*RRCReconfigurationComplete

Verify expected messages flow for A4 measurement configuration and deconfiguration for UE1, gNB2, AMF1
    Verify expected message flow    iniCtxSet=1     ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    bearerCtxMod=1
        ...    uECtxSet=1    uECtxMod=8    rrcReconf=4    rrcReconfCompl=4    timeout=300
    FAIL FLOW[timeout=300]: gNB${gnb_id} F1AP 9*uEContextModification
    FAIL FLOW[timeout=300]: UE_${ue_id} NR-RRC 5*RRCReconfiguration
    FAIL FLOW[timeout=300]: UE_${ue_id} NR-RRC 5*RRCReconfigurationComplete

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
    Log To Console    Set expexted messages flow for NR-DC rollback after FR1 SCell Release on UE${ue}, gNB${gnb}, AMF${amf}

Verify expexted messages flow for NR-DC rollback after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 3*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    Log To Console    Verify expexted messages flow for NR-DC rollback after FR1 SCell Release on UE${ue}, gNB${gnb}, AMF${amf}
#N_B41a
Set expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP 5*uEContextModification
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    EXPECT FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    Log To Console    Set expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue}, gNB${gnb}

Verify expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue:\d+}, gNB${gnb:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 5*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
	PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextSetup
    PASS FLOW[timeout=60]: gNB${gnb} E1AP 2*bearerContextModification
    Log To Console    Verify expexted messages flow for NR-DC setup after FR1 SCell Release on UE${ue}, gNB${gnb}

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
    Log To Console    Set Expexted Messages For Unsuccesfull FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE${ue}, gNB${gnb}, AMF${amf_id}

Verify Expexted Messages Flows For Unsuccesfull FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE${ue:\d+}, gNB${gnb:\d+}, AMF${amf_id:\d+}
    PASS FLOW[timeout=60]: gNB${gnb} F1AP 4*uEContextModification
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC 1*RRCReconfigurationComplete
    FAIL FLOW[timeout=60]: UE_${ue} NR-RRC 2*RRCReconfigurationComplete
    PASS FLOW[timeout=60]: UE_${ue} NR-RRC RRCRelease
    PASS FLOW[timeout=60]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=60]: gNB${gnb} F1AP uEContextRelease
    PASS FLOW[timeout=60]: gNB${gnb} E1AP bearerContextRelease
    Log To Console    Verify Expexted Messages For Unsucces FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE${ue},gNB${gnb},AMF${amf_id}

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
    Log To Console    Set messages for A1 SCell Addition after NR-DC rollback and FR1 SCell Release for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}

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
    Log To Console    Verify expected messages for A1 SCell Add after NR-DC rollback and FR1 SCell Rel for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}
#N_B5c
Set expexted messages flow for NR-DC setup after FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=120]: gNB${gnb_id} F1AP 7*uEContextModification
    EXPECT FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=120]: gNB${gnb_id} E1AP 2*bearerContextModification
    Log To Console    Set expexted messages flow for NR-DC setup after FR1 SCell Release for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}

Verify expexted messages flow for NR-DC setup after FR1 SCell Release for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=120]: gNB${gnb_id} F1AP 7*uEContextModification
    PASS FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=120]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    PASS FLOW[timeout=120]: gNB${gnb_id} E1AP 2*bearerContextModification
    Log To Console   Verify expexted messages flow for NR-DC setup after FR1 SCell Release for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}

Set expexted messages flow for Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup

Verify expexted messages flow for Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback, gNB${gnb_id:\d+}
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup

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

Expect Messages for NR-DC Bearer Takeback ULRRCMessageTransfer
    [Arguments]    ${ue_id}    ${alias}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_SCGFailureInformation as SCGFailureInformation_1
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration_1st
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_1st
    ...     alias=${alias}    overall_timeout=60
