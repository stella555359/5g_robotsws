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

Suite Setup  Run Setup  f1ap=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***

CB008225_G_B3_LRC_sent_three_times_with_different_eventTypes_for_UE_in_RRC_INACTIVE_when_eventType_direct_causes_resume_to_other_cell
    # TODO Dawid
    [Documentation]
    ...  DESCRIPTION:
    ...  NRBTS.rrcInactLocationReportEnabled = true (CB008225)
    ...  NRBTS.actLocationReportingSA = true (5GC000770)

    [Tags]    B3_7
    [Setup]     Prepare test environment
    [Teardown]    Cleanup after test

    Log to console      UE attach
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Log to console      UE goes inactive
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA

    Log to console      UE receievs LCR wit AoI with 2 cells
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 is not sent
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    EXPECT FLOW: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=10]: AMF1 NGAP 2*locationReport
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
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    FAIL FLOW[timeout=10]: AMF1 NGAP 2*locationReport

    Log to console      UE receives LCR with change of serving cell

    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 is not sent

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=10]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=10]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 is not sent
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell



    Change for UE1 target cell of resume procedure to 2 with cause mt_Access
    Log to console      UE resume to cell2 by LocationReport direct
    EXPECT FLOW[timeout=10]: AMF1 NGAP 3*locationReport
    EXPECT UE1 rrcResume successfull procedure ending in CONNECTED state
    Send LocationReportingControl for UE1 with eventType=direct
    PASS FLOW[timeout=10]: AMF1 NGAP 3*locationReport
    PASS UE1 rrcResume successfull procedure ending in CONNECTED state


    Log to console      Verify 3 location reports for 3 events
    Verify that [1/3]LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that [2/3]LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that [3/3]LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that gNB sends [1/3]LocationReport without timestamp
    Verify that gNB sends [2/3]LocationReport without timestamp
    Verify that gNB sends [3/3]LocationReport without timestamp

    Run Keywords And Expect Single Pass
    ...    Verify that [1/3]LocationReport contains NRCELL-2 identity in areaOfInterestList   AND
    ...    Verify that [2/3]LocationReport contains NRCELL-2 identity in areaOfInterestList   AND
    ...    Verify that [3/3]LocationReport contains NRCELL-2 identity in areaOfInterestList

    Run Keywords And Expect Single Pass
    ...   Verify that [1/3]LocationReport contains eventType equal to change-of-serve-cell    AND
    ...   Verify that [2/3]LocationReport contains eventType equal to change-of-serve-cell    AND
    ...   Verify that [3/3]LocationReport contains eventType equal to change-of-serve-cell

    Run Keywords And Expect Single Pass
    ...   Verify that [1/3]LocationReport contains eventType equal to direct   AND
    ...   Verify that [2/3]LocationReport contains eventType equal to direct   AND
    ...   Verify that [3/3]LocationReport contains eventType equal to direct


    Run Keywords And Expect Single Pass
    ...   Check mapping and presence between NRCELL and locationReportingReferenceID in areaOfInterestList in [1/3] message   AND
    ...   Check mapping and presence between NRCELL and locationReportingReferenceID in areaOfInterestList in [2/3] message   AND
    ...   Check mapping and presence between NRCELL and locationReportingReferenceID in areaOfInterestList in [3/3] message


    Log to console      UE resume to cell2 suceessfull



*** Keywords ***

Check mapping and presence between NRCELL and locationReportingReferenceID in areaOfInterestList in ${num} message
    Verify that ${num}LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that ${num}LocationReport contains uEPresence equal to out for locationReportingReferenceID 1
    Verify that ${num}LocationReport contains NRCELL-locationReportingReferenceID mapping 2:2
    Verify that ${num}LocationReport contains uEPresence equal to in for locationReportingReferenceID 2


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
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20
