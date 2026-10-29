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
...      == Info==
...         Test suite with manual test cases for CB010683-A.
...         Common preconditions for all TCs:
...             - gNB2 classical - real hardware - ASIL + ABIO
...	            - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4: non-mMIMO cells with 4Tx4Rx
...             - NR cells are up
...             - AMF1 simulated
...             - Airphone simulator configured for SA mode
...             - gNB2 up and running with four SA cells
...             - no UE traffic on gNB
...             - NRBTS.actNrLBRTXPowerSaving = False (CB008392)
...             - NRBTS.actNrLBPowerSaving = False (5GC000431)
...             - NRBTS.actNrExtCellSOMethod = False (CB010683-A)
...             - NRBTS.actNrMixedSOMethod = False (CB010683-B)
...             - NRBTS.actLbpsCtrlLogicEnh = False (CB008745)
...             - No NRPGRP is configured on gNB
...             - rdLowLoadSwitchOffDelay = 60s (changed default value)
...             - rdHighLoadSwitchOnDelay = 60s (changed default value)
...
...      == TESTING TOOLS ==
...         AirPhone, 5GCSim, UTE
...
...      == TEST ENVIRONMENT ==
...         - gNB classicBTS in SA mode
...         - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
...
...      == CONTACTS ==
...         - Paulina Jedras <paulina.jedras@nokia.com>
...         - Malgorzata Konior <malgorzata.konior@nokia.com>

Resource    ../CB010683/resources/CB010683_common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
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
CB010683-A_1 Activation and deactivation of actNrExtCellSOMethod without PSG reconfiguration
    [Tags]    A_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when CB010683-A feature flag is active, then Power Groups with no
    ...     extended configuration for any cell behaves as legacy 5GC000431 or CB008392 feature.
    ...     Test verifies, that after CB010683-A feature activation and deactivation all cells in energy saving state
    ...     are switched to notEnergySaving state, even if no extended configuration for cell is used.
    ...
    ...  == Precondition: ==
    ...    Common preconditions with exceptions:
    ...  - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = cell switch off
    ...  - NRPGRP-2.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 3, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 4, lbpsUseExtConfig = False
    ...  - NRPGRP-2.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in reducedEnergySaving state
    ...   - NRCELL-3, NRCELL-4 are in energySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19654;5G_RAN_USR_COM_19656;5G_CP_ARC_ALG_10419
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4660 USCB010683-A#B1: CB010683-A sub-feature activation
    ...     -  CB010683-4661 USCB010683-A#B2: CB010683-A sub-feature deactivation

    [Setup]  Prepare test environment A_1

    start collecting syslog  prefix=A_1

    Wait 2x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]
    Activate CB010683-A feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 2x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]
    Deactivate CB010683-A feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 2x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]

    [Teardown]  Basic cleanup

CB010683-A_3 Cells with extended config with no period or period not matching current time - PSG level period matching
    [Tags]    A_3
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that cells which are using extended configuration are not considered for energy
    ...     saving actions, if time period from extended configuration is not configured with current time or no
    ...     period is configured.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 4, nrCellId = 4, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 2, lbpsCellSOMethod = TX switch off, period starts in 7min from now, duration = 24h
    ...        - nrCellId = 3, lbpsCellSOMethod = TX switch off, period starts in 5min from now, duration = 5min
    ...        - nrCellId = 3, lbpsCellSOMethod = cell switch off, period starts 1h from now, duration = 5 min
    ...                                           (period added just to fulfil PDL rules)
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
    ...  == Postconditions ==
    ...   - All cells are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10678;5G_CP_ARC_ALG_10747
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_collecting_syslog  prefix=A_3
    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Log to console  Wait until period for cell3 will be started
    Wait 300s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Log to console  Wait until period for cell2 will be started
    Wait 120s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Log to console  Wait until period for cell3 will be finished
    Wait 180s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Attach UE3 to gNB2 cell2 with ICS during PDU session setup
    Attach UE4 to gNB2 cell2 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic

    Wait 1xTXOn for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3,4] has values [0,1,1,1]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3,4] has values [0,0,0,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3,4] has values [0,>0,>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3,4] has values [0,0,0,0]

    [Teardown]  Basic cleanup

