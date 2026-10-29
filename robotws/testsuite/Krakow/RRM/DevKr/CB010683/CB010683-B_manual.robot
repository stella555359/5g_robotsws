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
CB010683-B_1 Activation and deactivation of actNrMixedSOMethod without PSG reconfiguration
    [Tags]    B_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test verifies, that after CB010683-B feature activation and deactivation all cells in energy saving state
    ...     are switched to notEnergySaving state, even if are not configured with 'mixed switch off' method.
    ...
    ...     This test case verifies, that when CB010683-B feature flag is active, then:
    ...     - Power Group with lbpsSoMethod = 'mixed switch off' behaves as legacy 5GC000431
    ...     - Power Group with lbpsSoMethod = 'TX switch off' behaves as legacy CB008392
    ...
    ...  == Precondition: ==
    ...    Common preconditions with exceptions:
    ...  - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...
    ...  - NRPGRP-1.lbpsSOMethod = TX switch off
    ...  - NRPGRP-1.lbpsCellList =
    ...     - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...     - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...  - NRPGRP-1.lbpsPeriodList =
    ...     - period starts now, not suspended, duration = 24h
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...
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
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19659;5G_RAN_USR_COM_19660;5G_CP_ARC_ALG_10419
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4915 USCB010683-B#B1: CB010683-B sub-feature activation
    ...     -  CB010683-4916 USCB010683-B#B2: CB010683-B sub-feature deactivation

    [Setup]  Prepare test environment B_1

    start_collecting_syslog  prefix=B_1
    Wait 2x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]
    Activate CB010683-B feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 2x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]
    Deactivate CB010683-B feature flag
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 2x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,energySaving,energySaving]

    [Teardown]  Basic cleanup

CB010683-B_3 Cell with Mixed Switch Off method - conditions for both Cell and TX switch off met
    [Tags]    B_3
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when for Power Group with lbpsSOMethod ='mixed switch off' conditions
    ...     for both cell switch off and TX paths switch off are met in the same time, then cells can be switched off
    ...     to energySaving state, skipping reducedEnergySaving state.
    ...
    ...     Test verifies also switching off cells with lbpsSOMethod ='mixed switch off' with special value
    ...     lbpsSoOrder = 100.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = mixed switch off
    ...     - NRPGRP-2.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 100, nrCellId = 2, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 100, nrCellId = 3, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList = empty
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = rdLowLoadSwitchOffDelay
    ...     - NRPGRP-1.lbpsRTXMinLoad = 20
    ...     - NRPGRP-1.lbpsMinLoad = 10
    ...     - NRPGRP-1.lbpsLastCellRTXMinLoad = 10
    ...     - NRPGRP-1.lbpsLastCellMinLoad = 10
    ...     - NRPGRP-1.lbpsRTXSOffTime = 60
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2, NRCELL-3 are in energySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18851;5G_RAN_USR_COM_18852;5G_CP_ARC_ALG_10676;5G_CP_ARC_ALG_10681
    ...                           5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4675 USCB010683-B#B5: Manage Mixed Switch Off Mode Interaction with MIMO Muting and Cell Switch
    ...                                       Off Power Saving Modes
    ...     -  CB010683-4676 USCB010683-B#B6: Determine Mixed Power Saving Mode

    [Setup]  Prepare test environment B_3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=B_3
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Attach UE1 to gNB2 cell3 with ICS during PDU session setup
    Run 50Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,notEnergySaving,notEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2,3] energySavingState change to [energySaving,energySaving,energySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3] has values [0,0,0]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3] has values [1,1,1]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3] has values [0,0,0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3] has values [>0,>0,>0]

    [Teardown]  Basic cleanup


