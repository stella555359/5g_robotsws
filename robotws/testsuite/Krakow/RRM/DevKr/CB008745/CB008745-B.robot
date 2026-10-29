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
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run setup
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008745-B_2 Feature activation and deactivation - no change of load calculation and cell switch on-off rule in active PSG
    [Tags]    B_2    SKIPRUN
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
    ...   In this test case lbpsLoadCalcMethod and lbpsSOffTrRule/lbpsSOnTrRule are set to the same values as default for 5GC000431,
    ...   so only monitoring window length is changed.
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
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G_N_combined, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = MinValueMethod
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

    [Setup]  Prepare test environment B_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start collecting syslog  prefix=B_2

    Activate 5GC000431 feature flag
    Sleep  80s   To verify that hardcoded 5min cell switch off monitoring window is ongoing (not lbpsMonWinForCellSOff)
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Activate CB008745 feature flag
    Log to console  Cell should switch off immediately, as lbpsMonWinForCellSOff is already reached
    Wait 20s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Attach UE1 to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Run 150Mbps DL traffic on UE1 non-GBR bearer and wait 15s  #to stabilize measurements with high traffic
    Sleep  70s  Wait until cell switch on monitoring window is finished
    Wait 20s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Stop 150Mbps DL traffic on UE1 GBR bearer and wait 15s  #to stabilize measurements with low traffi
    Sleep  70s   Wait until cell switch off monitoring window is finished
    Wait 20s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is above 60
    ...                 Check RTPM counter: NRCELL-2 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is equal 0

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 2
    ...                 Check RTPM counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0

    Run 150Mbps DL traffic on UE1 GBR bearer and wait 0s
    Sleep  20s   To get at least 1 period with load above lbpsMaxLoad
    Deactivate CB008745 feature flag  # Takes ~30-40s
    # Monitoring window for cell switch on is not restarted
    Sleep  40s  To verify that hardcoded 2min cell switch on monitoring window is ongoing (not lbpsMonWinForCellSOn)
    Check for cells [1,2] if energySavingState equals [energySaving,notEnergySaving]
    Wait 70s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Stop 150Mbps DL traffic on UE1 GBR bearer and wait 15s  #to stabilize measurements with low traffic
    Sleep  200s  To verify that hardcoded 5min cell switch off monitoring window is ongoing (not lbpsMonWinForCellSOnff)
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Sleep  110s   Wait until cell switch off monitoring window is finished
    Wait 20s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    [Teardown]  Basic cleanup


CB008745-B_3 Feature activation and deactivation - change of load calculation and cell switch on-off rule in active PSG
    [Tags]    B_3    SKIPRUN
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


