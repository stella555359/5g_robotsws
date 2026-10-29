*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010683
...         The CB010683 feature introduces additional power saving configuration options and switch off mode by means of
...         its sub-features.
...         The CB010683-A sub-feature introduces Cell-level Extended Power Saving configuration options which allow
...         the Operator to modify at Cell-level the applicable Power Saving Time Windows as well as Switch Off method.
...         The CB010683-B sub-feature introduces a new Mixed Power Saving mode to allow successive MIMO Muting
...         and Cell Switch Off decisions on same cell during same period of time, based on traffic load conditions
...         and configuration options.
...
...         This feature can be enabled/disabled by new O&M parameter.
...
...      == TEST SET NAME ==
...         CB010683 MIMO Muting and Cell Switch OFF during same period for 5G
...
...      == TESTING SPLIT ==
...         CB010683-A Cell-level Extended Configurations for MIMO Muting and Cell Switch Off
...         CB010683-B Mixed Mode Load Based Power Saving
...
...      == CONTACTS ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB010683 CFAM
...
...      == HISTORY ==
...         [17.07.2023] - TC Create
...         [xx.xx.2023] - Review closed

Resource    ../CB010683/resources/CB010683_common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    CONFIGS_Krakow/CB010683/CB010683_non-mMIMO_mMIMO.yaml
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup     Run Setup
Suite Teardown  Run Teardown

*** Variables ***
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010683/scfc_1AQQA_1AEQQ_2AZQU_4CELLS.xml
${AP_XML}                 ${CURDIR}/../../../../../custom-config/Krakow/CB010683/iphy_1AQQA_1AEQQ_2AZQU_4CELLS.xml
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_non-mMIMO_mMIMO_SANSA.lua
${WAIT_TIME}=             ${20}

*** Test Cases ***
CB010683-Robustness Lock and block of NRCELL with mixed switch off method during switchingOff state
    [Tags]    Robustness
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies that:
    ...     - cell with 'mixed switch off' method is not out of service after block-unblock, lock-unlock and automatic
    ...     lock-unlock when cell is in switchingOff energySavingstate, and it's previous state was reducedEnergySaving;
    ...     - other cells from Power Saving Group in reducedEnergySaving and switchingOff state are not impacted.
    ...
    ...     Test verifies both mMIMO and non-mMIMO cells.
    ...     Additional robustness factor is maximum number of cell periods in one Power Group
    ...     (2400 structures in NRPGRP-1.lbpsCellPeriodList).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2  mMIMO cells with 32Tx32Rx
    ...  - NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving = True (CB008133/CB010471)
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...  - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...  - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...  - NRBTS.actCoordinated4g5gPowerSaving = cellDeactivation
    ...  - no UE traffic on gNB
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = mixed switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 100, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 1, nrCellId = 2, lbpsUseExtConfig = True,
    ...     - lbpsCellSOOrder = 100, nrCellId = 3, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 4, lbpsUseExtConfig = True
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - 7 periods, which cover 24h/7days
    ...  - NRPGRP-1.lbpsCellPeriodList =
    ...     - nrCellId = 2, lbpsCellSOMethod = TX switch off, 2400 not overlapping periods, which cover 24h/7days
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRBTS-1.shutdownWindow = 42
    ...
    ...  == Postconditions ==
    ...   - All cells in Power Group are enabled, in notEnergySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AQQA, AEQQ, AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: OAM_REQ_RAT_1069
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  No scenario
    ...
    ...  == HISTORY ==
    ...     [17.07.2023] - TC Create
    ...     [xx.xx.2023] - Review closed

    Attach UE11 to gNB2 cell4 with ICS during PDU session setup

    Block mMIMO cell during switchingOff energySavingState
    Block non-mMIMO cell during switchingOff energySavingState

    Lock mMIMO cell during switchingOff energySavingState
    Lock non-mMIMO cell during switchingOff energySavingState

    Automatic lock mMIMO cell during switchingOff energySavingState
    Automatic lock non-mMIMO cell during switchingOff energySavingState

    [Teardown]  Robustness cleanup

*** Keywords ***
Robustness cleanup
    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to suspended for all periods
    Wait ${WAIT_TIME}s for cells [1,2,3] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving]
    Wait ${WAIT_TIME}s for cells [1,2,3] operationalState change to [enabled,enabled,enabled]
    Detach and kill UEs from 1 to 20
    Configure  [{'MOC':'NRCELL', 'pMax':'26'}]

Block mMIMO cell during switchingOff energySaving state
    start collecting syslog  prefix=Block_mMIMO
    Block cell1 - flow with checking cells order [1,2,3]
    stop collecting syslog

