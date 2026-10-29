*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature introduces support for MFBI in MN.
...
...      == TEST SET NAME ==
...      CB008490-QR: Support MFBI in MCG
...
...      == TESTING SPLIT ==
...      CB008490-SR-QR#B101 UE configured with NR-DC with the alternative band chosen for the PCell
...      CB008490-SR-QR#B201 FR1 CA established with alternative PCell band is released when UE enters NR-DC with
...                     alternative PCell band
...      CB008490-SR-QR#B301 Alternative band not allowed for the FR2 PSCell for the UE in NR-DC
...
...      == TESTING SCOPE ==
...      CB008490-SR-QR#B201 FR1 CA established with alternative PCell band is released when UE enters NR-DC with
...                     alternative PCell band
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=7258
...
...      == HISTORY ==
...         [09.01.2025] - Create Test Suite
...         [20.02.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=926834)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_n26_n261_TDD_FDD_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_QR_B201.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_2cells_n26.xml


*** Test Cases ***
CB008490-QR-B201 Successful NR-DC Setup with PCell alternative band after blind SCell Addition
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Purpose of this test case is to verify successful NR-DC setup with alternative band on MN gNB when
    ...  UE has Carrier Aggregation configured.
    ...  UE is configured with PCell's and SCell's alternative band due to UE CA capabilities. After NR-DC A4
    ...  measurement report, SCell is released and PSCell Addition is completed.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 is configured to support inter-gNB NR-DC Master Node role with two FR1 cells.
    ...     NRBTS/actMultiFrequencyBandIndicatorNRSupport = true
    ...     NRBTS/NRCONNECTMODE_PROFILE-1/multiFreqBandIndicatorNR[1] = 5
    ...     NRCELL-1/freqBandIndicatorNR = 26
    ...     NRCELL-1/nrConnectModeProfileDN -> NRCONNECTMODE_PROFILE-1
    ...     NRCELL-2/freqBandIndicatorNR = 26
    ...     NRCELL-2/nrConnectModeProfileDN -> NRCONNECTMODE_PROFILE-1
    ...
    ...  SN gNB3 is configured to support inter-gNB NR-DC Secondary Node role with FR2 cell operating on band n261.
    ...
    ...  UE supports bands: n5,n26,n261 and band combinations: CA_n5(2A), DC_n5A_n261A
    ...
    ...  == POSTCONDITION ==
    ...   - UE is configured with NR-DC with alternative PCell band - n5 and n261 on SN gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29013
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-QR#B2: Successful NR-DC Setup for a UE attached on alternative band of PCell and supporting native
    ...     band for PSCell candidate(s) - PCell and FR1 SCell on MN gNB
    ...
    ...  == HISTORY ==
    ...  [09.01.2025] - Create Test Suite
    ...  [20.02.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=926834)

    [Setup]  Prepare test environment CB008490-QR-B201

    Attach UE1 without ICS to MN gNB2 NRCELL-3
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Set expected messages flows for SCell addition for UE1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Verify expected messages flows for SCell addition for UE1
    Verify that NRCELL-3 alternative band was configured for UE1
    Verify that NRCELL-4 alternative band was configured as SCell for UE1

    Set expected messages flows for SCell release for UE1
    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SCell release for UE1
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    [Teardown]  Basic cleanup sim SN

*** Keywords ***
Set expected messages flows for SCell addition for UE${ue_id}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Verify expected messages flows for SCell addition for UE${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Verify that NRCELL-3 alternative band was configured for UE${ue_id}
    ${flow_alias}=     Get flow name
    ...     3*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measObjectToAddModList contains (freqBandIndicatorNR eq 5)
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias}

Set expected messages flows for SCell release for UE${ue_id}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Verify expected messages flows for SCell release for UE${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     sCellToReleaseList is present
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias}
