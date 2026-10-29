*** Settings ***
Force Tags    CONFIGURED    CRT    PY310    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Katarzyna Bandrowska, Emilia Godlewska-Lipka, Marta Klukas, Milosz Dunikowski
...             :contact:  emilia.godlewska-lipka@nokia.com, marta.klukas@nokia.com, milosz.dunikowski@nokia.com

Resource    ../resources/feature_keywords.robot
Resource    ../../resources/testing_env.robot
Resource    ../../keywords/traffic.robot
Resource    ../../keywords/keywords.robot

Library        taf.ul.ettf.setups
Library        ../resources/multignb_variables.py
Library        ../resources/KeywordsCB008490.py
Library        ta5g_ue_measurements
Library        ta5g_pm_counters
Library        ../resources/syslog_collector.py
Library        ../../../resources/scout_report.py
Variables      ../resources/custom_policy.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}


*** Variables ***
${LOGGING_POLICY}=          REMOTE_HOST_POLICY
${SCFC_MN_EA}=              scfc_MN_n1A_n78A_AHGD_AEQE_3Slices_VONR.xml
${SCFC_SN_EA}=              scfc_SN_n257_AWEUB_1CC_3Slices_VONR.xml
${IPHY_EA}=                 ${CURDIR}/config/iphy_MN_AHGD_AEQE_SN_AWEUB.xml
${cfg_EA}=                  ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M_3Slices_VONR.cfg
${SCFC_MN_F}=               scfc_MN_n1A_n78A_AHGD_AEQE_aCSI_beamforming_on_PCell.xml
${SCFC_SN_F}=               scfc_SN_n257_AWEUB.xml
${IPHY_F}=                  ${CURDIR}/config/iphy_MN_AHGD_AEQE_SN_AWEUB.xml
${cfg_F}=                   ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M.cfg
${SCFC_MN_KA}=              scf_KA_MN_n78_AEQE.xml
${SCFC_SN_KA}=              scf_KA_SN_AWEUB.xml
${IPHY_KA}=                 ${CURDIR}/config/iphy_KA_MN_AEQE_SN_AWEUB_3_cell.xml
${cfg_KA}=                  ${CURDIR}/config/cfg_KA_n78A.cfg
${SCFC_MN_QA}=              scfc_MN_n78_AEQE.xml
${SCFC_SN_QA}=              scfc_SN_n257_AWEUB_QA.xml
${IPHY_QA}=                 ${CURDIR}/config/iphy_MN_AEQE_AHGD_SN_AWEUB.xml
${cfg_QA}=                  ${CURDIR}/config/cfg_QA_n257M_and_n78A_n257M.cfg
${ue1}=                     1
${amf_id}=                  1
${pdu_id}=                  1
@{sCellIndex_2CC}=          2
@{FAULT_IDS_LIST}=          6450    4383

*** Test Cases ***
CB008490_EA_EC101_Release_of_PDU_Sessions_non_last_RRC_Reconfiguration_timeout
    [Setup]     Run Keywords
    ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    EA
    ...    AND         Start Collecting Syslog From Gnbs
    ...    AND         Setup multigNB devices aliases
    Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic    ue_id=${ue1}    pdu_id=${pdu_id}    nwslice=1    gw_id=1      throughput=150Mbps
    Establish Pdu Session With Traffic    ue_id=${ue1}    pdu_id=2    nwslice=2    gw_id=2      throughput=60Mbps
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Wait 5s For NR-DC Setup
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Get Values From APIDs In SNnodeAddPrep
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=30Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=30Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=ul    cell_group=SCG    selection_type=Average    margin=10%
    Set Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On SN Side
    Set Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On MN Side
    Wait 3s For Prodedure Establish
    Perform Command To Drop RRC Reconfiguration Complete Message
    Release Pdu Session Without Confirmation    ue_id=${ue1}    pdu_id=1
    Verify Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On SN Side
    Verify Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On MN Side
    Verify E1AP On SN side EA
    Verify E1AP On MN side EA
    Verify F1AP On SN side EA
    Verify F1AP On MN side EA
    Verify RRC EA
    Verify XNAP EA
    Verify NGAP EA

    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue1}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Stop Collecting Syslog And Download Files
    ...            AND    Add Scout Scf Id To Test Data

