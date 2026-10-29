*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature introduces successful inter-gNB NR-DC PSCell addition procedure upon receipt of A4 Measurement Report
...      with one NR-DC PSCell candidate cell from a UE. UE is connected to MN gNB (SA cell, FR1) and NR-DC A4 measurement for
...      PSCell (NR-DC-SN cell, FR2) candidate NR frequency is configured at UE. Xn-C link is configured between MN gNB and SN gNB.
...      Testing will be focused on Secondary Node (SN gNB) side, Master Node (MN gNB) side will be done by other team.
...
...      == TEST SET NAME ==
...      CB008490-B#B2: Successful inter-gNB NR-DC PSCell Addition upon receipt of UE measurement report with one NR-DC PSCell candidate cell
...
...      == TESTING SPLIT ==
...      CB008490-SR-B-B201: SNode Addition with TDD PCell with one QoS Flow after A4 measurement report
...      CB008490-SR-B-B202: SNode Addition with multiple QoS Flows after A4 measurement report
...
...      == TESTING SCOPE ==
...      CB008490-SR-B-B201: SNode Addition with TDD PCell with one QoS Flow after A4 measurement report
...      1.	CB008490-SR-B-B201_SN_new_UEContext_based_on_SNode_Addition_Request_one_qos_flow_and_one_combination_is_compatible_with_PSCell_CFRA
...      2.	CB008490-SR-B-B201_SN_new_UEContext_based_on_SNode_Addition_Request_one_qos_flow_and_one_combination_is_compatible_with_PSCell_CBRA
...      3.	CB008490-SR-B-B201_SNode_Addition_with_different_settings_at_SN_for_nrDcDrbParam_or_x2FlowControlProfForCu
...      4.	CB008490-SR-B-B201_Snode_Addition_with_special_settings_at_SN_for_max_MIMO_at_FR2
...
...      == CONTACTS ==
...         - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Konrad Bem <konrad.bem@nokia.com>
...
...      == MAINTAINER ==
...         - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Konrad Bem <konrad.bem@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=579
...
...      == HISTORY ==
...      [21.12.2023] - Create Test Suite
...      [08.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=899132)

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIO_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_ABIO_CBRA.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
${yaml_B201_2}=           ${CURDIR}/config/yaml/B201_2.yaml
${yaml_B201_2_revert}=      ${CURDIR}/config/yaml/B201_2_default.yaml