CB010683-B_4 Cell with Mixed Switch Off method - conditions for only TX switch Off met
    [Tags]    B_4
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when for Power Group with lbpsSOMethod ='mixed switch off' conditions
    ...     for only TX switch off are met, then cells go to reducedEnergySaving state and cell switch off for
    ...     this cells is not possible. No more energy saving action is observed, until conditions for
    ...     cell switch off are met.
    ...
    ...     Test verifies also switching off/on cells with lbpsSOMethod ='mixed switch off' with special value
    ...     lbpsSoOrder = 100.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = mixed switch off
    ...     - NRPGRP-2.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 100, nrCellId = 2, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 100, nrCellId = 3, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 100, nrCellId = 4, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList = empty
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 60 (rdLowLoadSwitchOffDelay)
    ...     - NRPGRP-1.lbpsRTXSOnTime = 30
    ...     - NRPGRP-1.lbpsRTXMinLoad = 10
    ...     - NRPGRP-1.lbpsMinLoad = 0
    ...     - NRPGRP-1. lbpsLastCellRTXMinLoad = 10
    ...     - NRPGRP-1. lbpsLastCellMinLoad = 0
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2, NRCELL-3 NRCELL-4 are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18851;5G_RAN_USR_COM_18852;5G_CP_ARC_ALG_10747;5G_CP_ARC_ALG_10676
    ...                           5G_CP_ARC_ALG_10678;5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4675 USCB010683-B#B5: Manage Mixed Switch Off Mode Interaction with MIMO Muting and Cell Switch
    ...                                       Off Power Saving Modes
    ...     -  CB010683-4676 USCB010683-B#B6: Determine Mixed Power Saving Mode
    ...

    [Setup]  Prepare test environment B_4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=B_4
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

    Attach UE1 to gNB2 cell2 with ICS during PDU session setup
    Run 70Mbps DL traffic on UE1 PDU1 QFI1 and wait 10 seconds
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Wait time equal to 1x(CellOff+SW)
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Configure  [{'MOC': 'NRPGRP', 'ID': '1', 'lbpsMinLoad': '20'}]
    Wait 1x(CellOff+SW) for cells [1,2,3,4] energySavingState change to [energySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UE2 to gNB2 cell3 with ICS during PDU session setup
    Attach UE3 to gNB2 cell3 with ICS during PDU session setup
    Attach UE4 to gNB2 cell3 with ICS during PDU session setup
    Attach UE5 to gNB2 cell4 with ICS during PDU session setup
    Attach UE6 to gNB2 cell4 with ICS during PDU session setup
    Attach UE7 to gNB2 cell4 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE5 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE6 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE7 PDU1 QFI1 and wait 10 seconds

    Wait 1xTXOn for cells [1,2,3,4] energySavingState change to [energySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 1xCellOn for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2,3,4] has values [1,1,1,1]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2,3,4] has values [1,0,0,0]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2,3,4] has values [>0,>0,>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2,3,4] has values [>0,0,0,0]

    [Teardown]  Basic cleanup

CB010683-B_5 Mixed Switch Off method in cell extended config
    [Tags]    B_5
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that both CB010683-A and CB010683-B can be activated and used in the same
    ...     Power Group. 'Mixed switch off' method can be configured in cell extended configuration. Power Group
    ...     level lbpsSOMethod is different than 'mixed switch off'.
    ...
    ...  == Precondition: ==
    ...     Common preconditions
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = TX switch off
    ...     - NRPGRP-2.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = True
    ...     - NRPGRP-1.lbpsCellPeriodList =
    ...        - nrCellId = 2, lbpsCellSOMethod = mixed switch off, period starts now, duration = 24h
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 30
    ...     - NRPGRP-1.lbpsRTXSOnTime = 30
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1, NRCELL-2 are in notEnergySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_18851;5G_RAN_USR_COM_18852;5G_CP_ARC_ALG_10676;5G_CP_ARC_ALG_10678
    ...                           5G_CP_ARC_ALG_10681;5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4675 USCB010683-B#B5: Manage Mixed Switch Off Mode Interaction with MIMO Muting and Cell Switch
    ...                                       Off Power Saving Modes
    ...     -  CB010683-4676 USCB010683-B#B6: Determine Mixed Power Saving Mode

    [Setup]  Prepare test environment B_5

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_collecting_syslog  prefix=B_5
    Configure gNB with NRPGRPs[1] and Energy Saving features flags
    Wait 1xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]
    Wait 1xTXOff for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]
    Wait 1x(CellOff+SW) for cells [1,2] energySavingState change to [reducedEnergySaving,energySaving]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Attach UE3 to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 10 seconds

    Wait 1xTXOn for cells [1,2] energySavingState change to [notEnergySaving,energySaving]
    Wait 1xCellOn for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counter NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) for NRCELLs [1,2] has values [1,1]
    ...                 Verify that counter CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) for NRCELLs [1,2] has values [0,1]
    ...                 Verify that counter NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) for NRCELLs [1,2] has values [>0,>0]
    ...                 Verify that counter SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) for NRCELLs [1,2] has values [0,>0]

    [Teardown]  Basic cleanup

