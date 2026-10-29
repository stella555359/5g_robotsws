*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED    CIT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski, Kornel Dłużniewski
...             :contact: tomasz.dabrowski@nokia.com


Resource            ../resources/feature_keywords.robot
Resource            ../../resources/testing_env.robot
Resource            ../../keywords/traffic.robot
Resource            taf/rfrl/utilities/utf_lab/utf_lab.robot
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot

Library             testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490/resources/keywords.py
Library             taf.ul.ettf.setups
Library             ../resources/multignb_variables.py
Library             ../resources/KeywordsCB008490.py
Library             ../resources/syslog_collector.py
Variables           ../resources/custom_policy.py
Library             taf.sbts.oam.coam.admin     WITH NAME    admin
Library             OperatingSystem      WITH NAME    os
Library             ../resources/common_keywords.py


Suite Setup        Run Keywords
#...                Update UTF Lab on UTE VM
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Netconf access
...    AND         Upload oransnapshot.xml to AP   iphy_snap=${IPHY_SNAP}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}    remote_hosts=${REMOTE_HOSTS}    timeout=600
...    AND         Enforce protocol    nr-rrc
#...    AND         Start UTF Lab on UTE VM
#...    AND         Wait Until UTF Lab Connection Is Established

Test Setup         Run Keywords
#...                  UTF Lab Start Tracing gNB    gnb_ip=192.168.255.129    gnb_port=443     gnb_username=Nemuadmin      gnb_password=nemuuser
...                  Enable Tshark Verification
...    AND           Setup multigNB devices aliases
...    AND           Start Collecting Syslog From Gnbs

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${SCFC_GNB_MN}=             MN_scfc_LAB4A1_oran.xml
${SCFC_GNB_SN}=             SN_scfc_LAB4A1_oran.xml
${IPHY}=                    ${CURDIR}/config/iphy_LAB4A1_oran.xml
${IPHY_SNAP}                iphy_snap_CB008490_LAB4A1_N78.xml
${cfg}=                     ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M_LA_B4A1_oran.cfg
${ue_id}=                   1
${pdu_id}=                  1
${amf_id}=                  1
${band_comb_1}=             1
${band_comb_2}=             3
${band_comb_index_asn_1}=   '0x0000'
${band_comb_index_asn_2}=   '0x0002'
@{meas_objects_id_list}=     1     2     2
@{report_config_ids}=        1     1
@{FAULT_IDS_LIST}=            6450    4383
@{mn_logs}=                 cp_5g
${UTF_DIR_NAME}             UTF_LAB
${CONNECTION_ALIAS}         UTE_UTF_LAB

*** Test Cases ***
CB008490-LA_B4_Alt1_CSI-RS_Upgrade_In_PCell_During_NR-DC_Bearer_Takeback
    Set ICS Flow
    ta5g_ue_mobility.Attach Ue    ue_id=${ue_id}    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Establish Pdu Session
    Send Data Traffic    inactive_timer=1
    Wait 2s For Message Flow To Set Up
    Verify ICS Flow
    Get Values From GTP_Tunnel In ICS To Compare Later
    Get Values From QosFlowLevelQosParameters In ICS
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Wait 5s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Get Values From APIDs In SNnodeAddPrep
    Set Expected Message Flow For Takeback On MN Side After PDU Session Modification
    Set Expected Message Flow For Takeback On SN Side
    Wait 2s For NRDC Takeback
    Trigger PDU Session Modify Procedure For UE1 With PDU1 And QoS Flow ID Eq 2
    Verify Expected Message Flow For Takeback On MN Side After PDU Session Modification
    Verify Expected Message Flow For Takeback On SN Side
    Get Values Of GtpTunnels
    Get Values From PDUSessionAdmittedAddedAddReqAck In SNnodeAddPrep
    Get Values Of PDCP Status Transfer
    Get Values From GTP_Tunnel In Takeback And Verify They Are Correctly Assigned For MN Side
    Get Values From LogicalChannelIdentity In Takeback And Verify They Are Correctly Assigned For MN Side
    Verify E1AP On SN side
    Verify E1AP On MN side
    Verify F1AP On SN side
    Verify F1AP On MN side
    Verify RRC
    Verify XNAP
    Verify NGAP
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Wait 6s For A4 Retry Timer Expired
    #Verify that UeCapability check is passed
    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue_id}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Stop Collecting Syslog And Download Files
#    ...            AND    Stop UTF Lab on UTE VM
    ...            AND    Add scout external execution id to the reporting portal