*** Test Cases ***
CB008490-SR-B-B201 SN new UEContext based on SNode Addition Request one qos flow and one combination is compatible with PSCell CBRA
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the inter-gNB NR-DC PSCell addition procedure upon receipt of A4 Measurement Report
    ...  with one NR-DC PSCell candidate cell from a UE, in CBRA mode (Contention Based Random Access). UE transmits/receives UL/DL data
    ...  in SA Cell in MN gNB and is in the coverage of NR-DC-SN Cell in SN gNB then sends A4 NR-DC measurement report. Upon receipt of the
    ...  A4 NR-DC measurement report MN gNB-CU-CP decides to perform PSCell Addition procedure towards SN gNB, pre-selects the PSCell and
    ...  builds up allowed BC list. Test performed using CBRA mode on SN gNB.
    ...
    ...  == PRECONDITION ==
    ...  Use common preconditions from AC (https://collab.ext.net.nokia.com/ui#review:id=899132)
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78)
    ...  - HARDWARE ID:  gNB3 (ASIL + ABIO) with simulated 1x AEQE (band n78) and 1x AWEUB (band n257)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-B#B2
    ...
    ...  == HISTORY ==
    ...  [21.12.2023] - Create Test Suite
    ...  [08.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=899132)

    [Setup]  Prepare test environment CB008490-B

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run DL and UL traffic on UE1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3


    ### (1) SNodeAdditionRequest verifiers
    Verify SNodeAdditionRequest for SN gNB3

    ### (2) BearerContextSetupRequest verifiers
    Verify BearerContextSetupRequest for SN gNB3

    ### (3) BearerContextSetupResponse verifiers
    Verify BearerContextSetupResponse for SN gNB3

    ### (4) UEContextSetupRequest verifiers
    Verify UEContextSetupRequest for SN gNB3

    ### (5) UEContextSetupResponse verifiers
    Verify UEContextSetupResponse for SN gNB3 without CFRA

    ### (6) SNodeAdditionRequestAcknowledge verifiers
    Verify SNodeAdditionRequestAcknowledge for SN gNB3

    ### (7) XnUAddressIndication verifiers
    Verify XnUAddressIndication for SN gNB3

    ### (8) SNodeReconfigurationComplete
    Verify SNodeReconfigurationComplete for SN gNB3

    ### (9) SNStatusTransfer verifiers
    Verify SNStatusTransfer for SN gNB3

    ### RRCReconfiguration verifiers
    Verify RRCReconfiguration has masterCellGroup, secondaryCellGroup, logicalChannelIdentity and radioBearerConfig2 for UE1

    ### (10) BearerContextModificationRequest verifiers
    Verify BearerContextModificationRequest for SN gNB3

    ### (11) BearerContextModificationResponse verifiers
    Verify BearerContextModificationResponse for SN gNB3

    ### (12) Check FOR CBRA (CFRA not present) / CFRA (CFRA present) - DONE in step (5)

    ### (13) BearerContextInactivityNotification verifiers
    Verify BearerContextInactivityNotification for SN gNB3

    ### (14) pDUSessionResourceModifyIndication verifiers
    Verify PDUSessionResourceModifyIndication for MN gNB2

    Compare GTP tunnels at SN gNB3

    Verify traffic on UE1

    [Teardown]  Basic cleanup

CB008490-SR-B-B201 SNode Addition with different settings at SN for nrDcDrbParam or x2FlowControlProfForCu

    [Tags]    B201-2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the inter-gNB NR-DC PSCell addition procedure upon receipt of A4 Measurement Report
    ...  with one NR-DC PSCell candidate cell from a UE, in CBRA mode (Contention Based Random Access). UE transmits/receives UL/DL data
    ...  in SA Cell in MN gNB and is in the coverage of NR-DC-SN Cell in SN gNB then sends A4 NR-DC measurement report. Upon receipt of the
    ...  A4 NR-DC measurement report MN gNB-CU-CP decides to perform PSCell Addition procedure towards SN gNB, pre-selects the PSCell and
    ...  builds up allowed BC list. Test performed using CBRA mode and dlDataSplitModeNrDc = dlOverXxU, dlPreferredPathNrDc - deleted on SN gNB.
    ...
    ...  == PRECONDITION ==
    ...  Use common preconditions from AC (https://collab.ext.net.nokia.com/ui#review:id=899132)
    ...  Additional preconditions for this TC:
    ...  SN gNB configuration:
    ...  NRBTS/NRDRB-11 with nrDcDrbParam is configured:
    ...  NRBTS/NRDRB-11/nrDcDrbParam/dlDataSplitModeNrDc = dlOverXxU
    ...  NRBTS/NRDRB-11/nrDcDrbParam/dlPreferredPathNrDc - deleted
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78)
    ...  - HARDWARE ID:  gNB3 (ASIL + ABIO) with simulated 1x AEQE (band n78) and 1x AWEUB (band n257)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-B#B2
    ...
    ...  == HISTORY ==
    ...  [21.12.2023] - Create Test Suite
    ...  [08.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=899132)

    [Setup]  Prepare test environment CB008490-B201-2

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3


    ### (1) SNodeAdditionRequest verifiers
    Verify SNodeAdditionRequest for SN gNB3

    ### (2) BearerContextSetupRequest verifiers
    Verify BearerContextSetupRequest for SN gNB3 with dlDataSplitModeNrDc set to dlOverXxU

    ### (3) BearerContextSetupResponse verifiers
    Verify BearerContextSetupResponse for SN gNB3

    ### (4) UEContextSetupRequest verifiers
    Verify UEContextSetupRequest for SN gNB3

    ### (5) UEContextSetupResponse verifiers
    Verify UEContextSetupResponse for SN gNB3 without CFRA

    ### (6) SNodeAdditionRequestAcknowledge verifiers
    Verify SNodeAdditionRequestAcknowledge for SN gNB3

    ### (7) XnUAddressIndication verifiers
    Verify XnUAddressIndication for SN gNB3

    ### (8) SNodeReconfigurationComplete
    Verify SNodeReconfigurationComplete for SN gNB3

    ### (9) SNStatusTransfer verifiers
    Verify SNStatusTransfer for SN gNB3

    ### RRCReconfiguration verifiers
    Verify RRCReconfiguration has masterCellGroup, secondaryCellGroup, logicalChannelIdentity and radioBearerConfig2 for UE1

    ### (10) BearerContextModificationRequest verifiers
    Verify BearerContextModificationRequest for SN gNB3

    ### (11) BearerContextModificationResponse verifiers
    Verify BearerContextModificationResponse for SN gNB3

    ### (13) BearerContextInactivityNotification verifiers
    Verify BearerContextInactivityNotification for SN gNB3

    ### (14) pDUSessionResourceModifyIndication verifiers
    Verify PDUSessionResourceModifyIndication for MN gNB2

    Compare GTP tunnels at SN gNB3

    [Teardown]  Cleanup test environment CB008490-B201-2

