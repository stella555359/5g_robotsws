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
...      CFAM Leader        : Jędrzej Jarecki       (Nokia - PL/Krakow) <jedrzej.jarecki@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...                           Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
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
...      [02.08.2022] - Create Test Suite
...      [30.11.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=868819)
...      [11.05.2023] - Migration to new AP_LO

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/2c_FS_TDD_n41_FR2_n258_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1b_n41_n258.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_2c_n41_n258.xml

${nrcell2_pci}=  52

*** Test Cases ***
CB008717-D-B1b_No_NRDC_A4_activation_for_UEs_with_insufficient_capabilites
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the situation when UEs are attached with insufficient capabilities and A4 measurements are not
    ...  configured in these UEs after attach and PDU Session Setup with ICS procedure. Three cases with three UEs with different capabilities
    ...  are checked:
    ...  - UE1: does not have correct band combination in ue capabilities
    ...  - UE2: does not have correct channel bandwidth in ue capabilities
    ...  - UE3: correct ue capabilities but NIDD parameter rejectSuppBcs is set to BCS4
    ...
    ...  PRECONDITION:
    ...  - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...  - NRBTS/actBcsCheck is set to 2 (enabled_NRDC)
    ...  - NRBTS/rejectSuppBcs is set to 0 (none)
    ...  - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  - NRBTS/NRCELL-1 simulated on AEHC radio module - NR_BAND: n41 (TDD)
    ...  - NRBTS/NRCELL-1 channel bandwidth: 70MHz (TDD)
    ...  - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n258 (TDD)
    ...  - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...  - UE-NR-Capability
    ...    - for all UEs: measAndMobParameters/measAndMobParameters-Common/independentGapConfig: supported
    ...    - UE1: supports band combination n41_n257 instead of n41_n258
    ...    - UE2: supports 50Mhz channel bandwidth instead of 100MHz for FR2
    ...    - UE3: NRBTS/rejectSuppBcs is set to 1 (BCS4)
    ...   - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...   - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...   - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...
    ...  POSTCONDITION:
    ...  - UE1 does not have A4 measurements configured
    ...  - UE2 does not have A4 measurements configured
    ...  - UE3 has A4 measurements configured
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15954
    ...       *BACKLOG ID: FCA_5G_L2L3-101988
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik   (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: USCB008717-D#B1: Successful PSCell Addition
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
    ...  [23.11.2022] - Create first Test Case shape
    ...  [30.11.2022] - Final TC shape
    ...  [30.11.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=868819)
    ...  [30.11.2022] - Add TC to CRT
    ...  [11.05.2023] - Migration to new AP_LO

    [Tags]  D-B1b

    [Setup]  Prepare test environment D-B1b

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows to check if A4 measurements are not configured for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows to check if A4 measurements are not configured for UE1, gNB2 and AMF1

    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows to check if A4 measurements are not configured for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows to check if A4 measurements are not configured for UE2, gNB2 and AMF1

    Configure    {'MOC': 'NRBTS', 'rejectSuppBcs': 'BCS4'}

    Attach UE3 without ICS to gNB2 cell1
    Set expected messages flows to check if A4 measurements are not configured for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows to check if A4 measurements are not configured for UE3, gNB2 and AMF1

#   CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 3 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (700, 900) for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 0 for NRCELL-1
    #Verify that SUM_UE_NRDC_MN_CU is in range (0, 0) for NRCELL-1

    Detach and kill UE3

    Configure    {'MOC': 'NRBTS', 'rejectSuppBcs': 'none'}

    Attach UE3 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:258 and ssb:2043739 for UE3
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE3
    Verify that 2 out of 2 RRCReconfiguration does not contain ssb-RSRP for UE3
    Detach and kill UE3

    Configure    {'MOC': 'NRBTS', 'rejectSuppBcs': 'BCS4', 'actBcsCheck': 'enabled_FR1'}

    Attach UE3 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:258 and ssb:2043739 for UE3
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE3
    Verify that 2 out of 2 RRCReconfiguration does not contain ssb-RSRP for UE3
    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-2 for UE3
    Set Test Variable  ${meas_id}
    UE3 sends A4 measurement id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify that UE3 was successfully configured NR-DC for gNB2

#   CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 3 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (700, 900) for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-1
    #Verify that SUM_UE_NRDC_MN_CU is in range (100, 200) for NRCELL-1

    Attach UE6 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
#    Add to UE6 initial PDU session with ICS
    Add to UE6 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE6, gNB2 and AMF1
    UE6 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE6, gNB2 and AMF1
    Verify that UE6 was successfully configured NR-DC for gNB2

    Attach UE7 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE7, gNB2 and AMF1
#    Add to UE7 initial PDU session with ICS
    Add to UE7 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE7, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE7, gNB2 and AMF1
    UE7 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE7, gNB2 and AMF1
    Verify that UE7 was successfully configured NR-DC for gNB2

#   CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 5 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (1300, 1500) for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 3 for NRCELL-1
    #Verify that SUM_UE_NRDC_MN_CU is in range (700, 900) for NRCELL-1

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 2 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 2 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-1
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-1
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 2 for NRCELL-1
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-1
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-1

    Set indexToRFSP to 87 for UE8
    Attach UE8 to gNB2 cell1 with ICS during PDU session setup
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in RRCReconfiguration that UE8 1 DRBs were added
    Set expected messages flows for A4 measurement based PSCell addition for UE8, gNB2 and AMF1
    UE8 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE8, gNB2 and AMF1
    Verify that UE8 was successfully configured NR-DC for gNB2

    # CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 6 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (1600, 1800) for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 4 for NRCELL-1
    #Verify that SUM_UE_NRDC_MN_CU is in range (700, 1200) for NRCELL-1

    [Teardown]  Cleanup after test D-B1b
