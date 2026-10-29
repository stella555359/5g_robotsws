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
...          [03.08.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}    custom_ranac=1,1    cell_messages=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008225_G_EC2_feature_deactivated_by_ranAC_LRC_sent_for_UE_in_RRC_INACTIVE_state
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure when UE is in RRC-INACTIVE state and AMF sends NGAP: LocationReportingControl
    ...  to gNB for UE. Feature Flag for Location Reporting in RRC-INACTIVE state is enabled NRBTS.rrcInactLocationReportEnabled = true.
    ...  But after UE goes to RRC-INACTIVE state ranAC is disabled on cell.
    ...  The gNB should respond with NGAP: LocationReport to AMF. Paging and RRCResume procedures are not started for UE after LCR with event
    ...  'direct'. LocationReport with timestamp is sent when ranACs on both cells are the same NRPLMNSET_SA-1.ranAC = 1 because when ranAC
    ...  on one cell is disabled, on other is enabled and gNB triggers paging it this case. UE does not respond to paging and gNB sends
    ...  LocationReport with timestamp according to G-EC1 scenario.
    ...  LocationReport with timestamp is not sent when ranACs on both cells are different Cell-1/NRPLMNSET_SA-1.ranAC = 1
    ...  and Cell-2NRPLMNSET_SA-1.ranAC = 2 because gNB does not trigger paginng it this case.
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
    ...     - NRBTS/NRCELL-1/NRPLMNSET_SA-1.ranAC = 1
    ...     - NRBTS/NRCELL-2/NRPLMNSET_SA-1.ranAC = 1
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
    ...      [03.08.2023] - Create first Test Case shape

    [Tags]    EC2_3

    [Setup]  Run Keywords
    ...      Start egate collection    AND
    ...      Prepare test environment
    # ------------ ranACs are the same on both cells ------------

    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'drbRrcInactInactivityTimerSA': '15'}

    # ------------ B2 part - Send LRC for UE1 in INACTIVE state ------------

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    EXPECT FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=5]: NRCELL_2_1 NR-RRC Paging is not started
    EXPECT FLOW[timeout=5]: gNB2 F1AP paging is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=5]: NRCELL_2_1 NR-RRC Paging is not started
    FAIL FLOW[timeout=5]: gNB2 F1AP paging is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Send LRC with event change-of-serving-cell for UE1 in INACTIVE state when ranAC is disabled ------------

    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': ''}

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Send LRC with event ue-presence-in-area-of-interest for UE1 in INACTIVE state when ranAC is disabled ------------

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for both cells
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

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

    # ------------ Send LRC with event direct for UE1 in INACTIVE state when ranAC is disabled ------------

    EXPECT FLOW[timeout=10]: gNB2 F1AP paging
#    EXPECT FLOW[timeout=10]: NRCELL_2_1 NR-RRC Paging
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
    Change for UE1 target cell of resume procedure to 1 with cause mt_Access
    Send LocationReportingControl for UE1 with eventType=direct
    PASS FLOW[timeout=10]: gNB2 F1AP paging
#    PASS FLOW[timeout=10]: NRCELL_2_1 NR-RRC Paging
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    FAIL FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    FAIL UE1 rrcResume procedure remaining in inactive state

    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains eventType equal to direct
    Verify that gNB sends LocationReport with timestamp for UE1

    Detach and kill UE1

    # ------------ ranACs are different on cells ------------

    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '2'}

    # ------------ B2 part - Send LRC for UE1 in INACTIVE state ------------

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 2 for UE_1

    EXPECT FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=5]: NRCELL_2_1 NR-RRC Paging is not started
    EXPECT FLOW[timeout=5]: gNB2 F1AP paging is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=5]: NRCELL_2_1 NR-RRC Paging is not started
    FAIL FLOW[timeout=5]: gNB2 F1AP paging is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Send LRC with event change-of-serving-cell for UE1 in INACTIVE state when ranAC is disabled ------------

    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': ''}

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Send LRC with event ue-presence-in-area-of-interest for UE1 in INACTIVE state when ranAC is disabled ------------

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for both cells
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

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

    # ------------ Send LRC with event direct for UE1 in INACTIVE state when ranAC is disabled ------------

    EXPECT FLOW[timeout=10]: gNB2 F1AP paging is not started
    EXPECT FLOW[timeout=10]: NRCELL_2_1 NR-RRC Paging is not started
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
    Change for UE1 target cell of resume procedure to 1 with cause mt_Access
    Send LocationReportingControl for UE1 with eventType=direct
    FAIL FLOW[timeout=10]: gNB2 F1AP paging is not started
    FAIL FLOW[timeout=10]: NRCELL_2_1 NR-RRC Paging is not started
    FAIL FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    FAIL FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    FAIL UE1 rrcResume procedure remaining in inactive state

    [Teardown]    Run Keywords
    ...           Cleanup after test    AND
    ...           Stop egate collection

*** Keywords ***
Prepare test environment
    Configure       ${yaml_paths_to_configure}
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
#    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'true'}
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20