*** Keywords ***
Create dcap filters
    ${f1ap_protocol}=     Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPRT_CPRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPRT_CPRT_RECEIVEFROMCPUE_ID"
    ${e1ap_protocol}=    Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_RECEIVEFROMCPUE_ID"
    ${other_protocols}=    Catenate    SEPARATOR=;  "Message name"="SctpMessage"    "Message name"="ZmqMessage"
    ...    "Message name"="TmMessage"
    ${filtered_protocols}=  Catenate  SEPARATOR=;  ${f1ap_protocol}  ${e1ap_protocol}  ${other_protocols}
    [Return]    ${filtered_protocols}

Verify that UeCapability check is passed
    @{master_node_messages}=    Create List    UeCapabilityCheckRequest
    ...   UeCapabilityCheckResponse    passed
    Stop UTFLAB and verify messages    ${master_node_messages}

Stop UTFLAB and verify messages
    [Arguments]    ${messages_to_check}
    ${timestamp} =    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename} =    Catenate    SEPARATOR=_    ${TEST_NAME}    ${timestamp}
    ${utf_dir}     Catenate    SEPARATOR=/    ${OUTPUT_DIR}    ${UTF_DIR_NAME}
    Set test variable    ${utf_dir}
    os.create directory    ${utf_dir}
    UTF Lab Stop Tracing and Collect Results    log_dir=${utf_dir}   with_name=${filename}
    ${filters}    create dcap filters
    Unpack and prepare new DCAP 5gm files to verify json    ${utf_dir}/${filename}   ${filters}     connection=${CONNECTION_ALIAS}
    ${json_folder}    Catenate    SEPARATOR=/    ${utf_dir}    ${filename}
    @{files}=    os.List Files In Directory    ${json_folder}    *.json    absolute=True
    Verify Message Sequence In Multiple Json Files    ${files}    ${messages_to_check}

Upload oransnapshot.xml to AP
    [Arguments]  ${iphy_snap}
    Log To Console     Uploading Oransnapshot: ${iphy_snap}
    ${Oran_alias}      SSH.connect to    192.168.200.1   toor4nsn    oZPS0POrRieRtu   alias=iphy
    ssh.Upload File    ${CURDIR}/config/${iphy_snap}    /rom/simmode/${iphy_snap}  connection=${Oran_alias}

Netconf access
        admin.connect_to    name=gnb_connection
        admin.enable_ssh_access    timeout=${30}    connection=gnb_connection
        admin.configure_netconf_radio_management    authentication_method=NoAuthentication
        ...                                                    id=1
        ...                                                    name=xranuser
        ...                                                    password=xran-password
        ...                                                    dist_name=${EMPTY}
        ...                                                    unsecure_ciphering=False
        ...                                                    format=${EMPTY}
        ...                                                    value=${EMPTY}
        ...                                                    connection=gnb_connection


Get Values From PDUSessionAdmittedAddedAddReqAck In SNnodeAddPrep
    ${PDUSessionAdmittedAddedAddReqAck}=    Get value of parameter from message
    ...    procedure=sNGRANnodeAdditionPreparation    message=SNodeAdditionRequestAcknowledge   num_of_message=1
    ...    all=1    protocol=XNAP    device=gNB2    parameter=pduSessionId
    Set Test Variable    ${PDUSessionAdmittedAddedAddReqAck}

