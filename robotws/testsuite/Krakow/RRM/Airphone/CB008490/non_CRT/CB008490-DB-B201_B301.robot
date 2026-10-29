*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature describes scenarios with sk-Counter incrementation and reset, unsuccesful PSCell Addition resulting in takeback.
...
...      == TEST SET NAME ==
...      CB008490-DB PSCell Addition (functionality requiring takeback)
...
...      == TESTING SPLIT ==
...      CB008490-DB#B101: sk-Counter incrementation and reset
...      CB008490-DB#B201: Unsuccessful inter-gNB NR-DC PSCell Addition in MN
...      CB008490-DB#B301: Unsuccessful inter-gNB NR-DC PSCell Addition in SN
...      CB008490-DB#B401: Concurrency handling in SN
...
...      == TESTING SCOPE ==
...      CB008490-DB#B201: Unsuccessful inter-gNB NR-DC PSCell Addition in MN
...      1. CB008490-SR-DB-B201_1 - Unsuccessful SNodeAddition due to timeout before XnAP SNodeAdditionRequestAcknowledge is received
...      2. CB008490-SR-DB-B201_2 - Successful SNodeAddition to different SN gNB after XnAP SNodeAdditionRequestAcknowledge not received
...      3. CB008490-SR-DB-B201_4 - AMF initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
...      4. CB008490-SR-DB-B201_6 - gNB initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
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
...         CB008490 CFAM
...
...      == HISTORY ==
...      [04.12.2024] - Create Test Suite
...      [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot
Resource    ../resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIO_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIO.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008490-SR-DB_B201_3_5_B301_1
    [Setup]  Prepare test environment CB008490-SR-DB_B201_3_5_B301_1

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Wait until PM counter files are ready and saved for gNBs

#   CB008490-SR-DB-B201_3 - AMF initiated UE release during SNodeAddition after XnAP SNodeAdditionRequestAcknowledge - MN side
#   CB008490-SR-DB-B301_1 - AMF initiated UE release during SNodeAddition after XnAP SNodeAdditionRequestAcknowledge - SN side
    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 2 seconds
    Set expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, MN gNB, UE1
    Set expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, SN gNB, UE1
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    sleep    1
    Release UE1 initiedted by AMF with Cause:NAS_normal_release
    Verify expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, MN gNB, UE1
    Verify expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, SN gNB, UE1
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:normal-release, gNB2

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Wait until PM counter files are ready and saved for gNBs

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify counter value on NRBTS-2 NRCELL-1 for M55125C09025 - NG_FLOW_REL_NORMAL_INSESSION equals 1
    ...    Verify counter value on NRBTS-2 NRCELL-1 for M55163C00013 - NG_FLOW_REL_NORM_INSESSN_PMQAP equals 1
    ...    Verify counter value on NRBTS-2 NRCELL-1 for M55125C00029 - NG_FLOW_REL_NOR_NRDC equals 0
    ...    Verify counter value on NRBTS-2 NRCELL-1 for M55125C00030 - NG_FLOW_REL_ABN_NRDC equals 0
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55125C00052 - NG_FLOW_REL_NRDC_NOR_INS equals 0
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55125C00053 - NG_FLOW_REL_NRDC_ABN_INS equals 0
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55125C00054 - NG_FLOW_REL_NRDC_A_UEL_I equals 0
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55163C00532 - NG_FLOW_REL_NRDC_NOR_INS_PMQAP equals 0
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55163C00533 - NG_FLOW_REL_NRDC_ABN_INS_PMQAP equals 0
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55163C00534 - NG_FLOW_REL_NRDC_A_UEL_I_PMQAP equals 0


#   CB008490-SR-DB-B201_5 - gNB initiated UE release during SNodeAddition after XnAP SNodeAdditionRequestAcknowledge - MN side
    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Run 30Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 2 seconds
    Set expected messages flows for canceled SNodeAddition after gNB initiated UE release before RRC Reconfiguration Complete, MN gNB, UE2
    Set expected messages flows for canceled SNodeAddition after gNB initiated UE release before RRC Reconfiguration Complete, SN gNB, UE2
    Trigger Radio Link Failure for UE2
    UE2 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for canceled SNodeAddition after gNB initiated UE release before RRC Reconfiguration Complete, MN gNB, UE2
    Verify expected messages flows for canceled SNodeAddition after gNB initiated UE release before RRC Reconfiguration Complete, SN gNB, UE2
    Verify that F1AP:UEContextModificationRequired contains cause:radioNetwork:rl-failure-others, gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:radio-connection-with-UE-lost, gNB2

    [Teardown]  CB008490-SR-DB_B201_3_5_B301_1 cleanup


*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Set expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, MN gNB, UE${ue_id:\d+}
    EXPECT FLOW[timeout=7]: gNB2 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=7]: gNB2 XNAP xnUAddressIndication
    EXPECT FLOW[timeout=7]: gNB2 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=7]: gNB2 XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=7]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=7]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=7]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=7]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=7]: gNB2 NGAP pDUSessionResourceModifyIndication

    EXPECT FLOW[timeout=7]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=7]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    EXPECT FLOW[timeout=7]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=7]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB2 E1AP bearerContextRelease

