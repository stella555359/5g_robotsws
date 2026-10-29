*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature introduces handling of incorrect content of XnAP:SNodeAdditionRequestAcknowledge message
...      or errors on MN side during inter-gNB NR-DC setup.
...
...      == TEST SET NAME ==
...      CB008490-DA PSCell Addition (MN generic error cases)
...
...      == TESTING SPLIT ==
...      CB008490-DA#EC101 Handling of incorrect XnAP:SNodeAdditionRequestAcknowledge during the inter-gNB NR-DC PSCell Addition
...      CB008490-DA#EC201 timerRRCGuard timer expiry during the inter-gNB NR-DC PSCell Addition while waiting for RRC:RRCReconfigurationComplete
...      CB008490-DA#EC202 Errors related to NGAP:PDUSessionResourceModifyConfirm message during the inter-gNB NR-DC PSCell Addition
...
...      == TESTING SCOPE ==
...      CB008490-DA#EC101 Handling of incorrect XnAP:SNodeAdditionRequestAcknowledge during the inter-gNB NR-DC PSCell Addition
...      1. CB008490-SR-DA-EC101_1 Handling of incorrect SNodeAdditionRequestAcknowledge during the inter-gNB NR-DC PSCell Addition
...                                     - one SN candidate
...      2. CB008490-SR-DA-EC101_2 Handling of incorrect SNodeAdditionRequestAcknowledge during the inter-gNB NR-DC PSCell Addition
...                                     - two SN candidates
...      CB008490-DA#EC201 timerRRCGuard timer expiry during the inter-gNB NR-DC PSCell Addition while waiting for RRC:RRCReconfigurationComplete
...      3. CB008490-SR-DA-EC201 timerRRCGuard timer expiry during the inter-gNB NR-DC PSCell Addition
...      CB008490-DA#EC202 Errors related to NGAP:PDUSessionResourceModifyConfirm message during the inter-gNB NR-DC PSCell Addition
...      4. CB008490-SR-DA-EC202 Handling of incorrect PDUSessionResourceModifyConfirm during the inter-gNB NR-DC PSCell Addition
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
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=7258
...
...      == HISTORY ==
...      [03.09.2024] - Create Test Suite
...      [05.09.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=918957)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_3xsimSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257_simSN.xml
&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  3=52  4=53  5=54

