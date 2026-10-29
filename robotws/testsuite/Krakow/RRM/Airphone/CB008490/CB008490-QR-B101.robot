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
...      CB008490-SR-QR#B101 UE configured with NR-DC with the alternative band chosen for the PCell
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
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_QR_B101_MN.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

*** Test Cases ***
CB008490-QR-B101 Successful NR-DC Setup for a UE attached on alternative band of PCell and UE supporting native band of PSCell candidate
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Purpose of this test case is to verify that UE can successfully configure split bearer using alternative band on
    ...  MN gNB. PCell is configured with native and alternative band. NR-DC-SN cell is configured with native band only.
    ...  Test coveres A4 measurements configuration and NR-DC setup after:
    ...  - ICS when UE supports only PCell alternative band,
    ...  - XN HO when UE supports only alternative band of target cell,
    ...  - intra-gNB reestablishment when UE supports only alternative band of target cell,
    ...  - ICS when UE supports PCell native and alternative band, but indicates more MIMO layers for BC with alt band.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 is configured to support inter-gNB NR-DC Master Node role with one FR1 cell.
    ...     NRBTS/actMultiFrequencyBandIndicatorNRSupport = true
    ...     NRBTS/NRCONNECTMODE_PROFILE-1/multiFreqBandIndicatorNR[1] = 77
    ...     NRCELL-1/freqBandIndicatorNR = 78
    ...     NRCELL-1/nrConnectModeProfileDN -> NRCONNECTMODE_PROFILE-1
    ...
    ...  SN gNB3 is configured to support inter-gNB NR-DC Secondary Node role with FR2 cell operating on band n257.
    ...
    ...  UE4, UE13 and UE14 support band n77 and DC-n77_n257 band combination
    ...  UE5 supports bands: n77, n78 and band conbinations: DC-n77_n257, DC-n78_n257, but indicates more MIMO layers
    ...    for DC-n77_n257 BC
    ...
    ...  == POSTCONDITION ==
    ...   - UEs have NR-DC configured with PCell alternative band
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - sim gNB4 in SA mode for inter-gNB HO
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29016
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-QR#B1: Successful NR-DC Setup for a UE attached on alternative band of PCell and UE supporting native
    ...     band of PSCell candidate(s) - PCell only on MN gNB - main, ALT.2, ALT.3 and ALT.4
    ...
    ...  == HISTORY ==
    ...  [09.01.2025] - Create Test Suite
    ...  [20.02.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=926834)

    [Setup]  Prepare test environment CB008490-QR

    # ======================================== ICS ====================================================
    Attach UE4 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE4 and AMF1
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE4 and AMF1
    Verify that NRCELL-1 alternative band was configured for UE4

    Set expected messages flows for SNodeAddition for UE4, MN real gNB2 and SN sim gNB3
    UE4 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE4, MN real gNB2 and SN sim gNB3

    # ======================================== HO ====================================================
    Attach UE13 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Set expected messages flows to check A4 activation without DRX after HO for UE13
    Trigger UE13 XN HO to gNB2 NRCELL-1
    Verify expected messages flows to check A4 activation without DRX after HO for UE13
    Verify that A4 measurements are configured for UE13 in 2 out of 2 RRCReconfiguration message

    Set expected messages flows for SNodeAddition for UE13, MN real gNB2 and SN sim gNB3
    UE13 sends A4 measurement with id=7 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE13, MN real gNB2 and SN sim gNB3

    # ================================ reestablishment ========================================================
    Attach UE14 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE14 and AMF1
    Add to UE14 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE14 and AMF1
    Verify that NRCELL-1 alternative band was configured for UE14

    Set expected messages flows to check A4 activation without DRX after reestablishment for UE14
    Trigger reestablishment for UE14 to gNB2 NRCELL-1
    Verify expected messages flows to check A4 activation without DRX after reestablishment for UE14
    Verify that A4 measurements are configured for UE14 in 2 out of 2 RRCReconfiguration message

    Set expected messages flows for SNodeAddition for UE14, MN real gNB2 and SN sim gNB3
    UE14 sends A4 measurement with id=2 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE14, MN real gNB2 and SN sim gNB3

    # ================================ alt more MIMO layers ========================================================
    Attach UE5 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE5 and AMF1
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE5 and AMF1
    Verify that NRCELL-1 alternative band was configured for UE5

    Set expected messages flows for SNodeAddition for UE5, MN real gNB2 and SN sim gNB3
    UE5 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE5, MN real gNB2 and SN sim gNB3

    [Teardown]  Basic cleanup sim SN

*** Keywords ***
Verify that NRCELL-1 alternative band was configured for UE${ue_id}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measObjectToAddModList contains (freqBandIndicatorNR eq 77)
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias}
