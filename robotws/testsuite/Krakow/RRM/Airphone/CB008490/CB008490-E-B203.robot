*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE context release. UE should be transmit
...      from RRC-CONNECTED to RRC_IDLE state after procedure.
...
...      == TEST SET NAME ==
...      CB008490-E UE context release
...
...      == TESTING SPLIT ==
...      CB008490-E#B1 - UE Context Release - RRC Reestablishment
...      CB008490-E#B2 - UE Context Release - due to preemption
...      CB008490-E#B3 - UE Context Release - due to failure in AMF reselection
...      CB008490-E#B4 - UE Context Release - due to Xn-U Error (UP Error Indication from SN gNB-CU-UP to MN gNB-DU)
...
...      == TESTING SCOPE ==
...      CB008490-E#B2 - UE Context Release - due to preemption
...
...      == CONTACTS ==
...         - Maciej Madej <maciej.madej@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...         - Maciej Madej <maciej.madej@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...      [22.03.2024] - Create Test Suite
...      [25.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906037)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIO_3xsimSN_GMC.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257_simSN.xml


*** Test Cases ***
CB008490-E-B203_UE_Context_release_MN_exception_SNodeReleaseRequestAcknowledge_not_received
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior for transition of the UE with established inter-gNB NR-DC connection
    ...  (with established SN-terminated split bearer) to RRC IDLE triggered by preemption. This is exception1 case,
    ...  during procedure NGAP:UEContextReleaseCommand is not received from AMF. In the next step NGAP:ErrorIndication message occurred.
    ...
    ...  == PRECONDITION ==
    ...  - USR_RRM_23633 - Common text (Precondition) to all CB008490-E User Scenarios
    ...  - NRBTS.actUserPreemption = 'true'
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...  UE1 is in RRC-IDLE state
    ...  All resources related to UE1 are released successfully
    ...  UE2 is in ACTIVE state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB simulated BTS sim_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - *depending on AP deliveries possible TC will be executed with simulated_MN/SN at CRT stage
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23639
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Maciej Madej <maciej.madej@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-E#B2 - UE Context Release - due to preemption
    ...                     - Exception4: NRBTS.timerXnUeProcGuard expires and XnAP: SNodeReleaseRequestAcknowledge
    ...                       is not received by MN gNB-CU-CP
    ...  == HISTORY ==
    ...  [22.03.2024] - Create Test Suite
    ...  [25.04.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906037)

    [Setup]  Prepare test environment CB008490-E-B203

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Set expected message flows for UE1 Context Release without XNAP SNodeReleaseAcknowledge, MN gNB2 with AMF1
    Deregister UE1
    Verify expected message flows for UE1 Context Release without XNAP SNodeReleaseAcknowledge, MN gNB2 with AMF1

    Verify that XNAP:UeContextRelease contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:UeContextRelease contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains RRCContainer for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq 1 for MN gNB2
    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2

    [Teardown]  CB008490-E-B203 cleanup

