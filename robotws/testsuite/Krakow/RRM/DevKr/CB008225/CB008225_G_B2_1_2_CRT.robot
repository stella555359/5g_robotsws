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
...          https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008225/CB008225_G_B2_1_2_CRT.robot
...
...          [17.05.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00     DISABLE_GENERATION
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008225_G_B2_LRC_ue_presence_in_the_area_of_interest_and_change_of_serve_cell_UE_in_RRC_INACTIVE_RAN_Paging_not_sent_LocationReport_sent
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure when UE is in RRC-INACTIVE state and AMF sends NGAP: LocationReportingControl
    ...  with 'change-of-serve-cell' to gNB for UE. The gNB should respond with NGAP: LocationReport (with NRCGI, TAI and timestamp) to AMF. Paging
    ...  and RRCResume procedure is not started for UE.
    ...  Second part of test is check exactly the same procedure as before but when AMF sends NGAP:LocationReportingControl with
    ...  'ue-presence-in-area-of-interest'.
    ...  Additionaly this scenario checks situation when feature flag rrcInactLocationReportEnabled is disabled and AMF sends
    ...  NGAP: LocationReportingControl - the gNB should not send NGAP: LocationReport then.
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
    ...     - NRBTS.rrcInactPreferredStateEnabled = true (CB006597)
    ...     - NRBTS.actRrcReleasePreference = true (CB006597)
    ...     - NRBTS.outOfConnectedPreference = inavtive (CB006597)
    ...     - NRBTS.timerReleasePreferenceProhibit = s0 (CB006597)
    ...
    ...  TEST STEPS:
    ...     1. Attach UE1 to gNB cell1 with ICS during PDU session setup
    ...     2. UE1 goes to RRC_INACTIVE state by inavtivity (NRBTS.drbRrcInactInactivityTimerSA expired)
    ...     3. The gNB receives from AMF NGAP: LocationReportingControl with 'change-of-serve-cell'
    ...     4. Verify if Paging and RRCResume procedures are not started
    ...     5. Verify if the gNB sends NGAP: LocationReport with UserLocationInformation IE (including NRCGI+TAI+timestamp) for concerned UE
    ...        (AMF UE NGAP ID) with 'change-of-serve-cell'
    ...     6. Detach UE1.
    ...     7. Disable 8225-G feature by setting flag rrcInactLocationReportEnabled to false
    ...     8. Perform the same steps as before from step 1 to step 6 for UE2 and verify if the gNB does not send NGAP: LocationReport
    ...     9. Enable 8225-G feature by setting flag rrcInactLocationReportEnabled to true
    ...     10. Attach UE1 to gNB cell1 with ICS during PDU session setup
    ...     11. UE1 goes to RRC_INACTIVE state by sending UAI with RRCPreferredState 'inactive'
    ...     12. The gNB receives from AMF NGAP: LocationReportingControl with 'ue-presence-in-area-of-interest' with NRCELL-2 as Area of Interest
    ...     13. Verify if Paging and RRCResume procedures are not started
    ...     14. Verify if the gNB sends NGAP: LocationReport with UserLocationInformation IE (including NRCGI+TAI+timestamp) for concerned UE
    ...         (AMF UE NGAP ID) with 'ue-presence-in-area-of-interest' with NRCELL-2 as Area of Interest
    ...     15. The gNB receives from AMF NGAP: LocationReportingControl with 'ue-presence-in-area-of-interest' with both NRCELL-1 and NRCELL-2
    ...         as Areas of Interest
    ...     16. Verify if Paging and RRCResume procedures are not started
    ...     17. Verify if the gNB sends NGAP: LocationReport with UserLocationInformation IE (including NRCGI+TAI+timestamp) for concerned UE
    ...         (AMF UE NGAP ID) with 'ue-presence-in-area-of-interest' with both NRCELL-1 and NRCELL-2 as Areas of Interest
    ...     18. Detach UE1.
    ...     19. Disable 8225-G feature by setting flag rrcInactLocationReportEnabled to false
    ...     20. Perform the same steps as before from step 10 to step 18 for UE3 and verify if the gNB does not send NGAP: LocationReport
    ...
    ...  POSTCONDITION:
    ...     - RAN Paging procedure is not started
    ...     - UEs are in RRC_INACTIVE state
    ...     - The gNB sends to AMF first NGAP: LocationReport with UserLocationInformation IE (including NRCGI+TAI+timestamp) for concerned UE
    ...       (AMF UE NGAP ID) with 'change-of-serve-cell'
    ...     - The gNB sends to AMF second NGAP: LocationReport with UserLocationInformation IE (including NRCGI+TAI+timestamp) for concerned UE
    ...       (AMF UE NGAP ID) with with 'ue-presence-in-area-of-interest' with NRCELL-2 as Area of Interest
    ...     - The gNB sends to AMF third NGAP: LocationReport with UserLocationInformation IE (including NRCGI+TAI+timestamp) for concerned UE
    ...       (AMF UE NGAP ID) with with 'ue-presence-in-area-of-interest' with both NRCELL-1 and NRCELL-2 as Areas of Interest
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_18114;5G_CP_OTH_1894;5G_CP_OTH_12448;5G_CP_OTH_13056;5G_CP_ARC_ALG_9728;
    ...                               5G_CP_OTH_12454;5G_CP_OTH_1892
    ...       *BACKLOG ID: FCA_5G_L2L3-140841
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
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008225/CB008225_G_B2_1_2_CRT.robot
    ...
    ...      [20.03.2023] - Create first Test Case shape
    ...      [20.06.2023] - Final version
    ...      [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

    [Tags]    B2_1

    [Setup]    Prepare test environment
    Log to console      Checking change-of-serving-cell succ case
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1
    Sleep  5

    EXPECT FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=10]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=10]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    Log to console      Checking change-of-serving-cell failure case
    # disable feature
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'false'}

    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE2 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_2
    Sleep  5

    EXPECT FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=10]: UE_2 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    Send LocationReportingControl for UE2 with eventType=change-of-serving-cell
    FAIL FLOW[timeout=10]: AMF1 NGAP locationReport

    FAIL FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=10]: UE_2 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    Log to console  Cleanup
    Cleanup after test

    Log to console      Checking ue-presence-in-area-of-interest succ case

    Prepare test environment B2_2
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by UAI
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 is not sent
    EXPECT FLOW[timeout=5]: AMF1 NGAP paging is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    EXPECT FLOW: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for NRCELL-2
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    FAIL FLOW[timeout=5]: AMF1 NGAP paging is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    PASS FLOW: AMF1 NGAP locationReport
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Run Keyword and Continue on Failure
    ...      Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 2

    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 is not sent
    EXPECT FLOW[timeout=5]: AMF1 NGAP paging is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    EXPECT FLOW: AMF1 NGAP locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for both cells
    PASS FLOW: AMF1 NGAP locationReport

    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Run Keyword and Continue on Failure
    ...      Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 2

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 is not sent
    FAIL FLOW[timeout=5]: AMF1 NGAP paging is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup


    Log to console      Checking ue-presence-in-area-of-interest failure case

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'false'}

    Attach UE3 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE3 goes to RRC_INACTIVE by UAI
    EXPECT FLOW[timeout=5]: UE_3 NR-RRC RRCResumeRequest1 is not sent
    EXPECT FLOW[timeout=5]: AMF1 NGAP paging is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    EXPECT FLOW: AMF1 NGAP locationReport
    Send LocationReportingControl for UE3 with eventType=ue-presence-in-area-of-interest for NRCELL-2
    Verify that LocationReportingControl contains NRCELL-locationReportingReferenceID mapping 2:2
    FAIL FLOW[timeout=5]: AMF1 NGAP paging is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    FAIL FLOW: AMF1 NGAP locationReport



    EXPECT FLOW[timeout=5]: UE_3 NR-RRC RRCResumeRequest1 is not sent
    EXPECT FLOW[timeout=5]: AMF1 NGAP paging is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    EXPECT FLOW: AMF1 NGAP locationReport
    Send LocationReportingControl for UE3 with eventType=ue-presence-in-area-of-interest for both cells
    FAIL FLOW: AMF1 NGAP locationReport



    [Teardown]    Cleanup after test

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

Prepare test environment B2_2
    Enable interaction CB008225-G with 5GC000770
    Enable interaction CB008225 with CB006597


Cleanup after test
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20