CB008745-B_4 Continuous calculation of sliding average load
    [Tags]    B_4    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   Test verifies that monitoring window for sliding average load is not disturbed by actions which
    ...   are changing immediately state of the power saving group:
    ...   - suspended period
    ...   - modification of lbpsCellList
    ...   - cell lock
    ...   Test verifies, that power saving group (NRPGRP) can be removed and added again when CB008745 is active.
	...   Next steps can be verified only in syslog:
    ...   History of sliding average load for power group should be restarted. After first 10s period sliding average
    ...   load for cell switch off/on must be equal to current pgLoad.
    ...   First load measurement after NRPGRP addition should be equal to real load, because when any power saving
    ...   feature is active (5GC000431 or CB008392), L2 is calculating continuously load measurements for all enabled
    ...   cells in gNB, even if cell does not belog to power saving group.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
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
    ...  - NRPGRP-1.lbpsMonWinForCellSOff = 200
    ...  - NRPGRP-1.lbpsMonWinForCellSOn = 200
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G_N_combined, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = SlidingAverageMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = SlidingAverageMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 40
    ...  - NRPGRP-1.lbpsMinLoad = 20
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1, NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16819
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008745-B#4: Determine Cell Switch On List
    ...     -  USCB008745-B#5: Determine Cell Switch Off List
    ...
    ...  == HISTORY ==
    ...     [21.10.2022] - TC Create
    ...     [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

    [Setup]  Prepare test environment B_4

    start collecting syslog  prefix=B_4

    Attach UEs[1,2] to gNB2 cell2 with 1 non-GBR bearer
    Run 110Mbps DL traffic on UEs[1,2] non-GBR bearer
    # Started traffic is lower than lbpsMinLoad (if 2 cells in PSG are enabled)

    Activate 5GC000431 and CB008745 feature flags
    Log to console  Cell should switch off immediately, as load is below lbpsMinLoad
    Wait 20s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to suspended for all periods
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to notSuspended for all periods
    Log to console  Wait for cell switch off less than lbpsMonWinForCellSOff
    Wait 170s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Remove nrCellId=2 from NRPGRP-1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    # There is only 1 cell left in NRPGRP, so it won't be switched off, even if there is no traffic

    Restore nrCellId=2 to NRPGRP-1
    Log to console  Wait for cell switch off less than lbpsMonWinForCellSOff
    Wait 170s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Lock nrCellId=1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Unlock nrCellId=1
    Log to console  Wait for cell switch off less than lbpsMonWinForCellSOff
    Wait 170s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Remove NRPGRP-1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Attach UEs[3,4] to gNB2 cell2 with 1 non-GBR bearer
    Run 130Mbps DL traffic on UEs[3,4] non-GBR bearer
    # Increase traffic for cell2
    # Started traffic will be higher than lbpsMinLoad (if 2 cells in new PSG will be enabled)

    Restore NRPGRP-1 with cell1 and cell2
    Log to console  None of cells should switch off, as load is above lbpsMinLoad
    Sleep  210s  reason=Wait longer than lbpsMonWinForCellSOff
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    [Teardown]  Cleanup after test B_4

CB008745-B_5 Online modification of lbpsSOffTrRule and lbpsSOnTrRule
    [Tags]    B_5
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   Test verifies that when lbpsSOffTrRule/lbpsSOnTrRule is changed to:
    ...   - MaxValueMethod/MinValueMethod, then monitoring window is restarted
    ...   - SlidingAverageMethod, then monitoring window is continued
    ...   Test verifies, that when load in one 10s period is not meeting threshold for cell switch off/on, then:
    ...   - for MinValueMethod/MaxValueMethod monitoring window is restarted
    ...   - for SlidingAverageMethod monitoring window is continued
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
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
    ...  - NRPGRP-1.lbpsMonWinForCellSOff = 120
    ...  - NRPGRP-1.lbpsMonWinForCellSOn = 100
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G_N_combined, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = MinValueMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 20
    ...  - NRPGRP-1.lbpsMinLoad = 10
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1, NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16818;5G_RAN_USR_COM_16819
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008745-B#4: Determine Cell Switch On List
    ...     -  USCB008745-B#5: Determine Cell Switch Off List
    ...
    ...  == HISTORY ==
    ...     [21.10.2022] - TC Create
    ...     [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

    [Setup]  Prepare test environment B_5

    start collecting syslog  prefix=B_5

    Attach UEs[1,2,3,4] to gNB2 cell2 with 1 non-GBR bearer
    Run 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Activate 5GC000431 and CB008745 feature flags

    Log to console    Step 1: Switching off cell with MaxValueMethod and monitoring window restart due to period with high traffic
    Stop 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Sleep  60s  To get at least 5 periods with load below lbpsMinLoad
    Run 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Sleep  20s  To get at least 1 period with load above lbpsMinLoad
    Stop 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Log to console  Monitoring window for cell switch off is restarted
    Sleep  50s  To verify that monitoring window for cell1 switch off is ongoing
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]


    Log to console    Step 2: Switching off cell after changing lbpsSOffTrRule to SlidingAverageMethod without monitoring window restart
    Modify NRPGRP-1.lbpsSOffTrRule/lbpsSOnTrRule to SlidingAverageMethod   # Takes ~30-40s
    Log to console  Wait for cell switch off less than lbpsMonWinForCellSOff until average load and LoadAftSwOff will be below lbpsMinLoad
    Wait 40s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]


    Log to console    Step 3: Switching on cell with SlidingAverageMethod and monitoring window containing period with low traffic
    Run 100Mbps DL traffic on UEs[1,2,3,4] non-GBR bearer
    Sleep  40s  To get at least 3 periods with load above lbpsMaxLoad
    Stop 100Mbps DL traffic on UEs[1,2,3,4] non-GBR bearer
    Sleep  20s  To get at least 1 period with load below lbpsMaxLoad
    Run 100Mbps DL traffic on UEs[1,2,3,4] non-GBR bearer
    Log to console  Wait for cell switch on less than lbpsMonWinForCellSOn until average load will be above lbpsMaxLoad
    Wait 70s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]


    Log to console  Step 4: Switching off cell with SlidingAverageMethod and monitoring window containing period with high traffic
    Sleep  80s  To stabilize high traffic
    Stop 100Mbps DL traffic on UEs[1,2,3,4] non-GBR bearer
    Sleep  60s  To get at least 5 periods with load below lbpsMinLoad
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Run 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Sleep  20s  To get at least 1 period with load above lbpsMinLoad
    Stop 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Log to console  Wait for cell switch off less than lbpsMonWinForCellSOff until average load and LoadAftSwOff will be below lbpsMinLoad
    Wait 100s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]


    Log to console  Step 5: Restart of cell switch on monitoring window after changing lbpsSOnTrRule to MinValueMethod
    Modify NRPGRP-1.lbpsSOnTrRule to MinValueMethod
    Log to console  Monitoring window is restarted
    Run 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Sleep  80s  To verify that monitoring window for cell1 switch on is ongoing
    Check for cells [1,2] if energySavingState equals [energySaving,notEnergySaving]
    Wait 60s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup


