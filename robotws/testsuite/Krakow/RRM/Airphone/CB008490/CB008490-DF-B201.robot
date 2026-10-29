*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces RAN sharing/slicing in inter-gNB NR-DC cases.
...
...      == TEST SET NAME ==
...      CB008490-DF PSCell Addition (RAN sharing/slicing)
...
...      == TESTING SPLIT ==
...      CB008490-DF#B101 - NR-DC A4 measurements configuration with PLMN check
...      CB008490-DF#B201 - NR-DC A4 measurements handling - PLMN validation
...      CB008490-DF#B301 - SN side PLMN and SNSSAI validation
...      CB008490-DF#B401 - Dynamic Add/Remove Cell
...      CB008490-DF#B501 - Interaction with Graceful handling
...
...      == TESTING SCOPE ==
...      CB008490-DF#B201 - NR-DC A4 measurements handling - PLMN validation
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1919
...
...      == HISTORY ==
...      [19.11.2024] - Create Test Suite
...      [02.12.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=923873)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n77_n261_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_DF_B201_MN.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_DF_B201_SN.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_3cells_n257_1xAWEUB.xml
&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=52  3=53  4=54

*** Test Cases ***
CB008490-DF-B201 Removing of a cell from PSCell candidate - PLMN not supported at SN
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes S-Node Addition procedure upon reception of A4 Measurement Report for two
    ...  adjacent cells operating at the same frequency but leased by different operators.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 belonging to global PLMN#1 is configured to support inter-gNB NR-DC Master Node role with one FR1 cell
    ...  shared between two operators.
    ...  NRPLMN-1 -> PLMN#1
    ...  NRPLMN-2 -> PLMN#2
    ...  TRACKINGAREA-1
    ...     fiveGsTac = 1
    ...     snssaiList -> SNSSAI-1
    ...  SNSSAI-1
    ...     sst = 1
    ...     nrPlmnDnList -> NRPLMN-1, NRPLMN-2
    ...  NRCELL-1 (n78):
    ...     NRPLMNSET_SA-1
    ...         trackingAreaDN -> TRACKINGAREA-1
    ...         nrPlmnList -> NRPLMN-1, NRPLMN-2
    ...  NRADJNRCELL-1 -> SN_Cell-1
    ...  NRADJNRCELL-2 -> SN_Cell-2
    ...
    ...  SN gNB3 belonging to global PLMN#1 is configured to support inter-gNB NR-DC Secondary Node role with two
    ...  separate FR2 cells, each used by different operator.
    ...  NRPLMN-1 -> PLMN#1
    ...  NRPLMN-2 -> PLMN#2
    ...  TRACKINGAREA-1
    ...     fiveGsTac = 1
    ...     snssaiList -> SNSSAI-1
    ...  TRACKINGAREA-2
    ...     fiveGsTac = 2
    ...     snssaiList -> SNSSAI-1
    ...  SNSSAI-1
    ...     sst = 1
    ...     nrPlmnDnList -> NRPLMN-1, NRPLMN-2
    ...  SN_Cell-1 (n257, freqFR2#1):
    ...     NRPLMNSET_SA-1
    ...         trackingAreaDN -> TRACKINGAREA-1
    ...         nrPlmnList -> NRPLMN-1
    ...  SN_Cell-2 (n257, freqFR2#1):
    ...     NRPLMNSET_SA-1
    ...         trackingAreaDN -> TRACKINGAREA-2
    ...         nrPlmnList -> NRPLMN-2
    ...
    ...  For both gNBs:
    ...  NRBTS/actRanSharing = true
    ...  NRBTS/actSliceNumExt = false
    ...
    ...  UEs support MN and SN band combination for NR-DC in capabilities.
    ...  UEs selected PLMN is PLMN#1.
    ...  Xn link between MN and SN is established.
    ...
    ...  == POSTCONDITION ==
    ...  UE1 is in RRC-CONNECTED state on NRCELL-1 (MN-gNB) with NR-DC configured (SN_Cell-1)
    ...  UE2 is in RRC-CONNECTED state on NRCELL-1 (MN-gNB) with A4 measurements configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25900
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DF#B4: Removing of a cell from PSCell candidate set after reception of A4 Measurement Report
    ...                     due to PLMN not supported at SN - main and ALT#1
    ...
    ...  == HISTORY ==
    ...  [19.11.2024] - Create Test Suite
    ...  [02.12.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=923873)

    [Setup]    Basic prepare

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measId=1 with CELL-3: rsrp1=85 rsrq1=31 and CELL-2: rsrp2=84 rsrq2=30

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3
    Verify in SNodeAdditionRequest that candidateCellInfoListMN has 1 element, pci: 52 for SN gNB3

    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected failed messages flows for SNodeAddition for SN gNB3
    Set expected failed messages flows for SNodeAddition for MN gNB2

    UE2 sends A4 measurement with id=1 and PCIs [53]

    Verify messages for SNodeAddition did not occur for SN gNB3
    Verify messages for SNodeAddition did not occur for MN gNB2

    [Teardown]    Basic cleanup

*** Keywords ***
Set expected failed messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextInactivityNotification

Set expected failed messages flows for SNodeAddition for MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=3]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=3]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=3]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

Verify messages for SNodeAddition did not occur for SN gNB${sn_gnb_id:\d+}
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextSetup
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} F1AP uEContextSetup
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNStatusTransfer
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextModification
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextInactivityNotification

Verify messages for SNodeAddition did not occur for MN gNB${mn_gnb_id:\d+}
    FAIL FLOW[timeout=3]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    FAIL FLOW[timeout=3]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    FAIL FLOW[timeout=3]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
