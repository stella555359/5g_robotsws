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
...          [21.07.2023] - Create Test Suite
...          [28.07.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup  f1ap=${True}   custom_ranac=1, 2

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
...        CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
...        CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_2c_1eNBsim_1gNBsim.lua
${VIA_T380}=   ${False}

*** Test Cases ***

CB008225_G_B3_3_4_5_LR_change_of_serve_cell_during_rna_update_procedure_CRT
    [Documentation]
    ...  DESCRIPTION: This test scenario is designed for CRT and combines 3 test: G-B3-3, G-B3-4 and G-B3-5
    ...  [G-B3-3] CB008225_G_B3_LRC_change_of_serve_cell_for_UE_in_RRC_INACTIVE_during_RNA_update_ranAC_different_on_cells:
    ...     This test scenario describes the gNB behavior for successful location reporting procedure after transition of suspended UE1
    ...  from RRC_INACTIVE to RRC_CONNECTED state to different cell within the same gNB. The gNB should send NGAP: Location Report (with NRCGI, TAI).
    ...  As a precondition when UE1 is in RRC-INACTIVE state AMF sends NGAP: LocationReportingControl with 'change-of-serve-cell' to gNB for UE1.
    ...  The gNB sends Location Report with timestamp. Then RRCResume procedure is triggered by RNA update. On cells ranACs are different
    ...  so RRCResume procedure is unsuccessful and UE1 ends in RRC_INACTIVE state. After that another resume procedure (different than RNA update)
    ...  is triggered towards Cell2 and Location Report is not sent.
    ...  [G-B3-4] CB008225_G_B3_LRC_change_of_serve_cell_and_AoI_for_UE_in_RRC_INACTIVE_during_RNA_update_to_cell_without_ranAC
    ...     This test scenario describes the gNB behavior for successful location reporting procedure after transition of suspended UE1
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
    ...  [G-B3-5] CB008225_G_B3_LRC_ue_presence_in_the_area_of_interest_for_UE_in_RRC_INACTIVE_during_RNA_update_t380_expiry
    ...     This test scenario checks the same steps as in G-B3-3 but with event 'ue-presence-in-the-area-of-interes' and rna-update is sent after
    ...  T380 timer expiry. This scenario is a combination of all these checks for rna-update.
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
    ...     - when UE performs rna-update towards cell with ranAC configured, gNB performs RRCReleae and UE is in INACTIVE state
    ...     - when UE performs rna-update towards cell without ranAC configured, gNB performs fallback to RRCSetup and UE is in CONNECTED state
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UEs (AMF UE NGAP ID)
    ...       when event 'change-of-serve-cell' or 'ue-presence-in-the-area-of-interes' is stored and UE changes cell during rna-update
    ...     - NGAP:LocationReport is not sent to AMF when UE does not change cell during rna-update
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIL + ABIO)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_18155
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
    ...      [21.07.2023] - Create first Test Case shape
    ...      [28.07.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

    [Tags]    B3_3_4_5_CRT

    [Setup]    Run Keywords    Start egate collection    AND    Prepare test environment

    # ------------ G-B3-3 part ------------

    Log to console    G-B3-3 part
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '1'}

    # ------------ B2 part - Send LRC for UE1 in INACTIVE state ------------

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    EXPECT FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started

    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Resume to Cell2 by RAN update towards Cell2 which has different ranAC ------------

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Verify that gNB sends LocationReport containing NRCELL-2 identity
    Verify that gNB sends LocationReport without timestamp
    Verify that LocationReport contains eventType equal to change-of-serve-cell
    Verify that AreaCodeList contains AreaCode equal 1 for UE_1

    # ------------ Resume once again to Cell2 with cause != ranUpdate and verify if Location Report is not sent ------------

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    Detach and kill UE1

    # ------------ G-B3-5 part ------------

    Log to console    G-B3-5 part
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '2'}

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
    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    UE1 triggers RRCResume procedure to NRCELL-2
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    Detach and kill UE1

    # ------------ G-B3-4 part ------------

    Log to console    G-B3-4 part
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': ''}

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

    Send LocationReportingControl for UE1 with eventType=stop-change-of-serving-cell

    # ------------ B2 part - Send LRC for UE1 in INACTIVE state ------------

    EXPECT FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    EXPECT FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReport
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*locationReport
    Send LocationReportingControl for UE1 with eventType=change-of-serving-cell
    PASS FLOW[timeout=10]: AMF1 NGAP locationReport
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*locationReport

    FAIL FLOW[timeout=5]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCResumeRequest1 - RRCResume procedure is not started
    FAIL FLOW[timeout=5]: gNB2 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: gNB2 NGAP pDUSessionResourceSetup

    Verify that gNB sends LocationReport containing NRCELL-1 identity
    Verify that gNB sends LocationReport with timestamp for UE1
    Verify that LocationReport contains eventType equal to change-of-serve-cell

    # ------------ Resume to Cell2 by RAN update towards Cell2 which has no ranAC (feature is deactivated) ------------

    EXPECT FLOW[timeout=5]: AMF1 NGAP locationReport
    Trigger RRCResume procedure for UE1 by running RNA update towards NRCELL-2 with fallback to RRCSetup
    FAIL FLOW[timeout=5]: AMF1 NGAP locationReport

    [Teardown]    Run keywords   Cleanup after test   AND     Stop egate collection


*** Keywords ***
Prepare test environment
    Configure       ${yaml_paths_to_configure}
    Enable interaction CB008225-G with 5GC000770
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    Execute egate command    cmd=amf_paging_param id=1 max_paging_retries=10
    Execute egate command    cmd=ue_nr_rrc_setup_param id=1 pagingdelay=1s
    Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    Configure Areas of Interest as 2 cells
    Switch to send rna-update with command
    Observe NG-C ICS messages and update database



Cleanup after test
    Detach and kill UE1
    Detach and kill UE2
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '1-1', 'ranAC': '1'}
    Configure  {'MOC': 'NRPLMNSET_SA', 'ID': '2-1', 'ranAC': '1'}

Switch to send rna-update with timer
    Set Suite Variable    ${VIA_T380}     ${True}

Switch to send rna-update with command
    Set Suite Variable    ${VIA_T380}     ${False}
