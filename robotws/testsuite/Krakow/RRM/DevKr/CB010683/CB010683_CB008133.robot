*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010683
...         The CB010683 feature introduces additional power saving configuration options and switch off mode by means of
...         its sub-features.
...			The CB010683-A sub-feature introduces Cell-level Extended Power Saving configuration options which allow
...         the Operator to modify at Cell-level the applicable Power Saving Time Windows as well as Switch Off method.
...			The CB010683-B sub-feature introduces a new Mixed Power Saving mode to allow successive MIMO Muting
...			and Cell Switch Off decisions on same cell during same period of time, based on traffic load conditions
...			and configuration options.
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
...         [04.04.2023] - TC Create
...         [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

Resource    ../CB010683/resources/CB010683_common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_MP_AP_LO
    ...    CONFIGS_Krakow/CB010683/CB010683_mMIMO_MP.yaml
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup     Run setup
Suite Teardown  Run Teardown

*** Variables ***
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010683/scf_2AQQA_2AEQE_4CELLS_ASIM_ABIP.xml
${AP_XML}                 ${CURDIR}/../../../../../custom-config/Krakow/CB010683/iphy_2AQQA_2AEQE_4CELLS.xml
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_mMIMO_SANSA.lua
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB010683-A_16 Interaction with CB008133 and CB010471 - cells with extended config TX Switch Off method
    [Tags]    A_16
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that CB010683-A feature can be activated when in Power Group there are only
    ...     massive-MIMO cells. Feature CB008133 (CB010471) must be activated, CB008392 can be not active.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2: mMIMO cells with 32Tx32Rx
    ...  - NRCELL-3, NRCELL-4: mMIMO cells with 64Tx64Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrLBRTXPowerSaving = False (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving = True (CB008133/CB01047)
    ...  - NRBTS.actNrExtCellSOMethod = False (CB010683-A)
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 100, nrCellId = 2, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 3, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 100, nrCellId = 4, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are in reducedEnergySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules, 2xAQQA, 2xAEQE
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19654;CB_FIM_37543;CB_FIM_37542
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
    ...     -  CB010683-4660 USCB010683-A#B1: CB010683-A sub-feature activation
    ...
    ...  == HISTORY ==
    ...     [04.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    Start collecting syslog  prefix=A_16
    Wait 3xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 100Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds  #To stop cell switch off delay timers for both methods

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Enable 5GC000431 and CB010683-A feature flags, start using extended configuration for cell1 and cell3 with 'cell switch off' method
    Log to console  Cell should quit energy saving state immediately
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Stop 100Mbps DL traffic on UE1 PDU1 QFI1
    Detach and kill UE1
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [energySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [energySaving,reducedEnergySaving,energySaving,reducedEnergySaving]

    Change lbpsSOMethod to 'cell switch off', modify lbpsCellSoMethod for cell1, cell3 to 'TX switch off'
    # cell1, cell3 restart
    Log to console  Cell should quit energy saving state immediately
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,energySaving,reducedEnergySaving,energySaving]

    Disable 5GC000431 and CB010683-A feature flags, stop using extended configuration for cell1 and cell3, change lbpsSOMethod to 'TX switch off'
    # all cell's restart
    Log to console  Cell should quit energy saving state immediately
    Wait 3xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3,4] has values [2,2,2,2]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3,4] has values [1,1,1,1]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3,4] has values [>0,>0,>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3,4] has values [>0,>0,>0,>0]

    [Teardown]  Cleanup after A_16

CB010683-B_10 Interaction with CB008133 and CB010471 - cells with Mixed Switch Off method
    [Tags]    B_10
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that CB010683-B feature can be activated when in Power Group there are only
    ...     massive-MIMO cells. Feature CB008133/CB010471 and 5GC000431 must be activated, CB008392 can be not active.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2: mMIMO cells with 32Tx32Rx
    ...  - NRCELL-3, NRCELL-4: mMIMO cells with 64Tx64Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrLBRTXPowerSaving = False (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving = True (CB008133/CB01047)
    ...  - NRBTS.actNrExtCellSOMethod = False (CB010683-A)
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 100, nrCellId = 2, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 3, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 100, nrCellId = 4, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 60
    ...  - lbpsMaxLoad = 10
    ...  - lbpsMinLoad = 1
    ...  - lbpsRTXMaxLoad = 10
    ...  - lbpsRTXMinLoad = 1
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-3 are in notEnergySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules, 2xAQQA, 2xAEQE
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19659;CB_FIM_37543;CB_FIM_37542
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
    ...     -  CB010683-4671 USCB010683-B#B1: CB010683-B sub-feature activation
    ...
    ...  == HISTORY ==
    ...     [04.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    Start collecting syslog  prefix=B_10
    Wait 3xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 100Mbps DL traffic on UE1 PDU1 QFI1 and wait 10 seconds  #To stop cell switch off delay timers for both methods

    Enable 5GC000431 and CB010683-B feature flags and change NRPGRP-1.lbpsSOMethod to 'mixed switch off'
    Log to console  Cell should quit energy saving state immediately
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Stop 100Mbps DL traffic on UE1 PDU1 QFI1
    Detach and kill UE1
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [energySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [energySaving,reducedEnergySaving,energySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Attach UE3 to gNB2 cell4 with ICS during PDU session setup
    Attach UE4 to gNB2 cell4 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds
    Wait 1xCellOn for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    # lbpsRTXSOnTime = rdHighLoadSwitchOnDelay, cells with both methods can switch on together

    Set NRPGRP-1.lbpsPeriodList.lbpsSuspended to suspended for all periods  # to prevent cells from entering energy saving, when UEs will be detached
    Detach and kill UEs from 1 to 4

    # Check if it's possible to attach UEs to previously switched off cells (after transition reducedEnergySaving->energySaving->notEnergySaving)
    Sleep  10  To prepare AP for UE attach
    Check for cells [1,3] if operationalState equals [enabled,enabled]
    Attach UE5 to gNB2 cell1 with ICS during PDU session setup
    Attach UE6 to gNB2 cell3 with ICS during PDU session setup
    Run 20Mbps DL traffic on UE5 PDU1 QFI1 and wait 0 seconds
    Run 20Mbps DL traffic on UE6 PDU1 QFI1 and wait 15 seconds
    Verify 20Mbps DL traffic on UE5 PDU1 QFI1
    Verify 20Mbps DL traffic on UE6 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3,4] has values [1,1,1,1]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3,4] has values [1,0,1,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3,4] has values [>0,>0,>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3,4] has values [>0,0,>0,0]

    [Teardown]  Cleanup after B_10
