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

Suite Setup  Run Setup  f1ap=${True}        custom_ranac=1,2

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
${VIA_T380}=   ${True}

*** Test Cases ***

CB008225_G_B3_LRC_ue_presence_in_the_area_of_interest_for_UE_in_RRC_INACTIVE_during_RNA_update_t380_expiry
    # TODO Dawid
    [Documentation]
    ...  DESCRIPTION:
    ...  NRBTS.rrcInactLocationReportEnabled = true (CB008225)
    ...  NRBTS.actLocationReportingSA = true (5GC000770)
    ...  NRBTS/NRCELL-1.ranAC = 1
    ...  NRBTS/NRCELL-2.ranAC = 2

    [Tags]    B3_5

    [Setup]    Prepare test environment

    Edit object attributes    object_name=NRBTS-1    t380=5min      bts_id=1
    Log to console      UE attach
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1
    Log to console      UE inactive
    Log to console      UE receivs LCR with AoI for cell 1
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

    Log to console      UE resumes to cell2 via rNA update (via t380 on ap or by comannd, depending on VIA_T380 varaible)
    EXPECT FLOW[timeout=310]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=305]: AMF1 NGAP 2*locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2
    PASS FLOW[timeout=310]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=305]: AMF1 NGAP 2*locationReport
    Verify that AreaCodeList contains AreaCode equal 2 for UE_1
    Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 1
    Verify that gNB sends LocationReport without timestamp


    Log to console      UE resumes to cell2 via rNA update without cell change
    EXPECT FLOW[timeout=305]: AMF1 NGAP locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2
    FAIL FLOW[timeout=305]: AMF1 NGAP locationReport


    Log to console      UE resumes to cell2 via to connected
    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    Log to console      UE resumes to cell1 via rNA update (via t380 on ap or by comannd, depending on VIA_T380 varaible)
    EXPECT FLOW[timeout=310]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=305]: AMF1 NGAP 2*locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-1
    PASS FLOW[timeout=310]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=305]: AMF1 NGAP 2*locationReport
    Verify that AreaCodeList contains AreaCode equal 2 for UE_1
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that gNB sends LocationReport without timestamp

#    Repeat Keyword    2 times    Repeat Keyword with RNA update    # KW executes very long - one loop 20min (4 x T380 timer value [5min])

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
#    Disable interaction CB008225-G with 5GC000770
#    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20

Repeat Keyword with RNA update
    Log to console      UE resumes to cell2 via rNA update (via t380 on ap or by comannd, depending on VIA_T380 varaible)
    EXPECT FLOW[timeout=320]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-1
    PASS FLOW[timeout=320]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1
    Verify that LocationReport contains NRCELL-1 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains uEPresence equal to in for locationReportingReferenceID 1
    Verify that gNB sends LocationReport without timestamp


#    Log to console      UE resumes to cell2 via to connected
    Log to console      UE rna-update to cell2
    EXPECT FLOW: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    FAIL FLOW: AMF1 NGAP locationReport

    Log to console      UE resumes to cell2 via rNA update (via t380 on ap or by comannd, depending on VIA_T380 varaible)
    EXPECT FLOW[timeout=320]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2
    PASS FLOW[timeout=320]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that AreaCodeList contains AreaCode equal 2 for UE_1
    Verify that LocationReport contains NRCELL-2 identity in userLocationInformationNR
    Verify that LocationReport contains NRCELL-1 identity in areaOfInterestList
    Verify that LocationReport contains pLMNIdentity 0x134198 in userLocationInformationNR
    Verify that LocationReport contains pLMNIdentity 0x134198 in areaOfInterestList
    Verify that LocationReport contains NRCELL-locationReportingReferenceID mapping 1:1
    Verify that LocationReport contains uEPresence equal to out for locationReportingReferenceID 1
    Verify that gNB sends LocationReport without timestamp


#    Log to console      UE resumes to cell2 via to connected
    Log to console      UE rna-update to cell2
    EXPECT FLOW: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    FAIL FLOW: AMF1 NGAP locationReport
