*** Settings ***
Documentation
...    Common keywords file

Library     ta_emss
Library     taf.sw.reporting_portal
Library     ute_wtssim
Library     ta_messaging
Library     ta_logcollector
Library     ta5g_testline_management
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/common_keywords.py
Library     String

*** Variables ***
${CONFIG_DIR}=     ${EXECDIR}/custom-config/L2_KRK_1/
${logcollector}=   True

*** Keywords ***
Prepare suite environment
    [Arguments]  ${egate_config}=${EMPTY}  ${scfc}=${EMPTY}  ${ap_xml}=${EMPTY}  ${rad_params}=@{EMPTY}  ${x2}=True
    Logcollector start
    Configure VM interfaces
    ${CONFIGURE_ENV}    get variable value    ${configure}    "True"
    Run keyword if  ${CONFIGURE_ENV}=="True"
    ...    Configure env  egate_setup=${egate_config}  scfc=${scfc}  ap_xml=${ap_xml}  rad_params=${rad_params}
    Setup Egate  egate_port=20000  alias=default
    Run keyword if  ${x2}==True  Establish x2 link
    Enable UE capture on simulated eNB  enable=${True}
    Setup emss in test
    Enable Ciphering

Clean suite environment
    Teardown emss
    Logcollector stop

Logcollector start
    Run keyword if  ${logcollector}==True
    ...     Start collecting logs
    ...     ELSE
    ...     Log  Logcollector was omitted by user

Logcollector stop
    Run keyword if  ${logcollector}==True
    ...     Stop collecting logs
    ...     ELSE
    ...     Log  Logcollector was omitted by user

Setup emss in test
    Teardown emss  bts_id=1
    Setup emss     bts_id=1

Configure VM interfaces
    Log To Console    Configure VM interfaces...

    Start default simulated SANSA interfaces

Establish x2 link
    Execute egate command
    ...    cmd=enb_x2_link_up enb=1 target=2
    ...    pass_regexp=ENB-1: X2AP Link with GNB-2.*is up

Enable Ciphering
    Configure  testsuite/Krakow/RRM/L2_KRK_1/resources/enable_ciphering.yaml

Create aliases
    Create aliases for ues
    Create ENB device with alias 'MeNB' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable internal mirroring for alias  gNB2

Create ues deployment
    [Arguments]  ${ues}=${EMPTY}
    ${ues_deployment} =   get_ues_deployment   ${ues}
    Set Suite Variable  ${ues_deployment}

Register UE
    [Arguments]  ${UE_ID}  ${CELL_ID}  ${GNB_ID}=2  ${RRC_CHECK}=False
    Log to console  Register NR-UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    UE_${UE_ID}:NR-RRC_RRCSetupRequest as RRCSetupRequest
    ...    UE_${UE_ID}:NR-RRC_RRCSetup as RRCSetup
    ...    UE_${UE_ID}:NR-RRC_RRCSetupComplete as RRCSetupComplet
    ...    alias=Register_NR_RRC_UE${UE_ID}   overall_timeout=10
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    AMF1:NGAP_InitialUEMessage as InitialUEMessage
    ...    gNB${GNB_ID}:NGAP_DownlinkNASTransport as DownlinkNASTransport
    ...    AMF1:NGAP_UplinkNASTransport as UplinkNASTransport
    ...    alias=Register_NGAP_UE${UE_ID}   overall_timeout=10
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    gNB${GNB_ID}:F1AP_DLRRCMessageTransfer as DLRRCMessageTransfer
    ...    gNB${GNB_ID}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer
    ...    gNB${GNB_ID}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer_2nd
    ...    alias=Register_F1AP_UE${UE_ID}   overall_timeout=10
    Execute egate command
    ...    cmd=ue_change_location id=${UE_ID} cell=${CELL_ID} enb=2
    Sleep  2s
    Execute egate command
    ...    cmd=ue_register id=${UE_ID}
    ...    pass_regexp=UE${UE_ID}: UE performed Registration type INITIAL_REGISTRATION
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Register_NR_RRC_UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Register_NGAP_UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Register_F1AP_UE${UE_ID}
    Execute egate command
    ...    cmd=ue_disp id=${UE_ID}

