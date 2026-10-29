*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008392 provide the RAN level requirements of half of DL TX paths can be dynamically muted / unmuted
...         to save energy in low load conditions.
...         This feature is applied to non-beamforming MIMO configurations with 4T4R, 6T6R or 8T8R radio unit
...         and beamforming MIMO configurations with 8T8R radio unit.
...         This feature can be enabled/disabled by new O&M parameter.
...         This feature is only applied to TDD FR1 and FDD FR1.
...
...      == TEST SET NAME ==
...         CB008392 - Load based MIMO muting for Energy Efficiency
...
...      == TESTING SPLIT ==
...         Subfeature-A MIMO muting for 4T4R, 6T6R radio
...         Subfeature-B MIMO muting for 8T8R radio in non-BF configuration
...         Subfeature-C MIMO muting for 8T8R radio in subsectorization configuration
...         Subfeature-D MIMO muting for 8T8R radio in BF configuration
...         Subfeature-E feature interaction with 5GC00431
...         Subfeature-F feature interaction with EIRP control, uDTX
...
...      == CONTACTS ==
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008392 CFAM
...
...      == HISTORY ==
...         [08.07.2022] - TC Create
...         [xx.xx.xxxx] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

#Force Tags  master_classicalbts_all  CONFIGURED  RAN_5G_TDD  RAN_5G  SBTS00  SBTS23R1  CRT
#...          CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  SKIPRUN

Resource    ./resources/CB008392-common_keywords.robot
Resource    ./resources/configuration.robot

Suite Setup  Run setup
Suite Teardown  Run teardown

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SKIP_COUNTERS}=         ${TRUE}

*** Test Cases ***
CB008392-A_4 TX switch on-off order
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that gNB switch on/off is executed in specific order based on lbpsCellSOOrder value NR Cells
    ...  have their resources switched off according to the value of this parameter from the lowest value onwards.
    ...  Value 100 for this parameter has a special meaning:
    ...  - If NRPGRP.lbpsLastCellSOEnabled is equal to TRUE, the NR Cell is considered to have the lowest cell resource
    ...    switch off order value.
    ...  - If NRPGRP.lbpsLastCellSOEnabled is equal to FALSE, the cell resources cannot be switched off.
    ...
    ...    == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NR cell is up and connected to AMF1
    ...    - AMF1 simulated
    ...    - UE_1 - Airphone simulator configured for SA mode
    ...    - gNB2 up and running with four SA cells
    ...    - NRPGRP-1 is created
    ...    - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...    - NRPGRP-1.lbpsCellList = {
    ...         {
    ...         - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...         - NRPGRP-1.lbpsCellList.nrCellId = 1
    ...         }
    ...         {
    ...         - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 3
    ...         - NRPGRP-1.lbpsCellList.nrCellId = 2
    ...         }
    ...         {
    ...         - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 2
    ...         - NRPGRP-1.lbpsCellList.nrCellId = 3
    ...         }
    ...         {
    ...         - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 1
    ...         - NRPGRP-1.lbpsCellList.nrCellId = 4
    ...         }
    ...      }
    ...    - Time window is set according to current time
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...    - NRPGRP-1.lbpsRTXSOffTime = 30
    ...    - NRPGRP-1.lbpsRTXSOnTime = 30
    ...    - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...    - NRPGRP-1.lbpsRTXMinLoad = 20
    ...    - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...    - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...    - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...    - NRPGRP-1.lbpsLastCellSOEnabled = true
    ...    - NRBTS.actNrLBRTXPowerSaving = True
    ...    - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...    == Postconditions ==
    ...     - cell 2-4 "Energy saving state" is set to reducedEnergySaving
    ...     - cell 1 "Energy saving state" is set to notEnergySaving
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16094; 5G_RAN_USR_COM_16092; 5G_RAN_USR_COM_16093; 5G_RAN_USR_COM_16091
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  CB008392-7324 USCB008392-A#B7: 4TX Cell  Switch Off Cell TX Paths
    ...       -  CB008392-7325 USCB008392-A#B8: 4TX Cell  Switch On Cell TX Paths
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [xx.xx.xxxx] - Review closed ()


