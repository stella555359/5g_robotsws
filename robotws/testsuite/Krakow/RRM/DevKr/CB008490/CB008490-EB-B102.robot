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
...      CB008490-EB#B103 NG Partial Reset - AMF initiated  concurrency (SCT only)
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
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...      [26.08.2024] - Create Test Suite
...      [23.07.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=915535)
...

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=SN    sim_gNB=MN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n257_simMN.lua
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_3cells_n257_1xAWEUB_simMN.xml

*** Test Cases ***
CB008490-SR-EB-B102_SN_side_MN_simulated
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the SN gNB behaviour for UE with established inter-gNB NR-DC connection after receiving XnAP Reset Request.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-E User Scenarios (5G_RAN_USR_RRM_23633)
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_MN
    ...  - gNB classical BTS in SA mode as SN - gNB_SN
    ...  - gNB module SN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25646
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-EB#B1 - NG Full/Partial Reset - AMF initiated
    ...
    ...  == HISTORY ==
    ...  [26.08.2024] - Create Test Suite
    ...  [23.07.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=915535)

    [Setup]  Prepare test environment CB008490-EB-B102

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Add to UE1 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Set expected messages flows for SNodeAddition for SN gNB3
    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition for SN gNB3
    Send XNaP Reset Request from sim MN to SN gNB3 for UE1
    Detach and kill UE1

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Add to UE2 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Set expected messages flows for SNodeAddition for SN gNB3
    UE2 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition for SN gNB3

    Set expected messages flows for XN Reset for SN gNB3
    Send XNaP Reset Request from sim MN to SN gNB3 for UE2
    Verify expected messages flows for XN Reset for SN gNB3

    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that XNAP ResetRequest contains cause:transport:transport-resource-unavailable, gNB3
    Verify that resetRequest was send to the same UE as in SNodeAdditionRequest to SN gNB3
    Verify that E1AP Reset contains cause:transport:unspecified, gNB3
    Verify that F1AP Reset contains cause:transport:unspecified, gNB3

    [Teardown]  EB-102 cleanup