CB008490-SR-B-B201 Snode Addition with special settings at SN for max MIMO at FR2
    [Tags]    B201-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the inter-gNB NR-DC PSCell addition procedure upon receipt of A4 Measurement Report
    ...  with one NR-DC PSCell candidate cell from a UE, in CBRA mode (Contention Based Random Access). UE transmits/receives UL/DL data
    ...  in SA Cell in MN gNB and is in the coverage of NR-DC-SN Cell in SN gNB then sends A4 NR-DC measurement report. Upon receipt of the
    ...  A4 NR-DC measurement report MN gNB-CU-CP decides to perform PSCell Addition procedure towards SN gNB, pre-selects the PSCell and
    ...  builds up allowed BC list. Test performed using CBRA mode and NRCELL using MIMO mode on SN gNB.
    ...
    ...  == PRECONDITION ==
    ...  Use common preconditions from AC (https://collab.ext.net.nokia.com/ui#review:id=899132)
    ...  Additional preconditions for this TC:
    ...  SN gNB configuration:
    ...  NRBTS/NRCELL-2 max MIMO is configured (2x2)
    ...  NRBTS/NRCELL-2/dlMimoMode = 2x2 Open Loop Spatial Multiplexing
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78)
    ...  - HARDWARE ID:  gNB3 (ASIL + ABIO) with simulated 1x AEQE (band n78) and 1x AWEUB (band n257)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-B#B2
    ...
    ...  == HISTORY ==
    ...  [21.12.2023] - Create Test Suite
    ...  [08.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=899132)

    [Setup]  Prepare test environment CB008490-B

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 1Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3


    ### (1) SNodeAdditionRequest verifiers
    Verify SNodeAdditionRequest for SN gNB3

    ### (2) BearerContextSetupRequest verifiers
    Verify BearerContextSetupRequest for SN gNB3

    ### (3) BearerContextSetupResponse verifiers
    Verify BearerContextSetupResponse for SN gNB3

    ### (4) UEContextSetupRequest verifiers
    Verify UEContextSetupRequest for SN gNB3

    ### (5) UEContextSetupResponse verifiers
    Verify UEContextSetupResponse for SN gNB3 without CFRA and with MIMO check

    ### (6) SNodeAdditionRequestAcknowledge verifiers
    Verify SNodeAdditionRequestAcknowledge for SN gNB3

    ### (7) XnUAddressIndication verifiers
    Verify XnUAddressIndication for SN gNB3

    ### (8) SNodeReconfigurationComplete
    Verify SNodeReconfigurationComplete for SN gNB3

    ### (9) SNStatusTransfer verifiers
    Verify SNStatusTransfer for SN gNB3

    ### RRCReconfiguration verifiers
    Verify RRCReconfiguration has masterCellGroup, secondaryCellGroup, logicalChannelIdentity and radioBearerConfig2 for UE1

    ### (10) BearerContextModificationRequest verifiers
    Verify BearerContextModificationRequest for SN gNB3

    ### (11) BearerContextModificationResponse verifiers
    Verify BearerContextModificationResponse for SN gNB3

    ### (13) BearerContextInactivityNotification verifiers
    Verify BearerContextInactivityNotification for SN gNB3

    ### (14) pDUSessionResourceModifyIndication verifiers
    Verify PDUSessionResourceModifyIndication for MN gNB2

    Compare GTP tunnels at SN gNB3

    [Teardown]  Basic cleanup


