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

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Suite Setup     Run setup  rtpm=True
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/scf_4AZQU_4CELLS_SANSA-A-E.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/iphy_4AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
#In regression covred in
#CB008392-E Cell is reconfigured to change Power Saving Group with different lbpsSOMethod
CB008392-E_1 Cell is reconfigured to change Power Saving Group with different lbpsSOMethod - lbpsCellList modification
    [Tags]    E_1    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This test verifies, that cell(s) can be reconfigured from Power Saving Group with
    ...   - lbpsSOMethod = 'TX Switch Off' to 'cell Switch off'
    ...   - lbpsSOMethod = 'cell Switch off' to 'TX Switch Off'
    ...  Trigger for group change is modification of lbpsCellList
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-1.lbpsSOMethod = 'TX Switch Off'
    ...  - NRPGRP-2.lbpsSOMethod = 'cell Switch off'
    ...
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 2
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
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2.lbpsCellList = {
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
    ...  - NRBTS.actNrLBPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  rdLowLoadSwitchOffDelay = 300s (Switch-off delay time for 5GC000431)
    ...  NRBTS-1.shutdownWindow = 60 (duration of the cell shutdown for 5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1 and NRCELL-4 "Energy saving state" is set to reducedEnergySaving
    ...   For NRCELL-2 and NRCELL-3 "Energy saving state" is set to energySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_7430;5G_RAN_USR_COM_16102;5G_RAN_USR_COM_16103;CB_FIM_29800
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7358 USCB008392-E#B15: Handle Power Saving Configuration Change
    ...     -  CB008392-7359 USCB008392-E#B16: Manage Cell TX Path Reduction and Cell Switch Off Power Saving Interaction
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment E_1_2

    Activate CB008392 and 5GC000431 feature flags

    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 320s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Modify NRPGRP-1.lbpsCellList to contain cells [1, 4] NRPGRP-2.lbpsCellList to contain cells [2, 3]

    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait for 320s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,energySaving,energySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 400 - 570
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 80
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 470 - 520

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is equal 0
    ...                 Check counter: NRCELL-2 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 140 - 170
    ...                 Check counter: NRCELL-3 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 210 - 240
    ...                 Check counter: NRCELL-4 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 50 - 80

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0

    [Teardown]  Basic cleanup


#In regression covred in
#CB008392-E Cell is reconfigured to change Power Saving Group with different lbpsSOMethod
CB008392-E_2 Cell is reconfigured to change Power Saving Group with different lbpsSOMethod - lbpsSOMethod modification
    [Tags]    E_2    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This test verifies, that cell(s) can be reconfigured from Power Saving Group with
    ...   - lbpsSOMethod = 'TX Switch Off' to 'cell Switch off'
    ...   - lbpsSOMethod = 'cell Switch off' to 'TX Switch Off'
    ...  Trigger for group change is modification of lbpsSOMethod
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-1.lbpsSOMethod = 'TX Switch Off'
    ...  - NRPGRP-2.lbpsSOMethod = 'cell Switch off'
    ...
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 2
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
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2.lbpsCellList = {
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
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-2.lbpsRTXMinLoad = 20
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRBTS.actNrLBPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  rdLowLoadSwitchOffDelay = 300s (Switch-off delay time for 5GC000431)
    ...  NRBTS-1.shutdownWindow = 60 (duration of the cell shutdown for 5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1 and NRCELL-2 "Energy saving state" is set to energySaving
    ...   For NRCELL-3 and NRCELL-4 "Energy saving state" is set to reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_7430;5G_RAN_USR_COM_16102;5G_RAN_USR_COM_16103;CB_FIM_29800
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7358 USCB008392-E#B15: Handle Power Saving Configuration Change
    ...     -  CB008392-7359 USCB008392-E#B16: Manage Cell TX Path Reduction and Cell Switch Off Power Saving Interaction
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment E_1_2

    Activate CB008392 and 5GC000431 feature flags

    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 320s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Modify NRPGRP-1.lbpsSOMethod to 'Cell Switch off', NRPGRP-2.lbpsSOMethod to 'TX Switch Off'

    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait for 320s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [energySaving, energySaving, reducedEnergySaving, reducedEnergySaving]


    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 80
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 80
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 470 - 510
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 470 - 510

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 140 - 180
    ...                 Check counter: NRCELL-2 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 140 - 180
    ...                 Check counter: NRCELL-3 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 50 - 80
    ...                 Check counter: NRCELL-4 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 50 - 80

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0

    [Teardown]  Basic cleanup

#Optimization of:
#CB008392-E_1 Cell is reconfigured to change Power Saving Group with different lbpsSOMethod - lbpsCellList modification
#CB008392-E_2 Cell is reconfigured to change Power Saving Group with different lbpsSOMethod - lbpsSOMethod modification
CB008392-E Cell is reconfigured to change Power Saving Group with different lbpsSOMethod
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This test verifies, that cell(s) can be reconfigured from Power Saving Group with
    ...   - lbpsSOMethod = 'TX Switch Off' to 'cell Switch off'
    ...   - lbpsSOMethod = 'cell Switch off' to 'TX Switch Off'
    ...  Trigger for group change is modification of lbpsCellList and lbpsSOMethod
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-1.lbpsSOMethod = 'TX Switch Off'
    ...  - NRPGRP-2.lbpsSOMethod = 'cell Switch off'
    ...
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 2
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
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2.lbpsCellList = {
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
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRBTS.actNrLBPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  rdLowLoadSwitchOffDelay = 300s (Switch-off delay time for 5GC000431)
    ...  NRBTS-1.shutdownWindow = 60 (duration of the cell shutdown for 5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1 and NRCELL-4 "Energy saving state" is set to energySaving
    ...   For NRCELL-2 and NRCELL-3 "Energy saving state" is set to reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_7430;5G_RAN_USR_COM_16102;5G_RAN_USR_COM_16103;CB_FIM_29800
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7358 USCB008392-E#B15: Handle Power Saving Configuration Change
    ...     -  CB008392-7359 USCB008392-E#B16: Manage Cell TX Path Reduction and Cell Switch Off Power Saving Interaction
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment E_1_2

    Activate CB008392 and 5GC000431 feature flags

    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 340s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Modify NRPGRP-1.lbpsCellList to contain cells [1, 4] NRPGRP-2.lbpsCellList to contain cells [2, 3]
    Wait 400s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,energySaving,energySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is above 1

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is equal 0
    ...                 Check RTPM counter: NRCELL-2 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is above 1
    ...                 Check RTPM counter: NRCELL-3 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is above 1
    ...                 Check RTPM counter: NRCELL-4 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is above 1

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check RTPM counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check RTPM counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check RTPM counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0

    Omit when SKIP_COUNTERS present
    ...  rtpm clean

    Modify NRPGRP-1.lbpsSOMethod to 'Cell Switch off', NRPGRP-2.lbpsSOMethod to 'TX Switch Off'
    Wait 400s for cells [1,2,3,4] energySavingState change to [energySaving, reducedEnergySaving, reducedEnergySaving, energySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1
    ...                 Check RTPM counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check RTPM counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check RTPM counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1

    [Teardown]  Basic cleanup


#In regression covred in
#CB008392_5GC000431 Interaction with emergency call
CB008392-E_3 Determine Cell Switch Off List With Emergency Call - interaction with 5GC00431
    [Tags]    E_3    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell with ongoing emergency call can not be set into energySaving state.
    ...   Test verifies, that cells with lbpsCellSOOrder higher than cell with emergency call are not considered as candidates
    ...   for cell switch off, until emergency call will be ended.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without emergency call are set to
    ...   energySaving. Rest of the cells are set to energySaving when emergency call is ended.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = cell Switch Off
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
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRBTS.actNrLBPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...  - NRCELL-2.actEmergencyCall = True
    ...
    ...  rdLowLoadSwitchOffDelay = 300s (Switch-off delay time for 5GC000431)
    ...  rdHighLoadSwitchOnDelay = 120s (Switch-on delay time for 5GC000431)
    ...  NRBTS-1.shutdownWindow = 60 (duration of the cell shutdown for 5GC000431)
    ...
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...  - NRCELL-3.emergencyAreaIdList = 3
    ...  - NRCELL-4.emergencyAreaIdList = 4
    ...
    ...  == Postconditions ==
    ...   - All cell's "Energy saving state" is set to energySaving, emergency call is ended.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_9244
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej - <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-10714 5G-CP-RT shall determine Cell Switch Off list
    ...
    ...  == HISTORY ==
    ...     [07.09.2022] - TC Create
    ...     [12.09.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=866522)

    [Setup]  Prepare test environment E_3

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Activate 5GC000431 feature flag

    Start UE3 emergency call in NRCELL-2l
    ## Wait longer to verify, that NRCELL-2 will be still in notEnergySaving state
    Wait for 760s to trigger cell switch off
    Check for cells [1,2,3,4] if energySavingState equals [energySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop UE3 emergency call in NRCELL-2
    Wait for 1100s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [energySaving,energySaving,energySaving,energySaving]

    Set lbpsCellSOOrder to [100, 100, 100, 100] for cells [1,2,3,4]
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Wait for 20s until Airphone will be ready for UE attach after cell switch on procedure
    Start UE3 emergency call in NRCELL-2
    Wait for 370s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [energySaving,notEnergySaving,energySaving,energySaving]

    Stop UE3 emergency call in NRCELL-2
    Wait for 370s to trigger cell switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [energySaving,energySaving,energySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 2
    ...                 Check counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 2
    ...                 Check counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 2
    ...                 Check counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 2

    [Teardown]  Cleanup after test E_3

*** Keywords ***