CB008490_F_B301_MN_Initiated_NR_DC_Bearer_Takeback_Triggered_Due_To_Reception_Of_RRC_SCGFailureInformation
    [Documentation]    Since FB2420 this Test Case covers additionally FA_B201 User Scenario with some new verifications for beamforming.
    [Setup]     Run Keywords
    ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    F
    ...    AND         Start Collecting Syslog From Gnbs
    ...    AND         Setup multigNB devices aliases
    Set ICS Flow
    Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue1}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Establish Pdu Session
    Send Data Traffic    inactive_timer=1
    Wait 2s For Message Flow To Set Up
    Verify ICS Flow
    Get Values From GTP_Tunnel In ICS To Compare Later
    Get Values From QosFlowLevelQosParameters In ICS
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Wait 5s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Get Values From APIDs In SNnodeAddPrep
    Set Expected Message Flow For Takeback On MN Side
    Set Expected Message Flow For Takeback On SN Side
    Wait 2s For NRDC Takeback
    Trigger RRC SCGFailureInformation By Random Access Problem
    Verify Expected Message Flow For Takeback On MN Side
    Verify Expected Message Flow For Takeback On SN Side
    Get Values Of GtpTunnels
    Get Values From PDUSessionAdmittedAddedAddReqAck In SNnodeAddPrep
    Get Values Of PDCP Status Transfer
    Get Values From GTP_Tunnel In Takeback And Verify They Are Correctly Assigned For MN Side
    Get Values From LogicalChannelIdentity In Takeback And Verify They Are Correctly Assigned For MN Side
    Verify E1AP On SN side F
    Verify E1AP On MN side F
    Verify F1AP On SN side F
    Verify F1AP On MN side F
    Verify RRC F
    Verify XNAP F
    Verify NGAP F
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Wait 6s For A4 Retry Timer Expired
    Set Expected Message Flow For A4 Measurement Configuration And Deconfiguration
    Wait 6s For A4 Supervision Timer Expired
    Verify Expected Message For A4 Measurement Configuration And Deconfiguration
    Verify A4 Measurement Configuration With MeasId=3, MeasObjectId=2 and reportConfigId=1 For UE1
    Verify A4 Measurement Deconfiguration With MeasId=3 For UE1

    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue1}
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND             Add Scout Scf Id To Test Data

CB008490_FA_B202_Not_configuring_of_Beam_Refinement_on_the_MCG_leg_due_to_lack_of_UE_capability_during_the_inter_gNB_NR-DC_bearer_takeback
    [Setup]     Run Keywords
    ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    F
    ...    AND         Start Collecting Syslog From Gnbs
    ...    AND         Setup multigNB devices aliases
    Attach Ue    ue_id=3    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=3    pdu_id=${pdu_id}
    Set Scg UL Dist Percent    id=3
    Establish Pdu Session    ue_id=3
    Send Data Traffic    inactive_timer=1    ue_id=3
    Wait 2s For Message Flow To Set Up
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE3 GNB2
    Send Ue Measurement Nr    ue_id=3    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Wait 5s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE3 GNB2
    Verify That Throughput Is Reached On Cell Group    ue_id=3    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=3    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=3   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Set Expected Message Flow For Takeback On MN Side For RLC By SN DTX Detection    ue_id=3
    Set Expected Message Flow For Takeback On SN Side For RLC By SN DTX Detection    ue_id=3
    Wait 2s For NRDC Takeback
    Perform RLF By GNB DU SN DTX Detection    ue_id=3
    Verify Expected Message Flow For Takeback On MN Side For RLC By SN DTX Detection    ue_id=3
    Verify Expected Message Flow For Takeback On SN Side For RLC By SN DTX Detection    ue_id=3
    Verify Successful RLC Takeback By SN DTX Detection
    Verify That Throughput Is Reached On Cell Group    ue_id=3    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=3   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%

    [Teardown]     Run Keywords    Deregister UE    ue_id=3
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND             Add Scout Scf Id To Test Data

CB008490_SR_KA_B101_FR2_Cell_will_not_be_admitted_as_FR2_SCell_candidate_due_to_not_supported_PLMN_at_SN
    [Setup]     Run Keywords
    ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    KA
    ...    AND         Start Collecting Syslog From Gnbs
    ...    AND         Setup multigNB devices aliases

    Perform Commnad To Configure SMF Parameters    qos_id=2
    Set Internal Traffic Type To UE    ue_id=1    pdu_id=1
    Set Scg UL Dist Percent
    Attach Ue    ue_id=1
    Set Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition with 2CC FR2 CA For UE1
    Establish Pdu Session    ue_id=1
    Send Ue Measurement Nr    ue_id=1    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition with 2CC FR2 CA For UE1
    Verify If UE has configured 2CC FR2 Based On SelectedPLMN
    Send Data Traffic For UE1 With Two QFI
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=30Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=200Mbps      cell_index_min=1    cell_index_max=2
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=50%


