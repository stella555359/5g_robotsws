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
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == REFERENCES ==
...         CB008392 CFAM
...
...      == HISTORY ==
...         [14.07.2022] - TC Create
...         [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

Resource    ./resources/CB008392-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Suite Setup  Run Setup  rtpm=True
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/scf_4AZQU_4CELLS_SANSA-A-E.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/iphy_4AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
#In regression covred in
#CB008392-A_14_15 Interaction with CMAS and ETWS
CB008392-A_14 Interaction with CMAS
    [Tags]    A_14    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell broadcasting CMAS messages can not be set into reducedEnergySaving state.
    ...   Test verifies, that cells with lbpsCellSOOrder higher than cell with CMAS active are not considered as candidates
    ...   for TX switch off, until CMAS will be stopped.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without CMAS are set to reducedEnergySaving.
    ...   Rest of the cells are set to reducedEnergySaving when CMAS is stopped.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 3
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 4
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...  - NRBTS-1.actCMAS = True
    ...
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...  - NRCELL-3.emergencyAreaIdList = 3
    ...  - NRCELL-4.emergencyAreaIdList = 4
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, CMAS is not broadcasted
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_29816
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7323 USCB008392-A#B6: Determine Cell TX Path Switch Off List
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment A_14

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 feature flag

    Start CMAS notifications for NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    ## Wait longer to verify, that NRCELL-2 will be still in notEnergySaving state
    Wait for 100s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop CMAS notifications for NRCELL-2
    Wait for 130s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Set lbpsCellSOOrder to [100, 100, 100, 100] for cells [1,2,3,4]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Start CMAS notifications for NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Stop CMAS notifications for NRCELL-2
    Wait for 40s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 380 - 440
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 260 - 320
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 270 - 330
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 230 - 290

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Cleanup after test A_14

#In regression covred in
#CB008392-A_14_15 Interaction with CMAS and ETWS
CB008392-A_15 Interaction with ETWS
    [Tags]    A_15    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell broadcasting ETWS messages can not be set into reducedEnergySaving state.
    ...   Test verifies, that cells with lbpsCellSOOrder higher than cell with ETWS active are not considered as candidates
    ...   for TX switch off, until ETWS will be stopped.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without ETWS are set to reducedEnergySaving.
    ...   Rest of the cells are set to reducedEnergySaving when ETWS is stopped.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 3
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 4
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...  - NRBTS-1.actETWS = True
    ...
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...  - NRCELL-3.emergencyAreaIdList = 3
    ...  - NRCELL-4.emergencyAreaIdList = 4
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, ETWS is not broadcasted
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_29817
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7323 USCB008392-A#B6: Determine Cell TX Path Switch Off List
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment A_15

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 feature flag

    Start ETWS notifications for NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    ## Wait longer to verify, that NRCELL-2 will be still in notEnergySaving state
    Wait for 100s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Wait 5s until ETWS notifications for NRCELL-2 are finished
    Wait for 130s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Set lbpsCellSOOrder to [100, 100, 100, 100] for cells [1,2,3,4]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Start ETWS notifications for NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 50s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Wait 35s until ETWS notifications for NRCELL-2 are finished
    Wait for 50s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving, reducedEnergySaving, reducedEnergySaving, reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 390 - 450
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 230 - 290
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 270 - 330
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 230 - 290

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Basic cleanup

#Optimization of:
#CB008392-A_15 Interaction with ETWS
#CB008392-A_14 Interaction with CMAS
CB008392-A_14_15 Interaction with CMAS and ETWS
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell broadcasting CMAS/ETWS messages can not be set into reducedEnergySaving state.
    ...   Test verifies, that cells with lbpsCellSOOrder higher than cell with CMAS active are not considered as candidates
    ...   for TX switch off, until CMAS will be stopped.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without ETWS are set to reducedEnergySaving.
    ...   Rest of the cells are set to reducedEnergySaving when ETWS is stopped.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 3
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 4
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...  - NRBTS-1.actCMAS = True
    ...
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...  - NRCELL-3.emergencyAreaIdList = 3
    ...  - NRCELL-4.emergencyAreaIdList = 4
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, CMAS, ETWS is not broadcasted
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_29816;CB_FIM_29817
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7323 USCB008392-A#B6: Determine Cell TX Path Switch Off List
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment A_14_15

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 feature flag

    Start CMAS notifications for NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    ## Wait longer to verify, that NRCELL-2 will be still in notEnergySaving state
    Wait for 100s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop CMAS notifications for NRCELL-2
    Wait 140s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Set lbpsCellSOOrder to [100, 100, 100, 100] for cells [1,2,3,4]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Start ETWS notifications for NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Wait 35s until ETWS notifications for NRCELL-2 are finished
    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving, reducedEnergySaving, reducedEnergySaving, reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 160
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 120
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 80
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 40

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Cleanup after test A_14

#In regression covred in
#CB008392_5GC000431 Interaction with emergency call
CB008392-A_16 Interaction with emergency call
    [Tags]    A_16    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell with ongoing emergency call can not be set into reducedEnergySaving state.
    ...   Test verifies, that cells with lbpsCellSOOrder higher than cell with emergency call are not considered as candidates
    ...   for TX switch off, until emergency call will be ended.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without emergency call are set to
    ...   reducedEnergySaving. Rest of the cells are set to reducedEnergySaving when emergency call is ended.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 3
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 4
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...  - NRCELL-2.actEmergencyCall = True
    ...
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...  - NRCELL-3.emergencyAreaIdList = 3
    ...  - NRCELL-4.emergencyAreaIdList = 4
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, emergency call is ended.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_29818
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7323 USCB008392-A#B6: Determine Cell TX Path Switch Off List
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment A_16

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 feature flag

    Start UE3 emergency call in NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    ## Wait longer to verify, that NRCELL-2 will be still in notEnergySaving state
    Wait for 100s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop UE3 emergency call in NRCELL-2
    Wait for 130s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Set lbpsCellSOOrder to [100, 100, 100, 100] for cells [1,2,3,4]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Start UE3 emergency call in NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 50s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Stop UE3 emergency call in NRCELL-2
    Wait for 50s to trigger TX path switch off
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 360 - 420
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 240 - 300
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 250 - 310
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 210 - 270

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Cleanup after test A_16

#Optimization of:
#CB008392-A_16 Interaction with emergency call
#CB008392-E_3 Determine Cell Switch Off List With Emergency Call - interaction with 5GC00431
CB008392_5GC000431 Interaction with emergency call
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell with ongoing emergency call can not be set into reducedEnergySaving/energySaving state.
    ...   Test verifies, that cells with lbpsCellSOOrder higher than cell with emergency call are not considered as candidates
    ...   for TX switch off/cell switch off, until emergency call will be ended.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without emergency call are set to
    ...   reducedEnergySaving/energySaving. Rest of the cells are set to reducedEnergySaving/energySaving when emergency call is ended.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 2
    ...       }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-1.lbpsSOMethod = cell Switch Off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = {current minute}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...  - NRCELL-2.actEmergencyCall = True
    ...  - NRCELL-4.actEmergencyCall = True
    ...
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...  - NRCELL-3.emergencyAreaIdList = 3
    ...  - NRCELL-4.emergencyAreaIdList = 4
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, emergency call is ended.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_29818;5G_CP_ARC_ALG_9244
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7323 USCB008392-A#B6: Determine Cell TX Path Switch Off List
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment A_16_E_3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate CB008392 and 5GC000431 feature flags

    Start UE3 emergency call in NRCELL-2
    Start UE4 emergency call in NRCELL-4
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1

    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 340s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,energySaving,notEnergySaving]
    Wait for 100s to verify, that NRCELL-2, NRCELL-4 will be still in notEnergySaving state
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,notEnergySaving,energySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 350 - 600
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0
    ...                 Check RTPM counter: NRCELL-3 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 100 - 300
    ...                 Check RTPM counter: NRCELL-4 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is equal 0

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check RTPM counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0

    Omit when SKIP_COUNTERS present
    ...  rtpm clean

    Stop UE3 emergency call in NRCELL-2
    Stop UE4 emergency call in NRCELL-4
    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,notEnergySaving]
    Wait 340s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check RTPM counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1

    [Teardown]  Cleanup after test A_16_E_3
*** Keywords ***