CB008745-B_6 Online modification of lbpsLoadCalcMethod
    [Tags]    B_6    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when lbpsLoadCalcMethod is changed, threshold for cell switch off/on can be met without traffic level change.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
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
    ...  - NRPGRP-1.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = MinValueMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 20
    ...  - NRPGRP-1.lbpsMinLoad = 10
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 100 (to verify that CPLANE will ignore PDCCH load and focus on loadDlGBRAvg, loadDlCBNonGBRAvg)
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1, NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16819
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008745-B#4: Determine Cell Switch On List
    ...     -  USCB008745-B#5: Determine Cell Switch Off List
    ...
    ...  == HISTORY ==
    ...     [21.10.2022] - TC Create
    ...     [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

    [Setup]  Prepare test environment B_6

    start collecting syslog  prefix=B_6

    Attach UE1 to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI3 bearer
    Run 150Mbps DL traffic on UE1 non-GBR bearer and wait 0s
    Run 150Mbps DL traffic on UE1 GBR bearer and wait 0s

    Activate 5GC000431 and CB008745 feature flags
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Log to console    Load on loadDlGBRAvg and loadDlCBNonGBRAvg and is below lbpsMinLoad
    Log to console    Wait until cell switch off monitoring window is finished
    # TC may be not reproduced each time.
    # If cell1 will not be switched off, it can be still verified in syslog, that after modification of
    # lbpsLoadCalcMethod CPLANE is calculating pgLoad basing on expected measurements form L2
    Run Keyword And Continue On Failure
    ...     Wait 60s for cells [1,2] energySavingState change to [switchingOff,notEnergySaving]
    Run Keyword And Continue On Failure
    ...     Wait 80s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Modify NRPGRP-1.lbpsLoadCalcMethod to "Max(G_N_combined, P)"

    Log to console    Load on loadDlNonGBRAvg and is above lbpsMaxLoad; loadDlGBRAvg and loadDlCBNonGBRAvg are ignored
    Sleep  60s  Wait for cell switch on
    Wait 20s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup


CB008745-B_7 SA - traffic change with lbpsLoadCalcMethod = Max(G, C, P)
    [Tags]    B_7
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that PowerGroup pgLoad is updated according to lbpsLoadCalcMethod = Max(G, C, P).
    ...   GBR and nGBR traffic for SA UEs is changing, but is still above lbpsMaxLoad during monitoring window,
    ...   leading to cell switch on.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
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
    ...  - NRPGRP-1.lbpsMonWinForCellSOn = 160
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = MinValueMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 10
    ...  - NRPGRP-1.lbpsMinLoad = 5
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 100 (to verify that CPLANE will ignore PDCCH load and focus on loadDlGBRAvg, loadDlCBNonGBRAvg)
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1, NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16818;5G_RAN_USR_COM_16819
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008745-B#4: Determine Cell Switch On List
    ...     -  USCB008745-B#5: Determine Cell Switch Off List
    ...
    ...  == HISTORY ==
    ...     [21.10.2022] - TC Create
    ...     [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

    [Setup]  Prepare test environment B_7

    start collecting syslog  prefix=B_7

    Activate 5GC000431 and CB008745 feature flags
    Wait 140s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Attach UEs[1,2,3] to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Run 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Sleep  20s  To get at least 1 period with loadDlCBNonGBRAvg load above lbpsMaxLoad
    Run 100Mbps DL traffic on UEs[1,2,3] GBR bearer
    Sleep  20s  To get at least 1 period with loadDlGBRAvg/loadDlCBNonGBRAvg load above lbpsMaxLoad
    Stop 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Sleep  40s  To get at least 3 periods with loadDlGBRAvg load above lbpsMaxLoad
    Run 100Mbps DL traffic on UEs[1,2,3] non-GBR bearer
    Stop 100Mbps DL traffic on UEs[1,2,3] GBR bearer
    Sleep  20s  To get at least 1 period with loadDlCBNonGBRAvg load above lbpsMaxLoad

    Attach UEs[4,5,6] to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Run 100Mbps DL traffic on UEs[4,5,6] GBR bearer
    Sleep  20s  To get at least 1 period with loadDlGBRAvg load above lbpsMaxLoad
    Detach UEs[1,2,3]

    Check for cells [1,2] if energySavingState equals [energySaving,notEnergySaving]
    Sleep  40s  Wait until cell switch on monitoring window will be finished
    #lbpsMonWinForCellSOn should finish now (from starting traffic till now should pass not more than 160s)
    Wait 20s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup


CB008745-B_8 NSA - traffic change with lbpsLoadCalcMethod = Max(G, C, P)
    [Tags]    B_8    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that PowerGroup pgLoad is updated according to lbpsLoadCalcMethod = Max(G, C, P), when traffic for NSA UEs is changing.
    ...   (For NSA UEs only nGBR load can be started).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - gNB2 up and running with 2 SA+NSA cells
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
    ...  - NRPGRP-1.lbpsMonWinForCellSOn = 140
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = MinValueMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 10
    ...  - NRPGRP-1.lbpsMinLoad = 5
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 0
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1, NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_16818;5G_RAN_USR_COM_16819
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB008745-B#4: Determine Cell Switch On List
    ...     -  USCB008745-B#5: Determine Cell Switch Off List
    ...
    ...  == HISTORY ==
    ...     [21.10.2022] - TC Create
    ...     [07.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=870185)

    [Setup]  Prepare test environment B_8

    ## Verify syslog, if after changing UEs traffic new value of PowerGroup pgLoad is calculated, L2 is sending correct load
    start collecting syslog  prefix=B_8
    Activate 5GC000431 and CB008745 feature flags
    Wait 140s for cells [1,2] energySavingState change to [energySaving,notEnergySaving]

    Attach UE16 to simulated eNB1 CELL-1
    Attach UE17 to simulated eNB1 CELL-1
    Attach UE18 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE16 with NRCELL_2 on gNB2
    Trigger SgnbAddition procedure for UE17 with NRCELL_2 on gNB2
    Trigger SgnbAddition procedure for UE18 with NRCELL_2 on gNB2

    Log to console  Start DL traffic to increase loadDlCBNonGBRAvg
    Run 150Mbps DL traffic on split bearer for UE16 and wait 0 seconds
    Run 150Mbps DL traffic on split bearer for UE17 and wait 0 seconds
    Run 150Mbps DL traffic on split bearer for UE18 and wait 0 seconds

    Sleep  40s  To stabilize high DL traffic
    Log to console  Start UL traffic to increase loadPdcchAvg
    Run 150Mbps UL traffic on split bearer for UE16 and wait 0 seconds
    Run 150Mbps UL traffic on split bearer for UE17 and wait 0 seconds
    Run 150Mbps UL traffic on split bearer for UE18 and wait 0 seconds
    Sleep  20s  To stabilize high UL traffic

    Log to console  Stop DL traffic to decrease loadDlCBNonGBRAvg
    Stop 150Mbps DL traffic on split bearer for UE16
    Stop 150Mbps DL traffic on split bearer for UE17
    Stop 150Mbps DL traffic on split bearer for UE18

    Log to console  Verify that monitoring window for cell1 switch on is ongoing
    Check for cells [1,2] if energySavingState equals [energySaving,notEnergySaving]
    Sleep  80s  Wait until lbpsMonWinForCellSOn will be finished

    # lbpsMonWinForCellSOn should finish now (from starting traffic till now should pass not more than 140s)
    # In each 10s interval pgLoad was above lbpsMaxLoad, no matter if it was loadPdcchAvg or loadDlCBNonGBRAvg
    Wait 20s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup
