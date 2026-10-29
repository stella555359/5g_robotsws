*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This feature introduces the RRC Inactive state, including RRC state transitions to/from other states under the same gNB,
...      for 5G UEs operating in 3GPP NR Standalone (SA) mode.
...
...      TEST SET NAME: CB008225-G RRC Inactive and interaction with Location Reporting
...
...      TESTING SCOPE:
...          CB008225-A Configuration of RAN Area Code and broadcast of SIB1 for RRC Inactive State
...          CB008225-B Transition from RRC Connected to RRC Inactive State (Suspend)
...          CB008225-C RAN Paging for UE in RRC Inactive State
...          CB008225-D Transition from RRC Inactive to RRC Connected State (Resume)
...          CB008225-E RRC Inactive and interaction with Carrier Aggregation
...          CB008225-F RRC Inactive and interaction with intra gNB NR-DC
...          CB008225-G RRC Inactive and interaction with Location Reporting
...          CB008225-H RRC Inactive and interaction with Idle Mode Mobility Steering
...          CB008225-I RRC Inactive and interaction with other features
...          CB008225-J Tracing and PCMD support for UE in RRC_INACTIVE state
...          CB008225-K RRC Inactive and interaction with CB008311 feature
...          CB008225-L RRC Inactive and interaction with 5G Sleeping Cell Detection
...          CB008225-W Capacity and Performance
...
...      CONTACTS:
...          CFAM Leader        : Lukasz Haracz (Nokia - PL/Wroclaw) <lukasz.haracz@nokia.com>
...          ET owner (LPO/APO) : Karolina Zwierz (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...          Entity Testing L3  : Dawid Krawczuk (Nokia - PL/Krakow) <dawid.krawczuk@nokia.com>
...                               Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
...                               Grzegorz Szymik (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...
...      MAINTAINER:
...          I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:
...          CFAM link:        https://gates.nsn-net.net/view/000266ca#o=0
...          FTS link:         https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN Productization WoW/
...                            _layouts/15/Doc.aspx?sourcedoc=%7BBF0E0D78-5F93-44B6-B194-28AB9D40A9EC%7D
...          L3 ET Test Plan:  https://nokia-my.sharepoint.com/:w:/p/dawid_krawczuk/EQS_1YWHr45GoH6vG2FutwUBza6siTgzDgiC0cIbrwCq4Q
...
...      HISTORY:
...          History, current status and TC description is available in repository:
...          https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008225
...
...          [02.06.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008225_G_B4_LRC_change_of_serve_cell_UE_in_RRC_CONNECTED_then_UE_inactive_then_DL_user_data_triggers_RRCResume
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the gNB behavior for successful location reporting procedure after transition of suspended UE1
    ...  from RRC_INACTIVE to RRC_CONNECTED state to different cell within the same gNB (by running DL traffic). The gNB should send
    ...  NGAP: Location Report (with NRCGI, TAI).
    ...  This scenario is similar to B3-1 but as a precondition UE1 is in RRC-CONNECTED state when AMF sends NGAP: LocationReportingControl
    ...  with 'change-of-serve-cell' to gNB for UE1 and feature flag NRBTS.rrcInactLocationReportEnabled is set to false.
    ...  The RRCResume procedure is triggered by starting DL traffic.
    ...  This scenario checks if transition of UE through RRC_INACTIVE state has no effect on legacy behavior of Location Reporting feature
    ...  (5GC000770).
    ...  In the second part of scenario the gNB receives from AMF NGAP: LocationReportingControl with 'stop-change-of-serve-cell'. Second RRCResume
    ...  procedure is triggered by starting DL traffic but NGAP: Location Report is not sent by gNB in this case.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.rrcInactLocationReportEnabled = false (CB008225)
    ...     - NRBTS.drbRrcInactInactivityTimerSA = 5 (CB008225)
    ...     - NRBTS.actLocationReportingSA = true (5GC000770)
    ...     - NRBTS.actAdditionalSliceSupport = true (CB008120)
    ...     - NRBTS.tRanPagingGuard = 4 (s)
    ...     - NRDRB_QCI-1.qciValueList = [5]
    ...     - NRDRB_QCI-1.nrDrbDN = 'MRBTS-1/NRBTS-1/NRDRB-2'
    ...     - NRDRB-2.drbRrcInactInactivityTimerSA = 5 (s)
    ...     - UE-NR-Capability-v1530.inactiveState = supported
    ...
    ...  POSTCONDITION:
    ...     - RRCResume procedure is started
    ...     - UE1 is in RRC_CONNECTED state
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UEs (AMF UE NGAP ID)
    ...     - NGAP:LocationReport is not sent to AMF after receiving from AMF NGAP: LocationReportingControl with 'stop-change-of-serve-cell'
    ...
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19961
    ...       *BACKLOG ID: FCA_5G_L2L3-140860
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: https://gates.nsn-net.net/view/000266ca#o=734
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008225
    ...
    ...      [21.06.2023] - Create first Test Case shape

    [Tags]    B4_1

    [Setup]  Prepare test environment

    # ------------ Send LRC for UE1 in CONNTECTED state ------------

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ UE1 goes to RRC_INACTIVE by inactivity ------------

    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    # ------------ Resume to Cell2 by starting DL traffic for UE1 towards Cell2 ------------

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Trigger RRCResume procedure for UE1 by running DL traffic towards NRCELL-2
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that gNB sends LocationReport containing NRCELL-2 identity
    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    Stop and verify 5Mbps DL traffic on UE1 PDU1 QFI1

    # ------------ Send LRC with stop subscription for UE1 in CONNTECTED state ------------

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=stop-change-of-serving-cell
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    # ------------ UE1 goes to RRC_INACTIVE by inactivity ------------

    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    # ------------ Resume to Cell1 by starting DL traffic for UE1 towards Cell1 ------------

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Trigger RRCResume procedure for UE1 by running DL traffic towards NRCELL-1
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    Stop and verify 5Mbps DL traffic on UE1 PDU1 QFI1

    [Teardown]    Cleanup after test

*** Keywords ***
Prepare test environment
    Configure       ${yaml_paths_to_configure}
    Disable CB008225-G with enabled 5GC000770
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    Execute egate command    cmd=amf_paging_param id=1 max_paging_retries=10
    Execute egate command    cmd=ue_nr_rrc_setup_param id=1 pagingdelay=1s
    Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    Configure Areas of Interest as 2 cells
    Observe NG-C ICS messages and update database

Cleanup after test
    Detach and kill UE1
    Detach and kill UE2
#    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'true'}
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20

