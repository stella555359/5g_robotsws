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
...          [20.03.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}    disable_ran_sharing=${True}    custom_cell_level_ranac=1,1

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***

CB008225_G_B3_LRC_ue_presence_in_the_area_of_interest_for_UE_in_RRC_INACTIVE_then_UE_moves_out_or_into_Area_Of_Interest_LocationReport_sent
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the gNB behavior for successful location reporting procedure after transition of suspended UE1
    ...  from RRC_INACTIVE to RRC_CONNECTED state to different cell within the same gNB (by XXXX). The gNB should send
    ...  NGAP: Location Report (with NRCGI, TAI).
    ...  As a precondition when UE1 is in RRC-INACTIVE state AMF sends NGAP: LocationReportingControl with 'AOI' to gNB for UE1.
    ...  Then RRCResume procedure is triggered by starting traffic.
    ...  - The same procedure is then performed for UE2 but transition from RRC_INACTIVE to RRC_CONNECTED state is made to the same cell within the
    ...  the same gNB. In this situation the gNB should not send NGAP: Location Report.
    ...  - At the end is made intra-frequency intra-gNB handover for UE2 to different cell. In this situation The gNB should send
    ...  NGAP: Location Report (with NRCGI, TAI).
    ...
    ...  PRECONDITION:
    ...     - NRBTS.rrcInactLocationReportEnabled = true (CB008225)
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
    ...     - UE1 and UE2 are in RRC_CONNECTED state
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UEs (AMF UE NGAP ID):
    ...       -  for UE1 after starting traffic with change of serving cell
    ...       -  for UE2 after handover to second cell
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_18155;5G_CP_ARC_ALG_1036;5G_CP_ARC_ALG_9728
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
    ...      [05.06.2023] - Create first Test Case shape
    [Tags]    B3_2
    [Setup]    Prepare test environment
    [Teardown]    Cleanup after test
    Log to console      Attaching NRCELL-1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Log to console      UE waits to go inactive cell1
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Log to console      UE inactive
    EXPECT FLOW: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for NRCELL-1
    PASS FLOW: AMF1 NGAP locationReport
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Run Keyword and Continue on Failure
    ...      Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1

    # above procedures verifies B2_2 functionality, can be used then for regression


    EXPECT FLOW: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    Log to console      UE resume to cell 2
    PASS FLOW: AMF1 NGAP locationReport
    Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 1
    Verify that gNB sends LocationReport without timestamp




#    EXPECT FLOW[timeout=6]: AMF1 NGAP 2*locationReport
#    EXPECT FLOW[timeout=6]: AMF1 NGAP locationReport
#    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
#    Log to console      UE sending LRC direct in inactive state
#    Send LocationReportingControl for UE1 with eventType=direct
#    PASS UE1 rrcResume successfull procedure ending in CONNECTED state
#    PASS FLOW[timeout=6]: AMF1 NGAP locationReport
#    FAIL FLOW[timeout=6]: AMF1 NGAP 2*locationReport
#
#    Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
#    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
#    Verify that LocationReport contains eventType equal to direct
#    Verify that gNB sends LocationReport without timestamp
#
#    Log to console      UE waits to go inactive cell2
#    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
#    Log to console      UE inactive
#

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    # TO DO may add additional resume keyword to cell2 here
    Perform intra-frequency intra-gNB handover from gNB2 cell2 to cell1 for UE1
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that gNB sends LocationReport without timestamp

*** Keywords ***
Prepare test environment
    Enable interaction CB008225-G with 5GC000770
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    Execute egate command    cmd=amf_paging_param id=1 max_paging_retries=10
    Execute egate command    cmd=ue_nr_rrc_setup_param id=1 pagingdelay=1s
    Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    Configure Areas of Interest as 2 cells
    Observe NG-C ICS messages and update database



Cleanup after test
    Detach and kill UE1
    Detach and kill UE2
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20