#    [Setup]  Prepare test environment CB008392-A_4
    [Tags]
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 175Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    log to console    INITIAL
    Wait for 120s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-4 for UE_1
    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    log to console   FIRST
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-3 for UE_1
#    Run 60Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    log to console   SECOND
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-2 for UE_1
#    Run 30Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    log to console   THIRD
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-4 for UE_1
#    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    log to console   FOURTH
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    Increase nonGBR traffic by 30 mbps to trigger TX path switch off on cell-1 for UE_1
    Run 175Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    log to console   INITIAL
    Wait for 60s to trigger TX path switch on
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
#
##    Increase nonGBR traffic by 30 mbps to trigger TX path switch off on cell-2 for UE_1
##    Run 60Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
#    log to console   FIRST
#    Wait for 40s to trigger TX path switch on
#    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
#
##    Increase nonGBR traffic by 30 mbps to trigger TX path switch off on cell-3 for UE_1
##    Run 90Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
#    log to console   SECOND
#    Wait for 40s to trigger TX path switch on
#    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
#
##    Increase nonGBR traffic by 30 mbps to trigger TX path switch off on cell-4 for UE_1
##    Run 120Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
#    log to console   THIRD
#    Wait for 40s to trigger TX path switch on
#    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    log to console   change FLAG
    Set lbpsLastCellSOEnabled to false in NRPGRP-1

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-4 for UE_1
#    Run 90Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    log to console  FIRST
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-3 for UE_1
#    Run 60Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    log to console  SECOND
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-2 for UE_1
#    Run 30Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    log to console  THIRD
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    Decrease nonGBR traffic by 30 mbps to trigger TX path switch off on cell-2 for UE_1
#    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    log to console  LAST
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]


    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 30 - 50
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 90 - 110
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 120 - 130
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 150 - 170
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-1: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-2: NR_CELL_RTX_PWR_SAVING_CHNG_TO 2
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-3: NR_CELL_RTX_PWR_SAVING_CHNG_TO 2
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-4: NR_CELL_RTX_PWR_SAVING_CHNG_TO 2

#    [Teardown]  Set lbpsLastCellSOEnabled to true in NRPGR-1
#    [Teardown]  Basic cleanup

CB008392-A_5 TX switch off possible only in configured time period
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that gNB switch off or switch on cell TX paths is possible only in configured time period.
    ...  When time period ends TX paths should be switched on again.
    ...
    ...
    ...    == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NR cell is up and connected to AMF1
    ...    - AMF1 simulated
    ...    - UE_1 - Airphone simulator configured for SA mode
    ...    - gNB2 up and running with two SA cells
    ...    - NRPGRP-1 is created
    ...    - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...    - NRPGRP-1.lbpsCellList = {
    ...         {
    ...         - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...         - NRPGRP-1.lbpsCellList.nrCellId = 1
    ...         }
    ...      }
    ...    - Time window is set according to current time
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...    - NRPGRP-1.lbpsRTXSOffTime = 30
    ...    - NRPGRP-1.lbpsRTXSOnTime = 30
    ...    - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...    - NRPGRP-1.lbpsRTXMinLoad = 20
    ...    - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...    - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...    - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...    - NRPGRP-1.lbpsLastCellSOEnabled = true
    ...    - NRBTS.actNrLBRTXPowerSaving = True
    ...    - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...    == Postconditions ==
    ...     - cell's "Energy saving state" is set to notEnergySaving
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16094; 5G_RAN_USR_COM_16092; 5G_RAN_USR_COM_16093; 5G_RAN_USR_COM_16091
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  CB008392-7324 USCB008392-A#B7: 4TX Cell  Switch Off Cell TX Paths
    ...       -  CB008392-7325 USCB008392-A#B8: 4TX Cell  Switch On Cell TX Paths
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [xx.xx.xxxx] - Review closed ()


#    [Setup]  Prepare test environment CB008392-A_5
    [Tags]
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Set NRPGRP-1.lbpsDayOfWeek to the next day

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 175Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Set NRPGRP-1.lbpsDayOfWeek to current day

    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Wait for 200s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set NRPGRP-1.lbpsDayOfWeek to the next day
    Wait for 10s to trigger TX path switch on
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 90
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 90 - 130
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 130 - 170
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 140 - 180
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

#    [Teardown]  Basic cleanup

CB008392-A_11 Feature activation and deactivation
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that gNB switch on/off is executed after feature activation or deactivation.
    ...   After feature flag is enabled gNB should switch off TX paths after configured period of time (10s).
    ...   After feature flag is disabled gNB should switch on all TX paths previously switched off.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 4
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 1
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 3
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 2
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 2
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 3
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 1
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - cell 1-4 "Energy saving state" is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16094; 5G_RAN_USR_COM_16092; 5G_RAN_USR_COM_16093; 5G_RAN_USR_COM_16091
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008392-A#B1: Activate Load-Based Reduced TX Path Power Saving
    ...     -  USCB008392-A#B2: Deactivate Load-Based Reduced TX Path Power Saving
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [xx.xx.xxxx] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

#    [Setup]  Prepare test environment CB008392-A_11
    [Tags]
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 175Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Wait for 50s to trigger TX path switch off

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 feature flag
    Wait for 150s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Deactivate CB008392 feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 1 - 20
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 30 - 50
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 60 - 80
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 90 - 110
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-1: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-2: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-3: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-4: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1

#    [Teardown]  Cleanup after test