Attach UE
    [Arguments]  ${UE_ID}
    Log to console  ATTACH UE${UE_ID}
    Execute egate command
    ...    cmd=attach_ue id=${UE_ID}
    ...    pass_regexp=UE${UE_ID}: === UE IS ACTIVE
    Sleep  5s

SgNB Addition
    [Arguments]  ${UE_ID}  ${CELL_ID}  ${GNB_ID}=2  ${BEARER_ID}=2  ${RRC_CHECK}=False
    Log to console  SgNB ADDITION UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    gNB${GNB_ID}:X2AP_SgNBAdditionRequest as SgNBAdditionRequest
    ...    gNB${GNB_ID}:X2AP_SgNBAdditionRequestAcknowledge as RRCReconfiguration
    ...    gNB${GNB_ID}:X2AP_SgNBReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SgNBAddition_X2AP_UE${UE_ID}  overall_timeout=10
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    gNB${GNB_ID}:F1AP_UEContextSetupRequest as UEContextSetupRequest
    ...    gNB${GNB_ID}:F1AP_UEContextSetupResponse as UEContextSetupResponse
    ...    alias=SgNBAddition_UE${UE_ID}  overall_timeout=10
    Execute egate command
    ...    cmd=ue_dc_enb_start ue=${UE_ID} target_gnb=${GNB_ID} target_cells=${CELL_ID} bearer=${BEARER_ID} type=split_scg
    ...    pass_regexp=UE${UE_ID}: Proxy .eNB ${GNB_ID} cell ${CELL_ID}. reported successful RA
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=SgNBAddition_X2AP_UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=SgNBAddition_UE${UE_ID}

Establish PDU session
    [Arguments]  ${UE_ID}  ${PDU_ID}=${UE_ID}  ${SLICE_ID}=1  ${GW_ID}=${UE_ID}  ${GNB_ID}=2  ${RRC_CHECK}=False  ${CA_CHECK}=False
    ...     ${timeout}=None
    Log to console  ESTABLISH NR-UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    UE_${UE_ID}:NR-RRC_UECapabilityEnquiry as UECapabilityEnquiry
    ...    UE_${UE_ID}:NR-RRC_UECapabilityInformation as UECapabilityInformation
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=Established_NR_RRC_PDU_for_UE${UE_ID}   overall_timeout=20
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    AMF1:NGAP_InitialContextSetupRequest
    ...    AMF1:NGAP_UERadioCapabilityInfoIndication as UERadioCapabilityInfoIndication
    ...    AMF1:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...    alias=Established_NGAP_PDU_for_UE${UE_ID}   overall_timeout=20
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    gNB${GNB_ID}:F1AP_UEContextSetupRequest as UEContextSetupRequest
    ...    gNB${GNB_ID}:F1AP_UEContextSetupResponse as UEContextSetupResponse
    ...    gNB${GNB_ID}:F1AP_UEContextModificationRequest as UEContextModificationRequest_1st
    ...    gNB${GNB_ID}:F1AP_UEContextModificationResponse as UEContextModificationResponse_1st
    ...    gNB${GNB_ID}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${GNB_ID}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    alias=Established_PDU_for_UE${UE_ID}   overall_timeout=20
    Run keyword if  '${CA_CHECK}'=='True'
    ...    Expect message flow
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfiguration_CA
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_CA
    ...    alias=UE${UE_ID}_SCell_addition   overall_timeout=20
    Execute egate command
    ...    cmd=ue_pdu_session_setup pdu=${PDU_ID} ue=${UE_ID} nwslice=${SLICE_ID} gw=${GW_ID}
    ...    pass_regexp=UE${UE_ID}: Established PDU session    timeout=${timeout}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Established_NR_RRC_PDU_for_UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Established_NGAP_PDU_for_UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Established_PDU_for_UE${UE_ID}

