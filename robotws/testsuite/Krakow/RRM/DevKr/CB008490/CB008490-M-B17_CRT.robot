*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces mobility and non-basic measurements scenarios with inter-gNB NR-DC enabled:
...      - for incoming HO
...      - for ICS
...      - for retry timer related handling
...      - for IWK with RRC-Inactive
...
...      == TEST SET NAME ==
...      CB008490-M: Incoming mobility and non-basic measurement scenarios/legacy interactions
...
...      == TESTING SPLIT ==
...      For incoming HO:
...      CB008490-SR-M-B101 A2 MeasReport queued during PSCell Addition and during TakeBack
...      CB008490-SR-M-B102 Intra gNB HO with MFBI - mobillity measurements activated on UE when DU changed band to alternative
...
...      For ICS:
...      CB008490-SR-M-B1101 UE Cap Enquiry during not optimized ICS to cell with disabled NRDC
...      CB008490-SR-M-B1201 ICS optimized with non eligible PDU gNB blocks A3 A5 A2 for FWA
...      CB008490-SR-M-B1201 ICS not optimized with A2 redirection support gNB blocks A2 A3 A5
...      CB008490-SR-M-B1202 ICS optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1202 ICS optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1302 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
...
...      For retry timer related handling:
...      CB008490-SR-M-B1701 A4retryTimer restart when no NRDC eligible PDU on UE
...      CB008490-SR-M-B1702 A4 measurement configuration blocked when CB008490 disabled
...      CB008490-SR-M-B1702 A4 measurement configuration blocked when proper NRADJNRCELL not found
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == TESTING SCOPE ==
...      CB008490-SR-M-B1702 A4 measurement configuration blocked when CB008490 disabled
...      CB008490-SR-M-B1702 A4 measurement configuration blocked when proper NRADJNRCELL not found
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1260
...
...      == HISTORY ==
...      [15.04.2024] - Create Test Suite
...      [10.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup       Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

*** Test Cases ***
CB008490-SR-M-B1702 A4 measurement configuration blocked when CB008490 disabled or proper NRADJNRCELL not found
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior that A4 measurements activation and A4 retryTimer restart
    ...  are blocked when:
    ...    - NR-DC PSCell addition feature is disabled in PCell
    ...    - there is no NRHOIF configured on PCell for which NRHOIF.freqBandIndicator matches freqBandIndicator
    ...      of the associated NRADJNRCELL.
    ...
    ...  == PRECONDITION ==
    ...  - MN gNB and SN gNB configured according to CB008490-B common preconditions and CB008490-GA#B1. Additionally:
    ...     MN gNB:
    ...         NRHOIF-1: freqBandIndicatorNR=257, ssbFrequency=2071387
    ...         NRADJNRCELL-1 points to SN NRCELL-2
    ...         NRCELL-1.actCDRX = true
    ...  - SN gNB:
    ...         NRCELL-2: freqBandIndicatorNR=257, gscnOrSsPbchArfcn=22446 (2071387)
    ...  - UE1, UE2:
    ...         longDRX-Cycle: supported
    ...         measAndMobParameters/measAndMobParameters-Common/independentGapConfig is not present
    ...
    ...  == POSTCONDITION ==
    ...     A4 NR-DC measurements are not configured for UE1 and UE2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_24218
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-M#B17: Activate NR-DC inter-frequency A4 measurements when A4 retry timer expires - Exception#1
    ...
    ...  == HISTORY ==
    ...      [22.03.2024] - Create Test Suite
    ...      [10.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=908161)
    ...      [05.06.2024] - Merge M-B1702_1 and M-B1702_2 into one TC

    [Setup]    Prepare test environment CB008490-M-B1702

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for A4 measurement release and DRX configuration for UE1, MN gNB2
    Verify expected messages flows for A4 measurement release and DRX configuration for UE1, MN gNB2

    Expect that A4 measurements are not configured after retryTimer eq 60 expiry for UE1
    Deactivate CB008490 FAF on NRCELL-1
    Verify that A4 measurements are not configured after retryTimer eq 60 expiry for UE1

    Activate CB008490 FAF on NRCELL-1

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for A4 measurement release and DRX configuration for UE2, MN gNB2
    Verify expected messages flows for A4 measurement release and DRX configuration for UE2, MN gNB2

    Expect that A4 measurements are not configured after retryTimer eq 60 expiry for UE2
    Modify NRHOIF-1 ssbFrequency to 2071388
    Verify that A4 measurements are not configured after retryTimer eq 60 expiry for UE2

    [Teardown]  CB008490-M-B1702 cleanup
