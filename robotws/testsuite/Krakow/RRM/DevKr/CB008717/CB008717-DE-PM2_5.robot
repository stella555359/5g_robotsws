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
...      [04.09.2023] - Version befor UPD002 completed

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Setup  ute-ca=True   GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/2c_FS_FDD_n66_FR2_n258_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1a_FDD_n66_n258.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_2c_n66_n258.xml

*** Test Cases ***
CB008717-DE-PM2-5_PMQAP
    [Documentation]
    ...  DESCRIPTION: This test scenario verifies proper NRDC related PM Counter pegging per PMQAP profile.
    ...               Additional CB006898 enabling and configuration is needed to perform scenario.
    ...               Validation for SUM_UE_NRDC_MN_CU_PMQAP and PEAK_UE_NRDC_MN_CU_PMQAP is performed. Check for exact
    ...               value for SUM_UE_NRDC_MN_CU_PMQAP is not possible due to timing dependencies so only rough check
    ...               will be performed for that PM counter.
    ...
    ...  PRECONDITION:
    ...  For real_gNB same preconditions as in CB008717-D-B1c with addition to:
    ...  NRBTS/NRPMRNL/miNrRSACU = 5min
    ...  NRBTS/NRPMRNL/miNrUeState = 5min
    ...  NRBRS/NRPMRNL/miNrCUCM = 5min
    ...  NRBTS/NRPMRNL/miNrSaCuNrpmqap = 5min
    ...  NRBTS/NRPMRNL/miNrMaxCellCuNrpmqap = 5min
    ...  Configure NRBTS/actNrpmqapProfiles = true
    ...  Configure 4 NRPMQAP profiles:
    ...  NRBTS/NRPMQAP-1/cfg5qiRange= 2-4 (for GBR)
    ...  NRBTS/NRPMQAP-2/cfg5qiRange= 5-9 (for nonGBR)
    ...  NRBTS/NRPMQAP-3/cfg5qiRange= 170 (for nonGBR)
    ...  NRBTS/NRPMQAP-4/cfg5qiRange= 171-253 (for nonGBR not used in test scenario)
    ...  Configure NRCELL-2/ maxNumOfNrDcSnUsers = 5
    ...   UE-NR-Capability same as in CB008717-D-B4d
    ...  POSTCONDITION:
    ...  - UE1-5 with established NRDC connection
    ...  - UE6 connected mode
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_PM_786    /    5G_PM_788
    ...       *BACKLOG ID:
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyzak  (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_PM_788
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
    ...  [28.08.2023] - Create first Test Case shape
    ...  [04.09.2023] - Final TC shape
    ...  [07.09.2023] - Refactor to common function
    ...  [04.10.2023] -  PR728511 migrate from PEAK to MAX
    ...  [20.11.2023] - Add PDUModification scenario with counters

    [Tags]  DE-PM2-5

    [Setup]  Prepare test environment for PMQAP counters check

#    Prepare UE4 and UE5 with specific QoS settings
    Attach UE4 without ICS to gNB2 cell2
    Add to UE4 initial PDU session with ICS
    Add to UE4 second PDU session after ICS
    Add to UE4 third PDU session after ICS
    Add to UE4 PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []
    Trigger UE4 to enter idle mode

    Attach UE5 without ICS to gNB2 cell2
    Add to UE5 initial PDU session with ICS
    Add to UE5 PDU1 session QoS flows with 5QI from list [7,8,9] and delete QoS flows with 5QI from list [170]
    Trigger UE5 to enter idle mode

    #Wait for new PM Counter collecting period

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains only 5QI eq 170
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains only 5QI eq 170
    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1

    Attach UE3 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains only 5QI eq 170
    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1

    Exit idle mode and setup NRDC for UE4
    Exit idle mode and setup NRDC for UE5

    Attach UE6 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
    Add to UE6 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains only 5QI eq 170

    Expect that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE6, gNB2 and AMF1
    UE6 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE6, gNB2 and AMF1

    Add to UE3 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list []

    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Sleep    2
    UE3 sends A4 measurement id=2 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1

    Sleep    210    #to move TC close to new PM period
    Deregister UE2 from AMF1
    Deregister UE3 from AMF1
    Deregister UE5 from AMF1

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 6 for NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-1 in NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 2 for PMQAP-2 in NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 4 for PMQAP-3 in NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-4 in NRCELL-2

    #Verify that SUM_UE_NRDC_CAP is in range (1400, 1800) for NRCELL-2    #6UE in scenario
    #Verify that SUM_UE_NRDC_MN_CU is in range (1100, 1500) for NRCELL-2    #5UE with NRDC in scenario

    ##Verify that SUM_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-1 in NRCELL-2
    ##Verify that SUM_UE_NRDC_MN_CU_PMQAP is in range (400, 600) for PMQAP-2 in NRCELL-2
    ##Verify that SUM_UE_NRDC_MN_CU_PMQAP is in range (1000, 1200) for PMQAP-3 in NRCELL-2
    ##Verify that SUM_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-1 in NRCELL-2
    ##Verify that SUM_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-4 in NRCELL-2

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 7 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 6 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 6 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 1 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 9 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 8 for NRCELL-2

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 3 for NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-1 in NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-2 in NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 2 for PMQAP-3 in NRCELL-2
    ##Verify that MAX_UE_NRDC_MN_CU_PMQAP is equal to 0 for PMQAP-4 in NRCELL-2

    [Teardown]    Cleanup after test DE-PM2-5
