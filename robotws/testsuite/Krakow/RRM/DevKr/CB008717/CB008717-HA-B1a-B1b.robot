*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This sub-feature introduces update to A4 retryTimer logic for FWA UEs.
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
...      [30.10.2023] - Create Test Suite
...      [06.11.2023] - Approved by EFS
...      [06.11.2023] - Review closed

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup  Run Setup  ute-ca=True  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-HA-B1a_B1b_A4retryTimer_in_non_opt_ICS_of_FWA_and_nonFWA_UE_no_NRDC_eligible_PDU
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the behavior when the gNB shall start A4 retryTimer for a FWA UE after successful attach on a cell
    ...  where NR-DC feature is enabled and there is no NR-DC eligible PDU Session established for the UE.
    ...  Two separate cases are included in the following scenario:
    ...  - verification that A4 retryTimer is started for the FWA UE1 after successful not-optimized Initial Context Setup with no NR-DC eligible
    ...    PDU Session established for the UE1. Additionally, the gNB restarts A4 retryTimer upon A4 retryTimer expiry when there is still no NR-DC
    ...    eligible PDU session established for the UE1. Then, after PDU Session Setup with NR-DC eligible PDU session and when time equal to A4
    ...    retryTimer value passes, the gNB successfully configures NR-DC A4 inter-frequency measurements for the UE1
    ...  - verification that A4 retryTimer is not started for the non-FWA UE2 after successful not-optimized Initial Context Setup with no NR-DC
    ...    eligible PDU Session established for the UE2. After PDU Session Setup with NR-DC eligible PDU session and when time equal to A4 retryTimer
    ...    value passes, the gNB does not configure NR-DC A4 inter-frequency measurements for the UE2
    ...
    ...  PRECONDITION:
    ...  - For real gNB-2 the same preconditions as in CB008717-D-B1c scenario with addition to:
    ...    - NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...    - NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...    - NRBTS/NRCELL-6 simulated on AWEUB radio module - NR_BAND: n261
    ...    - NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...    - Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation:
    ...      - NRBTS/NRCELL-1 does not have NR-DC enabled
    ...      - NRBTS/NRCELL-2 has NR-DC enabled
    ...    - Two FR2 cells (NRBTS/NRCELL-3 and NRBTS/NRCELL-6) are active in pure NR-DC-SN mode of operation with enabled NR-DC
    ...    - NRBTS/identifiedFwaUeList:
    ...      - 1: 87
    ...    - NRBTS/actRfspIndex is set to true
    ...    - NRBTS/NRCELL-2/a4RetryTimer is set to 10s
    ...    - NRBTS/NRDRB-18/resType is set to GBR
    ...  - UE-NR-Capability the same as in CB008717-D-B1c scenario with addition to:
    ...    - UE1:
    ...      - set indexToRFSP to 87 via amf_ue_ics_param egate command
    ...    - UE2:
    ...      - set indexToRFSP to 88 via amf_ue_ics_param egate command
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE2 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_21681
    ...       *BACKLOG ID: FCA_5G_L2L3-192189
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik   (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_RAN_USR_RRM_17415, 5G_RAN_USR_RRM_18584
    ...  CFAM link:       https://gates.nsn-net.net/view/000268d5#o=1370
    ...  FTS link:        https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
    ...                   Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
    ...                   wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-HA+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [30.10.23] - Create first Test Case shape
    ...  [06.11.23] - Final TC shape
    ...  [06.11.23] - Review closed

    [Tags]  HA-B1a-B1b

    [Setup]  Prepare test environment for HA-B1a-B1b

    # ------------ UE1 part - FWA UE, not optimized ICS ------------
    Prepare NrDc UE1 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow

    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE1
    Set expected messages flows to check UECapabilityEnquiry request for UE1, gNB2 and AMF1
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE1
    Trigger UE1 idle mode exit
    Verify that expected message flows for UECapabilityEnquiry request occured for UE1, gNB2 and AMF1
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n260,n261 for UE1
    Verify that A4 measurements are not configured for UE1, gNB2 and AMF1 in RRCReconfiguration message

    Get occurence time of RRCReconfiguration after ICS for UE1

    Expect that A4 measurements are not configured after retryTimer expiry for UE1
    Verify that A4 measurements are not configured after retryTimer expiry for UE1

    Expect that A4 measurements are configured after adding eligible PDU session for UE1
    Reset QoS Flow settings on SMF
    Add to UE1 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE1
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE1 and verify if difference is equal 20s

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2

#    # ------------ UE2 part - non-FWA UE, not optimized ICS ------------

    Prepare NrDc UE2 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow

    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE2
    Set expected messages flows to check UECapabilityEnquiry request for UE2, gNB2 and AMF1
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE2
    Set indexToRFSP to 88 for UE2
    Trigger UE2 idle mode exit
    Verify that expected message flows for UECapabilityEnquiry request occured for UE2, gNB2 and AMF1
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE2
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE2
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n260,n261 for UE2
    Verify that A4 measurements are not configured for UE2, gNB2 and AMF1 in RRCReconfiguration message

    Set expected messages flows to check that A4 measurements are not installed after NR-DC eligible PDU session setup for non FWA UE2
    Reset QoS Flow settings on SMF
    Add to UE2 second PDU session after ICS
    Verify expected messages flows to check that A4 measurements are not installed after NR-DC eligible PDU session setup for non FWA UE2

    Verify that A4 measurements are not configured for UE2, gNB2 and AMF1 in RRCReconfiguration message

    [Teardown]    Cleanup after test HA-B1a-B1b
