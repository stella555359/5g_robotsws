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
...      [23.11.2023] - Create Test Suite
...      [27.11.2023] - Approved by EFS

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-HA-B1f_last_PDU_session_release_with_A4_NRDC_MR_recived_during_A4supervisionTimer
    [Documentation]
    ...  DESCRIPTION:
    ...     The key purpose of this test is to verify that UE is released when A4 measurement is received after last PDU Session
    ...     is released during A4 supervision timer running. Testcase is manual because of A4 supervision timer dependencies.
    ...
    ...  PRECONDITION:
    ...     The same preconditions as in CB008717-D-B1c scenario with addition to:
    ...         - NRBTS/identifiedFwaUeList: 87
    ...         - NRBTS/NRCELL-2/a4RetryTimer is set to 10s
    ...         - NRBTS/NRCELL-2/a4Fr2SupervisionTimer is set to 9000ms
    ...         - UE-NR-Capability the same as in CB008717-D-B1c scenario with addition to UE1:
    ...             set indexToRFSP to 87 via amf_ue_ics_param egate command
    ...
    ...  POSTCONDITION:
    ...    UE1 is released
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
    ...  [23.11.2023] - Create first Test Case shape
    ...  [27.11.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=897216)

    [Tags]  HA-B1f

    [Setup]  Prepare test environment HA-B1f

    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE1
    Set messages flows to check if A4 measurements are configured after ICS with NRDC eligible PDU for UE1, AMF1
    Attach UE1 without ICS to gNB2 cell2
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify messages flows to check if A4 measurements are configured after ICS with NRDC eligible PDU for UE1, AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify that gNB2 forwards UECapabilities received from UE1 to AMF1
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Trigger AMF Initiated PDU-1 Session Release for UE1

    Expect that after sending A4 measurement NRDC is not setup and UE1 is released
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify that after sending A4 measurement NRDC is not setup and UE1 is released

    [Teardown]  Cleanup after test HA-B1f
