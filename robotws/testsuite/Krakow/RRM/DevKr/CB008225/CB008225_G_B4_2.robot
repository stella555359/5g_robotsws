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

Suite Setup  Run Setup  f1ap=${True}        different_tacs=${True}      32_bit_long_gnb_id=${True}

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim_slices.lua
...                      CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim_slices.lua
...                      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim_slices.lua
...                      CLOUD_5G_I_LO_AP_LO=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim_slices.lua
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim_slices.lua

*** Test Cases ***

CB008225_G_B4_LRC_ue_presence_in_the_area_of_interest_UE_in_RRC_CONNECTED_then_UE_inactive_then_UE_moves_out_Area_Of_Interest
    [Documentation]
    ...  DESCRIPTION:

    [Tags]    B4_2
    [Setup]    Prepare test environment
    [Teardown]  Cleanup after test
    Log to console      Disabling rrcInactLocationReportEnabled
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'false'}
    Log to console      Attaching NRCELL-1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    EXPECT FLOW: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=ue-presence-in-area-of-interest for cells and tacs and rannodeids
    PASS FLOW: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-3 identity in areaOfInterestList

    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 3:3
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 200:4
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 201:5
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 300:6
    Verify that LocationReport contains gNBID-locationReportingReferenceID mapping 1:7
    Verify that LocationReport contains gNBID-locationReportingReferenceID mapping 2:8

    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 2
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 3
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 4
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 5
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 6
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 7
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 8

    Log to console      UE waits to go inactive cell1
    run keyword and ignore error       Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Log to console      UE inactive


    Change for UE1 target cell of resume procedure to 2 with cause mt_Access
    EXPECT FLOW: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
#    Trigger RRCResume procedure for UE1 by running UL traffic towards NRCELL-2
    Log to console      UE resume to cell 2
    PASS FLOW: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-3 identity in areaOfInterestList

    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 3:3
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 200:4
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 201:5
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 300:6
    Verify that LocationReport contains gNBID-locationReportingReferenceID mapping 1:7
    Verify that LocationReport contains gNBID-locationReportingReferenceID mapping 2:8

    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 2
    Verify that LocationReport does not contain locationReportingReferenceID 3 in UEPresenceInAreaOfInterestList
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 4
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 5
    Verify that LocationReport does not contain locationReportingReferenceID 6 in UEPresenceInAreaOfInterestList
    Verify that LocationReport does not contain locationReportingReferenceID 7 in UEPresenceInAreaOfInterestList
    Verify that LocationReport does not contain locationReportingReferenceID 8 in UEPresenceInAreaOfInterestList

    On failure       Verify that UE1 resume procedure was successfull via sending traffic

    Log to console      UE HOs to cell1
    EXPECT FLOW: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Perform intra-frequency intra-gNB handover from gNB2 cell2 to cell1 for UE1
    PASS FLOW: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-2 identity in areaOfInterestList
    Verify that LocationReport contains NRCELL-3 identity in areaOfInterestList

    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 3:3
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 200:4
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 201:5
    Verify that LocationReport contains TAC-locationReportingReferenceID mapping 300:6
    Verify that LocationReport contains gNBID-locationReportingReferenceID mapping 1:7
    Verify that LocationReport contains gNBID-locationReportingReferenceID mapping 2:8

    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 2
    Verify that LocationReport does not contain locationReportingReferenceID 3 in UEPresenceInAreaOfInterestList
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 4
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 5
    Verify that LocationReport does not contain locationReportingReferenceID 6 in UEPresenceInAreaOfInterestList
    Verify that LocationReport does not contain locationReportingReferenceID 7 in UEPresenceInAreaOfInterestList
    Verify that LocationReport does not contain locationReportingReferenceID 8 in UEPresenceInAreaOfInterestList

    On failure       Verify that UE1 resume procedure was successfull via sending traffic

*** Keywords ***
Prepare test environment
    Enable interaction CB008225-G with 5GC000770
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    Execute egate command    cmd=amf_paging_param id=1 max_paging_retries=10
    Execute egate command    cmd=ue_nr_rrc_setup_param id=1 pagingdelay=1s
    Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    Observe NG-C ICS messages and update database



Cleanup after test
    Detach and kill UE1
    Detach and kill UE2
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20
