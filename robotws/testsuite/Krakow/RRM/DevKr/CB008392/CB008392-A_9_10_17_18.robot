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
...         [19.07.2022] - TC Create
...         [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

Resource    ./resources/CB008392-common_keywords.robot
Library     testsuite/Krakow/RRM/resources/Python/AaShell.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Suite Setup  Run setup  rtpm=True
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/scf_4AZQU_4CELLS_SANSA-A-E.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/iphy_4AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008392-A_9 Switch on-off cells TX path after lbpsSuspended modification
    [Tags]    A_9    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when in Power Saving Group energy saving is suspended, then all cells with "Energy saving state" set to
    ...   reducedEnergySaving are set to notEnergySaving state immediately. When energy saving is unsuspended, cells can be again set to
    ...   reducedEnergySaving state.
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
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 2
    ...       }
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
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_7414;5G_RAN_USR_COM_16105;5G_RAN_USR_COM_16106
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7327 USCB008392-A#B18: Suspend Load-Based Reduced TX Paths Power Saving
    ...     -  CB008392-7328 USCB008392-A#B19: Un-suspend Load-Based Reduced TX Paths Power Saving
    ...
    ...  == HISTORY ==
    ...     [20.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment CB008392-A_9

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Activate CB008392 feature flag
    Wait for 80s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ## Check again energySavingState to verify that PSG is suspended
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  notSuspended  bts_id=1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 160 - 460
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 380
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 380
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 380

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2


    [Teardown]  Basic cleanup

CB008392-A_10 Switch on-off TX path after cell lock-unlock
    [Tags]    A_10
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when cell with "Energy saving state" set to reducedEnergySaving is locked, it's
    ...   "Energy saving state" is changed to notEnergySaving.  When cell is unlocked it comes back to reducedEnergySaving.
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
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, all cells are unlocked.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_OP_2288;CB_FIM_29820;CB_FIM_29821
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7324 USCB008392-A#B7: 4TX Cell Switch Off Cell TX Paths
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [14.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment CB008392-A_10

    Start Collecting Syslog    prefix=A_10
    Activate CB008392 feature flag
    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Lock NRCELL-1
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Unlock NRCELL-1
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    #Modification of this parameter triggers automatic NRCELL lock/unlock
    Change eNB parameter value  NRCELL-1.pMax  27  bts_id=1
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 20
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 100
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 100
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 100

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0

    [Teardown]  Cleanup after test A_10

CB008392-A_17 Switch on TX path failure
    [Tags]    A_17
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when cell TX paths can not be switched on, fault 1900 is raised.
    ...   Rest of cells in the same power group with energy saving state set to reducedEnergy should switch on TX paths and change state to
    ...   notEnergySaving. When failure is resolved, TX path can be switched on and cell's "Energy saving state" is set to notEnergySaving.
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
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 50
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to reducedEnergySaving, no new alarm is raised.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16095
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [20.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)
    ...     [20.03.2023] - Align with CB007184. Cell is not failed, but degraded, when half of TX paths can not be switched on

    [Setup]  Prepare test environment A_17

    Start Collecting Syslog    prefix=A_17
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Activate CB008392 feature flag

    Wait 180s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Enable TX activation failure for cell-4 on RRH-4

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 140Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds

    Wait for 40s to trigger TX path switch on

    Wait Until Keyword Succeeds  4x  30 sec
    ...  Verify that fault 1900 is raised for RMOD-4
    Wait Until Keyword Succeeds  4x  5 sec
    ...  Verify that fault 4003 is raised for NRCELL-4
    Check for cells [4] if availabilityStatus equals [degraded]

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Disable TX activation failure for cell-4 on RRH-4
    Reset RMOD-4
    Wait Until Keyword Succeeds  4x  60 sec
    ...  Verify that alarm with fault 1900 "RF Module configuring failed" is cleared

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop 140Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait 180s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 140
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 90
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 50
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 10

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    [Teardown]  Cleanup after test A_17

#In regression covred in
#CB008392-A_14_15 Interaction with CMAS and ETWS
CB008392-A_18 Switch on cell TX path after lbpsCellSOOrder modification
    [Tags]    A_18    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when lbpsCellSOOrder in Power Saving Group is changed, then all cells with "Energy saving state" set to
    ...   reducedEnergySaving are set to notEnergySaving state immediately. When conditions for cell TX switch on is meet, new order of
    ...   cells is applied.
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
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to notEnergySaving.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_7414
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [20.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment A_18

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Activate CB008392 feature flag
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    ## NRCELL-4 is not in energy saving due to lbpsLastCellSOEnabled = False

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds

    Set lbpsCellSOOrder to [10] for cells [1]
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait for 40s to trigger TX path switch off
    ## NRCELL-1 is not in energy saving due to lbpsLastCellSOEnabled = False
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 120 - 200
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 300 - 500
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 220 - 420
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 140 - 340

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1


    [Teardown]  Basic cleanup


*** Keywords ***
