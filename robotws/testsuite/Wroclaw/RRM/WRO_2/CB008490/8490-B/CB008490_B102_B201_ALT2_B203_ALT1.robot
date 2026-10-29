*** Settings ***
Force Tags    CONFIGURED    CIT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik, Magdalena Mlynarska,Katarzyna Bandrowska
...             :contact: edyta.rudnik@nokia.com

Resource    ../resources/feature_keywords.robot
Resource    ../../resources/testing_env.robot
Resource    ../../keywords/traffic.robot

Library        taf.ul.ettf.setups
Library        ../resources/multignb_variables.py
Library        ../resources/KeywordsCB008490.py
Library        ../resources/syslog_collector.py
Library        testsuite/Wroclaw/RRM/resources/scout_report.py
Variables      ../resources/custom_policy.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}    remote_hosts=${REMOTE_HOSTS}

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         Setup multigNB devices aliases

*** Variables ***
${LOGGING_POLICY}=          REMOTE_HOST_POLICY
${SCFC_GNB_MN}=             scfc_MN_n1A_n78A_AHGD_AEQE_with_nrrel_and_nrhoif_to_n257_ASIL_GMC.xml
${SCFC_GNB_SN}=             scfc_SN_n257_AWEUB_GMC.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AHGD_AEQE_SN_AWEUB.xml
${cfg}=                     ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M.cfg
${ue1}=                     1
${ue2}=                     2
${amf_id}=                  1
${pdu_id}=                  1
${band_comb_1}=             1
${band_comb_2}=             3
${band_comb_index_asn_1}=   '0x0000'
${band_comb_index_asn_2}=   '0x0002'
@{meas_objects_id_list}=     1     2     2
@{report_config_ids}=        1     1
@{FAULT_IDS_LIST}=            6450    4383

*** Test Cases ***
CB008490_SR_B_B201_Successful_inter-gNB_NR-DC_PSCell_Addition_upon_receipt_of_UE_measurement_report_cell_UE_independent_gap_capable_TDD_PCell_ALT2
    Start Collecting Syslog From Gnbs
    Set ICS flow
    Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue1}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Establish Pdu Session
    Send Data Traffic    inactive_timer=1
    Verify ICS Flow
    Get Values From RAN-UE-NGAP-ID In ICS To Compare Later
    Get Values From GTP_Tunnel In ICS to Compare Later
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue1} GNB2
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue1} GNB3
    Waiting For Message Flow To Set Up
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue1} GNB2
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue1} GNB3
    Get Values Of GtpTunnels From BearerContextSetupResponse And UEContextModificationResponse To Compare Later
    Verify E1AP
    Verify F1AP    band_comb=${band_comb_1}    band_comb_index_asn=${band_comb_index_asn_1}
    Verify RRC     ue_id=${ue1}
    Verify XNAP    band_comb=${band_comb_1}
    Verify NGAP
    Verify That MeasGapConfig Was Not Setup
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=30Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=30Mbps      cell_index_min=1    cell_index_max=1
                                   ...     direction=ul    cell_group=SCG    selection_type=Average    margin=10%
    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue1}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Stop Collecting Syslog And Download Files
    ...            AND    Add Scout Scf Id To Test Data


