*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE bulk release.
...
...      == TEST SET NAME ==
...      CB008490-EB: Bulk UE release
...
...      == TESTING SPLIT ==
...      CB008490-EB#B101 NG Full/Partial Reset - AMF initiated - MN side
...      CB008490-EB#B102 XNAP: Reset Request reception - SN side
...      CB008490-EB#B103 NG Partial Reset - AMF initiated concurrency (SCT only)
...      CB008490-EB#B201 NG Full/Patrial Reset - gNB initiated - MN side
...      CB008490-EB#B202 XNAP: Reset Request sending from SN side
...      CB008490-EB#B301 Partial Reset - Dropped Xn link
...      CB008490-EB#B302 Pool Failure - SDL

...
...      == TESTING SCOPE ==
...      CB008490-EB: Bulk UE release
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
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...  [08.07.2024] - Create Test Suite
...  [23.07.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=915535)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_3xsimSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257_simSN.xml

*** Test Cases ***
CB008490-SR-EB-B101_MN_side_gNB_SNs_simulated_AMF_partial_reset
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour for UE with established inter-gNB NR-DC connection during
    ...  AMF initiated NG Partial Reset procedure to reset/re-initialize the NG interface. Scenario focuses on MN side.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-E User Scenarios (5G_RAN_USR_RRM_23633)
    ...  - UE1 with configured inter-gNB NR-DC in SN gNB#1
    ...  - UE2 with configured inter-gNB NR-DC in SN gNB#2
    ...  - SN gNB#3 has no established inter-gNB NR-DC connection with MN gNB
    ...  - MN gNB has NRBTS.rrcReestabTypeSA set to '1' - corresponding to support of RRC Reestablishment in gNB intra-DU
    ...
    ...  == POSTCONDITION ==
    ...  - NR-DC is established for UE1 and UE2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25646
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...    CB008490-EB#B1 NG Full/Partial Reset - AMF initiated
    ...
    ...  == HISTORY ==
    ...  [08.07.2024] - Create Test Suite
    ...  [23.07.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904095)

    [Setup]  Prepare test environment CB008490-EB-B101

    Log To Console    Debug EB-B101

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB4
    UE2 sends A4 measurement with id=1 and PCIs [53]
    Verify expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB4

    Set expected messages for UE1 NG link reset
    Reset NG link for UE1 by AMF1
    Verify expected messages for UE1 NG link reset

    Verify that NGAP NGReset ResetType contains 'partOfNG-Interface', gNB2
    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that XNAP ResetRequest contains cause:transport:transport-resource-unavailable, gNB3
    Verify that resetRequest was send to the same UE as in SNodeAdditionRequest to SN gNB3

    Set expected message flows for UE1 reestablishment via RRC Setup
    Execute egate command    cmd=amf_ue_ics_param id=1 ue=1 indexToRFSP=1
    Trigger UE1 reestablishment via RRC Setup
    Verify expected message flows for UE1 reestablishment via RRC Setup

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    [Teardown]  EB-B101 cleanup


CB008490-SR-EB-B201_MN_side_gNB_full_reset
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour for UE with established inter-gNB NR-DC connection during
    ...  gNB initiated NG Full Reset procedure to reset/re-initialize the NG interface. Scenario focuses on MN side.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-E User Scenarios (5G_RAN_USR_RRM_23633)
    ...  - UE1 with configured inter-gNB NR-DC in SN gNB#1
    ...  - UE2 with configured inter-gNB NR-DC in SN gNB#2
    ...  - SN gNB#3 has no established inter-gNB NR-DC connection with MN gNB
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 and UE2 are released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25650
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-EB#B2 NG Full/Partial Reset - gNB initiated

    ...
    ...  == HISTORY ==
    ...  [08.07.2024] - Create Test Suite
    ...  [23.07.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904095)

    [Setup]  Prepare test environment CB008490-EB-B201

    Log To Console    Debug EB-B201

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB4
    UE2 sends A4 measurement with id=1 and PCIs [53]
    Verify expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB4

    Set expected messages for F1 SCTP connection drop
    Drop F1 SCTP connection on MN gNB
    Verify expected messages for F1 SCTP connection drop

    Verify that NGAP NGReset contains cause:radioNetwork:release-due-to-ngran-generated-reason, gNB2
    Verify that both E1AP Reset messages contains cause:transport:unspecified, gNB2

    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that XNAP ResetRequest contains cause:transport:transport-resource-unavailable, gNB3
    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB4
    Verify that XNAP ResetRequest contains cause:transport:transport-resource-unavailable, gNB4

    Verify that resetRequest was send to the same UE as in SNodeAdditionRequest to SN gNB3
    Verify that resetRequest was send to the same UE as in SNodeAdditionRequest to SN gNB4

    [Teardown]  EB-B201 cleanup

*** Keywords ***
Set expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN real gNB${mn_gnb_id:\d+} and SN sim gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer

Verify expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN real gNB${mn_gnb_id:\d+} and SN sim gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer
