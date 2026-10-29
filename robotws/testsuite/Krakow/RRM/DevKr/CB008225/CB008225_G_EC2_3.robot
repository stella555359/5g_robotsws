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
...          [06.07.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008225_G_EC2_feature_deactivated_LRC_ignored_ue_change_of_area_of_interest_LocationReport_not_sent
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure when UE is in RRC-INACTIVE state and AMF sends NGAP: LocationReportingControl
    ...  to gNB for UE. Feature Flag for Location Reporting in RRC-INACTIVE state is disabled NRBTS.rrcInactLocationReportEnabled = false.
    ...  The gNB should not respond with NGAP: LocationReport to AMF. Paging and RRCResume procedures are also not started for UE. Then RRCResume
    ...  procedure is triggered for UE to other cell and gNB should not send NGAP: LocationReport to AMF too.
    ...  This scenario checks when 8225-G when flag is disabled and NGAP: LocationReportingControl is received for UE in inactive state then
    ...  NGAP: LocationReport is not sent. After UE transition from inactive to active state with change of serving cell (and change of area
    ...  of interest) NGAP: LocationReport is also not sent.
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
    ...     - NGAP:LocationReport is not sent to AMF after receiving from AMF NGAP: LocationReportingControl during Feature Flag
    ...       rrcInactLocationReportEnabled disabled
    ...     - NGAP:LocationReport is sent to AMF after receiving from AMF NGAP: LocationReportingControl during Feature Flag
    ...       rrcInactLocationReportEnabled enabled
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19459
    ...       *BACKLOG ID: FCA_5G_L2L3-140861
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
    ...      [06.07.2023] - Create first Test Case shape

    [Tags]    EC2_3

    [Setup]   Run Keywords
    ...       Start egate collection    AND
    ...       Prepare test environment

    # ------------ Send LRC with 'ue-presence-in-area-of-interest' event for UE1 in INACTIVE state ------------
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'drbRrcInactInactivityTimerSA': '15'}
#    Configure  {'MOC': 'NRBTS', 'ID': '1', 'tRanPagingGuard': '15s'}
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for both cells
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    # ------------ UE1 resume to Cell2  ------------

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    # ------------ UE1 goes to RRC_INACTIVE by inactivity ------------

    run keyword and continue on failure     Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    run keyword and continue on failure     Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    # ------------ Send LRC with 'ue-presence-in-area-of-interest' event for UE1 in INACTIVE state ------------

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for both cells
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    # ------------ UE1 resume by LRC with event 'direct' to Cell1 after FF change ------------

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'true'}

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
    Change for UE1 target cell of resume procedure to 1 with cause mt_Access
    Send LocationReportingControl for UE1 with eventType=direct
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    PASS UE1 rrcResume successfull procedure ending in CONNECTED state

    Verify that UE1 sends ResumeRequest with cause=mt-Access
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains eventType equal to direct
    Verify that gNB sends LocationReport without timestamp
    On failure
    ...     Verify that UE1 resume procedure was successfull via sending traffic


    # ------------ UE1 goes to RRC_INACTIVE by inactivity ------------

    run keyword and continue on failure     Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    run keyword and continue on failure     Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    # ------------ Send LRC with 'ue-presence-in-area-of-interest' event for UE1 in INACTIVE state ------------

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for both cells
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport

    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 2

    # ------------ UE1 resume by LRC with event 'direct' to Cell2 after FF change ------------

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'false'}

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Change for UE1 target cell of resume procedure to 2 with cause mt_Access
    Send LocationReportingControl for UE1 with eventType=direct
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    # ------------ UE1 resume by LRC with event !='direct' to Cell2 after FF change ------------

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 2

    [Teardown]    Run Keywords
    ...           Cleanup after test    AND
    ...           Stop egate collection

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