CB010683-B_9 Interaction with CB008745 for PSG with Mixed Switch Off method
    [Tags]    B_9
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies, that when both CB008745 and CB010683-B are active, then Power Group with
    ...     lbpsSOMethod = 'mixed switch off' can be configured. Load quantity calculation and TX/cell switch off/on
    ...     rule are based on 5GC000431 and CB008392 default methods. CB008745 parameters: lbpsMonWinForCellSOff,
    ...     lbpsMonWinForCellSOn, lbpsLoadCalcMethod, lbpsSOffTrRule, lbpsSOnTrRule are not used.
    ...
    ...     Test verifies online modification of lbpsSOMethod:
    ...     - from 'cell switch off' to 'mixed switch off'
    ...     - from 'mixed switch off' to 'cell switch off'
    ...
    ...  == Precondition: ==
    ...     Common preconditions with addition:
    ...     - NRBTS.shutdownWindow = 60
    ...
    ...  Delta configuration plan prepared to apply at the beginning of the test:
    ...     - NRBTS.actNrLBRTXPowerSaving = True (CB008392)
    ...     - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...     - NRBTS.actNrMixedSOMethod = True (CB010683-B)
    ...     - NRBTS.actLbpsCtrlLogicEnh = True (CB008745)
    ...
    ...     - NRPGRP-1.lbpsSOMethod = cell switch off
    ...     - NRPGRP-1.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 1, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 2, nrCellId = 2, lbpsUseExtConfig = False
    ...     - NRPGRP-1.lbpsCellPeriodList = empty
    ...     - NRPGRP-1.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-1.lbpsRTXSOffTime = 60 (rdLowLoadSwitchOffDelay)
    ...     - NRPGRP-1.lbpsRTXSOnTime = 60 (rdHighLoadSwitchOnDelay)
    ...     - NRPGRP-1.lbpsMonWinForCellSOff = 200
    ...     - NRPGRP-1.lbpsMonWinForCellSOn = 200
    ...     - NRPGRP-1.lbpsSOffTrRule = SlidingAverageMethod
    ...     - NRPGRP-1.lbpsSOnTrRule = SlidingAverageMethod
    ...     - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)

    ...     - NRPGRP-2.lbpsSOMethod = mixed switch off
    ...     - NRPGRP-2.lbpsCellList =
    ...        - lbpsCellSOOrder = 1, nrCellId = 3, lbpsUseExtConfig = False,
    ...        - lbpsCellSOOrder = 2, nrCellId = 4, lbpsUseExtConfig = False
    ...     - NRPGRP-2.lbpsCellPeriodList = empty
    ...     - NRPGRP-2.lbpsPeriodList =
    ...        - period starts now, not suspended, duration = 24h
    ...     - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...     - NRPGRP-2.lbpsRTXSOffTime = 60 (rdLowLoadSwitchOffDelay)
    ...     - NRPGRP-2.lbpsRTXSOnTime = 60 (rdHighLoadSwitchOnDelay)
    ...     - NRPGRP-2.lbpsMonWinForCellSOff = 200
    ...     - NRPGRP-2.lbpsMonWinForCellSOn = 200
    ...     - NRPGRP-2.lbpsSOffTrRule = SlidingAverageMethod
    ...     - NRPGRP-2.lbpsSOnTrRule = SlidingAverageMethod
    ...     - NRPGRP-2.lbpsLoadCalcMethod = Max(G, C, P)
    ...
    ...   Content of message PsCell_PowerSavingLoadMeasurementInd (L2 -> L3) verified during the test:
    ...       For NRCELL-2:
    ...          MeasuredGBRNBRCellLoad = 0,
    ...          MeasurednGBRnNBRCellLoad = sum of GBR + nGBR load,
    ...          MeasuredCBnGBRCellLoad = 0
    ...       For NRCELL-4:
    ...          MeasuredGBRNBRCellLoad = GBR load,
    ...          MeasurednGBRnNBRCellLoad = nGBR load,
    ...          MeasuredCBnGBRCellLoad = CB nGBR load
    ...
    ...  == Postconditions ==
    ...   - All NRCELLs are in energySaving state
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_19661;CB_FIM_37545;5G_CP_ARC_ALG_10439;5G_CP_ARC_ALG_10518
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010683-4918 USCB010683-B#B4: Handle Mixed Mode Power Saving Configuration Change

    [Setup]  Prepare test environment B_9
    start_collecting_syslog  prefix=B_9
    Configure gNB with NRPGRPs[1,2] and Energy Saving features flags

    Wait 120s for cells [1,2,3,4] energySavingState change to [energySaving, notEnergySaving, energySaving, notEnergySaving]
    Wait 60s for cells [1,2,3,4] energySavingState change to [energySaving, notEnergySaving, energySaving, energySaving]
    Wait 140s for cells [1,2,3,4] energySavingState change to [energySaving, energySaving, energySaving, energySaving]

    Reconfigure NRPGRP-1.lbpsSoMethod to 'mixed switch off' and NRPGRP-2.lbpsSoMethod to 'cell switch off'
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Attach UE1 to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Attach UE2 to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Attach UE3 to gNB2 cell2 with 1 non-GBR and 1 GBR 5QI1 bearer
    Attach UE4 to gNB2 cell4 with 1 non-GBR and 1 GBR 5QI1 bearer
    Attach UE5 to gNB2 cell4 with 1 non-GBR and 1 GBR 5QI1 bearer
    Attach UE6 to gNB2 cell4 with 1 non-GBR and 1 GBR 5QI1 bearer

    Run 150Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 150Mbps DL traffic on UE2 PDU1 QFI2 and wait 0 seconds
    Run 150Mbps DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    Run 150Mbps DL traffic on UE4 PDU1 QFI2 and wait 0 seconds
    Run 150Mbps DL traffic on UE5 PDU1 QFI2 and wait 0 seconds
    Run 150Mbps DL traffic on UE6 PDU1 QFI1 and wait 10 seconds  #To stabilize high traffic

#    Verify content of message PsCell_PowerSavingLoadMeasurementInd  #manually
    Detach and kill UEs from 1 to 6

    Wait 120s for cells [1,2,3,4] energySavingState change to [energySaving, notEnergySaving, energySaving, notEnergySaving]
    Wait 60s for cells [1,2,3,4] energySavingState change to [energySaving, energySaving, energySaving, notEnergySaving]
    Wait 140s for cells [1,2,3,4] energySavingState change to [energySaving, energySaving, energySaving, energySaving]

    [Teardown]  Basic cleanup
