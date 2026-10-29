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
...                           Pawe³ Wojciechowski   (Nokia - PL/Krakow) <pawel.1.wojciechowski@nokia.com>
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
...         [05.01.2023] - Create Test Suite
...         [10.01.2023] - Create Test Case I-B2a
...         [19.01.2023] - Create Test Case I-B2b
...         [02.03.2023] - Create Test Case I-B2c
...         [09.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=878915)
...         [11.05.2023] - Migration to new AP_LO

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/I/3c_FS_TDD_n78_FR2_n257_n257_NRDC.lua
${SCFC}=                   Krakow/CB008717/I/SCFC_FS_I_B2_n78_n257_n257.xml
${AP_XML}=                 Krakow/CB008717/I/iphy_FS_3c_n78_n257_n257.xml

*** Test Cases ***
CB008717-I-B2a_MeasReport_filtered_when_RSRP_combined_and_NRREL_disabled
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the unsuccessful procedure of NR-DC PSCell addition, triggered by A4 Measurement Report event,
    ...  sent by UE with more than one NR-DC PSCell candidates. NR-DC setup is not triggered due to fact that all PSCell candidates from Measurement
    ...  Report are rejected - criteria are not met:
    ...  - First PSCell candidate is filtered by parameter a4MeasNrDcEnabled set to rsrpCombined and rsrq value in A4 Measurement Report lower than
    ...  threshold defined in NRHOIF - a4ThresholdNrDcSsbRsrq set to 49
    ...  - Second PSCell candidate is filtered by parameter nrDcAllowed set to false in NRREL
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
    ...     - NRBTS/NRCELL-3/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-3/totalNumberOfRAPreambles is set to 64
    ...
    ...  POSTCONDITION:
    ...     - NR-DC is not setup at UE1
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16103
    ...       *BACKLOG ID: FCA_5G_L2L3-92256
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik      (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS       (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=858
    ...  Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-I+Sub+feature+refinement?src=contextnavpagetreemode
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [05.01.2023] - Create first Test Case shape
    ...  [10.01.2023] - Final TC shape
    ...  [10.01.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=875357)
    ...  [20.01.2023] - Add TC to CRT
    ...  [11.05.2023] - Migration to new AP_LO

    [Tags]  I-B2a  SKIPRUN

    [Setup]  Prepare test environment I-B2a

    Attach UE5 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
#    Add to UE5 initial PDU session with ICS
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE5
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE5
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE5

    EXPECT FLOW[timeout=3]: gNB2 E1AP bearerContextModification
    UE5 sends A4 measId=1 with CELL-2: rsrp1=85 rsrq1=49 and CELL-3: rsrp2=95 rsrq2=50
    FAIL FLOW[timeout=3]: gNB2 E1AP bearerContextModification

    Set expected messages flows for A4 measurements deinstalation after A4SupervisionTimer expiry for UE5, gNB2
    Verify expected messages flows for A4 measurements deinstalation after A4SupervisionTimer expiry for UE5, gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE5

    [Teardown]  Cleanup after test I-B2a

CB008717-I-B2b_PSCell_Add_multiple_A4_multiple_cells_in_measReport
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the successful procedure of NR-DC PSCell addition, triggered by A4 Measurement Report event, sent
    ...  by UE with more than one NR-DC PSCell candidates. Two PSCell candidates meet the criteria and for NR-DC setup is chosen the one with better
    ...  parameters in A4 measurement report.
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
    ...     - NRCELL-1/NRREL-2.nrDcAllowed = true
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is set to 0
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-2/totalNumberOfRAPreambles is set to 64
    ...     - NRBTS/NRCELL-3/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-3/totalNumberOfRAPreambles is set to 64
    ...
    ...  POSTCONDITION:
    ...     - NR-DC with NRCELL-3 is setup at UE
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16103
    ...       *BACKLOG ID: FCA_5G_L2L3-94516
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik      (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS       (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=858
    ...  Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-I+Sub+feature+refinement?src=contextnavpagetreemode
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [12.01.2023] - Create first Test Case shape
    ...  [19.01.2023] - Final TC shape
    ...  [19.01.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=875783)
    ...  [20.01.2023] - Add TC to CRT
    ...  [11.05.2023] - Migration to new AP_LO

    [Tags]  I-B2b  SKIPRUN

    [Setup]  Prepare test environment I-B2b

    Attach UE6 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
#    Add to UE6 initial PDU session with ICS
    Add to UE6 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE6
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE6
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE6

    Set expected messages flows for A4 measurement based PSCell addition for UE6, gNB2 and AMF1
    UE6 sends A4 measId=1 with CELL-2: rsrp1=85 rsrq1=50 and CELL-3: rsrp2=86 rsrq2=50
    Verify expected messages flows for A4 measurement based PSCell addition for UE6, gNB2 and AMF1

    Verify that UE6 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UE6 sends measurement results of NRCELL-3 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellIds eq ${nrcell2_pci} and ${nrcell3_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell3_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE6
    Verify that RRCReconfiguration does not contain measGapConfig for UE6
    Verify that RRCReconfiguration contains cfra for UE6
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE6
    Verify in RRCReconfiguration for UE6 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell3_pci} for SCG
    Verify in ReconfigurationComplete for UE6 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

    [Teardown]  Cleanup after test I-B2b

CB008717-I-B2c_PSCell_Add_in_next_NRDC_meas_cycle_with_retryTimer_check
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the successful procedure of NR-DC PSCell addition, triggered by A4 Measurement Report event,
    ...  sent by UE with more than one NR-DC PSCell candidates. This scenario is combination of previous items I-B2a and I-B2b. Firstly NR-DC setup
    ...  is not triggered due to fact that all PSCell candidates from Measurement Report are rejected criteria are not met. Then parameters are
    ...  changed and all PSCell candidates are now eligible for NRDC. In the meantime, timers a4Fr2SupervisionTimer and a4RetryTimer expire and
    ...  after that A4 measurements are installed and A4 measurement report is sent by UE once again. In this case two PSCell candidates meet
    ...  the criteria and for NR-DC setup is chosen the one with better parameters in A4 measurement report.
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
    ...     - NRBTS/NRCELL-3/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-3/totalNumberOfRAPreambles is set to 64
    ...
    ...  POSTCONDITION:
    ...     - NR-DC with NRCELL-3 is setup at UE
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16103
    ...       *BACKLOG ID: FCA_5G_L2L3-94516
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik      (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS       (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=858
    ...  Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-I+Sub+feature+refinement?src=contextnavpagetreemode
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [23.02.2023] - Create first Test Case shape
    ...  [02.03.2023] - Final TC shape
    ...  [09.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=878915)
    ...  [09.03.2023] - Add TC to CRT
    ...  [11.05.2023] - Migration to new AP_LO

    [Tags]  I-B2c

    [Setup]  Prepare test environment I-B2c

    Attach UE7 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE7, gNB2 and AMF1
#    Add to UE7 initial PDU session with ICS
    Add to UE7 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE7, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE7
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE7
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE7

    EXPECT FLOW[timeout=3]: gNB2 E1AP bearerContextModification
    UE7 sends A4 measId=1 with CELL-2: rsrp1=85 rsrq1=49 and CELL-3: rsrp2=95 rsrq2=50
    FAIL FLOW[timeout=3]: gNB2 E1AP bearerContextModification

    Set expected messages flows for A4 measurements deinstalation after A4SupervisionTimer expiry for UE7, gNB2
    Verify expected messages flows for A4 measurements deinstalation after A4SupervisionTimer expiry for UE7, gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE7

    Configure    {'MOC': 'NRREL', 'ID': '1-2', 'nrDcAllowed': 'true'}

    Set expected messages flows for A4 measurements instalation after A4SupervisionTimer expiry for UE7, gNB2
    Verify expected messages flows for A4 measurements instalation after A4SupervisionTimer expiry for UE7, gNB2

    ${meas_id}=  Wait until keyword succeeds    20s    4s
    ...    Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-2 for UE7
    Sleep    2

    Set expected messages flows for A4 measurement based PSCell addition for UE7, gNB2 and AMF1
    UE7 sends A4 measId=${meas_id} with CELL-2: rsrp1=85 rsrq1=50 and CELL-3: rsrp2=86 rsrq2=50
    Verify expected messages flows for A4 measurement based PSCell addition for UE7, gNB2 and AMF1

    Verify that UE7 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UE7 sends measurement results of NRCELL-3 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellIds eq ${nrcell2_pci} and ${nrcell3_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell3_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to meas_id=${meas_id} for UE7
    Verify that RRCReconfiguration does not contain measGapConfig for UE7
    Verify that RRCReconfiguration contains cfra for UE7
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE7
    Verify in RRCReconfiguration for UE7 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell3_pci} for SCG
    Verify in ReconfigurationComplete for UE7 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

    [Teardown]  Cleanup after test I-B2c