CB008392-A_13 Last enabled cell in power group
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies proper behavior for NRBTS.NRPGRP.lbpsLastCellSOEnabled parmeter
    ...   This parameter indicates whether the last enabled power group cell may have resources switched
    ...   off (including cell switched off or TX switched off) and whether power group cells with the special handling cell
    ...   switch off order value (NRPGRP.lbpsCellList.lbpsCellSOOrder) may have resources switched off.
    ...   If this parameter is equal to TRUE, the last enabled cell and the cells with the special handling cell switch off
    ...   order value may have resources switched off. If this parameter is equal to FALSE, neither the last enabled cell nor
    ...   the cells with the special handling cell switch off order value may have resources switched off.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 4
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 1
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 3
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 2
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 2
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 3
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 1
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRBTS.actNrLBRTXPowerSaving = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - cell 1-4 "Energy saving state" is set to reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16094; 5G_RAN_USR_COM_16092; 5G_RAN_USR_COM_16093; 5G_RAN_USR_COM_16091
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7324 USCB008392-A#B7: 4TX Cell ? Switch Off Cell TX Paths
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell ? Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [xx.xx.xxxx] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

#    [Setup]  Prepare test environment CB008392-A_13
    [Tags]
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 175Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 175Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Wait for 150s to trigger TX path switch off

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set lbpsLastCellSOEnabled to true in NRPGRP-1

    ## EFS suggested that we should wait 40s (10s parameter change + 30s for energySavingState change)
    ## Probably 30s will be enough, if above kw "Set NRPGRP..." will take long time
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set lbpsLastCellSOEnabled to false in NRPGRP-1

    ## EFS suggested that we should wait 40s (10s parameter change + 30s for energySavingState change)
    ## Probably 30s will be enough, if above kw "Set NRPGRP..." will take long time
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 20 - 40
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 30 - 50
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 60 - 70
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter for NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range 90 - 110
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-1: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-2: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-3: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters for NRCELL-4: NR_CELL_RTX_PWR_SAVING_CHNG_TO 1

#    [Teardown]  Cleanup after test

CB008392-A_7 Cell degraded due to cell level alarm
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies that when one of the cells in power group becomes blocked (failed), the rest of cells in the same power group
    ...     with energy saving state set to reducedEnergy should switch on TX paths and change state to notEnergySaving.
    ...     When one cell is blocked (failed) it cannot switch off TX paths.
    ...     When one cell is blocked (failed), the rest of cells in the same power group cannot switch off TX paths as well.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA+NSA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - X2 link is up between gNB2 and simulated eNB1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 1
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 1
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 2
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 3
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...  - NRBTS.actNrLBRTXPowerSaving = True
    ...
    ...  == Postconditions ==
    ...   - All cells from power saving group have "Energy saving state" set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA+NSA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_OP_2249; 5G_RAN_OP_2251; 5G_RAN_OP_2254; 5G_RAN_OP_2288
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...    - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7324 USCB008392-A#B7: 4TX Cell Switch Off Cell TX Paths
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [14.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)
#    [Setup]  Prepare test environment CB008392-A_7
    [Tags]  A_7

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Activate CB008392 feature flag

    Block NRCELL-1
    Wait for 70s to trigger TX path switch off

    # NRCELL-1 cannot switch off TX due to blocked state
    # NRCELL-2,3,4 cannot switch off TX due to cell level fault on NRCELL-1
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set lbpsCellSOOrder to [100] for cells [1]
    Unblock NRCELL-1
    Wait for 40s to trigger TX path switch off

    # All cells should switch off TXs in same time due to lbpsCellSOOrder = 100
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    TODO: check after OAM fix
    Reset RMOD-1

    # All cells should switch on TXs immediately after fault is raised on NRCELL-2 (blocked cell)
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    #todo: range of counter values to be determined during execution
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1

#    [Teardown]  Cleanup after test A_7

