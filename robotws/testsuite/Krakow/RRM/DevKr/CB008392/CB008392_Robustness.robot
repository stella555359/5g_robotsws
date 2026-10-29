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
...         [xx.xx.2022] - Review

Resource    ./resources/CB008392-common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Suite Setup  Run setup
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=                    ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SKIP_COUNTERS}=              ${FALSE}

*** Test Cases ***
CB008392_Robustness_1 PSG with multiple lbpsPeriodList with short intervals
    [Tags]    Robustness_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that TX switch on/off works as expected, when Power Saving Group is configured with maximum
    ...   number of periods on lbpsPeriodList. Each period and interval before next period has short duration
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
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
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16091
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
    ...     [xx.xx.2022] - Review

    #####################################################################
    ############################# Variant 1 #############################
    #####################################################################

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1     100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1     2     3     4
    Set test variable    ${NRPGRP-1.lbpsDuration}               1
    Set test variable    ${NRPGRP-1.offset}                     3
    Set NRPGRP-1 parameters

    ${yaml}=  Create yaml for NRPGRP-1 with 25 lbpsPeriods with 1min intervals and CB008392 activation
    Configure  ${yaml}  node_id=1

    start_collecting_syslog   prefix=variant1
    ## Wait longer until firt lbps period is started
    Wait 180s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait for 30s until lbps period will be finished
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    FOR    ${i}    IN RANGE   24
       Wait 110s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
       Wait for 30s until lbps period will be finished
       Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    END
    stop_collecting_syslog
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 450 - 800
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 25
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0

    #####################################################################
    ############################# Variant 2 #############################
    #####################################################################

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}            30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}             30
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1     2     3     4
    Set test variable    ${NRPGRP-1.lbpsDuration}               1
    Set test variable    ${NRPGRP-1.offset}                     3
    Set NRPGRP-1 parameters

    ${yaml}=  Create yaml for NRPGRP-1 with 25 lbpsPeriods with 1min intervals and CB008392 activation
    Configure  ${yaml}  node_id=1

    start_collecting_syslog   prefix=varian2
    ## Wait longer until firt lbps period is started
    Wait 180s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait for 30s until lbps period will be finished
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    FOR    ${i}    IN RANGE   24
      Wait 110s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
      Wait for 30s until lbps period will be finished
      Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    END
    stop_collecting_syslog
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 450 - 800
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 450 - 800
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 450 - 800
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 450 - 800

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 25
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 25
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 25
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 25


    #####################################################################
    ############################# Variant 3 #############################
    #####################################################################

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}            30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}             30
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1     2     3     4
    Set test variable    ${NRPGRP-1.lbpsDuration}               1
    Set test variable    ${NRPGRP-1.offset}                     3

    Set NRPGRP-1 parameters
    ${yaml}=  Create yaml for NRPGRP-1 with 25 lbpsPeriods with 0min intervals and CB008392 activation
    Configure  ${yaml}  node_id=1

    start_collecting_syslog   prefix=variant3
    ## Wait longer until firt lbps period is started
    Wait 180s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    FOR    ${i}    IN RANGE   23
       Wait for 20s to check if energySavingState was not changed
       Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
       Wait for 20s to check if energySavingState was not changed
       Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
       Wait for 20s to check if energySavingState was not changed
       Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    END
    Wait 100s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]


    stop_collecting_syslog
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 1450 - 1510
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 1450 - 1510
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 1450 - 1510
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 1450 - 1510

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    [Teardown]  Basic cleanup
