*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008745 is impacting both 4G and 5G
...         In 5G CB008745 introduces new parameters for configuring the monitoring window of 5G Cell switching
...         CB008745 introduces PSG control logic improvement, so that cells are switch on/off in more flexible and accurate way
...         - Extend and support new method of load quantity calculation
...         - Extend and support new triggering rule of Cell switch on/off
...
...      == TEST SET NAME ==
...         4G/5G Cell Switch OFF & 4G MIMO Muting Responsiveness Improvements
...
...      == TESTING SPLIT ==
...         CB008745-B PSG control logic improvement in 5G for Cell Swtich off/on
...
...      == CONTACTS ==
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008745 CFAM
...
...      == HISTORY ==
...         [21.10.2022] - TC Create
...         [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

Resource    ./resources/CB008745-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run setup
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008745-B_3 Feature activation and deactivation - change of load calculation and cell switch on-off rule in active PSG
    [Tags]    B_3
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when feature is activated/deactivated, new parameters are taken into account in active Power Saving Group
    ...   After feature activation:
    ...   - monitoring window for cell switch off/on is defined by lbpsMonWinForCellSOff/lbpsMonWinForCellSOn parameters
    ...   - load quantity calculation is defined by lbpsLoadCalcMethod parameter
    ...     (can be checked only manually in syslog)
    ...   - cell switch off/on rule is defined by lbpsSOffTrRule/lbpsSOnTrRule parameters
    ...   After feature dactivation:
    ...   - monitoring window for cell switch off/on is based on default values: off=5min, on=2min
    ...   - load quantity calculation is based on 5GC000431 default formula: Max(G_N_combined, P)
    ...     (can be checked only manually in syslog)
    ...   - cell switch off/on rule is based on 5GC000431 default MinValueMethod/MaxValueMethod
    ...
    ...   In this test case lbpsLoadCalcMethod = Max(G, C, P), lbpsSOffTrRule/lbpsSOnTrRule = SlidingAverageMethod
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA cells
    ...  - NRCELL-1, NRCELL-2 are up
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = cell switch off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...    }
    ...  - NRPGRP-1.lbpsMonWinForCellSOff = 60
    ...  - NRPGRP-1.lbpsMonWinForCellSOn = 60
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = SlidingAverageMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = SlidingAverageMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 10
    ...  - NRPGRP-1.lbpsMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...
    ...  == Postconditions ==
    ...   Feature CB008745 is deactivated.
    ...   For NRCELL-1 "Energy saving state" is equal energySaving
    ...   For NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_OP_2408;5G_RAN_USR_COM_16853;5G_RAN_USR_COM_16915;5G_RAN_USR_COM_16917
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008745-B#2: Activate PSG Control Logic Improvement for 5G
    ...     -  USCB008745-B#3: Deactivate PSG Control Logic Improvement for 5G
    ...
    ...  == HISTORY ==
    ...     [21.10.2022] - TC Create
    ...     [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

    [Setup]     Prepare test environment B_3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start collecting syslog  prefix=B_3

    Activate 5GC000431 feature flag
    Sleep  80s  To verify that hardcoded 5min cell switch off monitoring window is ongoing (not lbpsMonWinForCellSOff)
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Activate CB008745 feature flag
    Log to console  Cell should switch off immediately, as there is no traffic
    # Sliding avregae load calculation is started after CB008745 activation
    # For SlidingAverageMethod first cell can be switched off when average load and first reported load is below lbpsMinLoad
    # even if average load is based on number of measurement periods lower than lbpsMonWinForCellSOff/10
    Wait 20s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Attach UEs[1,2] to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Run 100Mbps DL traffic on UEs[1,2] GBR bearer
    Sleep    15s    To stabilize measurements with high traffic
    Verify that in Power Saving load measurement is differentiation between GBR and nonGBR traffic type for cell2

    Log to console  Wait for cell switch on not longer than lbpsMonWinForCellSOn until average load will be above lbpsMaxLoad
    Wait 60s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Stop 100Mbps DL traffic on UEs[1,2] GBR bearer
    Sleep    15s    To stabilize measurements with low traffic
    Log to console  Wait for cell switch off not longer than lbpsMonWinForCellSOff until average load and LoadAftSwOff will be below lbpsMinLoad
    Wait 60s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is above 60
    ...                 Check RTPM counter: NRCELL-2 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is equal 0

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 2
    ...                 Check RTPM counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0

    Deactivate CB008745 feature flag
    Run 100Mbps DL traffic on UEs[1,2] GBR bearer
    Sleep    15s    To stabilize measurements with high traffic
    Verify that in Power Saving load measurement is no differentiation between GBR and nonGBR traffic type for cell2

    Sleep  70s  To verify that hardcoded 2min cell switch on monitoring window is ongoing (not lbpsMonWinForCellSOn)
    Check for cells [1,2] if energySavingState equals [energySaving,notEnergySaving]
    Wait 60s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

##     >>>This part will be not added to CRT
#    Stop 150Mbps DL traffic on UE1 GBR bearer and wait 15s  #to stabilize measurements with low traffic
#    Sleep  200s  To verify that hardcoded 5min cell switch off monitoring window is ongoing (not lbpsMonWinForCellSOnff)
#    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
#    Sleep  110s  Wait until cell switch off monitoring window is finished
#    Wait 20s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
#    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]
##     <<<

    [Teardown]   Basic cleanup
