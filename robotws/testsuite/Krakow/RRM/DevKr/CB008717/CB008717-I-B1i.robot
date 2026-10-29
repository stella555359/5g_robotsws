*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This subfeature introduces the procedure of NR-DC PSCell addition, triggered by A4 MeasurementReport event, sent by UE
...      with one or more NR-DC PSCell candidates. After the successful procedure appropriate NR-DC PSCell is setup at UE and all NR-DC A4
...      measurements are deactivated at UE.
...
...      TEST SET NAME: CB008717-I Successful Measurement based PSCell Addition
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
...      CFAM Leader        : Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...                           Paweł Wojciechowski   (Nokia - PL/Krakow) <pawel.1.wojciechowski@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:
...      CFAM link:        https://gates.nsn-net.net/view/00025f8e#o=731
...      FTS link:         https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
...                        /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
...                        ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
...      L3 ET Test Plan:  https://confluence.ext.net.nokia.com/display/M5FC/CB008717-I+Sub+feature+refinement?src=contextnavpagetreemode
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [20.12.2022] - Create Test Suite
...      [20.12.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=871736)
...      [10.05.2023] - Migration to new AP_LO

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/I/3c_FS_TDD_n78_FR2_n257_n257_NRDC.lua
${SCFC}=                   Krakow/CB008717/I/SCFC_FS_I_B2_n78_n257_n257.xml
${AP_XML}=                 Krakow/CB008717/I/iphy_FS_3c_n78_n257_n257.xml

*** Test Cases ***
CB008717-I-B1i_MeasReports_filtered_by_gNB
    [Documentation]
    ...  DESCRIPTION: The purpose of this test is to verify that NR-DC PSCell addition is not performed as a result of invalid A4 measurement.
    ...  Issues that make A4 measurement invalid:
    ...   - incorrect physicall cell id in A4 measurement report
    ...   - rsrq or rsrp with values lower than thresholds defined in NRHOIF
    ...   - NR-DC disabled in NRREL
    ...  PSCell addition is performed after providing third A4 measurement with valid candidate.
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - Two FR2 cells (NRBTS/NRCELL-2) are active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - NRBTS/NRCELL-3 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-3 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: supported
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrpCombined
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4ThresholdNrDcSsbRsrq is set to 49
    ...     - NRCELL-1/NRREL-1.nrDcAllowed = true
    ...     - NRCELL-1/NRREL-2.nrDcAllowed = false
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is set to 0
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-2/totalNumberOfRAPreambles is set to 64
    ...
    ...  POSTCONDITION:
    ...     - NR-DC with NRCELL-2 is setup at UE
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15300
    ...       *BACKLOG ID: FCA_5G_L2L3-94515
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik      (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS       (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=731
    ...  Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-I+Sub+feature+refinement?src=contextnavpagetreemode
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [14.12.2022] - Create first Test Case shape
    ...  [20.12.2022] - Final TC shape
    ...  [20.12.2022] - Add TC to CRT
    ...  [20.12.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=871736)
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1i

    [Setup]  Prepare test environment I-B1i

    Attach UE2 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE2
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE2
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE2

    EXPECT FLOW[timeout=3]: gNB2 E1AP bearerContextModification
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition with phycell_id=${nrcell3_pci} nrsrp_nr=85 nrsrq_nr=50
    FAIL FLOW[timeout=3]: gNB2 E1AP bearerContextModification

    EXPECT FLOW[timeout=3]: gNB2 E1AP bearerContextModification
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition with phycell_id=${nrcell2_pci} nrsrp_nr=85 nrsrq_nr=49
    FAIL FLOW[timeout=3]: gNB2 E1AP bearerContextModification

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition with phycell_id=${nrcell2_pci} nrsrp_nr=85 nrsrq_nr=50
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1

    Verify that UE2 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE2
    Verify that RRCReconfiguration does not contain measGapConfig for UE2
    Verify that RRCReconfiguration contains cfra for UE2
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE2
    Verify in RRCReconfiguration for UE2 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell2_pci} for SCG
    Verify in ReconfigurationComplete for UE2 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

    [Teardown]  Cleanup after test I-B1i