CB008490_QA_EC1_ALT1_Sleeping_cell_detection_and_recovery_action_phase_2_in_NRDC_SN_cell
    [Setup]     Run Keywords
    ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    QA
    ...    AND         Start Collecting Syslog From Gnbs
    ...    AND         Setup multigNB devices aliases
    Prepare UE Testmode For MSG3 Configuration    PROFILE_ID=1    TESTMODE_ACTION=missed_ra_resp    NUMBER_OF_ACTIONS=200
    Wait For Next Full PM Interval
    Attach Ue    ue_id=1
    Establish PDU Session Without Confirmation    ue_id=1
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE1
    Activation of Testmode For MSG3 Configuration    UE_IDs=1   ACTION_DESIRED=activate    PROFILE_ID=1
    Send Ue Measurement Nr    ue_id=1    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE1
    Attach Ue    ue_id=2
    Establish PDU Session Without Confirmation    ue_id=2    gw_id=2
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE2
    Activation of Testmode For MSG3 Configuration    UE_IDs=2   ACTION_DESIRED=activate    PROFILE_ID=1
    Send Ue Measurement Nr    ue_id=2    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE2

    Wait 305s For nrCntRachStpSlCellDetHChFrq Timer Expiration

    Attach Ue    ue_id=3
    Establish PDU Session Without Confirmation    ue_id=3    gw_id=3
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE3
    Activation of Testmode For MSG3 Configuration    UE_IDs=3    ACTION_DESIRED=activate    PROFILE_ID=1
    Send Ue Measurement Nr    ue_id=3    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE3
    Attach Ue    ue_id=4
    Establish PDU Session Without Confirmation    ue_id=4    gw_id=4
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE4
    Activation of Testmode For MSG3 Configuration    UE_IDs=4    ACTION_DESIRED=activate    PROFILE_ID=1
    Send Ue Measurement Nr    ue_id=4    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE4

    Wait 305s For nrCntRachStpSlCellDetHChFrq Timer Expiration

    Attach Ue    ue_id=5
    Establish PDU Session Without Confirmation    ue_id=5    gw_id=5
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE5
    Activation of Testmode For MSG3 Configuration    UE_IDs=5    ACTION_DESIRED=activate    PROFILE_ID=1
    Send Ue Measurement Nr    ue_id=5    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE5
    Attach Ue    ue_id=6
    Establish PDU Session Without Confirmation    ue_id=6    gw_id=6
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE6
    Activation of Testmode For MSG3 Configuration    UE_IDs=6    ACTION_DESIRED=activate    PROFILE_ID=1
    Send Ue Measurement Nr    ue_id=6    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE6

    Wait Until Keyword Succeeds   8 min   20 sec   Verify If Admin Alarm Is Up    alarm_id=7101    remote_host=${REMOTE_HOST_1_IP}
    Wait Until Keyword Succeeds   6 min   20 sec   Wait Until Cells Becomes Disabled on Secondary Node due to BBMOD Autonomous Reset
    Wait Until BaseBand Module and Available Cell is Enabled on Secondary Node    TIMEOUT=600    REMOTE_HOST=${REMOTE_HOST_1_IP}

    Attach Ue    ue_id=7
    Establish PDU Session With Traffic  ue_id=7    gw_id=7
    Set Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition For UE7
    Send Ue Measurement Nr    ue_id=7    meas_id=1    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition For UE7
    Verify Counter M55601C00007 Value After Test

    [Teardown]     Run Keywords    Verify If Admin Fault Is Up    fault_id=4547    remote_host=${REMOTE_HOST_1_IP}
    ...            AND             Verify If Admin Alarm Is Up    alarm_id=7114    remote_host=${REMOTE_HOST_1_IP}
    ...            AND             Add Scout Scf Id To Test Data
*** Keywords ***
#CB008490_EA_EC101_Release_of_PDU_Sessions_non_last_RRC_Reconfiguration_timeout KWs
Verify E1AP On SN side EA
    Verify In E1AP BearerContextModificationRequest_1 Out Of 1 That pDU-Session-ID Is Set To 1 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 1 That dRB-ID Is Set To 4 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 1 That cell-Group-To-Modify Has cell-Group-ID Set To 0 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 1 That cell-Group-To-Modify Has cell-Group-ID Set To 1 For GNB3
    Verify In E1AP BearerContextModificationRequest_1 Out Of 1 That cell-Group-To-Modify Has dL-TX-Stop Set To 'stop' For GNB3
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB3

