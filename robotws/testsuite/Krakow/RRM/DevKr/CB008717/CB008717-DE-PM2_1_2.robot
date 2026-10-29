*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This subfeature introduces successful establishment of MN terminated split bearer - additional content.
...      One NR-DC-SN cell, that can act as PSCell in NR-DC, is successfully activated. After Initial Context Setup,
...      NR DC establishment is attempted for NR DC eligible UEs, MN terminated Split Bearer Addition procedure is
...      successfully completed and bearer type is successfully changed from MCG to MN terminated split bearer.
...
...      TEST SET NAME: CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...
...      TESTING SCOPE:
...      CB008717-A NR-DC Cell Activation for a Secondary Node
...      CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...      CB008717-C UE Release due to AMF Context Release
...      CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...      CB008717-E UE Release without bearer takeback
...      CB008717-G Cell Management for Secondary Node
...      CB008717-H Configuration and Reception of A4 measurements
...      CB008717-I Successful Measurement based PSCell Addition
...      CB008717-J Interaction with event A4
...      CB008717-M Mobilty on PCell
...
...      CONTACTS:
...      CFAM Leader        :
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=720
...                     FTS link:              https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
...                                            /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
...                                            ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [07.08.2023] - Create Test Suite
...      [10.08.2023] - Approved by EFS

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True  faf=2

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/DE/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

