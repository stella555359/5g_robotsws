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

Force Tags    CONFIGURED    CRT    DAWID    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}        cell_messages=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008225_G_EC1_AMF_Paging_for_INACTIVE_UE_tRanPagingGuard_expires_LocationReportingFailureIndication_due_to_UE_in_RRC_INACTIVE_state_not_reachable
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure...
    ...
    ...  PRECONDITION:
    ...     - NRBTS.rrcInactLocationReportEnabled = true (CB008225)
    ...     - NRBTS.drbRrcInactInactivityTimerSA = 5 (CB008225)
    ...     - NRBTS.actLocationReportingSA = true (5GC000770)
    ...     - NRBTS.actAdditionalSliceSupport = true (CB008120)
    ...     - NRBTS.tRanPagingGuard = 5 (s)
    ...     - NRDRB_QCI-1.qciValueList = [5]
    ...     - NRDRB_QCI-1.nrDrbDN = 'MRBTS-1/NRBTS-1/NRDRB-2'
    ...     - NRDRB-2.drbRrcInactInactivityTimerSA = 5 (s)
    ...     - UE-NR-Capability-v1530.inactiveState = supported
    ...
    ...  POSTCONDITION:
    ...     - Successful RAN Paging procedure.
    ...     - UE is in RRC_CONNECTED state.
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UE (AMF UE NGAP ID)
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:
    ...       *BACKLOG ID:
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Marek Kieltyka <marek.kieltyka@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: https://gates.nsn-net.net/view/000266ca#o=706
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008225
    ...
    ...      [20.03.2023] - Create first Test Case shape


    [Setup]    Prepare test environment

    Log to console       paging timeout same cell
    Log to console      Attaching NRCELL-1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Log to console      Waiting UE inactive
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Log to console      UE is inactive
    EXPECT FLOW[timeout=20]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=20]: AMF1 NGAP locationReportingFailureIndication
    EXPECT FLOW: gNB2 F1AP paging
    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
    Log to console      Sending LCR direct
    # max tRanPagingGuard is set to 15, so waiting 20s
    Set UE1 paging response delay to 60s
    Send LocationReportingControl for UE1 with eventType=direct
    PASS FLOW: gNB2 F1AP paging
    PASS FLOW[timeout=20]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=20]: AMF1 NGAP locationReportingFailureIndication
    FAIL UE1 rrcResume procedure remaining in inactive state
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains eventType equal to direct
    run keyword and continue on failure        Verify that gNB sends LocationReport with timestamp for UE1
    Cleanup after test

    Log to console       paging timeout aftre rna update to second cell
    Log to console      Attaching UE2 NRCELL-1
    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Log to console      Waiting UE inactive
    Wait until UE2 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Log to console      UE is inactive
    Trigger RRCResume procedure for UE2 by running RNA update towards NRCELL-2
    Log to console      UE rna update to NRCELL2
    EXPECT FLOW[timeout=20]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=20]: AMF1 NGAP locationReportingFailureIndication
    EXPECT FLOW: gNB2 F1AP paging
    EXPECT UE2 rrcResume successfull procedure ending in CONNECTED state
    Log to console      Sending LCR direct when UE moved to NRCELL-2
    # max tRanPagingGuard is set to 15, so waiting 20s
    Set UE2 paging response delay to 60s
    Send LocationReportingControl for UE2 with eventType=direct
    PASS FLOW: gNB2 F1AP paging
    PASS FLOW[timeout=20]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=20]: AMF1 NGAP locationReportingFailureIndication
    FAIL UE2 rrcResume procedure remaining in inactive state
    run keyword and continue on failure        Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains eventType equal to direct
    run keyword and continue on failure        Verify that gNB sends LocationReport with timestamp for UE2
    Cleanup after test


    Log to console      timeout when waiting for resumecomplete
    Log to console      Attaching NRCELL-1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Log to console      Waiting UE inactive
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Log to console      UE is inactive
    EXPECT FLOW[timeout=20]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=20]: AMF1 NGAP locationReportingFailureIndication
    EXPECT FLOW: gNB2 F1AP paging
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1,RRCResume
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeComplete
    Log to console      Sending LCR direct, resumecopmlete dropped
    Set UE1 paging response delay to 1s
    Set UE1 to drop ResumeRequest message
    Change for UE1 target cell of resume procedure to 1 with cause mt_Access
    Send LocationReportingControl for UE1 with eventType=direct
    PASS FLOW: gNB2 F1AP paging
    PASS FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1,RRCResume
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeComplete
    FAIL FLOW[timeout=20]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=20]: AMF1 NGAP locationReportingFailureIndication
    Cleanup after test


    Log to console      rna update as response to direct ignored -> paging timeout
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Log to console      Waiting UE inactive
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Log to console      UE is inactive
    EXPECT FLOW: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=4]: AMF1 NGAP 2*locationReport
    EXPECT FLOW: gNB2 F1AP paging
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCResumeRequest1
#    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCRelease
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCResume
    EXPECT FLOW[timeout=4]: UE_1 NR-RRC RRCSetup
    Log to console      Sending LCR direct
    Change for UE1 target cell of resume procedure to 1 with cause rna_Update
    Send LocationReportingControl for UE1 with eventType=direct
    PASS FLOW: gNB2 F1AP paging
    PASS FLOW[timeout=4]: UE_1 NR-RRC RRCResumeRequest1
#    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCRelease
    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCResume
    FAIL FLOW[timeout=4]: UE_1 NR-RRC RRCSetup
    PASS FLOW: AMF1 NGAP locationReport
    FAIL FLOW[timeout=4]: AMF1 NGAP 2*locationReport
    Verify that UE1 sends ResumeRequest with cause=rna-Update
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains eventType equal to direct
    Verify that gNB sends LocationReport with timestamp for UE1


    # possible case to check, that after sending rnaupdate (ignored), UE sends resume with mt-acess -> accepted


    [Teardown]    Cleanup after test




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
    Set UE1 to use ResumeRequest message
    Set UE2 to use ResumeRequest message
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20