Verify E1AP On MN side EA
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2

Verify F1AP On SN side EA
     Verify In F1AP UEContextModificationRequest_1 Out Of 1 That TransmissionActionIndicator Is Set To 'stop' For gNB3

Verify F1AP On MN side EA
   Verify In F1AP UEContextModificationRequest_1 Out Of 1 That SCGIndicator Is Set To 'released' For GNB2
   Verify In F1AP UEContextModificationResponse_1 Out Of 1 That cellGroupConfig Is Present For GNB2
   Verify In F1AP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2
   Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That RRCContainer Is Present For GNB2

Verify RRC EA
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1

Verify XNAP EA
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That Cause Has radioNetwork Set To 'normal-release' For GNB2
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That pduSessionId Is Set To 1 For GNB2
    Verify In XNAP SNodeReleaseRequestAcknowledge_1 Out Of 1 That pduSessionId Is Set To 1 For GNB3
    Check Values From APIDs In SNodeReleaseRequest

Verify NGAP EA
    Verify In NGAP PDUSessionResourceReleaseCommand_1 Out Of 1 cause Is Set To "nas: normal-release" For AMF${amf_id}
    Verify In NGAP UEContextReleaseRequest_1 Out Of 1 Cause Is Set To "radioNetwork: radio-connection-with-ue-lost" For AMF${amf_id}
    Verify In NGAP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: radio-connection-with-ue-lost" For AMF${amf_id}

#F-FA KWs
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

Verify E1AP On SN side F
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
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 That Cause Has radioNetwork Set To 'action-desirable-for-radio-reasons' For GNB3

Verify F1AP On SN side F
     Verify UeContextModificationRequest
     Verify UeContextReleaseCommand

Verify UeContextModificationRequest
     Verify In F1AP UEContextModificationRequest_1 Out Of 1 That TransmissionActionIndicator Is Set To 'stop' For gNB3

Verify UeContextReleaseCommand
     Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That Cause Contains radioNetwork Set To 'action-desirable-for-radio-reasons' For GNB3

Verify XnAP F
    Verify SNodeReleaseRequest And SNodeReleaseRequestAcknowledge
    Verify XnUAddressIndication And SNStatusTransfer
    Verify UEContextRelease

Verify SNodeReleaseRequest And SNodeReleaseRequestAcknowledge
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That Cause Has radioNetwork Set To 'action-desirable-for-radio-reasons' For GNB3
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

Verify E1AP On MN side F
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

Verify F1AP On MN side F
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
    #-FA_B201
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 34 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 35 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 36 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceToAddModList Contains nzp-CSI-RS-ResourceId Set To 37 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-ResourceSetToAddModList Contains nzp-CSI-ResourceSetId Set To 2 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-MeasConfig Contains csi-SSB-ResourceSetToReleaseList With Value/s [0] For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ResourceConfigToAddModList Contains csi-ResourceConfigId Set To 10 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ResourceConfigToAddModList Contains Field csi-RS-ResourceSetList For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ResourceConfigToAddModList Contains Field nzp-CSI-RS-SSB For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That nzp-CSI-RS-SSB Contains nzp-CSI-RS-ResourceSetList With Value/s [2] For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-SSB-ResourceSetList Is Not Present For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ResourceConfigToAddModList Contains bwp-Id Set To 1 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ResourceConfigToAddModList Contains resourceType Set To "periodic" For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ReportConfigToAddModList Contains reportConfigId Set To 2 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ReportConfigToAddModList Contains reportConfigType And periodic For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-ReportConfigToAddModList Contains reportQuantity And cri-RSRP For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That tag-Id Is Set To 0 For GNB2

Verify RRC F
    Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig Contains drb-Identity Set To 4 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That pdcp-Config Is Present For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That masterCellGroup Contains cellGroupId Set To 0 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That servedRadioBearer Contains drb-Identity Set To 4 For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That rlc-BearerToAddModList Contains rlc-Config And mac-LogicalChannelConfig For UE1
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1

Verify NGAP F
    Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That pDUSessionID Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyIndication_1 Out Of 1 That qosFlowIdentifier Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That pDUSessionID Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That qosFlowIdentifier Is Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That transportLayerAddress Is Set To '${Ngap_transport_layer_adress}' For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyConfirm_1 Out Of 1 That gTP-TEID Is Set To '${Ngap_gTP_TEID}' For AMF${amf_id}