Verify expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, MN gNB, UE${ue_id:\d+}
    PASS FLOW[timeout=7]: gNB2 XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=7]: gNB2 XNAP xnUAddressIndication
    PASS FLOW[timeout=7]: gNB2 XNAP sNStatusTransfer
    FAIL FLOW[timeout=7]: gNB2 XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=7]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=7]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=7]: gNB2 E1AP 2*bearerContextModification
    FAIL FLOW[timeout=7]: gNB2 F1AP 2*uEContextModification
    FAIL FLOW[timeout=7]: gNB2 NGAP pDUSessionResourceModifyIndication

    PASS FLOW[timeout=7]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=7]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    PASS FLOW[timeout=7]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=7]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    PASS FLOW[timeout=7]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=7]: gNB2 E1AP bearerContextRelease

Set expected messages flows for canceled SNodeAddition after ${opt} initiated UE release before RRC Reconfiguration Complete, SN gNB, UE${ue_id:\d+}
    Log    ${opt}
    Log    ${ue_id}
    EXPECT FLOW[timeout=7]: gNB3 E1AP bearerContextSetup
    EXPECT FLOW[timeout=7]: gNB3 F1AP uEContextSetup
    EXPECT FLOW[timeout=7]: gNB3 E1AP bearerContextModification
    EXPECT FLOW[timeout=7]: gNB3 E1AP bearerContextInactivityNotification

    EXPECT FLOW[timeout=7]: gNB3 F1AP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB3 E1AP bearerContextRelease

Verify expected messages flows for canceled SNodeAddition after ${opt} initiated UE release before RRC Reconfiguration Complete, SN gNB, UE${ue_id}
    Log    ${opt}
    Log    ${ue_id}
    PASS FLOW[timeout=7]: gNB3 E1AP bearerContextSetup
    PASS FLOW[timeout=7]: gNB3 F1AP uEContextSetup
    PASS FLOW[timeout=7]: gNB3 E1AP bearerContextModification
    PASS FLOW[timeout=7]: gNB3 E1AP bearerContextInactivityNotification

    PASS FLOW[timeout=7]: gNB3 F1AP uEContextRelease
    PASS FLOW[timeout=7]: gNB3 E1AP bearerContextRelease

Set expected messages flows for canceled SNodeAddition after gNB initiated UE release before RRC Reconfiguration Complete, MN gNB, UE${ue_id:\d+}
    Set expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, MN gNB, UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModificationRequired

Verify expected messages flows for canceled SNodeAddition after gNB initiated UE release before RRC Reconfiguration Complete, MN gNB, UE${ue_id:\d+}
    Verify expected messages flows for canceled SNodeAddition after AMF initiated UE release before RRC Reconfiguration Complete, MN gNB, UE${ue_id}
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModificationRequired
