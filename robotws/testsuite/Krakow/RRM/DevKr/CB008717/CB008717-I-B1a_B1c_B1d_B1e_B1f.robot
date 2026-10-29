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
...      [02.08.2022] - Create Test Suite
...      [08.12.2022] - Add Test Case I-B1f
...      [03.02.2023] - Add Test Case I-B1d
...      [13.02.2023] - Add Test Case I-B1e
...      [02.03.2023] - Add Test Case I-B1e_2
...      [30.11.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=870897)
...      [10.05.2023] - Migration to new AP_LO

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/common/2c_TDD_n78_FR2_n257_NRDC.lua
${SCFC}=                   Krakow/CB008717/common/SCFC_FS_n78_n257.xml
${AP_XML}=                 Krakow/CB008717/common/iphy_FS_2c_n78_n257.xml

*** Test Cases ***
CB008717-I-B1a_PSCell_Add_one_A4_one_cell_in_measReport_RSRQ
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure of NR-DC PSCell addition, triggered by A4 MeasurementReport event, sent by UE
    ...  with one NR-DC PSCell candidate. Only one A4 MeasurementReport is configured. After the successful procedure it is expected
    ...  that NR-DC is set with appropriate PSCell setup at UE and all NR-DC A4 measurements are deactivated and de-configured.
    ...  Measurement type is set to RSRQ. In this scenario UE is capable of independent measurement gaps, so measurement gaps are not needed.
    ...  In ICS, there is one PDU Session with one non-GBR QoS Flow and there is no mimo change in PCell.
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: supported
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is not present
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n64
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
    ...       *BACKLOG ID: FCA_5G_L2L3-92251
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
    ...  [02.08.2022] - Create first Test Case shape
    ...  [30.11.2022] - Final TC shape
    ...  [30.11.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=861770)
    ...  [07.12.2022] - Add TC to CRT
    ...  [10.05.2023] - Remove TC from CRT
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1a  SKIPRUN

    [Setup]  Prepare test environment I-B1a

    Attach UE8 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE8, gNB2 and AMF1
#    Add to UE8 initial PDU session with ICS
    Add to UE8 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE8, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE8
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE8
    Verify that 2 out of 2 RRCReconfiguration does not contain ssb-RSRP for UE8

    Set expected messages flows for A4 measurement based PSCell addition for UE8, gNB2 and AMF1
    UE8 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE8, gNB2 and AMF1

    Verify that UE8 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE8
    Verify that RRCReconfiguration does not contain measGapConfig for UE8
    Verify that RRCReconfiguration does not contain cfra for UE8
    Verify that RRCReconfiguration does not contain ssb-RSRP for UE8
    Verify in RRCReconfiguration for UE8 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell2_pci} for SCG
    Verify in ReconfigurationComplete for UE8 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

    [Teardown]  Cleanup after test I-B1a

CB008717-I-B1c_PSCell_Add_UE_without_independent_MeasGap
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure of NR-DC PSCell addition, triggered by A4 MeasurementReport event, sent by UE with
    ...   one NR-DC PSCell candidate. Only one A4 MeasurementReport is configured. After the successful procedure it is expected that NR-DC is set
    ...  with appropriate PSCell setup at UE and all NR-DC A4 measurements are deactivated and de-configured. In this scenario UE is not capable
    ...  of independent measurement gaps, so measurement gaps are needed.
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: not present
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is present and set to 0
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-2/totalNumberOfRAPreambles is set to 64 (cbraPreamblesPerSsb < totalNumberOfRAPreambles)
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
    ...       *BACKLOG ID: FCA_5G_L2L3-92253
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
    ...  [02.09.2022] - Create first Test Case shape
    ...  [26.01.2023] - Final TC shape
    ...  [26.01.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=862399)
    ...  [03.02.2023] - Add TC to CRT
    ...  [10.05.2023] - Remove TC from CRT
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1c  SKIPRUN

    [Setup]  Prepare test environment I-B1c I-B1f

    Attach UE1 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE1
    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE1
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE1

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1

    Verify that UE1 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 contains measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE1
    Verify that RRCReconfiguration contains measGapConfig=release for UE1
    Verify that RRCReconfiguration contains cfra for UE1
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE1
    Verify in RRCReconfiguration for UE1 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell2_pci} for SCG
    Verify in ReconfigurationComplete for UE1 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

    [Teardown]  Cleanup after test I-B1c

CB008717-I-B1d_PSCell_Add_with_DRX_reconfiguration
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure of NR-DC PSCell addition, triggered by A4 MeasurementReport event, sent by UE with
    ...  one NR-DC PSCell candidate. Only one A4 MeasurementReport is configured. After the successful procedure it is expected that NR-DC is set
    ...  with appropriate PSCell setup at UE and all NR-DC A4 measurements are deactivated and de-configured. In this scenario additionally DRX
    ...  feature is enabled in PCell. There are two UEs: first - UE1 which is not capable of independent measurements gaps, so gNB performs DRX
    ...  setup procedure at UE1, and second - UE2 which is capable of independent measurement gaps and then there is no DRX activation for it
    ...  because DRX was activated earlier just after A4 measurements installation.
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: not present
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is present and set to 0
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-2/totalNumberOfRAPreambles is set to 64 (cbraPreamblesPerSsb < totalNumberOfRAPreambles)
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
    ...       *BACKLOG ID: FCA_5G_L2L3-92254
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
    ...  [27.01.2023] - Create first Test Case shape
    ...  [03.02.2023] - Final TC shape
    ...  [03.02.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=863964)
    ...  [03.02.2023] - Add TC to CRT
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1d

    [Setup]  Prepare test environment I-B1d

    Log To Console  Prepare test environment I-B1d - with DRX

    Attach UE10 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE10, gNB2 and AMF1
#    Add to UE10 initial PDU session with ICS
    Add to UE10 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE10, gNB2 and AMF1

    Verify RRCReconfiguration message content after A4 measurement configuration for UE10

    Set expected messages flows for A4 measurement based PSCell addition with DRX for UE10, gNB2 and AMF1
    UE10 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition with DRX for UE10, gNB2 and AMF1

    Verify messages during NRDC PSCell addition with DRX for UE10

    Detach and kill UE10
    Sleep  10

    Attach UE11 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration with DRX for UE11, gNB2 and AMF1
#    Add to UE11 initial PDU session with ICS
    Add to UE11 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration with DRX for UE11, gNB2 and AMF1

    Verify RRCReconfiguration message content after A4 measurement configuration with DRX for UE11

    Set expected messages flows for A4 measurement based PSCell addition without DRX for UE11, gNB2 and AMF1
    UE11 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition without DRX for UE11, gNB2 and AMF1

    Verify messages during NRDC PSCell addition without DRX for UE11

    [Teardown]  Cleanup after test I-B1d

CB008717-I-B1f_PSCell_Add_with_preamble_allocation_CFRA
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure of NR-DC PSCell addition, triggered by A4 Measurement Report event, sent by UE with
    ...  one NR-DC PSCell candidate. Only one A4 Measurement Report is configured. After the successful procedure it is expected that NR-DC is set
    ...  with appropriate PSCell setup at UE and all NR-DC A4 measurements are deactivated and de-configured. This scenario additionally checks
    ...  if CFRA preamble allocation is present during NR-DC setup. Three cases are checked:
    ...  - cbraPreamblesPerSsb < totalNumberOfRAPreambles and rsIndexResults is present - CFRA is present
    ...  - cbraPreamblesPerSsb < totalNumberOfRAPreambles and rsIndexResults is not present - CFRA is not present
    ...  - cbraPreamblesPerSsb = totalNumberOfRAPreambles and rsIndexResults is present - CFRA is not present
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: supported
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is present and set to 0
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n32
    ...     - NRBTS/NRCELL-2/totalNumberOfRAPreambles is set to 64 (cbraPreamblesPerSsb < totalNumberOfRAPreambles)
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
    ...       *BACKLOG ID: FCA_5G_L2L3-92259
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
    ...  [20.12.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=873983)
    ...  [03.01.2023] - Add TC to CRT
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1f

    [Setup]  Prepare test environment I-B1c I-B1f

    Log To Console  Prepare test environment I-B1f

    Log To Console  cbraPreamblesPerSsb < totalNumberOfRAPreambles and rsIndexResults is present - CFRA is present

    Attach UE9 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE9, gNB2 and AMF1
#    Add to UE9 initial PDU session with ICS
    Add to UE9 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE9, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE9
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE9
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE9

    Set expected messages flows for A4 measurement based PSCell addition for UE9, gNB2 and AMF1
    UE9 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE9, gNB2 and AMF1

    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that RRCReconfiguration contains cfra for UE9

    Verify common flow for A4 measurement based NRDC PSCell addition for I-B1f

    Detach and kill UE9
    Sleep  10

    Log To Console  cbraPreamblesPerSsb < totalNumberOfRAPreambles and rsIndexResults is not present - CFRA is not present

    Attach UE9 without ICS to gNB2 cell1
#    Add to UE9 initial PDU session with ICS
    Add to UE9 initial PDU session with ICS and indexToRFSP equal 87

    Set expected messages flows for A4 measurement based PSCell addition for UE9, gNB2 and AMF1
    UE9 sends A4 measurement id=1 for NR-DC PSCell addition without rsIndexResult
    Verify expected messages flows for A4 measurement based PSCell addition for UE9, gNB2 and AMF1

    Verify that UEContextSetupRequest contains measurement results of PSCell without rsIndexResults for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for gNB2
    Verify that RRCReconfiguration does not contain cfra for UE9

    Verify common flow for A4 measurement based NRDC PSCell addition for I-B1f

    Detach and kill UE9
    Sleep  10

    Log To Console  cbraPreamblesPerSsb = totalNumberOfRAPreambles and rsIndexResults is present - CFRA is not present

    Configure    {'MOC': 'NRCELL', 'ID': '2', 'cbraPreamblesPerSsb': 'n64'}

    Attach UE9 without ICS to gNB2 cell1