Verify Successful RLC Takeback By SN DTX Detection
    Verify In F1AP UEContextModificationRequired_1 Out Of 1 That Cause Contains radioNetwork Set To 'rl-failure-others' For GNB3
    Verify In XNAP SNodeReleaseRequired_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB3
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That cellGroupId Is Set To 0 For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That uplinkConfig Contains Field setup For GNB2
    Verify In F1AP UEContextModificationResponse_1 Out Of 2 That csi-MeasConfig Is Not Present For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig Contains drb-Identity Set To 4 For UE3
    Verify In RRC RRCReconfiguration_1 Out Of 1 That pdcp-Config Is Present For UE3
    Verify In RRC RRCReconfiguration_1 Out Of 1 That masterCellGroup Contains cellGroupId Set To 0 For UE3
    Verify In RRC RRCReconfiguration_1 Out Of 1 That servedRadioBearer Contains drb-Identity Set To 4 For UE3
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE3
    Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That Cause Contains radioNetwork Set To 'rl-failure-others' For GNB3
    Verify In E1AP BearerContextModificationResponse_2 Out Of 2 That dRB-ID Is Set To 4 For GNB2
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB3

#CB008490_KA KWs
Set Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition with 2CC FR2 CA For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    rrcReconf=3   rrcReconfCompl=3    sNnodeAddPrep=1    xnUAddressInd=1
    ...    sNStatusTransfer=1    sNnodeReconfCompl=1

Verify Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition with 2CC FR2 CA For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    rrcReconf=3    rrcReconfCompl=3    sNnodeAddPrep=1    xnUAddressInd=1
    ...    sNStatusTransfer=1    sNnodeReconfCompl=1

Verify If UE has configured 2CC FR2 Based On SelectedPLMN
    Verify In XNAP SNodeAdditionRequest_1 Out Of 1 That PLMN-Identity Is Set To "0x134198" For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndex_2CC} In CG-Config For GNB2
    Verify In RRC RRCReconfiguration_3 Out Of 3 That List sCellToAddModList Has 1 Element/s For UE1
    Verify In RRC RRCReconfigurationComplete_3 Out Of 3 That nr-SCG-Response Is Present For UE1

#CB008490_QA KWs
Prepare UE Testmode For MSG3 Configuration
    [Arguments]    ${PROFILE_ID}    ${TESTMODE_ACTION}     ${NUMBER_OF_ACTIONS}
    Execute Egate Command   cmd=cont_res_testmode_nr profile_id=${PROFILE_ID} ${TESTMODE_ACTION}=${NUMBER_OF_ACTIONS}

Activation of Testmode For MSG3 Configuration
    [Arguments]    ${UE_IDs}    ${ACTION_DESIRED}   ${PROFILE_ID}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_IDs} action=${ACTION_DESIRED} testmode=contention_resolution profile_id=${PROFILE_ID}

Wait Until BaseBand Module and Available Cell is Enabled on Secondary Node
    [Arguments]    ${TIMEOUT}   ${REMOTE_HOST}
    Wait For All Cells To Be Enabled    timeout=${TIMEOUT}    remote_host=${REMOTE_HOST}

Wait Until Cells Becomes Disabled on Secondary Node due to BBMOD Autonomous Reset
    Check All Cells Classical    search_key=operationalState    expected_state=disabled    remote_host=${REMOTE_HOST_1_IP}

Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=150
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=60
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=100
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=ul    mbps=60

Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    sNnodeAddPrep=1    xnUAddressInd=1    sNStatusTransfer=2    sNnodeReconfCompl=1
        ...    sNnodeReleaseRequired=1    XNAPuECtxRelease=1

Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    sNnodeAddPrep=1    xnUAddressInd=1    sNStatusTransfer=2    sNnodeReconfCompl=1
        ...    sNnodeReleaseRequired=1    XNAPuECtxRelease=1

Set Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    sNnodeAddPrep=1    xnUAddressInd=1    sNStatusTransfer=1    sNnodeReconfCompl=1

Verify Expected Message Flow For A4 Meas Based Succesfull Inter-gNB PSCell Addition For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    sNnodeAddPrep=1    xnUAddressInd=1    sNStatusTransfer=1    sNnodeReconfCompl=1

Verify Counter M55601C00007 Value After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}
    Verify Any Counters In File
        ...    M55601C00007    1      NR_DEG_RACHSR_REC_PHASE_II
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-2
        ...    file_path=${pm_counter_file}