CB008392-A_8 Cell degraded due to BTS level alarm
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies that when any enabled cell of a Power Saving Group becomes degraded or failed due to a fault that was raised
    ...     at BTS level, the rest of cells in the same power group with energy saving state set to reducedEnergy should switch on TX paths
    ...     and change state to notEnergySaving.
    ...     gNB OAM shall not switch off TX paths of a cell if this cell or any other cell of the same Power Saving Group is degraded or failed
    ...     due to a fault that was raised at BTS level.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA+NSA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - X2 link is up between gNB2 and simulated eNB1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 1
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 2
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 3
    ...       }
    ...       {
    ...       - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = 100
    ...       - NRPGRP-1.lbpsCellList.nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...  - NRBTS.actNrLBRTXPowerSaving = True
    ...  - NRBTS.x2LinkReestabTmr = 1min
    ...
    ...  == Postconditions ==
    ...   - All cells from power saving group have "Energy saving state" set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA+NSA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_OP_2250 ;5G_RAN_OP_2287
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...    - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7324 USCB008392-A#B7: 4TX Cell Switch Off Cell TX Paths
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [14.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)
#    [Setup]  Prepare test environment CB008392-A_8
    [Tags]  A_8

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Reset X2 link between gNB2 and simulated eNB1
    Wait for 65s to timer x2LinkReestabTmr expiry
    Check for cells [1,2,3,4] if availabilityStatus equals [degraded,degraded,degraded,degraded]

    Activate CB008392 feature flag

    Wait for 40s to trigger TX path switch off

    # NRCELL-1,2,3,4 cannot switch off TX due to BTS alarm (no X2 link available)
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Setup X2 link between gNB2 and simulated eNB1
    Wait for 5s to availabilityStatus change
    Verify that cells [1,2,3,4] are not degraded
    Wait for 40s to trigger TX path switch off

    # All cells should switch off TXs in same time due to lbpsCellSOOrder = 100
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

#    TODO: check after OAM fix
    Reset X2 link between gNB2 and simulated eNB1
    Wait for 60s to trigger TX path switch off

    # All cells should switch on TXs immediately after cell become degraded
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    #todo: range of counter values to be determined during execution
#    Omit when SKIP_COUNTERS present
#    ...  Wait until aggreagted PM counters file is ready and saved
#    Omit when SKIP_COUNTERS present
#    ...  Run Keyword And Continue On Failure
#    ...  Check counter NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x
#    Omit when SKIP_COUNTERS present
#    ...  Run Keyword And Continue On Failure
#    ...  Check counter NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x
#    Omit when SKIP_COUNTERS present
#    ...  Run Keyword And Continue On Failure
#    ...  Check counter NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x
#    Omit when SKIP_COUNTERS present
#    ...  Run Keyword And Continue On Failure
#    ...  Check counter NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES is in range x-x

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO 1

#    [Teardown]  Cleanup after test A_8

*** Keywords ***
Verify that NRCELL-1 energySavingState is notEnergySaving
    Verify that NRCELL-1 is not degraded
    Verify that NRCELL-1 energySavingState is notEnergySaving

Verify that ${object} ${parameter} is ${value}
    ${energySavingState_value}=     get object attributes    ${object}    ${parameter}
    should be true  ${energySavingState_value}  ${value}

Set NRPGRP-${id}.lbpsDayOfWeek to the next day
    Set time period with 2000 minutes offset for NRPGRP-${id}

    ${lbpsDuration}    get variable value      ${NRPGRP-${id}.lbpsDuration}  ${lbpsDuration_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDuration
    ...  value=${lbpsDuration}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDayOfWeek
    ...  value=${NRPGRP-${id}.lbpsDayOfWeek}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeHour
    ...  value=${NRPGRP-${id}.lbpsStartTimeHour}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeMinute
    ...  value=${NRPGRP-${id}.lbpsStartTimeMinute}
    ...  bts_id=1

#    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Set NRPGRP-${id}.lbpsDayOfWeek to current day
    Set time period with 0 minutes offset for NRPGRP-${id}

    ${lbpsDuration}    get variable value      ${NRPGRP-${id}.lbpsDuration}  ${lbpsDuration_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDuration
    ...  value=${lbpsDuration}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDayOfWeek
    ...  value=${NRPGRP-${id}.lbpsDayOfWeek}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeHour
    ...  value=${NRPGRP-${id}.lbpsStartTimeHour}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeMinute
    ...  value=${NRPGRP-${id}.lbpsStartTimeMinute}
    ...  bts_id=1

#    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Remove cell from NRPGRP-1.lbpsCellList with nrCellId=2
    Configure  ${CURDIR}/config/yaml_config/1_NRPGRP_del_cell.yaml

Add new cell to NRPGRP-1.lbpsCellList with nrCellId=2 and lbpsCellSOOrder=2
    Configure  ${CURDIR}/config/yaml_config/1_NRPGRP_add_cell.yaml

Modify NRPGRP-1.lbpsSOMethod to '${method_1}', NRPGRP-2.lbpsSOMethod to '${method_2}'
    Configure  [{'MOC': 'NRPGRP', 'ID': '1', 'lbpsSOMethod': '${method_1}'}, {'MOC': 'NRPGRP', 'ID': '2', 'lbpsSOMethod': '${method_2}'}]

Modify NRPGRP-1.lbpsCellList to contain cells [1, 4] NRPGRP-2.lbpsCellList to contain cells [2, 3]
    Create new plan
    Edit Planned Object Attributes   NRPGRP-1  lbpsCellList.nrCellId[1]=4
    Edit Planned Object Attributes   NRPGRP-2  lbpsCellList.nrCellId[1]=2
    Apply planned changes
