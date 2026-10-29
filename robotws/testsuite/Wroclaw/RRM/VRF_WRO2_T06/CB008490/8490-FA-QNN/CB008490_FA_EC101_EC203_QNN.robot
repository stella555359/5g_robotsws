*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    	CLOUD_5G_I_LOO_AP_LOOO

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik
...             :contact: edyta.rudnik@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ../resources/feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Library     ta5g_file_system
Library     ../resources/KeywordsCB008490.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/common_keywords.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Upload Fixed Iphy Plug
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Find Scfc And Send Delta Commissioning    scfc_filename=delta8490.json

Test Teardown      Run Keywords
...                Deregister UE    ue_id=1
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Find Errors
...    AND         Add Scout Scf Id To Test Data
...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Collect Selected Debug Files
...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                omit_collectors=sos_report

Suite Teardown    Run Keywords    Compress Test Logs
...    AND        Run Keyword And Ignore Error    Find Scfc And Send Delta Commissioning    scfc_filename=delta_disable_8490.json

*** Variables ***
@{FAULT_IDS_LIST}=          6450    4383
${ue_id}=                   1
${amf_id}=                  1
${pdu_id}=                  1
${cfg_FA_EC101}=            ${CURDIR}/config/TMO65_NRDC_n25A_n260Asim.cfg
${cfg_FA_EC203}=            ${CURDIR}/config/TMO65_NRDC_n25A_n260Asim.cfg
${cfg_QNN}=                 ${CURDIR}/config/TMO65_NRDC_n25A_n260Asim_foreign.cfg
${delta_QNN_unlock}=        delta_QNN_unlock.json
${delta_QNN_lock}=          delta_QNN_lock.json

*** Test Cases ***
CB008490_FA_EC101_inter-gNB_NR-DC_takeback_procedure_with_timer_expiry_before_XnAP_SNodeReleaseRequestAck_is_received
    [Setup]    Run Keywords   Prepare Test Setup Wihout Full Commissioning For One Real Gnb And Enable Tshark Verification    FA_EC101
    ...        AND            Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue    ue_id=${ue_id}    enb=2
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Establish Pdu Session
    Send Data Traffic    inactive_timer=1
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=4    phycell_id=58    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Get Values From APIDs In SNnodeAddPrep
    Send Command To Delay SNodeReleaseRequestAcknowledge Message
    Set Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
    Set Expected Delayed SNodeReleaseRequestAck
    Trigger RRC SCGFailureInformation With FailureType Set To T310-Expiry
    Verify Expected Delayed SNodeReleaseRequestAck
    Verify Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
    Verify Message Contents Of Successfull NR-DC Bearer Takeback
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=0.01
                                       ...       direction=dl    cell_group=MCG    selection_type=average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=10      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=average    margin=10%

CB008490_FA_EC203_ALT4_Unsuccessful_inter-gNB_NR-DC_SN-initiated_takeback_upon_detection_of_RLF_by_gNB-DU_SN_due_to_error_in_RRCReconfComplete
    [Setup]    Run Keywords   Prepare Test Setup Wihout Full Commissioning For One Real Gnb And Enable Tshark Verification    FA_EC203
    ...        AND            Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=${ue_id}    enb=2
    Establish Pdu Session
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Wait 2s For Measurement To Configure
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=4    phycell_id=58    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Wait 2s For Stability
    Delay RRCReconfigurationComplete
    Set Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
    Trigger Radio Link Failure On Sim gNB    cause=CauseRadioNetworkLayer_unspecified
    Verify Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
    Verify Message Contents Of NR-DC Bearer Takeback Interrupted By Lack Of RRCReconfigurationComplete Message From UE

CB008490_QNN_B6_Master_Node_rejects_received_S-Node_Addition_request
    [Documentation]    :copyright: Nokia
    ...                :authors: Joanna Kutrowska-Girzycka
    ...                :contact: joanna.kutrowska-girzycka@nokia.com
    [Setup]    Run Keywords    Find Scfc and Send Delta Commissioning   scfc_filename=${delta_QNN_lock}
    ...    AND    Prepare Test Setup Wihout Full Commissioning For One Real Gnb And Enable Tshark Verification    QNN
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Set Expected Message Flow For Unsuccessful GNB Authentication During Xn Setup Procedure For UE1 GNB2
    Find Scfc and Send Delta Commissioning   scfc_filename=${delta_QNN_unlock}
    Attach Ue    ue_id=${ue_id}    enb=2
    Establish Pdu Session
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=4    phycell_id=58    nrsrp_nr=60    event=A4
    Send SNodeAdditionRequest
    Verify Expected Message Flow For Unsuccessful GNB Authentication During Xn Setup Procedure For UE1 GNB2
#   Below 24727 is id of NokiaXnAuth structure
    Verify In XNAP XnSetupRequest_1 Out Of 1 That id Has 24727 For GNB2
    Verify In XNAP XnSetupResponse_1 Out Of 1 That id Does NOT Contain 24727 For GNB2
    Verify In XNAP SNodeAdditionRequestReject_1 Out Of 1 Cause Is Set To "misc: unspecified" For GNB2

*** Keywords ***
Start Vm Ethernet Interfaces For Simulated gNB2
    Start Vm Ethernet Interface    if_name=eth3:GNB2_NG_ADDR    ip_with_mask=10.0.1.8/24
    Start Vm Ethernet Interface    if_name=eth3:GNB2_XN_ADDR    ip_with_mask=10.0.1.9/24
    Start Vm Ethernet Interface    if_name=eth3:S11          ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2U      ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_S1       ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:MME_SIM      ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2C      ip_with_mask=10.0.1.137/24
    Start Vm Ethernet Interface    if_name=eth3:Server       ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:SERV         ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:AMF2         ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3         ip_with_mask=10.0.1.102/24