*** Keywords ***
Verify SNodeAdditionRequest for SN gNB3
    ### (1) SNodeAdditionRequest verifiers
    Verify in SNodeAdditionRequest that it has 8 required protocolIE items for SN gNB3
    Verify in SNodeAdditionRequest that pduSessionId is set to 1 and mn-terminated is not present and sn-terminated is present for SN gNB3
    Verify in SNodeAdditionRequest that gTPTunnel is present and pduSessionType is set to ipv4 for SN gNB3
    Verify in SNodeAdditionRequest that qosFlowsToBeForwarded list is 1 element for SN gNB3
    Verify in SNodeAdditionRequest that dl-dataforwarding is set to forwarding-proposed for SN gNB3
    Verify in SNodeAdditionRequest that sourceDRBtoQoSFlowMapping includes DRB ID 4 and QOS flow has 1 element for SN gNB3
    Verify in SNodeAdditionRequest that candidateCellInfoListMN has 1 element, pci: 52 for SN gNB3

Verify BearerContextSetupRequest for SN gNB3
    ### (2) BearerContextSetupRequest verifiers
    Verify in bearerContextSetupRequest that it has 8 required protocolIE items for SN gNB3
    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3

    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 7200 for SN gNB3
    Verify in BearerContextSetupRequest that pDU-Session-ID is set to 1 and pDU-Session-Type is set to ipv4 for SN gNB3
    Verify in BearerContextSetupRequest that securityIndication is present and integrityProtectionIndication set not-needed SN gNB3

    Verify in BearerContextSetupRequest that nG-UL-UP-TNL-Information is present and gTPTunnel is configured for SN gNB3
    Verify in BearerContextSetupRequest that defaultDRB is set and pDCP-Reestablishment is set for SN gNB3
    Verify in BearerContextSetupRequest that in cellGroupID: 1 uL-Configuration is 'no-data' and dL-TXStop is not present for SN gNB3
    Verify in BearerContextSetupRequest that in cellGroupID: 0 uL-Configuration is 'only' and dL-TXStop is not present for SN gNB3
    Verify in BearerContextSetupRequest that data-Forwarding-Request is dL, qoS-Flows-Forwarded-On-Fwd-Tunnels is not present for SN gNB3

Verify BearerContextSetupRequest for SN gNB3 with dlDataSplitModeNrDc set to dlOverXxU
    ### (2) BearerContextSetupRequest verifiers
    Verify in bearerContextSetupRequest that it has 8 required protocolIE items for SN gNB3
    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3

    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 7200 for SN gNB3
    Verify in BearerContextSetupRequest that pDU-Session-ID is set to 1 and pDU-Session-Type is set to ipv4 for SN gNB3
    Verify in BearerContextSetupRequest that securityIndication is present and integrityProtectionIndication set not-needed SN gNB3

    Verify in BearerContextSetupRequest that nG-UL-UP-TNL-Information is present and gTPTunnel is configured for SN gNB3
    Verify in BearerContextSetupRequest that defaultDRB is set and pDCP-Reestablishment is set for SN gNB3
    Verify in BearerContextSetupRequest that in cellGroupID: 1 uL-Configuration is 'no-data' and dL-TXStop set to 'stop' for SN gNB3
    Verify in BearerContextSetupRequest that in cellGroupID: 0 uL-Configuration is 'only' and dL-TXStop is not present for SN gNB3
    Verify in BearerContextSetupRequest that data-Forwarding-Request is dL, qoS-Flows-Forwarded-On-Fwd-Tunnels is not present for SN gNB3