Block non-mMIMO cell during switchingOff energySaving state
    start collecting syslog  prefix=Block_non-mMIMO
    Block cell3 - flow with checking cells order [3,2,1]
    stop collecting syslog

Block cell${cell_id:\d+} - flow with checking cells order [${order}]
    Log to console  Block of cell${cell_id} in switchingOff state
    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to notSuspended for all periods
    Wait 1x(CellOff+SW) for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [${order}] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 1xCellOff for cells [${order}] energySavingState change to [switchingOff,reducedEnergySaving,switchingOff]
    coam.block cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=100  connection=${ADMIN_CONNECTION}
    Wait 1xSW for cells [${order}] blockingState change to [Blocked,Unblocked,Unblocked]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [disabled,enabled,disabled]
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving]

    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 60Mbps DL traffic on UE11 PDU1 QFI1 and wait 20 seconds
    coam.unblock cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=100  connection=${ADMIN_CONNECTION}
    Wait ${WAIT_TIME}s for cells [${order}] blockingState change to [Unblocked,Unblocked,Unblocked]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [enabled,enabled,disabled]
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving]

    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to suspended for all periods
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [enabled,enabled,enabled]
    Stop 60Mbps DL traffic on UE11 PDU1 QFI1
    Verify that it is possible to attach UEs with traffic to cell1 and cell3

Lock mMIMO cell during switchingOff energySaving state
    start collecting syslog  prefix=Lock_mMIMO
    Lock cell1 - flow with checking cells order [1,2,3]
    stop collecting syslog

Lock non-mMIMO cell during switchingOff energySaving state
    start collecting syslog  prefix=Lock_non-mMIMO
    Lock cell3 - flow with checking cells order [3,2,1]
    stop collecting syslog

Lock cell${cell_id:\d+} - flow with checking cells order [${order}]
    Log to console  Lock of cell${cell_id} in switchingOff state
    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to notSuspended for all periods
    Wait 1x(CellOff+SW) for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [${order}] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 1xCellOff for cells [${order}] energySavingState change to [switchingOff,reducedEnergySaving,switchingOff]
    coam.lock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=100  connection=${ADMIN_CONNECTION}
    Wait 1xSW for cells [${order}] administrativeState change to [Locked,Unlocked,Unlocked]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [disabled,enabled,disabled]
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving]

    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 60Mbps DL traffic on UE11 PDU1 QFI1 and wait 20 seconds
    coam.unlock  dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=100  connection=${ADMIN_CONNECTION}
    Wait ${WAIT_TIME}s for cells [${order}] administrativeState change to [Unlocked,Unlocked,Unlocked]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [enabled,enabled,disabled]
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving]

    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to suspended for all periods
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [enabled,enabled,enabled]
    Stop 60Mbps DL traffic on UE11 PDU1 QFI1
    Verify that it is possible to attach UEs with traffic to cell1 and cell3

Automatic lock mMIMO cell during switchingOff energySaving state
    start collecting syslog  prefix=Automatic_lock_mMIMO
    Automatic lock cell1 - flow with checking cells order [1,2,3]
    stop collecting syslog

Automatic lock non-mMIMO cell during switchingOff energySaving state
    start collecting syslog  prefix=Automatic_lock_non-mMIMO
    Automatic lock cell3 - flow with checking cells order [3,2,1]
    stop collecting syslog

Automatic lock cell${cell_id:\d+} - flow with checking cells order [${order}]
    Log to console  Automatic lock of cell${cell_id} in switchingOff state
    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to notSuspended for all periods
    Wait 1x(CellOff+SW) for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [${order}] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 1xCellOff for cells [${order}] energySavingState change to [switchingOff,reducedEnergySaving,switchingOff]

    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 60Mbps DL traffic on UE11 PDU1 QFI1 and wait 20 seconds
    Change eNB parameter value  NRCELL-${cell_id}.pMax  25  bts_id=1
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [enabled,enabled,disabled]

    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to suspended for all periods
    Wait ${WAIT_TIME}s for cells [${order}] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving]
    Wait ${WAIT_TIME}s for cells [${order}] operationalState change to [enabled,enabled,enabled]
    Stop 60Mbps DL traffic on UE11 PDU1 QFI1
    Verify that it is possible to attach UEs with traffic to cell1 and cell3

Verify that it is possible to attach UEs with traffic to cell1 and cell3
    Sleep  10  To prepare AP for UE attach
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE12 to gNB2 cell3 with ICS during PDU session setup
    Run 20Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 20Mbps UL and DL traffic on UE12 PDU1 QFI1 and wait 15 seconds
    Verify 20Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 20Mbps UL and DL traffic on UE12 PDU1 QFI1
    Detach and kill UE1
    Detach and kill UE12
