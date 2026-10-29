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
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008392 CFAM
...
...      == HISTORY ==
...         [14.07.2022] - TC Create
...         [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)


Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Resource    ./resources/CB008392-common_keywords.robot

Suite Setup  Run Setup  rtpm=True
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/scf_4AZQU_4CELLS_SANSA-A-E.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008392/ASIL_ABIO_TDD_FR1_SANSA/iphy_4AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008392-A_7_8 Cell degraded due to cell and BTS level alarm
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies that when one of the cells in power group becomes failed, the rest of cells in the same power group
    ...     with energy saving state set to reducedEnergy should switch on TX paths and change state to notEnergySaving.
    ...     When one cell is failed it cannot switch off TX paths.
    ...     When one cell is failed, the rest of cells in the same power group cannot switch off TX paths as well.
    ...     In part 2 this test verifies that when any enabled cell of a Power Saving Group becomes degraded or failed due to a fault that was raised
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
    ...       lbpsCellSOOrder = 1
    ...       nrCellId = 1
    ...       }
    ...       {
    ...       lbpsCellSOOrder = 100
    ...       nrCellId = 2
    ...       }
    ...       {
    ...       lbpsCellSOOrder = 100
    ...       nrCellId = 3
    ...       }
    ...       {
    ...       lbpsCellSOOrder = 100
    ...       nrCellId = 4
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
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_OP_2249; 5G_RAN_OP_2251; 5G_RAN_OP_2254; 5G_RAN_OP_2288; 5G_RAN_OP_2250; 5G_RAN_OP_2287
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...    - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...    - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7324 USCB008392-A#B7: 4TX Cell Switch Off Cell TX Paths
    ...     -  CB008392-7325 USCB008392-A#B8: 4TX Cell Switch On Cell TX Paths
    ...
    ...  == HISTORY ==
    ...     [14.07.2022] - TC Create
    ...     [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

    [Setup]  Prepare test environment CB008392-A_7
    [Tags]  A_7

    Start Collecting Syslog    prefix=A_7_8
    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Activate CB008392 feature flag
    Wait 90s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Reset RMOD-1
    # All cells should switch on TXs immediately after fault is raised on NRCELL-1
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 90s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Deactivate CB008392 feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Reset X2 link between gNB2 and simulated eNB1
    Wait for 65s to timer x2LinkReestabTmr expiry
    Check for cells [1,2,3,4] if availabilityStatus equals [degraded,degraded,degraded,degraded]

    Activate CB008392 feature flag
    Wait for 50s to trigger TX path switch off
    # NRCELL-1,2,3,4 cannot switch off TX due to BTS alarm (no X2 link available)
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Setup X2 link between gNB2 and simulated eNB1
    Wait for 5s to availabilityStatus change
    Verify that cells [1,2,3,4] are not degraded
    Wait 90s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Reset X2 link between gNB2 and simulated eNB1
    Wait for 100s to trigger TX path switch off
    # NRCELL-1,2,3,4 cannot switch off TX due to BTS alarm (no X2 link available)
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3

    [Teardown]  Cleanup after test A_8