CB010683-A_4 Cells with extended config period matching current time - PSG level period not matching or is suspended
    [Tags]    A_4
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that cells which are using extended configuration are not considered for energy
    ...     saving actions, if time period from extended configuration is configured with current time, but time
    ...     period from Power Group level is not configured with current time or is suspended.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = cell switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 4, nrCellId = 4, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...        - nrCellId = 2, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...        - nrCellId = 3, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - 1st period starts now, not suspended, duration = 5min
    ...        - 2nd period starts 3min after 1st period, suspended, duration = 2min
    ...        - 3rd period starts immediately after 2nd period, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsRTXSOffTime = 30
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2, NRCELL-3 are in reducedEnergySaving state
    ...   - NRCELL-4 is in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18849
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start collecting syslog  prefix=A_4
    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 3xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    Log to console  Wait until Power Group 1st period will be finished
    Wait 200s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Sleep  5 minutes  Wait until Power Group 3rd period will be started
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 3xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3,4] has values [2,2,2,0]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3,4] has values [0,0,0,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3,4] has values [>0,>0,>0,0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3,4] has values [0,0,0,0]

    [Teardown]  Basic cleanup

CB010683-A_5 Cells with extended config with different methods in consecutive periods
    [Tags]    A_5
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when cells are using extended configuration and there is no gap between
    ...     consecutive periods and switch off method is the same, then cells are kept in energy saving state.
    ...     Test verifies, that when switch off method is different in consecutive periods, then cells are set to
    ...     notEnergySaving state due to mandatory gap, and after that can be considered for energy saving
    ...     actions according to new switch off method.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = TX switch off, period starts now, duration = 3min
    ...        - nrCellId = 1, lbpsCellSOMethod = TX switch off, period starts just after 1st period, duration = 3min
    ...        - nrCellId = 1, lbpsCellSOMethod = cell switch off, period starts 5min after 2nd period, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1 is in energySaving state
    ...   - NRCELL-2 is in reducedEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_5

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start collecting syslog  prefix=A_5
    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 2xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]
    Sleep  3 minutes
    Log to console  Verify that cells do not quit energy saving state when 2nd cell period starts
    Check for cells [1,2] if energySavingState equals [reducedEnergySaving,reducedEnergySaving]
    Wait 180s for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]
    Sleep  4 minutes  To verify that in 2nd cell period cell does not go to enery saving state
    Check for cells [1,2] if energySavingState equals [notEnergySaving,reducedEnergySaving]
    Sleep  1 minutes  To wait until 3rd period for cell will be started
    Wait 1x(CellOff+SW) for cells [1,2] energySavingState change to [energySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2] has values [1,1]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2] has values [1,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2] has values [>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2] has values [>0,0]

    [Teardown]  Basic cleanup

CB010683-A_7 Stop or start using extended configurations for some cells in PSG
    [Tags]    A_7
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies online modification of lbpsUseExtConfig for some cells from Power Group to stop
    ...     or start using extended configuration. After that all cells in Power Group are switched to notEnergySaving
    ...     state and next energy saving actions are performed according to Power Group level or cell level extended
    ...     configuration.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 4, nrCellId = 4, lbpsUseExtConfig = True
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 3, lbpsCellSOMethod = cell switch off, period starts now, duration = 24h
    ...        - nrCellId = 4, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...        - nrCellId = 4, lbpsCellSOMethod = cell switch off, period starts in 2 days from now, duration = 24h,
    ...                                           (period added just to fulfil PDL rules)
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
    ...  == Postconditions ==
    ...   - NRCELL-2, NRCELL-4 are in reducedEnergySaving state
    ...   - NRCELL-1 is in notEnergySaving state
    ...   - NRCELL-3 is on energySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18847;5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10419
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4663 USCB010683-A#B4: Handle Cell-level Extended Power Saving Configuration Change
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_7

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start collecting syslog  prefix=A_7
    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 2xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Create new plan
    Edit Planned Object Attributes   NRPGRP-1  lbpsCellList.lbpsUseExtConfig[1]=False
    Edit Planned Object Attributes   NRPGRP-1  lbpsCellList.lbpsUseExtConfig[2]=True
    Apply planned changes

    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,energySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3,4] has values [0,1,1,2]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3,4] has values [0,0,1,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3,4] has values [0,>0,>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3,4] has values [0,0,>1,0]

    [Teardown]  Basic cleanup