Verify BearerContextSetupResponse for SN gNB3
    ### (3) BearerContextSetupResponse verifiers
    Verify in BearerContextSetupResponse that nG-DL-UP-TNL-Information is present and gTPTunnel is configured for SN gNB3
    Verify in BearerContextSetupResponse that dRB-data-Forwarding-Info-Resp is present, uL-UP-Transport-Param has 2 elements for SN gNB3

Verify UEContextSetupRequest for SN gNB3
    ### (4) UEContextSetupRequest verifiers
    # OLD From CB008717-verify_UEContextSetup.robot
    Verify in UEContextSetupRequest that 1 DRBs set according to E1AP for gNB3

    # NEW From CB008490-verify_UEContextSetup.robot
    Verify in UEContextSetupRequest that id-SpCell-ID and NRCGI and nRCellIdentity is present for SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for SN gNB3
    Verify in UEContextSetupRequest that uLUPTNLInformation-ToBeSetup-List has 1 element for SN gNB3
    Verify in UEContextSetupRequest that uLConfiguration contains uLUEConfiguration is no-data for SN gNB3
    Verify in UEContextSetupRequest that DLPDCPSNLength is 18bits and ULPDCPSNLength is 18bits for SN gNB3

Verify UEContextSetupResponse common checks for SN gNB3 without CFRA
    ### (5) UEContextSetupResponse verifiers
    # NEW From CB008490-verify_UEContextSetup.robot
    Verify in UEContextSetupResponse that DUtoCURRCInformation contains CellGroupConfig with cellGroupId 1 for SN gNB3
    Verify in UEContextSetupResponse that cellGroupConfig contains rlc-BearerToAddModList and logicalChannelIdentity is 4 for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains mac-CellGroupConfig and physicalCellGroupConfig SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig and servCellIndex is present for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for SN gNB3
    Verify in UEContextSetupResponse that iE-Extensions contains SelectedBandCombinationIndex and SelectedFeatureSetIndex is present for SN gNB3
    Verify in UEContextSetupResponse that DRBs-Setup-List has 1 element and dRBID is 4 for SN gNB3
    Verify in UEContextSetupResponse that DRBs-Setup-List contains dLUPTNL-Information-ToBeSetup-List dLUPTNLInformation is present for SN gNB3

Verify UEContextSetupResponse for SN gNB3 with CFRA
    Verify in UEContextSetupResponse that DUtoCURRCInformation contains CellGroupConfig with cellGroupId 1 for SN gNB3
    Verify in UEContextSetupResponse that cellGroupConfig contains rlc-BearerToAddModList and logicalChannelIdentity is 4 for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains mac-CellGroupConfig and physicalCellGroupConfig SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig and servCellIndex is present for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3
    Verify in UEContextSetupResponse that iE-Extensions contains SelectedBandCombinationIndex and SelectedFeatureSetIndex is present for SN gNB3
    Verify in UEContextSetupResponse that DRBs-Setup-List has 1 element and dRBID is 4 for SN gNB3
    Verify in UEContextSetupResponse that DRBs-Setup-List contains dLUPTNL-Information-ToBeSetup-List dLUPTNLInformation is present for SN gNB3
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for SN gNB3

Verify UEContextSetupResponse for SN gNB3 without CFRA
    Verify UEContextSetupResponse common checks for SN gNB3 without CFRA


