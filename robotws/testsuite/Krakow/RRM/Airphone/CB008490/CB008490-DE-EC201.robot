*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature is related to SN generic error cases during SNodeAddition.
...
...      == TEST SET NAME ==
...      CB008490-DE PSCell Addition (SN generic error cases)
...
...      == TESTING SPLIT ==
...      -CB008490-DE#EC201: Unsuccessful inter-gNB NR-DC PSCell Addition on SN due to problems resulting
...      with XnAP: SNodeAdditionReject
...      -CB008490-DE#EC202: Unsuccessful inter-gNB NR-DC PSCell Addition on SN due to incorrect Bearer Context Setup
...      procedure response on E1AP interface (SCT only)
...      -CB008490-DE#EC203: Unsuccessful inter-gNB NR-DC PSCell Addition on SN due to incorrect UE Context Setup
...      procedure response on F1AP interface (SCT only)
...      -CB008490-DE#EC204: Concurrency Handling: XNAP: Snode Release Request reception on SN during ongoing PScell
...      Addition procedure (SCT only)

...
...      == TESTING SCOPE ==
...      CB008490-DE#EC201: Unsuccessful inter-gNB NR-DC PSCell Addition on SN due to problems resulting with XnAP: SNodeAdditionReject
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/00025ee1#o=9047
...
...      == HISTORY ==
...      [11.09.2024] - Create Test Suite
...      [11.09.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=918675)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=SN    sim_gNB=MN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n257_simMN.lua
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_3cells_n257_1xAWEUB_simMN.xml

*** Test Cases ***
CB008490-SR-DE-EC201 Unexpected content of SNodeAdditionRequest – SN side
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour for UE during unsuccessful SNodeAddition procedure due to
    ...  unexpected content in XNAP: SNodeAdditionRequest on SN side.
    ...
    ...  == PRECONDITION ==
    ...  - UE1 is connected to MN gNB and NRDC A4 measurement for PSCell candidate is configured at UE side
    ...
    ...  == POSTCONDITION ==
    ...  - SN terminated Split Bearer Addition procedure is cancelled.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_MN
    ...  - gNB classical BTS in SA mode as SN - gNB_SN
    ...  - gNB module SN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25304
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-DE#EC201: Unsuccessful inter-gNB NR-DC PSCell Addition on SN due to problems resulting with XnAP: SNodeAdditionReject
    ...
    ...  == HISTORY ==
    ...  [11.09.2024] - Create Test Suite
    ...  [11.09.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=918675)

    [Setup]  Prepare test environment CB008490-DE-EC201

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Add to UE1 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Set expected messages flows for failed SNodeAddition for SN gNB3
    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for failed SNodeAddition for SN gNB3

    Verify that SNodeAdditionRequest does not contain AvailableDrbIds for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:unspecified for SN gNB3

    [Teardown]  DE-EC201 cleanup
