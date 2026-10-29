*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE context release. UE should be transmitted from RRC-CONNECTED
...      to RRC_IDLE state after procedure.
...
...      == TEST SET NAME ==
...      CB008490-E: UE Context Release
...
...      == TESTING SPLIT ==
...      CB008490-E#B1 - UE Context Release - RRC Reestablishment
...      CB008490-E#B2 - UE Context Release - due to preemption
...      CB008490-E#B3 - UE Context Release - due to failure in AMF reselection
...      CB008490-E#B4 - UE Context Release - due to Xn-U Error (UP Error Indication from SN gNB-CU-UP to MN gNB-DU)
...
...      == TESTING SCOPE ==
...      CB008490-E#B4 - UE Context Release - due to Xn-U Error (UP Error Indication from SN gNB-CU-UP to MN gNB-DU)
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/00025ee1#o=9047
...
...      == HISTORY ==
...      [29.03.2024] - Create Test Suite
...      [TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904095))
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257_simSN.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008490-E-B4_UE_Context_release_Xn-U_Error
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour for the successful transition of UE with established inter gNB NR-DC connection
    ...  (with established SN-terminated split bearer) to RRC IDLE triggered by Xn-U GTP-U error for UL data indicated by MN gNB-DU.
    ...
    ...  == PRECONDITION ==
    ...  - USR_RRM_23633 - Common text (Precondition) to all CB008490-E User Scenarios
    ...  - Attach UE1 to SA cell in MN gNB and start DL/UL data transfer
    ...  - UE1 has inter-gNB NRDC connection established with SN gNB
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 is in RRC-IDLE state
    ...  - XnAP interface connection for the inter-gNB NR-DC UE is removed
    ...  - All resources related to UE1 are released successfully
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23633, 5G_RAN_USR_RRM_23687
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Michal Szymakowski    <michal.szymakowski@nokia.com>
    ...     - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-E#B4 - UE Context Release - due to Xn-U Error (UP Error Indication from SN gNB-CU-UP to MN gNB-DU)
    ...
    ...  == HISTORY ==
    ...  [29.03.2024] - Create Test Suite
    ...  [TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904095)

    [Setup]  Prepare test environment CB008490-E-B4

    Log To Console    Debug E-B4

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved for NRBTS-2

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Set expected message flows for UE1 Release due to GTP-U Error, MN real gNB2 and SN sim gNB3
    Trigger GTP-U Error for UE1, pdu=1, qfi=1 from gNB3
    Verify expected message flows for UE1 Release due to GTP-U Error, MN real gNB2 and SN sim gNB3

    Verify that F1AP:UEContextModificationRequired contains cause:transport:transport-resource-unavailable, gNB2

    Verify that NGAP:UEContextReleaseRequest contains cause:transport:unspecified for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:transport:unspecified for MN AMF1

    Verify that XNAP SNodeReleaseRequest contains cause:transport:unspecified, gNB2

    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains RRCContainer for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq 1 for MN gNB2

    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2
    Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo with dRB-ID eq 4 for gNB2

    Attach UE2 without ICS to MN gNB2 NRCELL-1
    Attach UE3 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for PDU session and A4 measurement configuration for UE3 and AMF1
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE3 and AMF1

    Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds
    Run 10Mbps UL and DL traffic on UE3 PDU1 QFI1 and wait 5 seconds

    Detach and kill UE2
    Deregister UE3

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved for NRBTS-2

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C00030 - NG_FLOW_REL_ABN_NRDC equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C00029 - NG_FLOW_REL_NOR_NRDC equals 0
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55116C00055 - IE_NRDC_MN_CU_REL_REQ equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C09025 - NG_FLOW_REL_NORMAL_INSESSION equals 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55163C00013 - NG_FLOW_REL_NORM_INSESSN_PMQAP equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C09026 - NG_FLOW_REL_ABNORMAL_INSESSION equals 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55163C00014 - NG_FLOW_REL_ABNRM_INSESN_PMQAP equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55350C00022 - NG_FLOW_IN_SESSION_DUR is above 1000

    [Teardown]  E-B4 cleanup
