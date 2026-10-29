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

Suite Setup  Run Setup  f1ap=${True}  custom_ranac=1, ''

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***

CB008225_G_B3_LRC_change_of_serve_cell_and_AoI_for_UE_in_RRC_INACTIVE_during_RNA_update_to_cell_without_ranAC
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the gNB behavior for successful location reporting procedure after transition of suspended UE1
    ...  from RRC_INACTIVE to RRC_CONNECTED state to different cell within the same gNB. The gNB should send NGAP: Location Report (with NRCGI, TAI).
    ...  As a precondition when UE1 is in RRC-INACTIVE state AMF sends NGAP: LocationReportingControl with 'change-of-serve-cell' to gNB for UE1 and
    ...  second message NGAP: LRC with 'ue-presence-in-the-area-of-interes' - Area of Interest is current Cell1 for UE1. The gNB should send two
    ...  Location Report with timestamp - one for each event. Next ranAC on Cell1 is changed online to another value. Then RRCResume procedure
    ...  is triggered by RNA update. RNA update is done with last visited NRCGI, ranAC and then RRCRelese with suspendConfig IE is sent (UE1
    ...  transition to RRC_INACTIVE). The gNB does not send Location Report. Next AMF sends NGAP: LocationReportingControl with
    ...  'stop-change-of-serve-cell' and then once again sends NGAP: LRC with 'change-of-serve-cell' Cell1 now has new ranAC. The gNB sends Location
    ...  Report with timestamp. After that another resume procedure (different than RNA update) is triggered towards Cell2. On Cell2 ranAC
    ...  is not present so RRCResume fallbacks to RRCSetup. New UE context is created and old is released. Location Report is sent without timestamp
    ...  (because UE is in RRC_CONNECTED state), with nrCellIdentity Cell2 and new AMF and RAN IDs.
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
    ...     - NRBTS/NRCELL-1.ranAC = 1
    ...     - NRBTS/NRCELL-2.ranAC not configured (CB008225 is "disabled" on NRCELL-2)
    ...
    ...  POSTCONDITION:
    ...     - Two RRCResume procedures are started
    ...     - UE1 is in RRC_INACTIVE state after first RRCResume procedure
    ...     - UE1 is in RRC_CONNECTED state after second RRCResume procedure with fallback to RRCSetup
    ...     - NGAP:LocationReport is not sent to AMF after first RRCResume procedure
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UEs (AMF UE NGAP ID) after
    ...       second RRCResume procedure
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
    ...      [13.06.2023] - Create first Test Case shape

    [Tags]    B3_4

    [Setup]    Prepare test environment

    # ------------ B2 part - Send two LRCs for UE1 in INACTIVE state ------------

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    EXPECT FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 3*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for NRCELL-1
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 1:1
    PASS FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 3*locationReport

    FAIL FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends [1/2]LocationReport containing NRCELL-1 identity
    Verify that gNB sends [1/2]LocationReport with timestamp for UE1
    Verify that [1/2]LocationReport contains eventType equal to change-of-serve-cell

    Verify that [2/2]LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that [2/2]LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that [2/2]LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that [2/2]LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that [2/2]LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that [2/2]LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that gNB sends [2/2]LocationReport with timestamp for UE1

    # ------------ NRBTS/NRCELL-1/NRPLMNSET_SA-1.ranAC to the new value ------------

    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '5'}

    #  RRCResume will be triggered automatically or manually by egate command?

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-1
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    #TODO: UE flow during ranAC update
#    UE1 has resume triggered (RRCResumeRequest.resumeCause=rna-Update).
#    RNA Update is done with last visited NRCGI, ranac and then RRCRelease with suspendConfig IE is sent (UE transits to RRC_INACTIVE).
#    Location report is not sent.

    Send LocationReportingControl for UE1 with eventType=stop-change-of-serving-cell

    # ------------ B2 part - Send LRC for UE1 in INACTIVE state ------------

    EXPECT FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=10]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=10]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Resume to Cell2 by RAN update towards Cell2 which has no ranAC (feature is deactivated) ------------

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2 with fallback to RRCSetup
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

#    TODO: UE1 triggers RRCResume procedure to NRCELL-2
    # UE1 resumes to cell-2 which doesn't have ranAC configured (RRCResumeRequest1.resumeCause=rna-Update).
    # RRCSetup fallback is triggered
    # LocationReport is sent without timestamp (because UE is in RRC_CONNECTED state) and nrCellIdentity cell-2.
    # Location Report is sent with new (?) AP IDs to AMF
    # New info: Location Report is not sent when RRCSetup was performed - need to send new LocationReportControl - add it to test?

    [Teardown]    Cleanup after test


*** Keywords ***
Prepare test environment
    Configure       ${yaml_paths_to_configure}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': ''}
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
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '1'}