#    Add to UE9 initial PDU session with ICS
    Add to UE9 initial PDU session with ICS and indexToRFSP equal 87

    Set expected messages flows for A4 measurement based PSCell addition for UE9, gNB2 and AMF1
    UE9 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE9, gNB2 and AMF1

    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for gNB2
    Verify that RRCReconfiguration does not contain cfra for UE9

    Verify common flow for A4 measurement based NRDC PSCell addition for I-B1f

    [Teardown]  Cleanup after test I-B1f

CB008717-I-B1e_PDU_Session_Modify_queue_NRDC_success
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure of NR-DC PSCell addition, triggered by A4 Measurement Report event, sent by UE with
    ...  one NR-DC PSCell candidate. Only one A4 Measurement Report is configured. After the successful procedure it is expected that NR-DC is set
    ...  with appropriate PSCell setup at UE and all NR-DC A4 measurements are deactivated and de-configured. This scenario additionally checks
    ...  interaction with other ongoing procedure - A4 Measurement Report is sent during ongoing PDU Session Modification procedure. In this case,
    ...  the PSCell addition procedure should be queued until the ongoing procedure is completed.
    ...  In ICS, there is one PDU Session with one non-GBR QoS Flow and there is no mimo change in PCell.
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: supported
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is not present
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n64
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
    ...       *BACKLOG ID: FCA_5G_L2L3-92255
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
    ...  [09.02.2023] - Create first Test Case shape
    ...  [13.02.2023] - Final TC shape
    ...  [13.02.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=863967)
    ...  [13.02.2023] - Add TC to CRT
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1e

    [Setup]  Prepare test environment I-B1e

    Log To Console  Start test case I-B1e success

    Attach UE12 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE12, gNB2 and AMF1
#    Add to UE12 initial PDU session with ICS
    Add to UE12 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE12, gNB2 and AMF1

    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE12
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE12
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE12

    UE12 sends A4 measurement id=1 for NR-DC PSCell addition during ongoing PDU Session Modification procedure

    Verify that UE12 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_2 of 3 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_2 of 3 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_2 of 3 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE12
    Verify that RRCReconfiguration does not contain measGapConfig for UE12
    Verify that RRCReconfiguration contains cfra for UE12
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE12
    Verify in RRCReconfiguration for UE12 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell2_pci} for SCG
    Verify in 2 out of 2 ReconfigurationComplete for UE12 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_3 of 3 contains RRCReconfigurationCompleteIndicator=true for gNB2

    [Teardown]  Cleanup after test I-B1e

CB008717-I-B1e_PDU_Session_Release_queue_NRDC_fails
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure of NR-DC PSCell addition, triggered by A4 Measurement Report event, sent by UE with
    ...  one NR-DC PSCell candidate during other ongoing procedure (PDU Session Release) before gNB receives RRC:RRCReconfigurationComplete message
    ...  from the UE . In this scenario the message RRC: RRCReconfigurationComplete does not come at all finally, so in this case, the PSCell
    ...  addition procedure should be queued and never be processed because of gNB initiated UE release - NRBTS.timerRRCGuard expiration during
    ...  PDU Session Release procedure. After that the UE is detached and attached again and it is checked that A4 measurement based PSCell addition
    ...  procedure can be performed after previous unfinished one.
    ...
    ...  PRECONDITION:
    ...     - rdNrDcDefaultPSCellLcrId is set to default (16384)
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n78 (TDD)
    ...     - NRBTS/NRCELL-1 channel bandwidth: 60MHz (TDD)
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n257 (TDD)
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz (TDD)
    ...     - UE-NR-Capability/measAndMobParameters/measAndMobParameters-Common/independentGapConfig: supported
    ...     - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2071387
    ...     - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 257
    ...     - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrq
    ...     - NRBTS/NRCELL-1/sMeasConfigSsbRsrp is not present
    ...     - NRBTS/NRCELL-2/cbraPreamblesPerSsb is set to n64
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
    ...       *BACKLOG ID: FCA_5G_L2L3-92255
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
    ...  [09.02.2023] - Create first Test Case shape
    ...  [28.02.2023] - Final TC shape
    ...  [28.02.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=870897)
    ...  [28.02.2023] - Add TC to CRT
    ...  [10.05.2023] - Migration to new AP_LO

    [Tags]  I-B1e

    [Setup]  Prepare test environment I-B1e-fail

    Log To Console  Start test case I-B1e fail

    Attach UE13 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE13, gNB2 and AMF1
#    Add to UE13 initial PDU session with ICS
    Add to UE13 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE13, gNB2 and AMF1


    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE13
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE13
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE13

    UE13 sends A4 measurement id=1 for NR-DC PSCell addition during ongoing PDU Session Release procedure with RRCGuard timer expiration

    [Teardown]  Cleanup after test I-B1e