*** Test Cases ***
CB008490-SR-DA PScell Addition failure
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Purpose of this test case is to verify gNB behaviour in PSCell Addition failure scenarios due to:
    ...  - incorrect XNAP:SNodeAdditionRequestAcknowledge message
    ...  - timerRRCGuard timeout
    ...  - incorrect NGAP:PDUSessionResourceModifyConfirm message
    ...
    ...  == PRECONDITION ==
    ...  - MN and SN gNB are configured as in CFAM CB008490-M Common Preconditions #1 5G_RAN_USR_RRM_23189 and #2 5G_RAN_USR_RRM_23190
    ...  - MN-NRBTS-2/NRCELL-1 simulated on AEQE radio module - NR_BAND: n78 (PCI-50) - NR-DC enabled
    ...  - SN gNB3 cell-3 simulated on EGATE - NR_BAND: n257 (PCI-52) - NR-DC-SN mode of operation
    ...  - SN gNB4 cell-4 simulated on EGATE - NR_BAND: n257 (PCI-53) - NR-DC-SN mode of operation
    ...  - UEs support DC-n78_n257 NR-DC band combination
    ...
    ...  == POSTCONDITION ==
    ...   - UE1 is in RRC-CONNECTED state with NRCELL-1, NR-DC is not configured
    ...   - UE2 is in RRC-CONNECTED state with NRCELL-1, gNB4 cell-4 is configured as PSCell
    ...   - UE3 and UE4 are released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - sim gNB4 in NR-DC-SN mode as SN
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25311; 5G_RAN_USR_RRM_25312
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-DA#EC1: Unsuccessful inter-gNB NR-DC PSCell Addition due to incorrect XnAP: SNodeAdditionRequestAcknowledge -
    ...                     main and ALT.1
    ...  CB008490-DA#EC2: Unsuccessful inter-gNB NR-DC PSCell Addition due to error at MN side after XnAP:SNodeAdditionRequestAcknowledge
    ...                     ALT.3 and ALT.5
    ...
    ...  == HISTORY ==
    ...  [03.09.2024] - Create Test Suite
    ...  [05.09.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=918957)

    [Setup]  Prepare test environment CB008490-DA

    # ================================ incorrect SNodeAdditionRequestAcknowledge ================================

    Configure sim SN gNB3 to send XNAP:SNodeAdditionRequestAcknowledge with mn-terminated container

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeRelease for SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeRelease for SN sim gNB3

    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB3

    Configure sim SN gNB3 to send correct XNAP:SNodeAdditionRequestAcknowledge message

     # ========================= incorrect first SNodeAdditionRequestAcknowledge ====================================

    Configure sim SN gNB3 to send XNAP:SNodeAdditionRequestAcknowledge without sn-terminated container

    Attach UE2 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for SNodeRelease for SN sim gNB3
    Set expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB4

    UE2 sends A4 measId=1 with CELL-3: rsrp1=85 rsrq1=31 and CELL-4: rsrp2=84 rsrq2=30

    Verify expected messages flows for SNodeRelease for SN sim gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB4

    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB3

    Configure sim SN gNB3 to send correct XNAP:SNodeAdditionRequestAcknowledge message

    # ================================ timerRRCGuard expiry ========================================================

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE3 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE3 and AMF1
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE3 and AMF1

    Setup delay before sending RRC:RRCReconfigurationComplete from UE3

    Set expected messages flows for PSCell Addition up to RRC:RRCReconfigurationComplete for UE3, MN gNB2
    Set expected messages flows for SNodeRelease for SN sim gNB3
    Set expected messages flows for UEContextRelease for UE3, MN gNB2

    UE3 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for PSCell Addition up to RRC:RRCReconfigurationComplete for UE3, MN gNB2
    Verify expected messages flows for SNodeRelease for SN sim gNB3
    Verify expected messages flows for UEContextRelease for UE3, MN gNB2

    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:radio-connection-with-UE-lost, gNB3
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:radio-connection-with-ue-lost for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:radioNetwork:radio-connection-with-ue-lost for MN AMF1
    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2
    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Check RTPM counter on bts_id=1: NRCELL-1 NG_FLOW_REL_NRDC_STP_BFR_RCNFG (M55125C00050) is equal 1

    Remove delay before sending RRC:RRCReconfigurationComplete from UE3

    # ============================ incorrect PDUSessionResourceModifyConfirm =========================================

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Configure AMF1 to send NGAP:PDUSessionResourceModifyConfirm with PDUSessionResourceFailedToModifyList for UE4

    Attach UE4 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE4 and AMF1
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE4 and AMF1

    Set expected messages flows for PSCell Addition with incorrect PDUSessionResourceModifyConfirm for UE4, MN gNB2
    Set expected messages flows for SNodeRelease for SN sim gNB3
    Set expected messages flows for UEContextRelease for UE4, MN gNB2

    UE4 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for PSCell Addition with incorrect PDUSessionResourceModifyConfirm for UE4, MN gNB2
    Verify expected messages flows for SNodeRelease for SN sim gNB3
    Verify expected messages flows for UEContextRelease for UE4, MN gNB2

    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB3
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:release-due-to-ngran-generated-reason for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:radioNetwork:release-due-to-ngran-generated-reason for MN AMF1
    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2
    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Check RTPM counter on bts_id=1: NRCELL-1 NG_FLOW_REL_NRDC_STP_AFT_RCNFG (M55125C00051) is equal 1

    Configure AMF1 to send NGAP:PDUSessionResourceModifyConfirm without PDUSessionResourceFailedToModifyList for UE4

    [Teardown]  DA cleanup

*** Keywords ***
Set expected messages flows for PSCell Addition up to RRC:RRCReconfigurationComplete for UE${ue_id}, MN gNB${mn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Verify expected messages flows for PSCell Addition up to RRC:RRCReconfigurationComplete for UE${ue_id}, MN gNB${mn_gnb_id}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Set expected messages flows for UEContextRelease for UE${ue_id}, MN gNB${mn_gnb_id}
    Log  Set expected message flow for UE${ue_id} relelase
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease

Verify expected messages flows for UEContextRelease for UE${ue_id}, MN gNB${mn_gnb_id}
    Log  Verify expected message flow for UE${ue_id} relelase
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease

Set expected messages flows for SNodeRelease for SN sim gNB${sn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP uEContextRelease

Verify expected messages flows for SNodeRelease for SN sim gNB${sn_gnb_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP uEContextRelease

Set expected messages flows for PSCell Addition with incorrect PDUSessionResourceModifyConfirm for UE${ue_id}, MN gNB${mn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

Verify expected messages flows for PSCell Addition with incorrect PDUSessionResourceModifyConfirm for UE${ue_id}, MN gNB${mn_gnb_id}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