CB008490_SR_B_B203_Successful_inter-gNB_NR-DC_PSCell_Addition_upon_receipt_of_UE_measurement_report_different_BC_FDD_PCell_ALT1
    Start Collecting Syslog From Gnbs
    Set ICS flow
    Attach Ue    ue_id=${ue2}    enb=2    cell=2
    Set Internal Traffic Type To UE    ue_id=${ue2}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Establish Pdu Session    ue_id=${ue2}    pdu_id=${pdu_id}    gw_id=2
    Send Data Traffic    ue_id=${ue2}    inactive_timer=1
    Verify ICS flow
    Get Values From RAN-UE-NGAP-ID In ICS To Compare Later
    Get Values From GTP_Tunnel In ICS To Compare Later
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue2} GNB2
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue2} GNB3
    Waiting For Message Flow To Set Up
    Send Ue Measurement Nr    ue_id=${ue2}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue2} GNB2
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue2} GNB3
    Get Values of GtpTunnels From BearerContextSetupResponse And UEContextModificationResponse To Compare Later
    Verify E1AP
    Verify F1AP    band_comb=${band_comb_2}    band_comb_index_asn=${band_comb_index_asn_2}
    Verify RRC     ue_id=${ue2}
    Verify XNAP    band_comb=${band_comb_2}
    Verify NGAP
    Verify MeasGapConfig Setup
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue2}    expected_throughput=10Kbps
                                         ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue2}    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                         ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue2}    expected_throughput=30Mbps      cell_index_min=0    cell_index_max=0
                                         ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue2}    expected_throughput=30Mbps      cell_index_min=1    cell_index_max=1
                               ...     direction=ul    cell_group=SCG    selection_type=Average    margin=10%
    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue2}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Stop Collecting Syslog And Download Files
    ...            AND    Add Scout Scf Id To Test Data

CB008490_SR_B_B102_A4_activation_after_InitialContextSetup_UERadioCapability_found_insufficient
    Set Amf Param To Trigger B102 Scenario
    Set ICS and A4 Measurement Configuration Message Flow For B102 Scenario
    Attach Ue    ue_id=${ue2}    enb=2    cell=2
    Set Scg UL Dist Percent
    Establish Pdu Session    ue_id=${ue2}    pdu_id=${pdu_id}    gw_id=2
    Waiting For PDU Session Establishment
    Verify ICS and A4 Measurement Configuration Message Flow For B102 Scenario
    Verify B102 scenario
    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue2}
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Add Scout Scf Id To Test Data

*** Keywords ***
Set ICS and A4 Measurement Configuration Message Flow For B102 Scenario
    Set expected message flow    ue_id=2    iniCtxSet=1    ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    rrcReconf=2
    ...    rrcReconfCompl=2    bearerCtxMod=1    secModeCommand=1    secModeComplete=1    uECtxMod=4

Verify ICS and A4 Measurement Configuration Message Flow For B102 Scenario
     Verify expected message flow    ue_id=2    iniCtxSet=1    ueCapaEnq=1    ueCapaInfo=1    ueRadCapInfoInd=1    bearerCtxSet=1    rrcReconf=2
    ...    rrcReconfCompl=2    bearerCtxMod=1    secModeCommand=1    secModeComplete=1    uECtxMod=4

Get Values From RAN-UE-NGAP-ID In ICS To Compare Later
    ${NG-RANnodeUEXnAPID}=    Get value of parameter from message
    ...    procedure=initialContextSetup     message=InitialContextSetupRequest    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=RAN-UE-NGAP-ID
    Set Test Variable    ${NG-RANnodeUEXnAPID}