Get Values Of GtpTunnels
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    ${E1AP_uP_TNL_Inf_TLA}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=transportLayerAddress    index_of_value=1
    ${E1AP_UP_TNL_Inf_gTP-TEID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1    parameter_name=gTP-TEID    index_of_value=1

    Set Test Variable    ${E1AP_UP_TNL_Inf_TLA}
    Set Test Variable    ${E1AP_UP_TNL_Inf_gTP-TEID}

Get Values Of PDCP Status Transfer

    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB3
    ...     protocol=E1AP

    ${E1AP_pdcp_status_transfer_UL}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_2   parameter_name=pDCP-SN    index_of_value=0
    ${E1AP_pdcp_status_transfer_DL}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_2    parameter_name=pDCP-SN    index_of_value=1

    Set Test Variable    ${E1AP_pdcp_status_transfer_UL}
    Set Test Variable    ${E1AP_pdcp_status_transfer_DL}

Get Values From QosFlowLevelQosParameters In ICS
    ${QoS_characteristics}=    Get value of parameter from message
    ...    procedure=initialContextSetup     message=InitialContextSetupRequest    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=qosCharacteristics
    ${fiveQI}=    Get value of parameter from message
    ...    procedure=initialContextSetup     message=InitialContextSetupRequest    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=fiveQI
    Set Test Variable    ${QoS_characteristics}
    Set Test Variable    ${fiveQI}

Get Values From GTP_Tunnel In Takeback And Verify They Are Correctly Assigned For MN Side
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    ${flow_alias_2}=     Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${TB_E1AP_UL_TLA1}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=transportLayerAddress  index_of_value=2

    ${TB_E1AP_UL_TB_gTP_TEID_1}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=gTP-TEID    index_of_value=2

    ${TB_E1AP_DL_transport_layer_adress_1}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=transportLayerAddress  index_of_value=1

    ${TB_E1AP_DL_TB_gTP_TEID_1}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=gTP-TEID    index_of_value=1

     ${TB_E1AP_nG-DL-UP-TNL_transport_layer_adress_1}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=transportLayerAddress  index_of_value=0

    ${TB_E1AP_nG-DL-UP-TNL_TB_gTP_TEID_1}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationResponse_1   parameter_name=gTP-TEID    index_of_value=0

    ${TB_E1AP_UL_TB_gTP_TEID_2}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationRequest_2   parameter_name=gTP-TEID    index_of_value=0

    ${TB_E1AP_UL_transport_layer_adress_2}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=BearerContextModificationRequest_2    parameter_name=transportLayerAddress  index_of_value=0

    ${TB_F1AP_DL_transport_layer_adress_1}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias_2}   message_alias=UEContextModificationResponse_1   parameter_name=transportLayerAddress   index_of_value=0

    ${TB_F1AP_DL_TB_gTP_TEID_1}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias_2}   message_alias=UEContextModificationResponse_1   parameter_name=gTP-TEID    index_of_value=0

     ${TB_NGAP_DL_TB_gTP_TEID_1}=    Get value of parameter from message
    ...    procedure=pDUSessionResourceModifyIndication    message=PDUSessionResourceModifyIndication    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=gTP-TEID

    ${TB_NGAP_DL_transport_layer_adress_1}=    Get value of parameter from message
    ...    procedure=pDUSessionResourceModifyIndication     message=PDUSessionResourceModifyIndication    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=transportLayerAddress

    Set Test Variable    ${TB_E1AP_UL_TLA1}
    Set Test Variable    ${TB_E1AP_UL_TB_gTP_TEID_1}
    Set Test Variable    ${TB_E1AP_DL_transport_layer_adress_1}
    Set Test Variable    ${TB_E1AP_DL_TB_gTP_TEID_1}
    Set Test Variable    ${TB_E1AP_UL_TB_gTP_TEID_2}
    Set Test Variable    ${TB_E1AP_UL_transport_layer_adress_2}
    Set Test Variable    ${TB_F1AP_DL_transport_layer_adress_1}
    Set Test Variable    ${TB_F1AP_DL_TB_gTP_TEID_1}
    Set Test Variable    ${TB_NGAP_DL_transport_layer_adress_1}
    Set Test Variable    ${TB_NGAP_DL_TB_gTP_TEID_1}

    Should Not Be True    ${TB_E1AP_DL_transport_layer_adress_1}==${TB_F1AP_DL_transport_layer_adress_1}
    Should Not Be True    ${TB_E1AP_DL_TB_gTP_TEID_1}==${TB_F1AP_DL_TB_gTP_TEID_1}
    Should Be True        ${TB_E1AP_UL_transport_layer_adress_2}==${TB_F1AP_DL_transport_layer_adress_1}
    Should Be True        ${TB_E1AP_UL_TB_gTP_TEID_2}==${TB_F1AP_DL_TB_gTP_TEID_1}
    Should Be True        ${TB_E1AP_nG-DL-UP-TNL_transport_layer_adress_1}==${TB_NGAP_DL_transport_layer_adress_1}
    Should Be True        ${TB_E1AP_nG-DL-UP-TNL_TB_gTP_TEID_1}==${TB_NGAP_DL_TB_gTP_TEID_1}

Get Values From LogicalChannelIdentity In Takeback And Verify They Are Correctly Assigned For MN Side
    ${flow_alias}=     Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${TB_logicalchannelidentity_rlc_BearerToAddModList}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=UEContextModificationResponse_1   parameter_name=logicalChannelIdentity    index_of_value=0

    ${TB_logicalchannelidentity_rlc_BearerToReleaseList}=    Get Value From Message By Index
        ...    flow_alias=${flow_alias}   message_alias=UEContextModificationResponse_1   parameter_name=rlc-BearerToReleaseList    index_of_value=0

    Should Not Be True    ${TB_logicalchannelidentity_rlc_BearerToAddModList}==${TB_logicalchannelidentity_rlc_BearerToReleaseList}

