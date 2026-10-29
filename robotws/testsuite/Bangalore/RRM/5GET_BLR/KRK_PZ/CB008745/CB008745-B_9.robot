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
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
...           CONFIGS_Krakow/CB008745/CB008745-B.yaml

Suite Setup  Run setup    ute_ca=True
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCF}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB008745/scf_4AZQU_4CELLS_SANSA.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008745/iphy_4AZQU_4CELLS.xml

*** Test Cases ***
CB008745-B_9 Interaction with lbpsSOMethod = TX Switch Off
    [Tags]    B_9
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when CB008745 is active and in Power Saving Group lbpsSOMethod is changed:
    ...   - from 'cell switch off' to 'TX Switch Off', then load quantity calculation and TX switch off/on rule are based on CB008392 default methods,
    ...     monitoring window is defined by lbpsRTXSOffTime/lbpsRTXSOnTime parameters
    ...   - from 'TX Switch Off' to 'cell switch off', then load quantity calculation and TX switch off/on rule are defined by lbpsLoadCalcMethod
    ...     and lbpsSOffTrRule/lbpsSOnTrRule parameters, monitoring window is based on lbpsMonWinForCellSOff/lbpsMonWinForCellSOn parameters
    ...
    ...  == Precondition: ==
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - gNB2 up and running with 4 SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up
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
    ...  - NRPGRP-1.lbpsRTXSOffTime = 240
    ...  - NRPGRP-1.lbpsRTXSOnTime = 120
    ...  - NRPGRP-1.lbpsMonWinForCellSOff = 80
    ...  - NRPGRP-1.lbpsMonWinForCellSOn = 80
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)
    ...  - NRPGRP-1.lbpsSOffTrRule = SlidingAverageMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = SlidingAverageMethod
    ...  - NRPGRP-1.lbpsMaxLoad = 60
    ...  - NRPGRP-1.lbpsMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX switch off
    ...  - NRPGRP-2.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - NRPGRP-2.lbpsRTXSOffTime = 240
    ...  - NRPGRP-2.lbpsRTXSOnTime = 120
    ...  - NRPGRP-2.lbpsMonWinForCellSOff = 80
    ...  - NRPGRP-2.lbpsMonWinForCellSOn = 80
    ...  - NRPGRP-2.lbpsLoadCalcMethod = Max(G, C, P)
    ...  - NRPGRP-2.lbpsSOffTrRule = SlidingAverageMethod
    ...  - NRPGRP-2.lbpsSOnTrRule = SlidingAverageMethod
    ...  - NRPGRP-2.lbpsMaxLoad = 60
    ...  - NRPGRP-2.lbpsMinLoad = 5
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 60
    ...  - NRPGRP-2.lbpsRTXMinLoad = 5
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...
    ...  - NRBTS-1.shutdownWindow = 60 (time for graceful cell shutdown)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...  - NRBTS.actNrLBRTXPowerSaving = False (CB008392)
    ...
    ...  == Postconditions ==
    ...   For NRCELL-1 "Energy saving state" is equal reducedEnergySaving
    ...   For NRCELL-2 "Energy saving state" is equal notEnergySaving
    ...   For NRCELL-3 and NRCELL-4 "Energy saving state" is equal energySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_OP_2416
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

    [Setup]     Prepare test environment B_9

    start collecting syslog  prefix=B_9

    Attach UEs[1,2,3] to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Attach UEs[4,5,6] to gNB2 cell4 with 1 non-GBR and 1 GBR 5QI1 bearer
    Run 100Mbps DL traffic on UEs[1,2,3,4,5,6] non-GBR bearer
    Run 100Mbps DL traffic on UEs[1,2,3,4,5,6] GBR bearer
    Sleep  20s  To stabilize high traffic

    Activate 5GC000431 and CB008392 feature flags
    Verify that in Power Saving load measurement is no differentiation between GBR and nonGBR traffic type for cell2
    Verify that in Power Saving load measurement is no differentiation between GBR and nonGBR traffic type for cell4
    Activate CB008745 feature flag
    Sleep  30s  To collect at least 2 periods with the same traffic level
    Verify that in Power Saving load measurement is differentiation between GBR and nonGBR traffic type for cell2
    Verify that in Power Saving load measurement is no differentiation between GBR and nonGBR traffic type for cell4

    Stop 100Mbps DL traffic on UEs[1,2,3,4,5,6] non-GBR bearer
    Run 140Mbps DL traffic on UEs[1,2,3,4,5,6] GBR bearer
    Sleep  30s  To collect at least 2 periods with changed traffic level

    Modify NRPGRP-1.lbpsSOMethod to 'TX switch off', NRPGRP-2.lbpsSOMethod to 'cell switch off'
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Verify that in Power Saving load measurement is no differentiation between GBR and nonGBR traffic type for cell2
    Verify that in Power Saving load measurement is differentiation between GBR and nonGBR traffic type for cell4

    Sleep  120s  To verify that load from cells is reported correctly and pgLoad is still high enough to not switch TX/cells off
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Stop 140Mbps DL traffic on UEs[1,2,3,4,5,6] GBR bearer
    Log to console  Wait for cell switch off not longer than lbpsMonWinForCellSOff until average load for NRPGRP-2 will be below lbpsMinLoad
    Wait 80s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,switchingOff,notEnergySaving]
    Wait 80s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,energySaving,notEnergySaving]
    # In sliding method next cell can not be switched off earlier than before time equal to lbpsMonWinForCellSOff after switching off previous cell
    Log to console  Wait for 2nd cell switch off until restarted lbpsMonWinForCellSOff will be finished
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,energySaving,switchingOff]
    Wait 80s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,energySaving,energySaving]

    Log to console  Wait until timer lbpsRTXSOffTime for NRPGRP-1 will be finished
    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,energySaving,energySaving]

    [Teardown]   Basic cleanup
