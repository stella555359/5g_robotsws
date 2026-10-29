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
...         [04.04.2023] - TC Create
...         [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

Resource    ../CB010683/resources/CB010683_common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    CONFIGS_Krakow/CB010683/CB010683_non-mMIMO.yaml
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup     Run setup
Suite Teardown  Run Teardown

*** Variables ***
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010683/scf_4AZQU_4CELLS.xml
${AP_XML}                 ${CURDIR}/../../../../../custom-config/Krakow/CB010683/iphy_4AZQU_4CELLS.xml
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_non-mMIMO_SANSA.lua
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB010683-A_2 Activation and deactivation of actNrExtCellSOMethod with PSG reconfiguration
    [Tags]    A_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that together with CB010683-A feature activation it is possible to reconfigure
    ...     existing Power Group, add extended configuration for some cells and activate 5GC000431 or CB008392,
    ...     if not yet activated.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...  - NRBTS.actNrExtCellSOMethod = False (CB010683-A)
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 95
    ...  - NRPGRP-1.lbpsMaxLoad = 95
    ...  - NRPGRP-1.lbpsRTXMinLoad = 1
    ...  - NRPGRP-1.lbpsMinLoad = 1
    ...  - NRPGRP-1.lbpsLastCellMinLoad=0
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad=0
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in reducedEnergySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19654;5G_RAN_USR_COM_19656;5G_RAN_USR_COM_18843;5G_CP_ARC_ALG_10419
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
    ...     -  CB010683-4661 USCB010683-A#B2: CB010683-A sub-feature deactivation
    ...
    ...  == HISTORY ==
    ...     [04.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    [Setup]  Prepare test environment A_2

    start_collecting_syslog  prefix=A_2

    Wait 2xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]
    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 100Mbps DL traffic on UE1 PDU1 QFI1 and wait 10 seconds  #To stop cell switch off delay timers for both methods

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Check for cells [1,2] if energySavingState equals [reducedEnergySaving,reducedEnergySaving]
    Enable 5GC000431 and CB010683-A feature flags, add extended configuration for cell1 with 'cell switch off' lbpsCellSOMethod
    Log to console  Cells should quit energy saving state immediately
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Stop 100Mbps DL traffic on UE1 PDU1 QFI1
    Wait 1xTXOff for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2] energySavingState change to [energySaving,reducedEnergySaving]

    Set Power Group level period outside current time
    Wait time equal to 1xTXOff
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Set Power Group level period inside current time
    Wait 1xTXOff for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2] energySavingState change to [energySaving,reducedEnergySaving]

    Disable 5GC000431 and CB010683-A feature flags, stop using extended configuration for cell1
    Wait 2xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2] has values [1,3]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2] has values [2,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2] has values [>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2] has values [>0,0]

    [Teardown]  Basic cleanup

CB010683-B_2 Activation and deactivation of actNrMixedSOMethod with PSG reconfiguration
    [Tags]    B_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that together with CB010683-B feature activation it is possible to configure
    ...     lbpsSOMethod to 'mixed switch off' and activate 5GC000431 or CB008392, if not yet activated.
    ...
    ...     Test verifies, that after feature activation cells are saving energy in two steps, first TX paths are
    ...     switched off, then full cell is switched off. Conditions for TX paths switch off are met earlier than for cell
    ...     switch off.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = False (5GC000431)
    ...  - NRBTS.actNrExtCellSOMethod = False (CB010683-A)
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 95
    ...  - NRPGRP-1.lbpsMaxLoad = 95
    ...  - NRPGRP-1.lbpsRTXMinLoad = 1
    ...  - NRPGRP-1.lbpsMinLoad = 1
    ...  - NRPGRP-1.lbpsLastCellMinLoad=0
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad=0
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in reducedEnergySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19659;5G_RAN_USR_COM_19660;5G_RAN_USR_COM_19653;5G_CP_ARC_ALG_10419
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4671 USCB010683-B#B1: CB010683-B sub-feature activation
    ...     -  CB010683-4672 USCB010683-B#B2: CB010683-B sub-feature deactivation
    ...     -  CB010683-4916 USCB010683-B#B3: Configure Mixed Mode Power Saving Controls
    ...
    ...  == HISTORY ==
    ...     [05.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    [Setup]  Prepare test environment B_2
    start_collecting_syslog  prefix=B_2

    Wait 2xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]
    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Log to console  Start traffic to trigger pgLoad above lbpsRTXMinLoad/lbpsMinLoad and below lbpsRTXMaxLoad/lbpsMaxLoad
    Run 100Mbps DL traffic on UE1 PDU1 QFI1 and wait 10 seconds  #To stop cell switch off delay timers for both methods
    Wait time equal to 1xTXOn  #To verify, that traffic is not high enough to switch on cells
    Check for cells [1,2] if energySavingState equals [reducedEnergySaving,reducedEnergySaving]

    Enable 5GC000431 and CB010683-B feature flags and change NRPGRP-1.lbpsSOMethod to 'mixed switch off'
    Log to console  Cells should quit energy saving state immediately
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Stop 100Mbps DL traffic on UE1 PDU1 QFI1
    Detach and kill UE1
    Wait 1xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2] energySavingState change to [energySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2] energySavingState change to [energySaving,energySaving]

    Disable 5GC000431 and CB010683-B feature flags and change lbpsSOMethod for NRPGRP-1 to 'TX switch off'
    Log to console  Cells should quit energy saving state immediately
    Wait 2xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    # Check if it's possible to attach UEs to previously switched off cells (after transition reducedEnergySaving->energySaving->notEnergySaving)
    Check for cells [1,2] if operationalState equals [enabled,enabled]
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Run 20Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 20Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 15 seconds
    Verify 20Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 20Mbps UL and DL traffic on UE2 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2] has values [3,3]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2] has values [1,1]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2] has values [>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2] has values [>0,>0]

    [Teardown]  Basic cleanup

