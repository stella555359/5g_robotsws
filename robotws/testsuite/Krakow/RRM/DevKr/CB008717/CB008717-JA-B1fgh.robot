*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This sub-feature introduces activation/deactivation of A4 based measurements due to PDU Session Management.
...
...      TEST SET NAME: CB008717-HA Update to retryTimer logic for FWA UEs
...
...      TESTING SCOPE:
...      CB008717-A NR-DC Cell Activation for a Secondary Node
...      CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...      CB008717-C UE Release due to AMF Context Release
...      CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...      CB008717-E UE Release without bearer takeback
...      CB008717-G Cell Management for Secondary Node
...      CB008717-H Configuration and Reception of A4 measurements
...      CB008717-HA Update to retryTimer logic for FWA UEs
...      CB008717-I Successful Measurement based PSCell Addition
...      CB008717-J Interaction with event A4
...      CB008717-M Mobilty on PCell
...
...      CONTACTS:
...      CFAM Leader        : Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/000268d5#o=1370
...                     FTS link:              https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
...                                            /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
...                                            ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-HA+Sub+feature+refinement
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [14.12.2023] - Create Test Suite
...      [21.12.23] - Approved by EFS

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup  Run Setup  ute-ca=True  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-JA-B1fgh_A4_measurement_configured_after_RRCReestablishment_via_RRCSetup
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the behavior of the gNB during RRC Re-establishment procedures when NR-DC feature is enabled.
    ...  Four separate cases are included in the following scenario:
    ...  - UE1 with NR-DC A4 measurements activated and a4Fr2SupervisionTimer running in RRC_CONNECTED state re-establishes successfully
    ...    to a selected cell (another cell in the same serving gnb-DU) via RRCSetup. In this case the gNB stops a4Fr2SupervisionTimer, does't start
    ...    a4RetryTimer and sends towards UE1 RRC: RRCSetup (new IDLE to CONNECTED transition). Subsequently Initial Context Setup with
    ...    NR-DC eligible PDU Session procedure is completed for UE1 and right after NR-DC A4 measurements are activated for UE1. [JA-B1f]
    ...  - UE2 with no NR-DC A4 measurements activated and a4retryTimer running (due to non-NR-DC eligible PDU Session is setup on UE2)
    ...    in RRC_CONNECTED state re-establishes successfully to a selected cell (another cell in the same serving gnb-DU) via RRCSetup. In this
    ...    case the gNB stops a4retryTimer and sends towards UE2 RRC: RRCSetup (new IDLE to CONNECTED transition). Subsequently Initial Context Setup
    ...    with non-NR-DC eligible PDU Session procedure is completed for UE2, A4 measurements are not installed and gNB starts new a4retryTimer.
    ...    Upon expiration of a4retryTimer gNB restarts a4retry timer. Then NR-DC eligible PDU Session is added while a4retryTimer is running
    ...    and upon expiration of it gNB shall setup NR-DC A4 measurements for UE2. [JA-B1g]
    ...  - Non-FWA UE3 with non-NR-DC eligible PDU Session setup in RRC_CONNECTED state re-establishes successfully to a selected cell (another cell
    ...    in the same serving gnb-DU) via RRCSetup. In this case the gNB sends towards UE3 RRC: RRCSetup (new IDLE to CONNECTED transition).
    ...    Subsequently Initial Context Setup with non-NR-DC eligible PDU Session procedure is completed for UE3, A4 measurements are not installed
    ...    and gNB doesn't start a4retryTimer due to non-FWA UE3. [JA-B1h]
    ...  - UE4 with no NR-DC A4 measurements activated and a4retryTimer running (due to non-NR-DC eligible PDU Session is setup on UE4)
    ...    in RRC_CONNECTED state re-establishes successfully to a serving cell via 'standard' RRCReestablishment. In this case the gNB stops
    ...    a4retryTimer and sends towards UE4 RRC: RRCReestablishment. Subsequently UE4 shall answer with RRCReestablishmentComplete to gNB,
    ...    A4 measurements are not installed and gNB starts new a4retryTimer. Upon expiration of a4retryTimer gNB restarts a4retry timer. Then
    ...    NR-DC eligible PDU Session is added while a4retryTimer is running and upon expiration of it gNB shall setup NR-DC A4 measurements for UE4.
    ...    [JA-B1h]
    ...
    ...  PRECONDITION:
    ...  - For real gNB-2 the same preconditions as in CB008717-D-B1c scenario with addition to:
    ...    - NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...    - NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...    - NRBTS/NRCELL-6 simulated on AWEUB radio module - NR_BAND: n261
    ...    - NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...    - Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation:
    ...      - NRBTS/NRCELL-1 has NR-DC enabled
    ...      - NRBTS/NRCELL-2 has NR-DC enabled
    ...    - Two FR2 cells (NRBTS/NRCELL-3 and NRBTS/NRCELL-6) are active in pure NR-DC-SN mode of operation with enabled NR-DC
    ...    - NRBTS/identifiedFwaUeList:
    ...      - 1: 87
    ...    - NRBTS/actRfspIndex is set to true
    ...    - NRBTS/NRCELL-1/a4RetryTimer is set to 10s
    ...    - NRBTS/NRCELL-2/a4Fr2SupervisionTimer is set to 6s
    ...    - NRBTS/NRCELL-1/a4RetryTimer is set to 10s
    ...    - NRBTS/NRCELL-2/a4Fr2SupervisionTimer is set to 6s
    ...    - NRBTS/NRDRB-18/resType is set to GBR
    ...  - UE-NR-Capability the same as in CB008717-D-B1c scenario with addition to:
    ...    - UE1, UE2, UE4:
    ...      - set indexToRFSP to 87 via amf_ue_ics_param egate command
    ...    - UE3:
    ...      - set indexToRFSP to 88 via amf_ue_ics_param egate command
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE2 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE3 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...  - UE4 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_21876, 5G_RAN_USR_RRM_21877
    ...       *BACKLOG ID: FCA_5G_L2L3-131753, FCA_5G_L2L3-198518
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik   (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_RAN_USR_RRM_21876, 5G_RAN_USR_RRM_21877
    ...  CFAM link:       https://gates.nsn-net.net/view/00025ee1#o=9503&hlt
    ...  FTS link:        https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
    ...                   Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
    ...                   wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-JA+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [14.12.23] - Create first Test Case shape
    ...  [21.12.23] - Final TC shape

    [Tags]  JA-B1fgh

    [Setup]  Prepare test environment for JA-B1fgh

    # ------------ UE1 part - FWA UE, re-establishment via RRCSetup when a4Fr2SupervisionTimer is running ------------

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Set expected message flow for reestablishment via RRCSetup with A4 measurements installation for UE1, AMF1
    UE1 sends RRC Reestablishment Request to NRCELL-2
    Verify expected message flow for reestablishment via RRCSetup with A4 measurements installation for UE1, AMF1
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Verify that RRCReconfiguration with A4 measurements is sent right after RRCReestablishment without starting a4RetryTimer for UE1

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-3 for gNB2

    # ------------ UE2 part - FWA UE, re-establishment via RRCSetup when a4RetryTimer is running, non-NR-DC eligible PDU session ------------

    Prepare NrDc UE2 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow on NRCELL-1
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE2
    Trigger UE2 idle mode exit
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE2
    Verify that A4 measurements are not configured for UE2, gNB2 and AMF1 in RRCReconfiguration message

    Set expected message flow for reestablishment via RRCSetup without A4 measurements installation for UE2, AMF1
    UE2 sends RRC Reestablishment Request to NRCELL-2
    Verify expected message flow for reestablishment via RRCSetup without A4 measurements installation for UE2, AMF1
    Verify that A4 measurements are not configured for UE2 in RRCReconfiguration message

    Get occurence time of RRCReestablishment for UE2

    Expect that A4 measurements are not configured after retryTimer expiry for UE2
    Verify that A4 measurements are not configured after retryTimer expiry for UE2

    Expect that A4 measurements are configured after adding eligible PDU session for UE2
    Reset QoS Flow settings on SMF
    Add to UE2 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE2
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE2 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE2 and verify if difference is equal 20s

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-3 for gNB2

# ------------ UE3 part - non-FWA UE, re-establishment via RRCSetup, non-NR-DC eligible PDU session ------------

    Prepare NrDc UE3 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow on NRCELL-1
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE3
    Trigger UE3 idle mode exit
    Set indexToRFSP to 88 for UE3
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE3
    Verify that A4 measurements are not configured for UE3, gNB2 and AMF1 in RRCReconfiguration message

    Set expected message flow for reestablishment via RRCSetup without A4 measurements installation for UE3, AMF1
    UE3 sends RRC Reestablishment Request to NRCELL-2
    Verify expected message flow for reestablishment via RRCSetup without A4 measurements installation for UE3, AMF1
    Verify that A4 measurements are not configured for UE3 in RRCReconfiguration message

    Expect that A4 measurements are not configured after retryTimer expiry for UE3
    Verify that A4 measurements are not configured after retryTimer expiry for UE3

    Set expected messages flows to check that A4 measurements are not installed after NR-DC eligible PDU session setup for non FWA UE3
    Reset QoS Flow settings on SMF
    Add to UE3 second PDU session after ICS
    Verify expected messages flows to check that A4 measurements are not installed after NR-DC eligible PDU session setup for non FWA UE3
    Verify that A4 measurements are not configured for UE3, gNB2 and AMF1 in RRCReconfiguration message

    Expect that A4 measurements are not configured after retryTimer expiry for UE3
    Verify that A4 measurements are not configured after retryTimer expiry for UE3

# ------------ UE4 part - FWA UE, re-establishment via RRCSetup to the same cell when a4RetryTimer is running, non-NR-DC eligible PDU session -------

    Configure    {'MOC': 'NRBTS', 'rrcReestabTypeSA': 'sameGNB'}

    Prepare NrDc UE4 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow on NRCELL-2
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE4
    Trigger UE4 idle mode exit
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE4
    Verify that A4 measurements are not configured for UE4, gNB2 and AMF1 in RRCReconfiguration message

    Set expected message flow for reestablishment without A4 measurements installation for UE4, AMF1
    UE4 sends RRC Reestablishment Request to NRCELL-2
    Verify expected message flow for reestablishment without A4 measurements installation for UE4, AMF1
    Verify that A4 measurements are not configured for UE4 in RRCReconfiguration message

    Get occurence time of RRCReestablishment for UE4

    Expect that A4 measurements are not configured after retryTimer expiry for UE4
    Verify that A4 measurements are not configured after retryTimer expiry for UE4

    Expect that A4 measurements are configured after adding eligible PDU session for UE4
    Reset QoS Flow settings on SMF
    Add to UE4 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE4
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE4 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE4 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE4 and verify if difference is equal 20s

    Set expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    UE4 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    Verify that UE4 was successfully configured NR-DC for NRCELL-3 for gNB2

    [Teardown]    Cleanup after test JA-B1fgh