Verify E1AP On SN side
    Verify BearerContextModificationRequest
    Verify BearerContextModificationResponse
    Verify BearerContextReleaseCommand

Verify BearerContextModificationRequest
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dRB-ID Is Set To 4 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That cell-Group-To-Modify Has cell-Group-ID Set To 0 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That cell-Group-To-Modify Has cell-Group-ID Set To 1 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That cell-Group-To-Modify Has dL-TX-Stop Set To 'stop' For GNB3
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB3
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That dRB-ID Is Set To 4 For GNB3
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That qoS-Flow-Identifier Is Set To 1 For GNB3
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That pDCP-SN-Status-Request Is Set To 'requested' For GNB3

Verify BearerContextModificationResponse
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB3
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That dRB-ID Is Set To 4 For GNB3
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB3
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That dRB-ID Is Set To 4 For GNB3
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That pdcpStatusTransfer-UL Contains pDCP-SN And hFN For GNB3
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That pdcpStatusTransfer-DL Contains pDCP-SN And hFN For GNB3

Verify BearerContextReleaseCommand
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB3

Verify F1AP On SN side
     Verify UeContextModificationRequest
     Verify UeContextReleaseCommand

Verify UeContextModificationRequest
     Verify In F1AP UEContextModificationRequest_1 Out Of 1 That TransmissionActionIndicator Is Set To 'stop' For gNB3

Verify UeContextReleaseCommand
     Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That Cause Contains radioNetwork Set To 'unspecified' For GNB3

Verify XnAP
    Verify SNodeReleaseRequest And SNodeReleaseRequestAcknowledge
    Verify XnUAddressIndication And SNStatusTransfer
    Verify UEContextRelease

Verify SNodeReleaseRequest And SNodeReleaseRequestAcknowledge
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB3
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That pduSessionId Is Set To 1 For GNB3
    Check Values From APIDs in SNodeReleaseRequest
    Verify In XNAP SNodeReleaseRequestAcknowledge_1 Out Of 1 That pduSessionsToBeReleasedList-SNterminated Is Present For GNB3
    Verify In XNAP SNodeReleaseRequestAcknowledge_1 Out Of 1 That pduSessionId Is Set To ${PDUSessionAdmittedAddedAddReqAck} For GNB3

Verify XnUAddressIndication And SNStatusTransfer
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That pduSession-ID Is Set To 1 For GNB3
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That drb-ID Is Set To 4 For GNB3
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That qosFlowIdentifier Is Set To 1 For GNB3
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That dlForwardingUPTNL Contains tnl-address Set To '${E1AP_UP_TNL_Inf_TLA}' For GNB3
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That dlForwardingUPTNL Contains gtp-teid Set To '${E1AP_UP_TNL_Inf_gTP-TEID}' For GNB3
    Verify In XNAP SNStatusTransfer_1 Out Of 1 That drbID Is Set To 4 For GNB3
    Verify In XNAP SNStatusTransfer_1 Out Of 1 That pdcpStatusTransfer-UL Is Present For GNB2
    Verify In XNAP SNStatusTransfer_1 Out Of 1 That pdcpStatusTransfer-UL Contains pdcp-SN18 Set To ${E1AP_pdcp_status_transfer_UL} For GNB3
    Verify In XNAP SNStatusTransfer_1 Out Of 1 That pdcpStatusTransfer-DL Contains pdcp-SN18 Set To ${E1AP_pdcp_status_transfer_DL} For GNB3

Verify UEContextRelease
    Check Values From APIDs in XnapUEContextRelease

Verify E1AP On MN side
    Verify BearerContextModificationRequest On MN side
    Verify BearerContextModificationResponse On MN side

