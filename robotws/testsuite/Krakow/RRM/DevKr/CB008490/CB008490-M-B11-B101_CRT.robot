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
...      CB008490-SR-M-B1101 UE Cap Enquiry during not optimized ICS to cell with disabled NRDC
...      CB008490-SR-M-B101 A2 MeasReport queued during PSCell Addition and during TakeBack
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1260
...
...      == HISTORY ==
...      M-B1101:
...      [04.04.2024] - Create Test Suite
...      [16.04.2024] - Final shape of M-B11 Test Case
...      [16.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...      M-B101:
...      [15.04.2024] - Create Test Suite
...      [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN_multiUE.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

${yaml_A2_redirection}=   ${CURDIR}/config/yaml/A2_redirection.yaml
${A2_redirect_ssb_freq}=  633312

*** Test Cases ***
CB008490-SR-M-B11-B101 UE Cap Enquiry during not optimized ICS to cell with disabled NRDC
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior that:
    ...   - UE capability for NR-DC support should be enquired during not optimized Initial Context Setup if at least
    ...    one cell in gNB is identified as NR-DC PCell. UE attach is performed on a cell with NR-DC disabled. Additionally,
    ...    the scenario checks that after intra-gNB handover to another PCell all stored UE capabilities are delivered.
    ...   - A2 measurements for redirection are not blocked for FWA UEs during intra-gNB intra-DU HO. A2 measurements are
    ...    not removed when NR-DC A4 measurements are activated. Additionally A2 measurement report is queued when send
    ...    during PSCell Addition procedure and blind UE redirection is performed after NR-DC setup.
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
    ...
    ...  == POSTCONDITION ==
    ...  - UE7 is in RRC-IDLE state
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23189, 5G_RAN_USR_RRM_23190, 5G_RAN_USR_RRM_23179, 5G_RAN_USR_RRM_24311
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
    ...  CB008490-M#B11 UE Capability Enquiring about NR-DC support for all cells in gNB during not optimized ICS
    ...
    ...  == HISTORY ==
    ...  M-B1101:
    ...  [04.04.2024] - Create Test Suite
    ...  [16.04.2024] - Final shape of M-B11 Test Case
    ...  [16.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
    ...  M-B101:
    ...  [15.04.2024] - Create Test Suite
    ...  [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
    ...  [07.08.2025] - CNI-144225 - added backgorund UEs with real capabilities

    [Setup]  Prepare test environment CB008490-M-B11

    Attach background UEs 21-50 and start traffic

    Attach UE7 without ICS to MN gNB2 NRCELL-2

    Set expected messages flows to check UECapabilityEnquiry request for UE7
    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE7
    Add to UE7 initial PDU session with ICS and indexToRFSP equal 1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE7
    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE7

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE7
    Verify in UECapabilityEnquiry that message includes request for band:n78 and band:n257 for UE7

    Verify that A2,A3,A5 measurements are configured for UE7 in RRCReconfiguration message
    Verify that A4 measurements are not configured for UE7 in RRCReconfiguration message

    Run 10Mbps UL and DL traffic on UE7 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows to check UECapabilityEnquiry request did not occure for UE7
    Set expected messages flows to check A4 activation without DRX after HO for UE7
    Trigger intra-gNB inter-cell HO to NRCELL-1 for UE7
    Verify that expected message flows for UECapabilityEnquiry request did not occure for UE7
    Verify expected messages flows to check A4 activation without DRX after HO for UE7

    Verify that A2 for redirection is configured for UE7 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are deactivated in 1 out of 2 RRCReconfiguration message for UE7
    Verify that A4 measurements are configured for UE7 in 2 out of 2 RRCReconfiguration message
    Verify that A2 measurements are not deactivated for UE7 in 2 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE7 in 2 out of 2 RRCReconfiguration message

    Set expected messages flows for SNodeAddition for UE7, MN real gNB2 and SN sim gNB3
    UE7 sends A4 measurement with id=5 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE7, MN real gNB2 and SN sim gNB3
    Verify in RRCReconfiguration that sk-Counter is set to 0 for UE7

    Attach background UEs 51-60 and start traffic

    Set expected message flows for UE7 Context Release due to redirection, MN gNB2 with AMF1
    UE7 sends A2 measurement with id=4 for redirection
    Verify expected message flows for UE7 Context Release due to redirection, MN gNB2 with AMF1
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:redirection for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:radioNetwork:redirection for MN AMF1

    [Teardown]  Basic cleanup sim SN


*** Keywords ***
Attach background UEs ${start_ue}-${end_ue} and start traffic
    ${end_ue}    Evaluate    ${end_ue} + 1
    FOR   ${ue}   IN RANGE    ${start_ue}    ${end_ue}
        ${ue}    Convert to String    ${ue}
        Attach UE${ue} to gNB2 cell1 with ICS and PDU session setup after ICS
        Run 5Mbps UL and DL traffic on UE${ue} PDU1 QFI1 and wait 1 seconds
    END
    sleep    5