Get Values Of GtpTunnels From BearerContextSetupResponse And UEContextModificationResponse To Compare Later
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB3
    ...     protocol=E1AP
    ${flow_alias_2}=     Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${E1AP_uP_TNL_Inf_TLA}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextSetupResponse    parameter_name=transportLayerAddress    index_of_value=3
    ${E1AP_UP_TNL_Inf_gTP-TEID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextSetupResponse    parameter_name=gTP-TEID    index_of_value=3
    ${nG_DL_UP_TNLInf_TLA}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextSetupResponse    parameter_name=transportLayerAddress    index_of_value=0
    ${nG_DL_UP_TNLInf_gTPTEID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextSetupResponse    parameter_name=gTP-TEID    index_of_value=0
    ${dL_Data_For_TLA}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextSetupResponse    parameter_name=transportLayerAddress    index_of_value=1
    ${dL_Data_For_gTPTEID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}   message_alias=BearerContextSetupResponse    parameter_name=gTP-TEID    index_of_value=1
    ${UE_Ctx_Mod_Response_TLA}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias_2}   message_alias=UEContextModificationResponse_1   parameter_name=transportLayerAddress    index_of_value=0
    ${UE_Ctx_Mod_Response_gTP-TEID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias_2}   message_alias=UEContextModificationResponse_1   parameter_name=gTP-TEID    index_of_value=0

    Set Test Variable    ${E1AP_UP_TNL_Inf_TLA}
    Set Test Variable    ${E1AP_UP_TNL_Inf_gTP-TEID}
    Set Test Variable    ${nG_DL_UP_TNLInf_TLA}
    Set Test Variable    ${nG_DL_UP_TNLInf_gTPTEID}
    Set Test Variable    ${dL_Data_For_TLA}
    Set Test Variable    ${dL_Data_For_gTPTEID}
    Set Test Variable    ${UE_Ctx_Mod_Response_TLA}
    Set Test Variable    ${UE_Ctx_Mod_Response_gTP-TEID}

Compare APIDs in XnuAdressIndicator and SNodeAdditionRequestAcknowledge
    ${flow_alias_1}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB3
    ...     protocol=XNAP
    ${S-NG-RANnodeUEXnAPID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias_1}   message_alias=SNodeAdditionRequestAcknowledge    parameter_name=NG-RANnodeUEXnAPID   index_of_value=1

    ${flow_alias_2}=     Get flow name
    ...     procedure=xnUAddressIndication
    ...     device=gNB2
    ...     protocol=XNAP
    ${oldNG-RANnodeUEXnAPID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias_2}   message_alias=XnUAddressIndication    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1
    Should Be True    ${oldNG-RANnodeUEXnAPID}==${S-NG-RANnodeUEXnAPID}

Verify E1AP
    Verify BearerContextModificationRequest
    Verify BearerContextModificationResponse

Verify BearerContextModificationRequest
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dRB-ID Is Set To 4 For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dRB-Data-Forwarding-Information Is Present For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That list dRB-To-Modify-List-NG-RAN Has 1 Element/s For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That pDCP-SN-Status-Request Is Set To 'requested' For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That cell-Group-ID Is Set To 0 For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dL-TX-Stop Is Set To 'stop' For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That rAT-Type Is Set To 'nR' For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dL-Data-Forwarding Has transportLayerAddress Set To '${dL_Data_For_TLA}' For GNB2
    Verify In E1AP BearerContextModificationRequest_1 Out Of 2 That dL-Data-Forwarding Has gTP-TEID Set To '${dL_Data_For_gTPTEID}' For GNB2
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That pDU-Session-ID is set to 1 for gNB2
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That list dRB-To-Modify-List-NG-RAN has 1 element/s for gNB2
    Verify In E1AP BearerContextModificationRequest_2 Out Of 2 That cell-Group-To-Remove has cell-Group-ID set to 0 for gNB2

Verify BearerContextModificationResponse
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That dRB-ID Is Set To 4 For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That pDCP-SN-Status-Information Is Present For GNB2
    Verify In E1AP BearerContextModificationResponse_1 Out Of 2 That list dRB-Modified-List-NG-RAN Has 1 element/s For GNB2
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That pDU-Session-ID Is Set To 1 For GNB2

Verify NGAP
     Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That pDUSessionID Is Set To 1 For AMF1
     Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That gTPTunnel Has transportLayerAddress Set To '${nG_DL_UP_TNLInf_TLA}' For AMF1
     Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That gTPTunnel Has gTP-TEID Set To '${nG_DL_UP_TNLInf_gTPTEID}' For AMF1
     Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That pDUSessionID Is Set To 1 For AMF1
     Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That pDUSessionResourceModifyConfirmTransfer Is Present For AMF1

Verify F1AP
    [Arguments]    ${band_comb}    ${band_comb_index_asn}
     Verify UeContextModificationRequest    band_comb=${band_comb}
     Verify UeContextModificationResponse   band_comb_index_asn=${band_comb_index_asn}

Verify UeContextModificationRequest
    [Arguments]    ${band_comb}
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That ue-CapabilityInfo Is Present For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That allowedFeatureSetsList Has 1 For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That bandCombinationIndex Is Set To ${band_comb} For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That dRBID Is Set To 4 For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 In MeasConfig That measObjectId Eq 1 On Index 0 For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That MeasConfig Doesnt Contain measIdToAddModList For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That measIdToAddModList Is Not Present For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That BearerTypeChange Is Set To 'true' For gNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That gTPTunnel Contains gTP-TEID Set To '${E1AP_UP_TNL_Inf_gTP-TEID}' For GNB2
     Verify In F1AP UEContextModificationRequest_1 Out Of 2 That gTPTunnel Contains transportLayerAddress Set To '${E1AP_UP_TNL_Inf_TLA}' For GNB2
     Verify In F1AP UEContextModificationRequest_2 Out Of 2 That RRCReconfigurationCompleteIndicator Is Set To 'true' For GNB2
     Verify In F1AP UEContextModificationRequest_2 Out Of 2 That GNB-DUConfigurationQuery Is Set To 'true' For GNB2

Verify UeContextModificationResponse
    [Arguments]    ${band_comb_index_asn}
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That cellGroupId Is Set To 0 For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That rlc-BearerToAddModList Is Present For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List rlc-BearerToAddModList Has 1 Element/s For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List rlc-BearerToReleaseList Has 1 Element/s For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That rlc-BearerToAddModList Has 5 For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That rlc-BearerToReleaseList Has 4 For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That SelectedBandCombinationIndex Is Set To ${band_comb_index_asn} For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That SelectedFeatureSetEntryIndex Is Set To '0x00' For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That List DRBs-Modified-List Has 1 Element/s For GNB2
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That dRBID Is Set To 4 For GNB2

Verify MeasGapConfig Setup
     Verify In F1AP UEContextModificationResponse_1 Out Of 2 That measGapConfig Is Present For GNB2
     Verify In RRC RRCReconfiguration_1 Out Of 1 That measGapConfig Is Present For UE2

Verify That MeasGapConfig Was Not Setup
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That measGapConfig Is Not Present For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That measGapConfig Is Not Present For UE1

Verify RRC
     [Arguments]    ${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToRemoveList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That masterCellGroup Contains rlc-BearerToAddModList And rlc-BearerToReleaseList For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That rlc-BearerToAddModList Contains logicalChannelIdentity Set To 5 For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That rlc-BearerToReleaseList Has 4 For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroup Contains cellGroupId Set To 1 For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That List rlc-BearerToAddModList Has 2 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That am Contains ul-AM-RLC And dl-AM-RLC For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroup Contains rlc-BearerToAddModList And mac-CellGroupConfig For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroup Contains physicalCellGroupConfig And spCellConfig For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroup Contains drb-Identity Set To 4 For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroup Contains logicalChannelIdentity Set To 4 For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig2 Contains drb-ToAddModList And securityConfig For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig2 Contains sdap-Config For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That sdap-Config Contains pdu-Session Set To 1 For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That List drb-ToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig2 Contains reestablishPDCP Set To 'true' For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig2 Contains pdcp-Config For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That sk-Counter Is Present For UE${ue_id}
     Verify In RRC RRCReconfigurationComplete_1 Out Of 1 That nr-SCG-Response Is Present For UE${ue_id}

Verify XnAP
    [Arguments]    ${band_comb}
    Verify SNodeAdditionRequest    bc=${band_comb}
    Verify SNodeAdditionRequestAcknowledge    bc=${band_comb}
    Verify XnUAddressIndication And SNStatusTransfer

Verify SNodeAdditionRequestAcknowledge
    [Arguments]    ${bc}
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That NG-RANnodeUEXnAPID Has ${NG-RANnodeUEXnAPID} For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That List PDUSessionAdmittedAddedAddReqAck Has 1 Element/s For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That PDUSessionAdmittedAddedAddReqAck Has pduSessionId Set To 1 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That PDUSessionAdmittedAddedAddReqAck Contains sn-terminated For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That dL-NG-U-TNLatNG-RAN Contains tnl-address Set To '${nG_DL_UP_TNLInf_TLA}' For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That dL-NG-U-TNLatNG-RAN Contains gtp-teid Set To '${nG_DL_UP_TNLInf_gTPTEID}' For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That dRBsToBeSetup Contains drb-ID Set To 4 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That List dRBsToBeSetup Has 1 Element/s For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That upTNLInfo Contains tnl-address Set To '${E1AP_UP_TNL_Inf_TLA}' For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That upTNLInfo Contains gtp-teid Set To '${E1AP_UP_TNL_Inf_gTP-TEID}' For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sN-UL-PDCP-UP-TNLInfo Contains cellGroupID Set To 0 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That dlForwardingUPTNL Contains tnl-address Set To '${dL_Data_For_TLA}' For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That dlForwardingUPTNL Contains gtp-teid Set To '${dL_Data_For_gTPTEID}' For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That scg-RB-Config Is Present In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That bandCombinationIndex Set To ${bc} For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That reestablishPDCP Set To true For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That drb-Identity On Index 1 Is Set To 4 In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That pdcp-Config Is Present In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That reconfigurationWithSync Is Present In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That requestedFeatureSets Set To 1 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That cellGroupId Set To 1 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That servCellIndex Set To 1 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That physCellId Set To 52 For GNB3

Verify SNodeAddition Request
    [Arguments]    ${bc}
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That NG-RANnodeUEXnAPID is set to ${NG-RANnodeUEXnAPID} For gNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That UESecurityCapabilities Is Present For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That S-NG-RANnode-SecurityKey Is Present For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That pduSessionId Is Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That sn-terminated Is Present For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That uL-NG-U-TNLatUPF Contains tnl-address Set To '${Ngap_transport_layer_adress}' For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That uL-NG-U-TNLatUPF Contains gtp-teid Set To '${Ngap_gTP_TEID}' For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That qosFlowsToBeSetup-List Has qfi Set To 1 For gNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That qosFlowsToBeSetup-List Has fiveQI Set To 6 For gNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That dataforwardinginfofromSource Contains qosFlowsToBeForwarded For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That List qosFlowsToBeForwarded Has 1 Element/s For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That dataforwardinginfofromSource Has qosFlowIdentifier Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That dataforwardinginfofromSource Has dl-dataforwarding Set To "dl-forwarding-proposed" For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That dataforwardinginfofromSource Contains sourceDRBtoQoSFlowMapping For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That sourceDRBtoQoSFlowMapping Has drb-ID Set To 4 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That sourceDRBtoQoSFlowMapping Contains qosFlows-List For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That sourceDRBtoQoSFlowMapping Has rLC-Mode Set To "rlc-am" For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That List qosFlows-List Has 1 Element/s For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That qosFlows-List Has qfi Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That qosFlowLevelQoSParameters Has fiveQI Set To 6 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 In CG-ConfigInfo That physCellId Set To 52 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 In CG-ConfigInfo That bandCombinationIndex Set To ${bc} For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 In CG-ConfigInfo That allowedFeatureSetsList Set To [1] For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 In CG-ConfigInfo That lowBound Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 In CG-ConfigInfo That upBound Set to 31 for GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That candidateCellInfoListMN Is Present In CG-ConfigInfo For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That mcg-RB-Config Is Present In CG-ConfigInfo For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That List DRB-List Has 1 Element/s For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That DRB-List Has 4 For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That pdcp-Config Is Present In CG-ConfigInfo For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That drb-Identity Is Present In CG-ConfigInfo For GNB2
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 In CG-ConfigInfo That drb-Identity Set To 4 For GNB2

Verify XnUAddressIndication And SNStatusTransfer
    Verify in XNAP XnUAddressIndication_1 out of 1 that list XnUAddressInfoperPDUSession-List Has 1 Element/s For GNB2
    Compare APIDs In XnuAdressIndicator And SNodeAdditionRequestAcknowledge
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That List XnUAddressInfoperPDUSession-List Has 1 Element/s For GNB2
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That dRBsToBeSetupList Has dRB-ID Set To 4 For GNB2
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That pduSession-ID Is Set To 1 For GNB2
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That mN-Xn-U-TNLInfoatM Contains tnl-address Set To '${UE_Ctx_Mod_Response_TLA}' For GNB2
    Verify In XNAP XnUAddressIndication_1 Out Of 1 That mN-Xn-U-TNLInfoatM Contains gtp-teid Set To '${UE_Ctx_Mod_Response_gTP-TEID}' For GNB2
    Verify In XNAP SNStatusTransfer_1 Out Of 1 That pdcpStatusTransfer-UL Is Present For GNB2

Set Amf Param To Trigger B102 Scenario
    Execute Egate Command    cmd=amf_ue_ics_param ue=2 id=1 include_ue_capabilities=on ue_capabilities=${B102_INSUFFICIENT_UE_CAPA}

Verify B102 scenario
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That UERadioCapability Is Present For AMF${amf_id}
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That List appliedFreqBandListFilter Has 1 Element/s And bandNR Is Set To 257
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That IndexToRFSP Is Set To 1 For AMF${amf_id}
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That List PDUSessionResourceSetupListCxtReq Has 1 Element/s For AMF${amf_id}
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That List QosFlowSetupRequestList Has 1 Element/s For AMF${amf_id}
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That qosFlowLevelQosParameters Has fiveQI Set To 6 For AMF${amf_id}
    Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That MobilityRestrictionList Is Not Present For AMF${amf_id}

    Verify In RRC UECapabilityEnquiry_1 Out Of 1 That includeNR-DC Is Set To 'true' For UE2
    Verify In RRC UECapabilityEnquiry_1 Out Of 1 That CapabilityRequestFilter Contains Bands 1 and 257

    Verify In F1AP UEContextModificationRequest_1 Out Of 4 That RRCReconfigurationCompleteIndicator Is Set To 'true' For GNB2
    Verify In F1AP UEContextModificationRequest_2 Out Of 4 That GNB-DUConfigurationQuery Is Set To 'true' For GNB2
    Verify In F1AP UEContextModificationRequest_4 Out Of 4 That GNB-DUConfigurationQuery Is Set To 'true' For GNB2

    Verify In F1AP UEContextModificationRequest_3 Out Of 4 In MeasConfig That Fields measObjectId Are Equal ${meas_objects_id_list}
    Verify In F1AP UEContextModificationRequest_3 Out Of 4 In MeasConfig That freqBandIndicatorNR Eq 1 On Index 0 For GNB2
    Verify In F1AP UEContextModificationRequest_3 Out Of 4 In MeasConfig That freqBandIndicatorNR Eq 257 On Index 1 For GNB2
    Verify In F1AP UEContextModificationRequest_3 Out Of 4 In MeasConfig That Fields reportConfigId Are Equal ${report_config_ids}
    Verify In F1AP UEContextModificationRequest_3 Out Of 4 In MeasConfig That eventA4 Is Present For GNB2
    Verify In F1AP UEContextModificationRequest_3 Out Of 4 That measGapConfig Is Not Present For GNB2
    Verify In F1AP UEContextModificationResponse_3 Out Of 4 That measGapConfig Is Present For GNB2

    Verify In RRC RRCReconfiguration_2 Out Of 2 That List measObjectToAddModList Has 1 Element/s For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That List reportConfigToAddModList Has 1 Element/s For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That s-MeasureConfig Is Present For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That ssb-RSRP Is Set to 127 For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That reportConfigToAddModList Contains eventA4 For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That reportConfigToAddModList Contains reportConfigId Set To 1 For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That measIdToAddModList Contains measId Set To 1 For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That measIdToAddModList Contains measObjectId Set To 2 For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That measIdToAddModList Contains reportConfigId Set To 1 For UE2
    Verify In RRC RRCReconfiguration_2 Out Of 2 That measGapConfig Is Present For UE2

Verify In NGAP InitialContextSetupRequest_1 Out Of 1 That List appliedFreqBandListFilter Has 1 Element/s And bandNR Is Set To 257
    Verify Tcpdump Log    packet_filter=${F1AP_APPLIEDFREQBANDLISTFILTER_N257}

Verify In RRC UECapabilityEnquiry_1 Out Of 1 That CapabilityRequestFilter Contains Bands 1 and 257
    Verify Tcpdump Log    packet_filter=${RRC_UE_CAPA_ENQ_n1_n257}