Verify UEContextSetupResponse for SN gNB3 without CFRA and with MIMO check
    Verify UEContextSetupResponse common checks for SN gNB3 without CFRA
    ### (5) UEContextSetupResponse verifiers
    # NEW From CB008490-verify_UEContextSetup.robot
    #For TC 4:
    Verify in UEContextSetupResponse that CellGroupConfig contains pusch maxMIMO-Layers is 2, pdsch maxMIMO-Layers is 2 for SN gNB3


Verify SNodeAdditionRequestAcknowledge for SN gNB3
    ### (6) SNodeAdditionRequestAcknowledge verifiers
    Verify in SNodeAdditionRequestAck that PDUSessionAdmittedAddedReqAck has 1 element for SN gNB3
    Verify in SNodeAdditionRequestAck that mn-terminated is not present and sn-terminated is present for SN gNB3
    Verify in SNodeAdditionRequestAck that dL-NG-U-TNLatNG-RAN is present and dRBsToBeSetup has 1 element for SN gNB3
    Verify in SNodeAdditionRequestAck that in dRBsToBeSetup drb-ID is 4 and sN-UL-PDCP-UP-TNLInfo has 1 elements for SN gNB3
    Verify in SNodeAdditionRequestAck that in sn-terminated dataforwardinginfoTarget is present and DRB-List contains 4 for SN gNB3
    Verify in SNodeAdditionRequestAck that secondaryCellGroup is configured for SN gNB3

Verify XnUAddressIndication for SN gNB3
    ### (7) XnUAddressIndication verifiers
    Verify in XnUAddressIndication that dRBsToBeSetupList has 1 element and contains gtpTunnel tnl-address and gtp-teid for SN gNB3

Verify SNodeReconfigurationComplete for SN gNB3
    ### (8) SNodeReconfigurationComplete
    Verify in SNodeReconfigurationComplete that configuration-successfully-applied, m-NG-RANNode-to-S-NG-RANNode-Container is present for SN gNB3

Verify SNStatusTransfer for SN gNB3
    ### (9) SNStatusTransfer verifiers
    Verify in SNStatusTransfer that DRBsSubjectToStatusTransfer-List has 1 element and contains pdcpStatusTransfer UL and DL for SN gNB3

Verify BearerContextModificationRequest for SN gNB3
    ### (10) BearerContextModificationRequest verifiers
    Verify in BearerContextModReq that PDU-Session-Resource-To-Modify-List has 1 element with PDU-Session 1 and DRB-ID 4 for SN gNB3

Verify BearerContextModificationResponse for SN gNB3
    ### (11) BearerContextModificationResponse verifiers
    Verify in BearerContextModResp that PDU-Session-Resource-To-Modify-List has 1 element with PDU-Session 1 and DRB-ID 4 for SN gNB3

Verify BearerContextInactivityNotification for SN gNB3
    ### (13) BearerContextInactivityNotification verifiers
    Verify in BearerContextInactivityNotification that uE-Activity eq active and dRB-Activity-List is not present for SN gNB3

Verify PDUSessionResourceModifyIndication for MN gNB2
    ### (14) pDUSessionResourceModifyIndication verifiers
    Verify in PDUSessionResourceModifyIndication and PDUSessionResourceModifyConfirm are present for MN gNB2

Run DL and UL traffic on UE1
    Run 175Mbps DL traffic-1 on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic-2 on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic-3 on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic-4 on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps UL traffic-5 on UE1 PDU1 QFI1 and wait 2 seconds

Verify traffic on UE1
    Wait Until Keyword Succeeds  15s  2s
    ...    Verify 10MBps UL traffic on MCG bearer PDU-1 QFI-1 for UE1
    Verify 110MBps DL traffic on MCG bearer PDU-1 QFI-1 for UE1
    Verify 0MBps UL traffic on SCG bearer PDU-1 QFI-1 for UE1
    Verify 500MBps DL traffic on SCG bearer PDU-1 QFI-1 for UE1
