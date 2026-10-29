*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This subfeature introduces activation/deactivation of A4 based measurements and A4 retryTimer
...                    due to RRC Re-establishment to a different or the same cell for FWA UE.
...
...      TEST SET NAME: CB008717-J Interaction with event A4
...
...      TESTING SCOPE:
...      CB008717-A NR-DC Cell Activation for a Secondary Node
...      CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...      CB008717-C UE Release due to AMF Context Release
...      CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...      CB008717-E UE Release without bearer takeback
...      CB008717-G Cell Management for Secondary Node
...      CB008717-H Configuration and Reception of A4 measurements
...      CB008717-I Successful Measurement based PSCell Addition
...      CB008717-J Interaction with event A4
...      CB008717-M Mobilty on PCell
...
...      CONTACTS:
...      CFAM Leader        : Lukasz Juszczak       (Nokia - PL/Krakow) ,lukasz.juszczak@nokia.com.
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/000268d5#o=5621
...                     FTS link:              https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
...                                            Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
...                                            wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-JA+Sub+feature+refinement
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [22.01.2024] - Create Test Suite
...      [26.01.2024] - Approved by EFS
...      [26.01.2024] - Review closed

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True  faf=2

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-JA-B3c_A2_A3_A5_blocked_for_FWA_UEs_in_RRCReestablishment_during_XN_and_NG_ho
    [Documentation]
    ...  DESCRIPTION: This user scenario describes situation when mobility measurements (A3/A5/A2) are not configured on FWA UE during
    ...  RRC Re-establishment during incoming:
    ...  - inter-gNB XN based handover for UE1
    ...  - inter-gNB NG based handover for UE2
    ...
    ...  PRECONDITION:
    ...  - For real gNB-2 the same preconditions as in CB008717-D-B1c scenario with addition to:
    ...    - NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...    - NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...    - NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...    - NRBTS/NRCELL-6 simulated on AWEUB radio module - NR_BAND: n261
    ...    - Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation:
    ...      - NRBTS/NRCELL-1 does not have NR-DC enabled
    ...      - NRBTS/NRCELL-2 has NR-DC enabled
    ...    - Two FR2 cells (NRBTS/NRCELL-3 and NRBTS/NRCELL-6) are active in pure NR-DC-SN mode of operation
    ...    - NRBTS/rrcReestabTypeSA is set to 'sameGNB'
    ...    - NRBTS/identifiedFwaUeList:
    ...      - 1: 87
    ...    - NRBTS/actRfspIndex is set to true
    ...
    ...  - gNB2 is up and running
    ...  - UE-NR-Capability the same as in CB008717-D-B1c scenario with addition to:
    ...    - UE1: set indexToRFSP to 87 via amf_ue_ics_param egate command
    ...    - UE2: set indexToRFSP to 87 via amf_ue_ics_param egate command
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup
    ...  - UE2 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_22689
    ...       *BACKLOG ID: FCA_5G_L2L3-218877
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik   (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_RAN_USR_RRM_22689
    ...  CFAM link:       https://gates.nsn-net.net/view/000268d5#o=5621
    ...  FTS link:        https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
    ...                   Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
    ...                   wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-JA+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [22.01.24] - Create first Test Case shape
    ...  [26.01.24] - Final TC shape
    ...  [26.01.24] - Review closed

    [Tags]  JA-B3c

    [Setup]  Prepare test environment for JA-B3c

    # ---------- RRC Re-establishment during incoming inter-gNB XN based handover for UE1 ----------

    Attach UE1 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Set RRCReestablishment to be triggered during handover for UE1
    Set expected message flow for RRCReestablishment during incoming inter-gNB XN based handover for UE1
    Trigger UE1 handover from sim_gNB to gNB2 NRCELL-2
    Verify expected message flow for RRCReestablishment during incoming inter-gNB XN based handover for UE1

    Verify that indexToRFSP-87 is present in HandoverRequest message for inter-gNB XN based HO for UE1
    Verify measIdToRemoveList is present and measIdAddModList is not present UE1 in 2 out of 3 RRCReconfiguration
    Verify that fullConfig is not present for UE1 in 2 out of 3 RRCReconfiguration message
    Verify that A2/A3/A5 measurements are not configured in 1 out of 5 UEContextModificationRequest message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 2 out of 3 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 3 out of 3 RRCReconfiguration message
    Verify that A4 measurements are configured in 4 out of 5 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE1 in 3 out of 3 RRCReconfiguration message

    ${meas_id}=    Wait for NRDC A4 activation and get measID for UE1 and NRCELL-3

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-3 for gNB2

    # ---------- RRC Re-establishment during incoming inter-gNB NG based handover for UE2 ----------

    Execute egate command   cmd=gnb_param measEvent=A3 sa_ho=ng_based id=3

    Attach UE2 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Set RRCReestablishment to be triggered during handover for UE2
    Set expected message flow for RRCReestablishment during incoming inter-gNB NG based handover for UE2
    Trigger UE2 handover from sim_gNB to gNB2 NRCELL-2
    Verify expected message flow for RRCReestablishment during incoming inter-gNB NG based handover for UE2

    Verify that indexToRFSP-87 is present in HandoverRequest message for UE2
    Verify measIdToRemoveList is present and measIdAddModList is not present UE2 in 2 out of 3 RRCReconfiguration
    Verify that fullConfig is not present for UE2 in 2 out of 3 RRCReconfiguration message
    Verify that A2/A3/A5 measurements are not configured in 1 out of 5 UEContextModificationRequest message
    Verify that A2,A3,A5 measurements are not configured for UE2 in 2 out of 3 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE2 in 3 out of 3 RRCReconfiguration message
    Verify that A4 measurements are configured in 4 out of 5 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE2 in 3 out of 3 RRCReconfiguration message

    ${meas_id}=    Wait for NRDC A4 activation and get measID for UE2 and NRCELL-3

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-3 for gNB2

    [Teardown]    Cleanup after test JA-B3c