Set Expected Delayed SNodeReleaseRequestAck
    EXPECT FLOW[timeout=2]: gNB2 XNAP 1*mNGRANnodeinitiatedSNGRANnodeRelease

Verify Expected Delayed SNodeReleaseRequestAck
    Run Keyword And Expect Error    MessageObserverTimeout*    PASS FLOW[timeout=2]: gNB2 XNAP 1*mNGRANnodeinitiatedSNGRANnodeRelease

Verify Message Contents Of Successfull NR-DC Bearer Takeback
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That Cause Has radioNetwork Set To 'action-desirable-for-radio-reasons' For GNB2
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That pduSessionId Is Set To 1 For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1
    Verify In F1AP UEContextModificationRequest_2 Out Of 2 That RRCReconfigurationCompleteIndicator Is Set To 'true' For GNB2
    Verify In F1AP UEContextModificationRequest_2 Out Of 2 That GNB-DUConfigurationQuery Is Set To 'true' For GNB2
    Verify In F1AP UEContextModificationResponse_2 Out Of 2 That cellGroupConfig Is Present For GNB2
    Check Values From APIDs In SNodeReleaseRequest
    Check Values From APIDs in XnapUEContextRelease

Set Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
     Set expected message flow    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2    rrcReconf=1     rrcReconfCompl=1
        ...     pduSessResModInd=1     SCGFailureInfo=1

Verify Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
     Verify expected message flow    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2      rrcReconf=1    rrcReconfCompl=1
        ...     pduSessResModInd=1     SCGFailureInfo=1

Set Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
     Set expected message flow     sNnodeReleaseRequired=1     bearerCtxMod=2       sNStatusTransfer=1    uECtxMod=1    rrcReconf=1
     ...    XNAPuECtxRelease=1    NGAPueCtxReleaseReq=1    NGAPueCtxRelease=1    F1APuECtxRelease=1    bearerCtxRelease=1
     ...    rrcRelease=1

Verify Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
     Verify expected message flow    sNnodeReleaseRequired=1    bearerCtxMod=2     sNStatusTransfer=1    uECtxMod=1    rrcReconf=1
     ...    XNAPuECtxRelease=1    NGAPueCtxReleaseReq=1    NGAPueCtxRelease=1    F1APuECtxRelease=1    bearerCtxRelease=1
     ...    rrcRelease=1

Verify Message Contents Of NR-DC Bearer Takeback Interrupted By Lack Of RRCReconfigurationComplete Message From UE
    Verify In XNAP SNodeReleaseRequired_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB2
    Verify In F1AP UEContextModificationRequest_1 Out Of 1 That SCGIndicator Is Set To 'released' For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1
    Verify In NGAP UEContextReleaseRequest_1 Out Of 1 Cause Is Set To "radioNetwork: radio-connection-with-ue-lost" For AMF${amf_id}
    Verify In NGAP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: radio-connection-with-ue-lost" For AMF${amf_id}
    Verify In F1AP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2

CB008490_QNN_B6_Master_Node_rejects_received_S-Node_Addition_request
Set Expected Message Flow For Unsuccessful GNB Authentication During Xn Setup Procedure For UE${ue_id:\d+} GNB${gnb_id:\d+}
     Set expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}    timeout=90    xnSetup=1    sNnodeAddPrepFail=1

Verify Expected Message Flow For Unsuccessful GNB Authentication During Xn Setup Procedure For UE${ue_id:\d+} GNB${gnb_id:\d+}
     Verify expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}    timeout=90    xnSetup=1    sNnodeAddPrepFail=1

Send SNodeAdditionRequest
    ${prepare_hex}=    Catenate    SEPARATOR=
    ...                00070082c3000009001700020000005b0009020001000000000000004500200edcd70e49c1b71a28058e44fe716c7efd6eda72e741e2ae41cd91ff388607530
    ...                046000a0c400000003040000000004040031341980010000100002f0029006001402000000108a0000020a00000200f800a000101000000010000100000061e
    ...                28000804180008001800823782351884821811042bcf40a000ae9efc06ac10078a40002c10010180910600098385c00c4834000a040260300c45018053380a5
    ...                46c4dd608c21a08107484400516caa2a121cfa067d813e31cf9863ca1607038780bfffff800fffffe00141f003582308682041e21100125b2a8a82873e819f1
    ...                8e7cc31e50b0381c3c09fff000007ffc00000a0f883ac1184341020f10880092d954541439f40cf8c73e618f28581c0e1e04fec000003fb000001502d04de38
    ...                c21c002a3cfc5110011fb660aa40078f0021c4106115028fdfc81b8dc61c80000603a05a0381bc718438005479f8a220023f6cc154800f1e00438820c22a051
    ...                fbf90371f8e3900000c0540b40378e3087000a8f3f14440047ed982a9001e3c0087104184540a3f7f206ebf5c7200001800318789a001d0030c001fffffffff
    ...                107882001d0430c005fffffffff107800001d0030c003fffffffff00301360800ea0003b01c38180080c0e0649f16180c0c0c0070310f8b0e06002030381887
    ...                c501503448000448000408011e8470007c0050006020280381804a00e000c040422002085808400200064f00c0100000124a01c01004010040100401004b925
    ...                00e00802008020080200802600100000601f282b748dc230628060800004b292820380200802008020080200cb2928203802008020080200802014b29282000
    ...                060000001e9455576a2b95141a200410100200404010020808040080200c01840402004010040080a17201006500097e6d6c21a28f1401000000003f0a1009a
    ...                01a00235e3f0700005f00020060

    Execute Egate Command    cmd=send_hex source=gnb:3 target=gnb:2 hex=${prepare_hex}