CB010683-A_8 Switch on cells and TX due to traffic - timers for pgLoad monitoring equal for both methods
    [Tags]    A_8
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when timers for pgLoad monitoring are equal for both cell switch off and TX
    ...     switch off method, then at least two cells with different switch off methods can restore capacity at the
    ...     same time. It may happen, when pgLoadEstimated is above lbpsRTXMaxLoad or lbpsMaxLoad after selecting first
    ...     cell to restore capacity.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 4, nrCellId = 4, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 3, lbpsCellSOMethod = cell switch off, period starts now, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 60 (rdLowLoadSwitchOffDelay)
    ...     - NRPGRP-1.lbpsRTXSOnTime = 60 (rdHighLoadSwitchOnDelay)
    ...     - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...     - NRPGRP-1.lbpsMaxLoad = 7
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in reducedEnergySaving or in notEnergySaving state
    ...   - NRCELL-3 and NRCELL-4 are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10676;5G_CP_ARC_ALG_10747;
    ...                           5G_CP_ARC_ALG_10678;5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_8

    start collecting syslog  prefix=A_8
    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell4 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic

    Wait 1xCellOn for cells [3,4] energySavingState change to [notEnergySaving,notEnergySaving]
    Run keyword and ignore error
    ...  Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup

CB010683-A_9 Switch on cells and TX due to traffic - timers for pgLoad monitoring different for both methods
    [Tags]    A_9
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when timer for pgLoad monitoring is different for cell switch off and TX
    ...     switch off method, then cells with different switch off methods can NOT restore capacity at the same
    ...     time, even if pgLoadEstimated is still above lbpsRTXMaxLoad or lbpsMaxLoad after selecting first cell to
    ...     restore capacity.
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
    ...
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True,
    ...     - lbpsCellSOOrder = 4, nrCellId = 4, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsCellPeriodList =
    ...     - nrCellId = 3, lbpsCellSOMethod = cell switch off, period starts now, duration = 24h
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsMaxLoad = 10
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in reducedEnergySaving or in notEnergySaving state
    ...   - NRCELL-3 and NRCELL-4 are in notEnergySaving state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10747;5G_CP_ARC_ALG_10676
    ...                           5G_CP_ARC_ALG_10678;5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10518
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
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode
    ...
    ...  == HISTORY ==
    ...     [05.04.2023] - TC Create
    ...     [27.04.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=882237)

    [Setup]  Prepare test environment A_9

    start_collecting_syslog  prefix=A_9
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Attach UE3 to gNB2 cell2 with ICS during PDU session setup
    Attach UE4 to gNB2 cell2 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 10 seconds

    Wait 1xTXOn for cells [2,3,4] energySavingState change to [notEnergySaving,energySaving,notEnergySaving]
    # If traffic is high enough, next cells will restore capacity
    Run keyword and ignore error
    ...    Check for cells [1] if energySavingState equals [notEnergySaving]
    Wait 1xCellOn for cells [2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup

CB010683-A_10 Energy saving actions for next cells when conditions for first cell in order are not fulfilled
    [Tags]    A_10
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that further cells are considered for energy saving actions when pgLoad
    ...     conditions for first cell in order are not fulfilled and conditions for next cell, with different
    ...     switch off method are fulfilled.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = cell switch off, period starts now, duration = 24h
    ...        - nrCellId = 3, lbpsCellSOMethod = cell switch off, period starts now, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOnTime = 80
    ...     - NRPGRP-1.lbpsRTXSOffTime = 80
    ...     - NRPGRP-1.lbpsRTXMaxLoad = 30
    ...     - NRPGRP-1.lbpsMaxLoad = 90
    ...     - NRPGRP-1.lbpsRTXMinLoad = 20
    ...     - NRPGRP-1.lbpsMinLoad = 2
    ...     - NRPGRP-1.lbpsLastCellMinLoad = 20
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 and NRCELL-3 are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10676;5G_CP_ARC_ALG_10678;
    ...                           5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_10

    start collecting syslog  prefix=A_10
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic
    Wait 1xTXOff for cells [1,2,3] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving]

    Configure  [{'MOC': 'NRPGRP', 'ID': '1', 'lbpsMinLoad': '20'}]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,reducedEnergySaving,notEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,reducedEnergySaving,energySaving]

    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Attach UE3 to gNB2 cell2 with ICS during PDU session setup
    Attach UE4 to gNB2 cell2 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic

    Wait 1xTXOn for cells [1,2,3] energySavingState change to [energySaving,notEnergySaving,energySaving]

    Configure  [{'MOC': 'NRPGRP', 'ID': '1', 'lbpsMaxLoad': '25'}]
    Wait 1xCellOn for cells [2,3] energySavingState change to [notEnergySaving,notEnergySaving]
    # If traffic is high enough, next cell will restore capacity too
    Run keyword and ignore error
    ...  Check for cells [1] if energySavingState equals [notEnergySaving]

    [Teardown]  Basic cleanup

