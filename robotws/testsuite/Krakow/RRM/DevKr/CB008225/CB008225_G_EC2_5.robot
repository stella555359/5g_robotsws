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

Suite Setup  Run Setup  f1ap=${True}     custom_ranac=1,1

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008225_G_EC2_feature_deactivated_by_ranAC_LRC_sent_for_UE_in_RRC_INACTIVE_state
    [Documentation]
#    ...  DESCRIPTION: This test scenario describes the procedure when UE is in RRC-INACTIVE state and AMF sends NGAP: LocationReportingControl
#    ...  to gNB for UE. Feature Flag for Location Reporting in RRC-INACTIVE state is enabled NRBTS.rrcInactLocationReportEnabled = true.
#    ...  But after UE goes to RRC-INACTIVE state ranAC is disabled on cell.
#    ...  The gNB should respond with NGAP: LocationReport to AMF. Paging and RRCResume procedures are not started for UE after LCR with event
#    ...  'direct'. LocationReport with timestamp is sent when ranACs on both cells are the same NRPLMNSET_SA-1.ranAC = 1 because when ranAC
#    ...  on one cell is disabled, on other is enabled and gNB triggers paginng it this case. UE does not respond to paging and gNB sends
#    ...  LocationReport with timestamp according to G-EC1 scenario.
#    ...  LocationReport with timestamp is not sent when ranACs on both cells are different Cell-1/NRPLMNSET_SA-1.ranAC = 1
#    ...  and Cell-2NRPLMNSET_SA-1.ranAC = 2 because gNB does not trigger paginng it this case.
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

    [Tags]    EC2_5

    [Setup]  Run Keywords
    ...      Start egate collection     AND
    ...      Prepare test environment


    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'tRanPagingGuard': '15s'}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'drbRrcInactInactivityTimerSA': '15'}


    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-1
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2


#    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
#    Wait until UE2 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
#    Verify that AreaCodeList contains AreaCode equal 1 for UE_2
#    Trigger RRCResume procedure for UE2 by running RNA update towards NRCELL-1
#    Trigger RRCResume procedure for UE2 by running RNA update towards NRCELL-2



    Change for UE1 target cell of resume procedure to 1 with cause mt_Access
#    Change for UE2 target cell of resume procedure to 1 with cause rna_Update
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': ''}
    Change UE1 location to cell 1     # this causes wrong I-MAC calucation during resume
    Change UE2 location to cell 1

    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
#    EXPECT UE2 rrcResume successfull procedure ending in CONNECTED state
    EXPECT FLOW[timeout=5]: gNB2 F1AP paging
#    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport

    Send LocationReportingControl for UE1 with eventType=direct
#    Send LocationReportingControl for UE2 with eventType=direct
    PASS FLOW[timeout=5]: gNB2 F1AP paging
#    UE1 triggers RRCResume procedure to NRCELL-1 without traffic check   # WA for AP not hearing Paging from cell-1 while inactive on cell-2
#    UE2 triggers RRCResume procedure to NRCELL-1 without traffic check   # WA for AP not hearing Paging from cell-1 while inactive on cell-2
    # till other PR, UE-2 resume via mt-access, because currently rna-update during paging is not working

#    PASS FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    PASS FLOW[timeout=5]: AMF1 NGAP locationReport
    Verify that UE1 sends ResumeRequest with cause=mt-Access
#    Verify that UE2 sends ResumeRequest with cause=mt-Access
#    Verify that UE2 sends ResumeRequest with cause=rna-Update


    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains eventType equal to direct

#    Verify that gNB sends [1/2]LocationReport containing NRCELL-1 identity
#    Verify that gNB sends [2/2]LocationReport containing NRCELL-1 identity
#    Verify that gNB sends [1/2]LocationReport without timestamp
#    Verify that gNB sends [2/2]LocationReport without timestamp
#    Verify that [1/2]LocationReport contains eventType equal to direct
#    Verify that [2/2]LocationReport contains eventType equal to direct

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
    Run Keyword When Not In UTE
    ...        Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '1'}
#    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'true'}
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20