Release PDU session
    [Arguments]  ${UE_ID}  ${PDU_ID}=${UE_ID}  ${GNB_ID}=2  ${RRC_CHECK}=False
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    AMF1:NGAP_PDUSessionResourceReleaseCommand
    ...    gNB${GNB_ID}:F1AP_UEContextModificationRequest as UEContextModificationRequest_1st
    ...    gNB${GNB_ID}:F1AP_UEContextModificationResponse as UEContextModificationResponse_1st
    ...    gNB${GNB_ID}:F1AP_DLRRCMessageTransfer as DLRRCMessageTransfer
    ...    gNB${GNB_ID}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    AMF1:NGAP_UplinkNASTransport as PDUSessionReleaseComplete
    ...    AMF1:NGAP_PDUSessionResourceReleaseResponse as PDUSessionResourceReleaseResponse
    ...    gNB${GNB_ID}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${GNB_ID}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    alias=Release_PDU_for_UE${UE_ID}   overall_timeout=10
    Execute egate command
    ...    cmd=ue_pdu_session_release ue=${UE_ID} pdu=${PDU_ID}
    ...    pass_regexp=Successfully released PDU Session with ID ${PDU_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Release_PDU_for_UE${UE_ID}

SgNB release
    [Arguments]  ${UE_ID}  ${GNB_ID}=2  ${BEARER_ID}=2  ${RRC_CHECK}=False
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    gNB${GNB_ID}:X2AP_SgNBReleaseRequest as SgNBReleaseRequest
    ...    gNB${GNB_ID}:X2AP_SgNBReleaseRequestAcknowledge as SgNBReleaseRequestAcknowledge
    ...    gNB${GNB_ID}:X2AP_UEContextRelease as UEContextRelease
    ...    alias=Release_SgNB_X2AP_for_UE${UE_ID}   overall_timeout=10
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Expect message flow
    ...    gNB${GNB_ID}:F1AP_UEContextModificationRequest as UEContextModificationRequest
    ...    gNB${GNB_ID}:F1AP_UEContextModificationResponse as UEContextModificationResponse
    ...    gNB${GNB_ID}:F1AP_UEContextReleaseCommand as UEContextReleaseCommand
    ...    gNB${GNB_ID}:F1AP_UEContextReleaseComplete as UEContextReleaseCommplete
    ...    alias=Release_SgNB_F1AP_for_UE${UE_ID}   overall_timeout=10
    Execute egate command
    ...    cmd=enb_ue_dc_release ue=${UE_ID} bearer=${BEARER_ID} by=enb cause=off
    ...    pass_regexp=UE${UE_ID}:  === Bearer-type change from SCG-split to MCG is successful ===
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Release_SgNB_X2AP_for_UE${UE_ID}
    Run keyword if  '${RRC_CHECK}'=='True'
    ...    Flow occurred as expected  alias=Release_SgNB_F1APfor_UE${UE_ID}

Detach UE
    [Arguments]  ${UE_ID}
    Execute egate command
    ...    cmd=detach_ue id=${UE_ID}
    ...    pass_regexp=UE${UE_ID}: detached

Deregister UE
    [Arguments]  ${UE_ID}
    Execute egate command
    ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off
    ...    pass_regexp=UE${UE_ID}: detached

Set pdu param for internal traffic
    [Arguments]  ${UE_ID}  ${PDU_ID}=${UE_ID}
    Execute egate command
    ...    cmd=set_pdu_param ue=${UE_ID} pdu=${PDU_ID} trf_type=internal
    Sleep  2s

Get Ue C-RNTI
    [Arguments]  ${UE_ID}
    Set Test Variable    ${crnti}  crnti
    ${crnti_UE} =    Run Keyword If    '${ues_deployment}[${UE_ID}]'=='SA'
    ...  get from message  flow_alias=Established_PDU_for_UE${UE_ID}  message_alias=UEContextSetupResponse  field=C-RNTI
    ...  ELSE IF                       '${ues_deployment}[${UE_ID}]'=='NSA'
    ...  get from message  flow_alias=SgNBAddition_UE${UE_ID}  message_alias=UEContextSetupResponse  field=C-RNTI
    Set Test Variable    ${${crnti}${UE_ID}}    ${crnti_UE}