*** Test Cases ***
CB008717-DE-PM2-1_incomming_NRDC_capable_UE_via_inter_cell_HO_and_Xn_HO
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the gNB behavior that UE capability for indicating NR-DC support
    ...  should be enquired during the incoming inter-gNB XN HO and intra-gNB inter-cell HO if there is at least one
    ...  cell in gNB in which NR-DC feature is enabled.
    ...  The purpose of this testcase is to verify MAX_UE_NRDC_CAP counter
    ...
    ...  Additional part added related to outgoing XN HOs to check proper DECREMETN of MAX/SUM PM COUNTERS
    ...
    ...  PRECONDITION:
    ...  For real_gNB same preconditions as in CB008717-D-B1c with addition to:
    ...  NRBTS/NRPMRNL/miNrRSACU = 5min
    ...  NRBTS/NRPMRNL/miNrUeState = 5min
    ...  XN HO is supported between real and simulated gNB
    ...  NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...  NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...  NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...  NRBTS/NRCELL-4 simulated on AHCA radio module - NR_BAND: n5
    ...  Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation;
    ...  NRBTS/NRCELL-1 doesnt have NR-DC enabled, NRBTS/NRCELL-2 have NR-DC enabled
    ...  One FR2 cell (NRBTS/NRCELL-3) is active in pure NR-DC-SN mode of operation with enabled NR-DC
    ...  Both real_gNB - gNB2 and sim_gNB - gNB3 are up and running
    ...  XN link is established between sim_gNB and real_gNB
    ...  UE-NR-Capability same as in CB008717-D-B1c for UE1, UE2, UE3, UE4 with addition to:
    ...  nonCriticalExtension/nonCriticalExtension/receivedFilters/capabilityRequestFilterCommon/
    ...  /mrdc-Request/includeNR-DC - NOT present

    ...  POSTCONDITION:
    ...  - UE1 handovered to sim_gNB
    ...  - UE2 handovered to sim_gNB
    ...  - UE4 and UE5 handovered to NRCELL-2
    ...  - UE3 released from gNB
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_PM_787
    ...       *BACKLOG ID:
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyzak  (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_PM_787
    ...  CFAM link:       https://gates.nsn-net.net/view/00025f8e#o=720
    ...  FTS link:        https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
    ...                   /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
    ...                   ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [07.08.2023] - Create first Test Case shape
    ...  [10.08.2023] - Final TC shape
    ...  [16.08.2023] - Add additional outgoing XN HOs

    [Tags]  DE-PM2-1

    [Setup]  Prepare test environment for XN HOs

    #Wait for new PM Counter collecting period

    Attach UE1 with ICS to simulated gNB3

    Set expected messages flows to check incomming XN handover for UE1, gNB2 and gNB3
    Set expected messages flows to check UECapabilityEnquiry request for UE1, gNB2 and AMF1

    Trigger UE1 handover from sim_gNB to gNB2 NRCELL-1 with insufficient UECapabilites
    Verify that expected message flows for incomming XN handover occured for UE1, gNB2 and gNB3
    Verify that expected message flows for UECapabilityEnquiry request occured for UE1, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE1

    Attach UE2 with ICS to simulated gNB3

    Set expected messages flows to check incomming XN handover for UE2, gNB2 and gNB3
    Set expected messages flows to check UECapabilityEnquiry request for UE2, gNB2 and AMF1
    Trigger UE2 handover from sim_gNB to gNB2 NRCELL-1 with insufficient UECapabilites
    Verify that expected message flows for incomming XN handover occured for UE2, gNB2 and gNB3
    Verify that expected message flows for UECapabilityEnquiry request occured for UE2, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE2
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE2

    #Wait for new PM Counter collecting period

    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (400, 600) for NRCELL-1

    Attach UE3 with ICS to simulated gNB3
    Set UE3 to ignore RRCReconfiguration

    Set expected messages flows to check failure during incomming XN handover for UE3, gNB2 and gNB3
    Trigger UE3 handover from sim_gNB to gNB2 NRCELL-1 with insufficient UECapabilites
    Verify that expected message flows for failure during incomming XN handover occured for UE3, gNB2 and gNB3

    #Wait for new PM Counter collecting period

    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is equal to 600 for NRCELL-1

#    Deregister UE1 from AMF1     #removed due to merge with PM_2_1
#    Verify that AMF1 release UE with Cause Group: nas and Cause: 'normal-release' #removed due to merge with PM_2_1

    Attach UE4 without ICS to gNB2 cell1
    Set expected messages flows to check UECapabilityEnquiry request for UE4, gNB2 and AMF1
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 87
    Verify that A4 measurements are not configured for UE4, gNB2 and AMF1 in RRCReconfiguration message
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE4
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE4

    Set expected messages flows to check UECapabilityEnquiry request for UE4, gNB2 and AMF1
    Set expected messages flows to check A4 activation after inter-cell HO for UE4
    Trigger intra-gNB inter-cell HO to NRCELL-2 for UE4
    Verify that A4 measurements configured for UE4 after inter-cell HO in RRCReconfiguration message
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE4, gNB2 and AMF1

    Attach UE5 without ICS to gNB2 cell1
    Set expected messages flows to check UECapabilityEnquiry request for UE5, gNB2 and AMF1
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 87
    Verify that expected message flows for UECapabilityEnquiry request occured for UE5, gNB2 and AMF1
    Verify that A4 measurements are not configured for UE5, gNB2 and AMF1 in RRCReconfiguration message
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE5
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE5

    Set expected messages flows to check UECapabilityEnquiry request for UE5, gNB2 and AMF1
    Set expected messages flows to check A4 activation after inter-cell HO for UE5
    Trigger intra-gNB inter-cell HO to NRCELL-2 for UE5
    Verify that A4 measurements configured for UE5 after inter-cell HO in RRCReconfiguration message
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE5, gNB2 and AMF1

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 3 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (600, 700) for NRCELL-1
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (500, 600) for NRCELL-2

    # Part related to CB008717-DE-PM2_4_NR-DC_user_capability_outgoing_handover
    Set expected messages flows to check outgoing XN handover for UE1, gNB2 and gNB3
    ${meas_id}=   Get UE1 active Meas Id for frequency 425070 EventA3 and trigger rsrp
    Set Test Variable  ${meas_id}

    Trigger UE1 handover from gNB2 NRCELL-1 to sim_gNB with meas_id eq ${meas_id}
    Verify expected messages flows for outgoing XN handover for UE1, gNB2 and gNB3

    Set expected messages flows to check outgoing XN handover for UE2, gNB2 and gNB3
    ${meas_id}=   Get UE2 active Meas Id for frequency 425070 EventA3 and trigger rsrp
    Set Test Variable  ${meas_id}

    Trigger UE2 handover from gNB2 NRCELL-1 to sim_gNB with meas_id eq ${meas_id}
    Verify expected messages flows for outgoing XN handover for UE2, gNB2 and gNB3

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (10, 100) for NRCELL-1

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 0 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is equal to 0 for NRCELL-1

    [Teardown]    Cleanup after test DE-PM2_1

CB008717-DE-PM2-2_incomming_NRDC_capable_UE_via_inter_RAT_and_NG_HO
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the gNB behavior that UE capability for indicating NR-DC support
    ...    should be enquired during the incoming inter-gNB NG HO and inter-RAT HO if there is at least one cell in gNB
    ...    in which NR-DC feature is enabled.
    ...  The purpose of this testcase is to verify MAX_UE_NRDC_CAP counter
    ...
    ...  PRECONDITION:
    ...  For real_gNB same preconditions as in CB008717-D-B1c with addition to:
    ...  NRBTS/NRPMRNL/miNrRSACU = 5min
    ...  NRBTS/NRPMRNL/miNrUeState = 5min
    ...  NRBRS/NRPMRNL/miNrCUCM = 5min
    ...  NG HO is supported between real and simulated gNB
    ...  INTER RAT HO is supported between real and simulated gNB
    ...  NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...  NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...  NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...  NRBTS/NRCELL-4 simulated on AHCA radio module - NR_BAND: n5
    ...  Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation;
    ...  NRBTS/NRCELL-1 doesnt have NR-DC enabled, NRBTS/NRCELL-2 have NR-DC enabled
    ...  One FR2 cell (NRBTS/NRCELL-3) is active in pure NR-DC-SN mode of operation with enabled NR-DC
    ...  Both real_gNB - gNB2 and sim_gNB - gNB3 are up and running
    ...  UE-NR-Capability same as in CB008717-D-B1c with addition support for EUTRA params
    ...  POSTCONDITION:
    ...  - Counters values as expected
    ...  - UECapablityEnquiry procedure visible after incomming HOs
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_PM_787
    ...       *BACKLOG ID:
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyzak  (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_PM_787
    ...  CFAM link:       https://gates.nsn-net.net/view/00025f8e#o=720
    ...  FTS link:        https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
    ...                   /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
    ...                   ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [17.08.2023] - Create first Test Case shape
    ...  [23.08.2023] - Final TC shape
    ...  [04.10.2023] -  PR728511 migrate from PEAK to MAX

    [Tags]  DE-PM2-2

    [Setup]  Prepare test environment for NG HOs

    #Wait for new PM Counter collecting period
    Attach UE6 with ICS to simulated gNB3

    Set expected messages flows to check incomming NG handover for UE6, gNB2 and AMF1
    Set expected messages flows to check UECapabilityEnquiry request for UE6, gNB2 and AMF1

    Trigger UE6 handover from sim_gNB to gNB2 NRCELL-1 with insufficient UECapabilites
    Verify that expected message flows for incomming NG handover occured for UE6, gNB2 and AMF1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE6, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE6
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE6

    Attach UE7 with ICS to simulated gNB3

    Set expected messages flows to check incomming NG handover for UE7, gNB2 and AMF1
    Set expected messages flows to check UECapabilityEnquiry request for UE7, gNB2 and AMF1

    Trigger UE7 handover from sim_gNB to gNB2 NRCELL-1 with insufficient UECapabilites
    Verify that expected message flows for incomming NG handover occured for UE7, gNB2 and AMF1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE7, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE7
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE7

    Attach UE1 with ICS to simulated gNB3

    Set expected messages flows to check incomming NG handover for UE1, gNB2 and AMF1
    Set expected messages flows to check UECapabilityEnquiry request for UE1, gNB2 and AMF1

    Trigger UE1 handover from sim_gNB to gNB2 NRCELL-1 with sufficient UECapabilites
    Verify that expected message flows for incomming NG handover occured for UE1, gNB2 and AMF1
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE1, gNB2 and AMF1

    Attach UE2 with ICS to simulated gNB3

    Set expected messages flows to check incomming NG handover for UE2, gNB2 and AMF1
    Set expected messages flows to check UECapabilityEnquiry request for UE2, gNB2 and AMF1

    Trigger UE2 handover from sim_gNB to gNB2 NRCELL-2 with sufficient UECapabilites
    Verify that expected message flows for incomming NG handover occured for UE2, gNB2 and AMF1
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE2, gNB2 and AMF1

    #Wait for new PM Counter collecting period

    #Verify that MAX_UE_NRDC_CAP is equal to 3 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (700, 900) for NRCELL-1
    #Verify that MAX_UE_NRDC_CAP is equal to 1 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (100, 300) for NRCELL-2

    Deregister UE1 from AMF1
    Deregister UE2 from AMF1
    Deregister UE6 from AMF1
    Deregister UE7 from AMF1

    Enable InterRAT HO configuration on gNB

    Attach UE8 without ICS to gNB2 cell1
    Add to UE8 initial PDU session with ICS and indexToRFSP equal 87
    Perform inter RAT handover to LTE for UE8

    Attach UE9 without ICS to gNB2 cell1
    Add to UE9 initial PDU session with ICS and indexToRFSP equal 87
    Perform inter RAT handover to LTE for UE9

    #Wait for new PM Counter collecting period
    Set UE8 InterRAT sufficient NRDC capability in ue_param
    Set expected messages flows to check UECapabilityEnquiry request for UE8, gNB2 and AMF1
    Perform inter RAT handover from LTE to 5G for UE8
    Verify that expected message flows for UECapabilityEnquiry request occured for UE8, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE8
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE8


    Set UE9 InterRAT sufficient NRDC capability in ue_param
    Set expected messages flows to check UECapabilityEnquiry request for UE9, gNB2 and AMF1
    Perform inter RAT handover from LTE to 5G for UE9
    Verify that expected message flows for UECapabilityEnquiry request occured for UE9, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE9
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE9

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (500, 600) for NRCELL-1

    [Teardown]    Cleanup after test DE-PM2_2
