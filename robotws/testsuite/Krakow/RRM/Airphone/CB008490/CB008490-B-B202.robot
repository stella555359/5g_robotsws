*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
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
...      CB008490-SR-B-B202: SNode Addition with multiple QoS Flows after A4 measurement report
...      1. CB008490-SR-B-B202_SN_new_UEContext_based_on_SNode_Addition_Request_four_qos_flows_and_one_combination_is_compatible_with_PSCell
...
...      == CONTACTS ==
...         - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=698
...
...      == HISTORY ==
...      [13.12.2023] - Create Test Suite
...      [08.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=899446)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup    disable_RRC=True

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIO_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIO.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7
${encryption}=            ${True}

*** Test Cases ***
CB008490-SR-B-B202_SN_new_UEContext_based_on_SNode_Addition_Request_four_qos_flows_and_one_combination_is_compatible_with_PSCell
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour for the successful transition of UE with established inter-gNB
    ...  NR-DC connection (with established SN-terminated split bearer) to RRC IDLE. Release is initiated by AMF.
    ...  All UL/DL data traffic is stopped.
    ...
    ...  == PRECONDITION ==
    ...  Use common preconditions from AC (https://collab.ext.net.nokia.com/ui#review:id=899446) except:
    ...    - Additional NRDRB and NRDRB_5QI objects are configured on MN and SN to support 5QI values: 7, 8, 9, 170:
    ...      * All NRDRBs resType = nonGBR and rlcMode = 'RLC_AM'
    ...      * At SN:
    ...        - dlDataSplitModeNrDc = dlOverF1UXxU,
    ...        - ulDataPath = ulOverMCG,
    ...        - dlPreferredPathNrDc = MCG F1-U
    ...
    ...  == POSTCONDITION ==
    ...    UE1 was successfully configured with NR-DC
    ...    DL Traffic is ongoing on NR-DC-SN cell (FR2 cell on SN gNB) and SA PCell (FR1 cell on MN gNB)
    ...    UL traffic is ongoing only on SA PCell (FR1 cell on MN gNB)
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-B#B2: Successful inter-gNB NR-DC PSCell Addition upon receipt of UE measurement report with one NR-DC PSCell candidate cell
    ...
    ...  == HISTORY ==
    ...  [13.12.2023] - Create Test Suite
    ...  [08.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=899446)
    ...  [03.02.2025] - change after -DB: BearerContextInactivityNotification will always have 5 DRBs with same ID = 1

    [Setup]    Prepare test environment CB008490-B-B202

    Wait until keyword succeeds    3x    30s
    ...    Run keywords
    ...    Trigger UEs from 1 to 20 to send deregister request    AND
    ...    Procedure

    [Teardown]    Basic cleanup


*** Keywords ***
Verify SNodeAdditionRequest for SN gNB3
    ### (1) SNodeAdditionRequest verifiers
    Verify in SNodeAdditionRequest that it has 8 required protocolIE items for SN gNB3
    Verify in SNodeAdditionRequest that pduSessionId is set to 1 and mn-terminated is not present and sn-terminated is present for SN gNB3
    Verify in SNodeAdditionRequest that gTPTunnel is present and pduSessionType is set to ipv4 for SN gNB3
    Verify in SNodeAdditionRequest that qosFlowsToBeForwarded list is 4 element for SN gNB3
    Verify in SNodeAdditionRequest that dl-dataforwarding - forwarding-proposed is set for 4 QoS flows for SN gNB3
    Verify in SNodeAdditionRequest that sourceDRBtoQoSFlowMapping includes 4 DRBs with single QoS flow for SN gNB3
    Verify in SNodeAdditionRequest that DRB-List contains 4 elements for SN gNB3
    Verify in SNodeAdditionRequest that candidateCellInfoListMN has 1 element, pci: 52 for SN gNB3

Verify BearerContextSetupRequest for SN gNB3
    ### (2) BearerContextSetupRequest verifiers
    Verify in bearerContextSetupRequest that it has 7 required protocolIE items for SN gNB3
    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to drb for SN gNB3

    Verify in BearerContextSetupRequest that pDU-Session-ID is set to 1 and pDU-Session-Type is set to ipv4 for SN gNB3
    Verify in BearerContextSetupRequest that securityIndication is present and integrityProtectionIndication set not-needed SN gNB3

    Verify in BearerContextSetupRequest 4 DRBs in dRB-To-Setup-List-NG-RAN for SN gNB3

    Verify in BearerContextSetupRequest that all DRBs has dRB-Inactivity-Timer set to 7200 for SN gNB3

Verify BearerContextSetupResponse for SN gNB3
    ### (3) BearerContextSetupResponse verifiers
    Verify in BearerContextSetupResponse that nG-DL-UP-TNL-Information is present and gTPTunnel is configured for SN gNB3
    Verify in BearerContextSetupResponse 4 DRBs in dRB-Setup-List-NG-RAN for SN gNB3

Verify UEContextSetupRequest for SN gNB3
    ### (4) UEContextSetupRequest verifiers
    Verify in UEContextSetupRequest that 4 DRBs set according to E1AP for gNB3

    Verify in UEContextSetupRequest that id-SpCell-ID and NRCGI and nRCellIdentity is present for SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for SN gNB3

    Verify in UEContextSetupRequest 4 DRBs in DRBs-ToBeSetup-List for SN gNB3

Verify UEContextSetupResponse common checks for SN gNB3 without CFRA
    ### (5) UEContextSetupResponse verifiers
    Verify in UEContextSetupResponse that DUtoCURRCInformation contains CellGroupConfig with cellGroupId 1 for SN gNB3
    Verify in UEContextSetupResponse in rlc-BearerToAddModList logicalChannelIdentity eq [4,5,6,7] for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains mac-CellGroupConfig and physicalCellGroupConfig SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig and servCellIndex is present for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for SN gNB3
    Verify in UEContextSetupResponse that iE-Extensions contains SelectedBandCombinationIndex and SelectedFeatureSetIndex is present for SN gNB3
    Verify in UEContextSetupResponse 4 DRBs in DRBs-Setup-List for SN gNB3

Verify SNodeAdditionRequestAcknowledge for SN gNB3
    ### (6) SNodeAdditionRequestAcknowledge verifiers
    Verify in SNodeAdditionRequestAck that PDUSessionAdmittedAddedReqAck has 1 element for SN gNB3
    Verify in SNodeAdditionRequestAck that mn-terminated is not present and sn-terminated is present for SN gNB3
    Verify in SNodeAdditionRequestAck that dL-NG-U-TNLatNG-RAN is present for SN gNB3

    Verify in SNodeAdditionRequestAck that in dRBsToBeSetup drb-IDs eq [4,5,6,7] for SN gNB3
    Verify in SNodeAdditionRequestAck that length of dataForwardingResponseDRBItemList eq 4 for SN gNB3
    Verify in SNodeAdditionRequestAck in DRB-List DRB-ID eq [4,5,6,7] for SN gNB3
    Verify in SNodeAdditionRequestAck that secondaryCellGroup is configured for SN gNB3

Verify XnUAddressIndication for SN gNB3
    ### (7) XnUAddressIndication verifiers
    Verify in XnUAddressIndication in dRBsToBeSetupList dRB-ID eq [4,5,6,7] and contains gtpTunnel tnl-address and gtp-teid for SN gNB3

Verify SNodeReconfigurationComplete for SN gNB3
    ### (8) SNodeReconfigurationComplete
    Verify in SNodeReconfigurationComplete that configuration-successfully-applied, m-NG-RANNode-to-S-NG-RANNode-Container is present for SN gNB3

Verify SNStatusTransfer for SN gNB3
    ### (9) SNStatusTransfer verifiers
    Verify in SNStatusTransfer in DRBsSubjectToStatusTransfer-List drbID eq [4,5,6,7] and contains pdcpStatusTransfer UL and DL for SN gNB3

Verify BearerContextModificationRequest for SN gNB3
    ### (10) BearerContextModificationRequest verifiers
    Verify that BearerContextModReq contains 1 PDU session with id 1 and DRBs [4,5,6,7] for SN gNB3
    Verify that BearerContextModReq contains pdcp-SN-Status-Information copied form SNStatusTransfer for all DRBs for SN gNB3
    Verify in BearerContextModReq that all DRBs has the same gTPTunnels as in UEContextSetupResponse for SN gNB3

Verify BearerContextModificationResponse for SN gNB3
    ### (11) BearerContextModificationResponse verifiers
    Verify that BearerContextModResp contains 1 PDU session with id 1 and DRBs [4,5,6,7] for SN gNB3

Verify BearerContextInactivityNotification for SN gNB3
    ### (13) BearerContextInactivityNotification verifiers
    Verify in BearerContextInactivityNotification that uE-Activity is not present and dRB-Activity-List contains DRBs [1,1,1,1,1] for SN gNB3

Verify PDUSessionResourceModifyIndication for MN gNB2
    ### (14) pDUSessionResourceModifyIndication verifiers
    Verify in PDUSessionResourceModifyIndication that associatedQosFlowList contains 4 QFIs for MN gNB2

Verify RRCReconfiguration for MN gNB3
    Verify RRCReconfiguration has masterCellGroup, secondaryCellGroup, logicalChannelIdentity and radioBearerConfig2 for UE1
    Verify in RRCReconfiguration that rlc-BearerToAddModList has 4 elements with logicalChannelIdentity for UE1

Verify traffic on UE1
#    sleep  10
    Verify 10MBps UL traffic on MCG bearer PDU-1 QFI-1 for UE1
    Verify 25MBps DL traffic on MCG bearer PDU-1 QFI-1 for UE1
    Verify 0MBps UL traffic on SCG bearer PDU-1 QFI-1 for UE1
    Verify 145MBps DL traffic on SCG bearer PDU-1 QFI-1 for UE1

    Verify 10MBps UL traffic on MCG bearer PDU-1 QFI-2 for UE1
    Verify 25MBps DL traffic on MCG bearer PDU-1 QFI-2 for UE1
    Verify 0MBps UL traffic on SCG bearer PDU-1 QFI-2 for UE1
    Verify 145MBps DL traffic on SCG bearer PDU-1 QFI-2 for UE1

    Verify 10MBps UL traffic on MCG bearer PDU-1 QFI-3 for UE1
    Verify 25MBps DL traffic on MCG bearer PDU-1 QFI-3 for UE1
    Verify 0MBps UL traffic on SCG bearer PDU-1 QFI-3 for UE1
    Verify 145MBps DL traffic on SCG bearer PDU-1 QFI-3 for UE1

    Verify 10MBps UL traffic on MCG bearer PDU-1 QFI-4 for UE1
    Verify 25MBps DL traffic on MCG bearer PDU-1 QFI-4 for UE1
    Verify 0MBps UL traffic on SCG bearer PDU-1 QFI-4 for UE1
    Verify 145MBps DL traffic on SCG bearer PDU-1 QFI-4 for UE1

Verify sdap-Config for all DRBs
    Run Keyword And Continue On Failure
    ...    Verify in SNodeAdditionRequest and SNodeAdditionRequestAcknowledge sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${False}
    Run Keyword And Continue On Failure
    ...    Verify in BearerContextSetupRequest sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${False}

Procedure
    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Add to UE1 PDU1 session QoS flows with 5QI from list [8,9,170] and delete QoS flows with 5QI from list [] via amf

    # Run ~700Mb/s DL traffic and 40Mb/s UL traffic
    Run 10Mbps UL and 175Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps UL and 175Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps UL and 175Mbps DL traffic on UE1 PDU1 QFI3 and wait 0 seconds
    Run 10Mbps UL and 175Mbps DL traffic on UE1 PDU1 QFI4 and wait 2 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measurement with id=1 and PCIs [52]

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

    Verify SNodeAdditionRequest for SN gNB3
    Verify BearerContextSetupRequest for SN gNB3
    Verify BearerContextSetupResponse for SN gNB3
    Verify UEContextSetupRequest for SN gNB3
    Verify UEContextSetupResponse common checks for SN gNB3 without CFRA
    Verify SNodeAdditionRequestAcknowledge for SN gNB3
    Verify XnUAddressIndication for SN gNB3
    Verify SNodeReconfigurationComplete for SN gNB3
    Verify SNStatusTransfer for SN gNB3
    Run Keyword if   ${encryption} == ${False}
    ...     Verify RRCReconfiguration for MN gNB3
    Verify BearerContextModificationRequest for SN gNB3
    Verify BearerContextModificationResponse for SN gNB3
    Verify BearerContextInactivityNotification for SN gNB3
    Verify PDUSessionResourceModifyIndication for MN gNB2

    Compare GTP tunnels at SN gNB3
    Verify sdap-Config for all DRBs

    Wait until keyword succeeds    5x    5s
    ...    Verify traffic on UE1
