*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This user scenario describes the procedure that gNB does not try to activate NR-DC A4 measurements
...      but starts A4 retryTimer instead after ICS, successful incoming HO with no PDU session or no NR-DC eligible PDU
...      session established. Additionally, upon successful NR-DC PSCell addition, gNB starts A4 retryTimer when NR-DC
...      PScell is configured for UE already.
...
...      TEST SET NAME: CB008717-HA Update to retryTimer logic for FWA UEs
...
...      TESTING SCOPE:
...      CB008717-A NR-DC Cell Activation for a Secondary Node
...      CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...      CB008717-C UE Release due to AMF Context Release
...      CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...      CB008717-DE PM Counters for sub-feature D and E
...      CB008717-E UE Release without bearer takeback
...      CB008717-G Cell Management for Secondary Node
...      CB008717-H Configuration and Reception of A4 measurements
...      CB008717-HA Update to retryTimer logic for FWA UEs
...      CB008717-I Successful Measurement based PSCell Addition
...      CB008717-J Interaction with event A4
...      CB008717-JA Activation/Deactivation of A4 based measurements due to PDU Session Management
...      CB008717-M Mobilty on PCell
...
...      CONTACTS:
...      CFAM Leader        :
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=720
...                     FTS link:              https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
...                                            /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
...                                            ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [24.10.2023] - Create Test Suite
...      [24.10.2023] - Approved by EFS

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
CB008717-HA-B1d_A4retryTimer_FWA_to_non_FWA_transfer_via_UE_Ctx_Modification_or_DL_NAS_Transport
    [Documentation]
    ...  DESCRIPTION:
    ...  The key purpose of this test is to verify that FWA status is checked and stored in UE Context only once at the beginning of
    ...  UE life when UE enters the cell via RRC Setup. FWA Status is not re-evaluated after RFSP Index change.
    ...  Below cases are included in the following scenario:
    ...     - UE1 is transferred from FWA to non-FWA UE via UE Context Modification, after successful not-optimized ICS with no NRDC
    ...       eligible PDU Session establishment, before A4 retryTimer value passes
    ...     - UE2 is transferred from FWA to non-FWA UE via Downlink NAS Transport, after successful not-optimized ICS with no NRDC
    ...       eligible PDU Session establishment, after A4 retryTimer value passes
    ...
    ...  PRECONDITION:
    ...    The same preconditions as in CB008717-D-B1c scenario with addition to:
    ...     - NRBTS/identifiedFwaUeList: 87
    ...     - NRBTS/NRCELL-2/a4RetryTimer: 10s
    ...     - NRBTS/NRDRB-1/resType: GBR
    ...
    ...  POSTCONDITION:
    ...     UE1 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...     UE2 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21681
    ...       *BACKLOG ID: FCA_5G_L2L3-176270
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Karolina Sroczyk-Konefał  (Nokia - PL/Krakow) <karolina.sroczyk-konefal@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS            (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US:
    ...  CFAM link:       https://gates.nsn-net.net/view/00025f8e#o=720
    ...  FTS link:        https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
    ...                   /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
    ...                   ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...    https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [24.10.2023] - Create first Test Case shape
    ...  [06.11.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=897216)

    [Tags]  HA-B1d-1

    [Setup]  Prepare test environment HA-B1d-1

    # ------------ UE1 part - FWA -> non-FWA via NGAP:UEContextMOdification ------------

    Prepare NrDc UE1 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow
    Set expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE1, AMF1
    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE1
    Trigger UE1 idle mode exit
    Verify expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE1, AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify that gNB2 forwards UECapabilities received from UE1 to AMF1
    Get occurence time of RRCReconfiguration after ICS for UE1

    Transfer UE1 from FWA to non-FWA by setting RFSP index to 77 via NGAP:UEContextModification
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

    # ------------ UE2 part - FWA -> non-FWA via NGAP:DownlinkNASTransport ------------

    Prepare NrDc UE2 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow
    Set expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE2, AMF1
    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE2
    Trigger UE2 idle mode exit
    Verify expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE2, AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE2
    Verify that gNB2 forwards UECapabilities received from UE2 to AMF1
    Get occurence time of RRCReconfiguration after ICS for UE2

    Expect that A4 measurements are not configured after retryTimer expiry for UE2
    Verify that A4 measurements are not configured after retryTimer expiry for UE2

    Expect that A4 measurements are configured after adding eligible PDU session for UE2
    Reset QoS Flow settings on SMF
    Add to UE2 second PDU session after ICS
    Set indexToRFSP for UE2 to 77 using DL NAS Transport message
    Verify that A4 measurements are configured after adding eligible PDU session for UE2
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE2 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE2 and verify if difference is equal 20s

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-2 for gNB2

    [Teardown]  Cleanup after test HA-B1d-1

CB008717-HA-B1d_A4retryTimer_FWA_to_non_FWA_transfer_via_reconf_of_identifiedFwaUeList
    [Documentation]
    ...  DESCRIPTION:
    ...     The key purpose of this test is to verify that FWA status is checked and stored in UE Context only once at the beginning
    ...     of UE life when UE enters the cell via RRC Setup. FWA Status is not re-evaluated after RFSP Index change.
    ...     Below case is included in the following scenario:
    ...         -UE1 is transferred from FWA to non-FWA UE via online reconfiguration of NRBTS/identifiedFwaUeList, after successful
    ...          not-optimized Initial Context Setup with NRDC eligible PDU Session establishment, before A4 retryTimer value passes
    ...
    ...  PRECONDITION:
    ...    The same preconditions as in CB008717-D-B1c scenario with addition to:
    ...     - NRBTS/identifiedFwaUeList: 87
    ...     - NRBTS/NRCELL-2/a4RetryTimer: 10s
    ...     - NRBTS/NRDRB-1/resType: GBR
    ...
    ...  POSTCONDITION:
    ...    UE1 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21681
    ...       *BACKLOG ID: FCA_5G_L2L3-176270
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Karolina Sroczyk-Konefał  (Nokia - PL/Krakow) <karolina.sroczyk-konefal@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS            (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US:
    ...  CFAM link:       https://gates.nsn-net.net/view/00025f8e#o=720
    ...  FTS link:        https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
    ...                   /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
    ...                   ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...    https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [15.11.2023] - Create first Test Case shape
    ...  [27.11.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=897216)

    [Tags]  HA-B1d-2    SKIPRUN

    [Setup]  Prepare test environment HA-B1d-2

    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE1
    Set messages flows to check if A4 measurements are configured and deconfigured after ICS with NRDC eligible PDU for UE1, AMF1
    Attach UE1 without ICS to gNB2 cell2
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify messages flows to check if A4 measurements are configured and deconfigured after ICS with NRDC eligible PDU for UE1, AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify that gNB2 forwards UECapabilities received from UE1 to AMF1
    Verify that A4 measurements are configured in 3 out of 6 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE1 in 2 out of 3 RRCReconfiguration message
    Verify that A4 measurements are not configured in 5 out of 6 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE1 in 3 out of 3 RRCReconfiguration message

    Transfer UE1 from FWA to non-FWA by online reconfiguration of identifiedFwaUeList by setting RFSP index to 77

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-1 for UE1
    Set Test Variable  ${meas_id}
    Sleep    2

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    [Teardown]  Cleanup after test HA-B1d-2

CB008717-HA-B1e_A4retryTimer_during_PDU_session_setup
    [Documentation]
    ...  DESCRIPTION:
    ...     The key purpose of this test is to verify A4 retryTimer expiration event is queued by gNB when
    ...     PDU Session Setup procedure is ongoing. Below cases are included in the following scenario:
    ...     UE1 - A4 retryTimer expires during PDU Session Setup. After procedure completion, A4 retryTimer is restarted.
    ...  PRECONDITION:
    ...    The same preconditions as in CB008717-D-B1c scenario with addition to:
    ...     - NRBTS/identifiedFwaUeList: 87
    ...     - NRBTS/NRCELL-2/a4RetryTimer: 4s
    ...     - NRBTS/rrcGuardTimer: 6s
    ...     - NRBTS/actGnbInitRlf: false
    ...     - NRBTS/actUeInitRlf: false
    ...     - NRBTS/NRDRB-1/resType: GBR
    ...
    ...  POSTCONDITION:
    ...    UE1 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21681
    ...       *BACKLOG ID: FCA_5G_L2L3-176270
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyżak  (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS            (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US:
    ...  CFAM link:       https://gates.nsn-net.net/view/00025f8e#o=720
    ...  FTS link:        https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
    ...                   /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
    ...                   ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...    https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [29.11.2023] - Create first Test Case shape
    ...  [01.12.2023] - Final implementation

    [Tags]  B1e

    [Setup]  Prepare test environment HA-B1d-2

    Prepare NrDc UE1 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow
    Set expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE1, AMF1
    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE1
    Trigger UE1 idle mode exit
    Verify expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE1, AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify that gNB2 forwards UECapabilities received from UE1 to AMF1
    Get occurence time of RRCReconfiguration after ICS for UE1
    #1st a4retrytimer running

#    Expect that A4 measurements are not configured after retryTimer expiry for UE1
    EXPECT FLOW[timeout=4]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCReconfigurationComplete
    #2nd a4retrytimer running
    FAIL FLOW[timeout=4]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCReconfigurationComplete
#    Verify that A4 measurements are not configured after retryTimer expiry for UE1

    Set delay RRCReconfigurationComplete by 5000ms for UE1
    Add to UE1 PDU1 session QoS flows with 5QI from list [9,8] and delete QoS flows with 5QI from list []
    EXPECT FLOW[timeout=4]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCReconfigurationComplete
    #3rd a4retrytimer running
    #4th a4retrytimer running
    FAIL FLOW[timeout=4]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCReconfigurationComplete
#    Expect that A4 measurements are not configured after retryTimer expiry for UE1
#    Verify that A4 measurements are not configured after retryTimer expiry for UE1

    Expect that A4 measurements are configured after adding eligible PDU session for UE1
    Reset QoS Flow settings on SMF
    Set delay RRCReconfigurationComplete by 5000ms for UE1
    Add to UE1 second PDU session after ICS
    #5th a4retrytimer running
    #6th a4retrytimer running
    Verify that A4 measurements are configured after adding eligible PDU session for UE1
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE1 and verify if difference is equal 24s

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-1 for UE1
    Set Test Variable  ${meas_id}
    Sleep    2
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    [Teardown]    Detach and kill UE1
