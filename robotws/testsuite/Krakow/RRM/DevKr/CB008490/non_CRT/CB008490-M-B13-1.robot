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
...      - for security related
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
...      CB008490-SR-M-B1201 ICS optimized with A2 redirection support gNB blocks A2 A3 A5
...      CB008490-SR-M-B1202 ICS not optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1202 ICS not optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1301 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
...      CB008490-SR-M-B1302 Allowing mobility and A2 measurements for redirection during PDU Session Setup with MFBI when DU changes band to
...      alernative
...
...      For retry timer related handling:
...      CB008490-SR-M-B1701 A4retryTimer restart when no NRDC eligible PDU on UE
...      CB008490-SR-M-B1702 A4retryTimer restart blocked when CB008490 disabled
...      CB008490-SR-M-B1702 A4retryTimer restart blocked when proper NRADJNRCELL not found
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == TESTING SCOPE ==
...      CB008490-SR-M-B1301 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
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
...      [19.04.2024] - Create Test Suite
...      [24.04.2024] - Final shape of M-B13 Test Case
...      [24.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...
Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot
Resource    ../resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/../config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

${yaml_A2_redirection}=   ${CURDIR}/../config/yaml/A2_redirection.yaml
${A2_redirect_ssb_freq}=  633312

*** Test Cases ***
CB008490-SR-M-B1301 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the behavior when the gNB shall block A4 measurements and start A4 retryTimer for a FWA UE after successful
    ...  first PDU Session Resource Setup (after non-optimized Initial Context Setup without PDU Session) on a cell where NR-DC feature is enabled
    ...  and there is no NR-DC eligible PDU Session established for the UE. Additionally, the scenario checks that the gNB determines to block
    ...  A2/A3/A5 moblity measurements for FWA UE and does not block A2 for redirection measurements due to actRedirect flag enabled.
    ...
    ...  == PRECONDITION ==
    ...  - MN and SN gNB are configured as in CFAM CB008490-M Common Preconditions #1 5G_RAN_USR_RRM_23189 and #2 5G_RAN_USR_RRM_23190
    ...    with addition to:
    ...    - MN-NRBTS-2/NRCELL-1 simulated on AEQE radio module - NR_BAND: n78 (PCI-50)
    ...    - MN-NRBTS-2/NRCELL-2 simulated on AEQE radio module - NR_BAND: n78 (PCI-51)
    ...    - SN-NRBTS-3/NRCELL-3 simulated on EGATE - NR_BAND: n257 (PCI-52)
    ...    - Two FR1 cells (MN-NRBTS-2/NRCELL-1 and MN-NRBTS-2/NRCELL-2) are active in pure SA mode of operation:
    ...      - MN-NRBTS-2/NRCELL-1 has NR-DC enabled actNrDualConnectivity is set to inter-gNB_FR1-FR2
    ...      - MN-NRBTS-2/NRCELL-2 does not have NR-DC enabled actNrDualConnectivity is set to disabled
    ...    - One FR2 cell (SN-NRBTS-3/NRCELL-3) is active in pure NR-DC-SN mode of operation
    ...    - MN-NRBTS-2/actRedirect is set to true
    ...    - MN-NRBTS-2/NRCELL-1/NRREDRT-1 is configured
    ...    - MN-NRBTS-2/NRCELL-1/a2MeasRedirectEnabled is set to rsrp
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-1 (MN-gNB) with inter-gNB NR-DC setup with NRCELL-3 (SN-gNB)
    ...  - A2/A3/A5 measurements for mobility purposes are not activated for UE1
    ...  - A2 for redirection measurements are activated for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - sim gNB4 for inter-gNB handovers
    ...  - sim eNB1 for inter-RAT handovers
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23189,5G_RAN_USR_RRM_23190,5G_RAN_USR_RRM_23179,5G_RAN_USR_RRM_24312
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-M#B13 Not activate A3/A5/A2 on FWA UE during the first PDU Session Resource Setup Request
    ...
    ...  == HISTORY ==
    ...  [19.04.2024] - Create Test Case
    ...  [24.04.2024] - Final Test Case shape
    ...  [24.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)

    [Setup]  Prepare test environment CB008490-M-B12-B13

    Set indexToRFSP to 1 for UE1
    Set expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE1
    Attach UE1 to gNB2 cell1 with ICS without PDU session
    Verify expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify in UECapabilityEnquiry that message includes request for band:n78 and band:n257 for UE1

    Get occurence time of NGAP InitialContextSetup for AMF1

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE1
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE1

    Expect that A4 measurements are configured after adding first eligible PDU session for UE1
    Add to UE1 initial PDU session after ICS
    Verify that A4 measurements are configured after adding first eligible PDU session for UE1
    Verify that UEContextSetupRequest contains A2 measurements
    Verify that UEContextSetupRequest contains no A3,A5 measurements
    Verify that A2 measurements are configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A2 for redirection is configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE1 and verify if difference is equal 20s

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=3 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    [Teardown]  Basic cleanup sim SN
