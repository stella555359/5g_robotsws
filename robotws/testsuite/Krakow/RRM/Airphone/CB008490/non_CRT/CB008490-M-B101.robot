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
...      CB008490-SR-M-B1201 ICS not optimized with A2 redirection support gNB blocks A2 A3 A5
...      CB008490-SR-M-B1202 ICS optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1202 ICS optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1302 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
...
...      For retry timer related handling:
...      CB008490-SR-M-B1701 A4retryTimer restart when no NRDC eligible PDU on UE
...      CB008490-SR-M-B1701 A4retryTimer restart blocked when CB008490 disabled or proper NRADJNRCELL not found
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == TESTING SCOPE ==
...      CB008490-SR-M-B101 A2 MeasReport queued during PSCell Addition and during TakeBack
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
...      [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
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
CB008490-SR-M-B101 A2 MeasReport queued during PSCell Addition and during TakeBack
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior that A2 measurements for redirection are not blocked for FWA UEs
    ...  during intra-gNB intra-DU HO. A2 measurements are not removed when NR-DC A4 measurements are activated.
    ...  Additionally A2 measurement report is queued when send during PSCell Addition procedure and blind UE redirection
    ...  is performed after NR-DC setup.
    ...
    ...  == PRECONDITION ==
    ...  - MN source and target cells (NRCELL-2 and NRCELL-1) are configured as in CFAM CB008490-M Common Preconditions #1.
    ...  - MN target cell NRCELL-1 is configured additionally as in CFAM CB008490-M Common Preconditions #2.
    ...  In addition:
    ...  Two FR1 cells (MN-NRBTS-2/NRCELL-1 and MN-NRBTS-2/NRCELL-2) are active in pure SA mode of operation:
    ...    MN-NRBTS-2/NRCELL-1 has NR-DC enabled
    ...         actNrDualConnectivity is set to inter-gNB_FR1-FR2
    ...    MN-NRBTS-2/NRCELL-2 does not have NR-DC enabled
    ...         actNrDualConnectivity is set to disabled
    ...    NRBTS-2.actRedirect  = true (5GC000708)
    ...
    ...  == POSTCONDITION ==
    ...     UE1 is in RRC-IDLE
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23178
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-M#B1 Activate inter-frequency A4 measurements for NR-DC PSCell Addition after intra-gNB intra-DU
    ...         Handover for NR-DC setup (excluding intra-DU intra-Cell handover) - ALT6
    ...
    ...  == HISTORY ==
    ...      [15.04.2024] - Create Test Suite
    ...      [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)

    [Setup]    Prepare test environment CB008490-M-B101

    Attach UE1 without ICS to MN gNB2 NRCELL-2
    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE1

    Set expected messages flows to check A4 activation without DRX after HO for UE1
    Trigger intra-gNB inter-cell HO to NRCELL-1 for UE1
    Verify expected messages flows to check A4 activation without DRX after HO for UE1

    Verify that A2 for redirection is configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are deactivated in 1 out of 4 UEContextModificationRequest message
    Verify that A2,A3,A5 measurements are deactivated for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message
    Verify that A2 measurements are not deactivated for UE1 in 2 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 2 out of 2 RRCReconfiguration message

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=5 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Verify in RRCReconfiguration that sk-Counter is set to 0 for UE1

    Set expected message flows for UE1 Context Release due to redirection, MN gNB2 with AMF1
    UE1 sends A2 measurement with id=4 for redirection
    Verify expected message flows for UE1 Context Release due to redirection, MN gNB2 with AMF1
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:redirection for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:radioNetwork:redirection for MN AMF1

    [Teardown]  Basic cleanup sim SN