CB010683-A_6_B_6 Modification of cell extended config
    [Tags]    A_6
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies online modification of lbpsCellSOMethod for cells which are using extended configuration.
    ...     After that all cells in power group are switched to notEnergySaving state and new lbpsCellSOMethod are applied
    ...     for next energy saving actions.
    ...     This test case verifies, that Power Group with lbpsSOMethod = 'mixed switch off' can have cells which
    ...     are using extended configuration.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...  - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...  - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...  - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...
    ...  - NRPGRP-1.lbpsSOMethod = mixed switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...     - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True,
    ...     - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsCellPeriodList =
    ...     - nrCellId = 1, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h,
    ...     - nrCellId = 2, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-3 are in reducedEnergySaving state
    ...   - NRCELL-2 is in energySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18847;5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10439;
    ...                           5G_CP_ARC_ALG_10440;5G_CP_OTH_14266;5G_RAN_USR_COM_18851;5G_RAN_USR_COM_18852;
    ...                           5G_CP_ARC_ALG_10676;5G_CP_ARC_ALG_10681
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
    ...     -  CB010683-4663 USCB010683-A#B4: Handle Cell-level Extended Power Saving Configuration Change
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode
    ...     -  CB010683-4675 USCB010683-B#B5: Manage Mixed Switch Off Mode Interaction with MIMO Muting and Cell Switch
    ...                                       Off Power Saving Modes
    ...     -  CB010683-4676 USCB010683-B#B6: Determine Mixed Power Saving Mode
    ...
    ...  == HISTORY ==
    ...     [05.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)
    ...     [30.08.2023] - Changes due to PR725621
    ...     [26.10.2023] - Changes due to PR732662

    [Setup]  Prepare test environment A_6_B_6

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test
    start_collecting_syslog  prefix=A_6_B_6

    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving]

    Modify lbpsCellSoMethod for cell1 to 'mixed switch off', cell2 to 'cell switch off'
    Log to console  Cells should quit energy saving state immediately
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,energySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,energySaving,energySaving]

    # delay timers for both methods are reset and not incremented, as no more cell can go to further energy saving
    Remove extended configuration for cell1, cell2
    Log to console  Cells should quit energy saving state immediately
    Check for cells [1,2,3] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [notEnergySaving,notEnergySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3] has values [2,1,3]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3] has values [1,1,3]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3] has values [>0,>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3] has values [>0,>0,>0]

    # counters are checked earlier, because this part can be not deterministic
    Check for cells [1,2,3] if energySavingState equals [notEnergySaving,notEnergySaving,energySaving]
    Stop using extended configuration for cell1, cell2
    Log to console  delay timer for both switching off methods is already crossed, cell switch off method is choosen for cell1
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,notEnergySaving,notEnergySaving]
    Wait 3x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,energySaving,energySaving]

    [Teardown]  Basic cleanup