Verify BearerContextModificationRequest On MN side
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dRB-To-Setup-List-NG-RAN Has dRB-ID set to 4 for GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That pDCP-Configuration Has rLC-Mode set to "rlc-am" for GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That cell-Group-ID Is Set To 0 For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That cell-Group-Information Has cell-Group-ID set to 0 for GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That qoS-Flow-Identifier Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That data-Forwarding-Request Is Set To "dL" For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dRB-To-Remove-List-NG-RAN Has dRB-ID set to 4 for GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That transportLayerAddress Is Set To '${Ngap_transport_layer_adress}' For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That nG-UL-UP-TNL-Information Has gTP-TEID Set To '${Ngap_gTP_TEID}' For GNB2

    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That qoS-Characteristics Is Present And Has non-Dynamic-5QI For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That qoSFlowLevelQoSParameters Has fiveQI Set To ${fiveQI} For GNB2

    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That pDU-Session-ID is set to 1 for gNB2
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That dRB-To-Modify-List-NG-RAN Has dRB-ID set to 4 for GNB2
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That cell-Group-ID Is Set To 0 For GNB2

Verify BearerContextModificationResponse On MN side
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That dRB-ID Is Set To 4 For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That cell-Group-ID Is Set To 0 For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That qoS-Flow-Identifier Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That nG-DL-UP-TNL-Information Contains gTP-TEID And transportLayerAddress For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That dL-Data-Forwarding Contains gTP-TEID And transportLayerAddress For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That uP-TNL-Information Contains gTP-TEID And transportLayerAddress For GNB2
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That dRB-ID Is Set To 4 For GNB2

Verify F1AP On MN side
     Verify UeContextModificationRequest On MN side
     Verify UeContextModificationResponse On MN side

Verify UeContextModificationRequest On MN side
   Verify In F1AP UEContextModificationRequest_1 Out Of 2 That dRBID Is Set To 4 For GNB2
   Verify In F1AP UEContextModificationRequest_1 Out Of 2 That BearerTypeChange Is Set To 'true' For GNB2
   Verify In F1AP UEContextModificationRequest_1 Out Of 2 That SCGIndicator Is Set To 'released' For GNB2
   Verify In F1AP UEContextModificationRequest_1 Out Of 2 That uLUPTNLInformation Contains transportLayerAddress Set To '${TB_E1AP_UL_TLA1}' For GNB2
   Verify In F1AP UEContextModificationRequest_1 Out Of 2 That uLUPTNLInformation Contains gTP-TEID Set To '${TB_E1AP_UL_TB_gTP_TEID_1}' For GNB2
   Verify In F1AP UEContextModificationRequest_2 Out Of 2 That RRCReconfigurationCompleteIndicator Is Set To 'true' For GNB2
   Verify In F1AP UEContextModificationRequest_2 Out Of 2 That GNB-DUConfigurationQuery Is Set To 'true' For GNB2

Verify UeContextModificationResponse On MN side
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That cellGroupId Is Set To 0 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That drb-Identity Is Set To 4 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That rlc-Config Is Present For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That mac-LogicalChannelConfig Is Present For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That uplinkConfig Contains Field setup For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That pdsch-ServingCellConfig Is Present For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That dRBID Is Set To 4 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-MeasConfig Is Present For GNB2
    Verify In F1AP UEContextModificationResponse_2 Out Of 2 That cellGroupConfig Is Present For GNB2
    Verify In F1AP UEContextModificationResponse_2 Out Of 2 That csi-MeasConfig Is Present For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List nzp-CSI-RS-ResourceToAddModList Has 2 Element/s For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 182 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 183 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List nzp-CSI-RS-Resources Has 4 Element/s For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List csi-IM-Resources Has 4 Element/s For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List csi-IM-ResourceToAddModList Has 2 Element/s For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That tag-Id Is Set To 0 For GNB2

Verify RRC
    Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig Contains drb-Identity Set To 4 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That pdcp-Config Is Present For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That masterCellGroup Contains cellGroupId Set To 0 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That servedRadioBearer Contains drb-Identity Set To 4 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That rlc-BearerToAddModList Contains rlc-Config And mac-LogicalChannelConfig For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List nzp-CSI-RS-ResourceToAddModList Has 2 Element/s For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 182 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 183 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List nzp-CSI-RS-Resources Has 4 Element/s For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List csi-IM-Resources Has 4 Element/s For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List csi-IM-ResourceToAddModList Has 2 Element/s For UE1
Verify NGAP
    Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That pDUSessionID Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That qosFlowIdentifier Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyRequest_1 Out Of 1 That qosFlowIdentifier Is Set To 2 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyRequest_1 Out Of 1 That QosFlowAddOrModifyRequestList Is Present For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That pDUSessionID Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That qosFlowIdentifier Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That transportLayerAddress Is Set To '${Ngap_transport_layer_adress}' For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That gTP-TEID Is Set To '${Ngap_gTP_TEID}' For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyResponse_1 Out Of 1 That qosFlowIdentifier Is Set To 2 For AMF${amf_id}