CB010683-A_11 Last cell switch off - cells with lbpsCellSoOrder equal 100
    [Tags]    A_11
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that cells with lbpsCellSoOrder = 100 using extended configuration are not
    ...     eligible for energy saving actions when last cell(s) in Power Group are not allowed for cell/TX switch off,
    ...     even if all other cells with lower lbpsCellSoOrder are still in notEnergySaving state and are not allowed
    ...     for energy saving actions in current time.
    ...
    ...     When last cell(s) in Power Group are allowed for energy saving actions (lbpsLastCellSOEnabled is
    ...     changed to True), then multiple cells with lbpsCellSoOrder = 100 are switched off/on together.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = cell switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1,   nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2,   nrCellId = 2, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 100, nrCellId = 3, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 100, nrCellId = 4, lbpsUseExtConfig = True
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = cell switch off, period starts in 1 day from now, duration = 24h,
    ...                                           (period added just to fulfil PDL rules)
    ...        - nrCellId = 2, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h,
    ...        - nrCellId = 3, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...        - nrCellId = 4, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1 is in notEnergySaving state
    ...   - NRCELL-2 is in reducedEnergySaving or in notEnergySaving state
    ...   - NRCELL-3 and NRCELL-4 are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10747;5G_CP_ARC_ALG_10676
    ...                           5G_CP_ARC_ALG_10678;5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_11

    start_collecting_syslog  prefix=A_11
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait time equal to 2xTXOff
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Configure  [{'MOC': 'NRPGRP', 'ID': '1', 'lbpsLastCellSOEnabled': 'True'}]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Attach UE3 to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic

    Wait 1xTXOn for cells [3,4] energySavingState change to [notEnergySaving,notEnergySaving]
    Run keyword and ignore error
    ...  Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup

CB010683-A_12 Last cell switch off - cells with lbpsCellSoOrder not equal 100
    [Tags]    A_12
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that cell with highest lbpsCellSoOrder (!= 100) using extended configuration is
    ...     switched on, when last cell which is not in energy saving state becomes disabled and last cell in Power
    ...     Group is not allowed for energy saving actions (lbpsLastCellSOEnabled set to False).
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = cell switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 3, nrCellId = 3, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 4, nrCellId = 4, lbpsUseExtConfig = True
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = cell switch off, period starts in 1 day from now, duration = 24h,
    ...                                           (period added just to fulfil PDL rules)
    ...        - nrCellId = 2, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h,
    ...        - nrCellId = 3, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...        - nrCellId = 4, lbpsCellSOMethod = TX switch off, period starts now, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...     - NRPGRP-1.lbpsRTXSOffTime = 30
    ...
    ...  == Postconditions ==
    ...   - NRCELL-2, NRCELL-3 are in reducedEnergySaving state
    ...   - NRCELL-1, NRCELL-4 are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18848;5G_RAN_USR_COM_18849;5G_CP_ARC_ALG_10678;5G_CP_ARC_ALG_10676
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4664 USCB010683-A#B5: Manage Cell level Extended Configuration Interaction with MIMO Muting
    ...                                       and Cell Switch Off Power Saving Modes
    ...     -  CB010683-4665 USCB010683-A#B6: Determine Cell-level Extended Power Saving Mode

    [Setup]  Prepare test environment A_12

    start collecting syslog  prefix=A_12
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Wait 3xTXOff for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Block NRCELL-1
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]

    [Teardown]   Run keywords
    ...        Basic cleanup     AND
    ...        Unblock NRCELL-1

CB010683-A_15 Interaction with CB008745 when actNrExtCellSOMethod is active
    [Tags]    A_15
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when both CB008745 and CB010683-A are active, then:
    ...     - Power Group with lbpsSOMethod = 'cell switch off' switches off cells according to CB008745 rules. Such
    ...       Power Group can not have extended configuration for any cell.
    ...     - Power Group with cells with lbpsCellSOMethod = 'cell switch off' in extended configuration switches cells
    ...       off according to 5GC000431 rules and parameters for cell switch off. Parameters introduced by CB008745
    ...       even if configured, are ignored.
    ...
    ...  == Precondition: ==
    ...     Common preconditions with addition:
    ...     - NRBTS.shutdownWindow = 60
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actLbpsCtrlLogicEnh = True (CB008745)
    ...     - NRBTS.actNrExtCellSOMethod = True (CB010683-A)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = True,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 1, lbpsCellSOMethod = cell switch off, period starts now, duration = 24h,
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 50
    ...     - NRPGRP-1.lbpsMonWinForCellSOff = 200
    ...     - NRPGRP-1.lbpsMonWinForCellSOn = 90
    ...     - NRPGRP-1.lbpsSOffTrRule = SlidingAverageMethod
    ...     - NRPGRP-1.lbpsSOnTrRule = SlidingAverageMethod
    ...     - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)
    ...
    ...     - NRPGRP-2.lbpsSOMethod = cell switch off
    ...     - NRPGRP-2.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 3, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 2, nrCellId = 4, lbpsUseExtConfig = False
    ...     - NRPGRP-2.lbpsCellPeriodList = empty
    ...     - NRPGRP-2.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-2.lbpsRTXSOffTime = 50
    ...     - NRPGRP-2.lbpsMonWinForCellSOff = 200
    ...     - NRPGRP-2.lbpsMonWinForCellSOn = 90
    ...     - NRPGRP-2.lbpsSOffTrRule = SlidingAverageMethod
    ...     - NRPGRP-2.lbpsSOnTrRule = SlidingAverageMethod
    ...     - NRPGRP-2.lbpsLoadCalcMethod = Max(G, C, P)
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in notEnergySaving state
    ...   - NRCELL-3, NRCELL-4 are in energySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_37545

    [Setup]  Prepare test environment A_15
    start_collecting_syslog  prefix=A_15
    Configure gNB with NRPGRPs[1,2] and Energy Saving features flags

    Wait 180s for cells [1,2,3,4] energySavingState change to [notEnergySaving, reducedEnergySaving, energySaving, notEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [energySaving, reducedEnergySaving, energySaving, notEnergySaving]
    Wait 120s for cells [1,2,3,4] energySavingState change to [energySaving, reducedEnergySaving, energySaving, energySaving]

    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Attach UE2 to gNB2 cell2 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic

    Wait 1xTXOn for cells [1,2] energySavingState change to [energySaving,notEnergySaving]
    Wait 1xCellOn for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    [Teardown]  Basic cleanup