CB010683-A_13_B_8 Emergency Call on cell with extended config
    [Tags]    A_13
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when Emergency Call is ongoing on cell from Power Group, then this cell
    ...     and all other with higher lbpsCellSoOrder are not allowed for energy saving actions.
    ...     When Emergency Call is ongoing on cell which is not allowed for energy saving actions in current time
    ...     (not configured time period at cell level), then cells with higher lbpsCellSoOrder are allowed for energy
    ...     saving actions.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  Delta configurations plan#1 prepared to apply during the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...     - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True,
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = TX switch off, period starts 1 day from now, duration = 24h,
    ...        - nrCellId = 3, lbpsCellSOMethod = mixed switch off, period starts now, duration = 24h,
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 30
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1 is in notEnergySaving state, Emergency Call in ongoing
    ...   - NRCELL-2 is in reducedEnergySaving state
    ...   - NRCELL-3 is in energySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10676;5G_CP_ARC_ALG_10681;5G_RAN_USR_COM_18852
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode
    ...     -  CB010683-4676 USCB010683-B#B6: Determine Mixed Power Saving Mode
    ...
    ...  == HISTORY ==
    ...     [04.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    [Setup]  Prepare test environment A_13_B_8

    start_collecting_syslog  prefix=A_13_B_8
    Start UE1 emergency call in NRCELL-1
    Start UE2 emergency call in NRCELL-2

    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait time equal to 1xTXOff
    Check for cells [1,2,3] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving]

    Stop UE2 emergency call in NRCELL-2
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving]

    Start UE3 emergency call in NRCELL-3
    Wait time equal to 1x(CellOff+SW)
    Check for cells [1,2,3] if energySavingState equals [notEnergySaving,reducedEnergySaving,notEnergySaving]

    Log to console  delay timer for both switching off methods is already crossed, cell switch off method is choosen for cell3
    Stop UE3 emergency call in NRCELL-3
    Wait 1xSW for cells [1,2,3] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving]

    [Teardown]  Basic cleanup

CB010683-A_14_B_7 One cell from PSG failed - only cell switch off is allowed
    [Tags]    A_14
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when one cell from Power Group is failed due to cell level alarm, then all
    ...     cells are switched on immediately. Only cells with 'cell switch off' or 'mixed switch off' method are allowed
    ...     for energy saving actions - switching off cell. Switching off TX paths is not allowed. Tested cells are
    ...     using extended configuration, where periods with both 'cell switch off' and 'TX switch off' method are configured.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
    ...  - NR cells are up
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRBTS.actNrMixedSOMethod = False (CB010683-B)
    ...  - no UE traffic on gNB
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...     - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = mixed switch off, period starts now, duration = 24h,
    ...        - nrCellId = 2, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h,
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 60
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1 is in energySaving state
    ...   - NRCELL-2 and NRCELL-3 are in reducedEnergySaving state
    ...   - No fault on cells is present
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_RAN_OP_2750;5G_RAN_OP_2751;
    ...                           5G_RAN_USR_COM_19661;5G_RAN_USR_COM_18851;5G_RAN_USR_COM_18852
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode
    ...     -  CB010683-4918 USCB010683-B#B4: Handle Mixed Mode Power Saving Configuration Change
    ...     -  CB010683-4675 USCB010683-B#B5: Manage Mixed Switch Off Mode Interaction with MIMO Muting and Cell Switch
    ...                                       Off Power Saving Modes
    ...     -  CB010683-4676 USCB010683-B#B6: Determine Mixed Power Saving Mode
    ...
    ...  == HISTORY ==
    ...     [05.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    [Setup]  Prepare test environment A_14_B_7

    start_collecting_syslog  prefix=A_14_B_7
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [energySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [energySaving,reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRCELL-3.gscnOrSsPbchArfcn  11  bts_id=1
    Log to console  Cells should quit energy saving state immediately
    Check for cells [1,2,3] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,notEnergySaving,notEnergySaving]

    Wait time equal to 1xTXOff
    Check for cells [1,2,3] if energySavingState equals [energySaving,notEnergySaving,notEnergySaving]
    Block NRCELL-3  # needed to clear alarm on NRCELL-3
    Change eNB parameter value  NRCELL-3.gscnOrSsPbchArfcn  8019  bts_id=1
    Unblock NRCELL-3
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [energySaving,reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [energySaving,reducedEnergySaving,reducedEnergySaving]

    [Teardown]  Basic cleanup

*** Keywords ***
