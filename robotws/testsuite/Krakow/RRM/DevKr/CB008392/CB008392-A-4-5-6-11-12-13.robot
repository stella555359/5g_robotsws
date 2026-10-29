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
...         [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

Resource    ./resources/CB008392-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Suite Setup  Run setup  rtpm=True
Suite Teardown  Run teardown

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/scf_4AZQU_4CELLS_SANSA-A-E.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/iphy_4AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008392-A_4_11 TX switch on-off order and feature activation
    [Documentation]
    ...    == DESCRIPTION ==
    ...  Part I
    ...  This test verifies that gNB switch on/off is executed after feature activation or deactivation.
    ...  After feature flag is enabled gNB should switch off TX paths after configured period of time (10s).
    ...  After feature flag is disabled gNB should switch on all TX paths previously switched off.
    ...  Part II
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
    ...         - lbpsCellSOOrder = 100
    ...         - nrCellId = 1
    ...         }
    ...         {
    ...         - lbpsCellSOOrder = 3
    ...         - nrCellId = 2
    ...         }
    ...         {
    ...         - lbpsCellSOOrder = 2
    ...         - nrCellId = 3
    ...         }
    ...         {
    ...         - lbpsCellSOOrder = 1
    ...         - nrCellId = 4
    ...         }
    ...      }
    ...    - Time window is set according to current time
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...    - NRPGRP-1.lbpsRTXSOffTime = 30
    ...    - NRPGRP-1.lbpsRTXSOnTime = 30
    ...    - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...    - NRPGRP-1.lbpsRTXMinLoad = 20
    ...    - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...    - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...    - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...    - NRPGRP-1.lbpsLastCellSOEnabled = true
    ...    - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...    - NRBTS.actNrLBRTXPowerSaving = False
    ...
    ...    == Postconditions ==
    ...     - NRCELL-2-4.energySavingState is set to reducedEnergySaving
    ...     - NRCELL-1.energySavingState is set to notEnergySaving
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
    ...       [11.07.2022] - TC Create
    ...       [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)


    [Setup]  Prepare test environment CB008392-A_4_11
    [Tags]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds

    Omit when SKIP_COUNTERS present
    ...         Wait For Rtpm Before Test

    Activate CB008392 feature flag
    Wait 160s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Deactivate CB008392 feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 feature flag
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Wait for 60s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Set lbpsLastCellSOEnabled to false in NRPGRP-1

    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]


    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3

    [Teardown]  Basic cleanup

CB008392-A_6 Two configured power groups
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This test verifies that TX switch on/off is executed independently for each power group
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
    ...         - lbpsCellSOOrder = 1
    ...         - nrCellId = 1
    ...         }
    ...         {
    ...         - lbpsCellSOOrder = 2
    ...         - nrCellId = 2
    ...         }
    ...      }
    ...    - Time window is set according to current time
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...    - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...    - NRPGRP-1.lbpsRTXSOffTime = 30
    ...    - NRPGRP-1.lbpsRTXSOnTime = 30
    ...    - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...    - NRPGRP-1.lbpsRTXMinLoad = 20
    ...    - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...    - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...    - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...    - NRPGRP-1.lbpsLastCellSOEnabled = true
    ...    - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...    - NRPGRP-2 is created
    ...    - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...    - NRPGRP-2.lbpsCellList = {
    ...         {
    ...         - lbpsCellSOOrder = 1
    ...         - nrCellId = 3
    ...         }
    ...         {
    ...         - lbpsCellSOOrder = 2
    ...         - nrCellId = 4
    ...         }
    ...      }
    ...    - Time window is set according to current time
    ...    - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...    - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...    - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...    - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...    - NRPGRP-2.lbpsRTXSOffTime = 30
    ...    - NRPGRP-2.lbpsRTXSOnTime = 30
    ...    - NRPGRP-2.lbpsRTXMaxLoad = 80
    ...    - NRPGRP-2.lbpsRTXMinLoad = 50
    ...    - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...    - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...    - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...    - NRPGRP-2.lbpsLastCellSOEnabled = true
    ...    - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...    - NRBTS.actNrLBRTXPowerSaving = False
    ...
    ...    == Postconditions ==
    ...     - NRCELL-3-4.energySavingState is set to reducedEnergySaving
    ...     - NRCELL-1-2.energySavingState is set to notEnergySaving
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
    ...       [11.07.2022] - TC Create
    ...       [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment CB008392-A_6
    [Tags]
    Omit when SKIP_COUNTERS present
    ...         Wait For Rtpm Before Test

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds

    Activate CB008392 feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]

    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 10 seconds
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set NRPGRP-1.lbpsDayOfWeek to the next day
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    [Teardown]  Basic cleanup

CB008392-A_12 Deleting and Adding cell to lbpsCellList
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that newly added or removed cells from lbpsCellList are taken into considertion
    ...   for switch off/on TX paths.
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
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...
    ...  == Postconditions ==
    ...   - NRCELL-2-4.energySavingState is set to reducedEnergySaving
    ...   - NRCELL-1.energySavingState is set to notEnergySaving
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
    ...     [11.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment CB008392-A_12
    [Tags]

    Omit when SKIP_COUNTERS present
    ...         Wait For Rtpm Before Test

    Activate CB008392 feature flag
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Add new cell to NRPGRP-1.lbpsCellList with nrCellId=2 and lbpsCellSOOrder=2
    Run Keyword And Ignore Error
    ...  Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 90s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]

    Remove cell from NRPGRP-1.lbpsCellList with nrCellId=2
    Run Keyword And Ignore Error
    ...  Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0

    [Teardown]  Basic cleanup

CB008392-A_5_13 Last enabled cell in power group and switch off possible only in specified time period
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   Part I
    ...   This test verifies that gNB switch off or switch on cell TX paths is possible only in configured time period.
    ...   When time period ends TX paths should be switched on again.
    ...   Part II
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
    ...       - lbpsCellSOOrder = 4
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 3
    ...       - nrCellId = 2
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {next day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1-4.energySavingState is set to reducedEnergySaving
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
    ...     [11.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment CB008392-A_5_13
    [Tags]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 1Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 1Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Activate CB008392 feature flag
    Wait for 60s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...         Wait For Rtpm Before Test

    Set NRPGRP-1.lbpsDayOfWeek to current day
    Wait 140s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set NRPGRP-1.lbpsDayOfWeek to the next day
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Set NRPGRP-1.lbpsDayOfWeek to current day
    Wait for 180s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set lbpsLastCellSOEnabled to true in NRPGRP-1
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Set lbpsLastCellSOEnabled to false in NRPGRP-1
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Basic cleanup

*** Keywords ***
