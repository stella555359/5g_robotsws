*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008133
...         When using 64T64R massive MIMO radio units, half of DL TXs can be dynamically muted/unmuted to save energy in low load conditions.
...			CB008133 is applicable only for beam forming configurations in NR TDD FR1 where the cell is served by a 64T64R massive MIMO radio unit.
...			It provides energy savings by muting half of the TXs (32 TXs) in low load conditions. All 64 RXs are still used for uplink.
...			Muting is done when the load as measured by gNB goes below a configurable threshold. When the load increases above a configurable
...			threshold the muted TXs are switched on again. Muting and un-muting is done dynamically and automatically without cell down time.
...			The feature is the mMIMO counterpart of the feature CB008392. It also uses similar configuration as the feature CB008392
...			based on "power saving groups" (group of cells with overlapping coverage which share the load).
...
...         This feature can be enabled/disabled by new O&M parameter.
...         This feature is only applied to TDD FR1.
...
...      == TEST SET NAME ==
...         CB008133 - Massive MIMO muting (FR1) for energy efficiency
...
...      == TESTING SPLIT ==
...         Subfeature-A Basic mMIMO muting/unmuting algorithms
...         Subfeature-B Feature interaction
...
...      == CONTACTS ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008133 CFAM
...
...      == HISTORY ==
...         [07.11.2022] - TC Create
...         [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

Resource    ../CB008392/resources/CB008392-common_keywords.robot
Resource    resources/CB008133_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008133/CB008133.yaml

Suite Setup     Run Keywords
...             Run setup
...     AND     Enable internal mirroring for alias  gNB2

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008133/scf_2AEQE_2AZQU_SANSA.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008133/iphy_2AEQE_2AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008133-A_2 Activate Load-Based Reduced TX Path Power Saving
    [Tags]    A_2    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test verifies that after proper configuration of all related parameters and activating feature flag, gNB will reset and
    ...     after that reach onAir state without alarms
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = False
    ...
    ...  == Postconditions ==
    ...   - after gNB restart all cells should reach onAir
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_17318; 5G_RAN_USR_RRM_17320;5G_RAN_OP_2395;5G_RAN_OP_2399;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12192 USCB008133-A#B1: Activate Load-Based Reduced TX Path Power Saving
    ...     -  CB008133-12194 USCB008133-A#B3: Configure Load-Based Reduced TX Path Power Saving Controls
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)


    Set test variable    ${NRPGRP-1.lbpsSOMethod}              'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             20
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}            30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}             30
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set test variable    ${NRPGRP-1.offset}                     10
    Set test variable    ${NRPGRP-1.lbpsDuration}               60

    Set Test Variable       ${NRPGRP-1.lbpsSuspended}     		notSuspended

    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  True  bts_id=1
#    Verify that all cells are onAir


CB008133-A_3 Basic switch on-off cell TX paths in NSA mode
    [Tags]    A_3
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that gNB switch off or switch on cell TX paths based on nonGBR traffic in NSA mode.
    ...   When all conditions for switch off are meet new beamset with half TXs is used. Cell's "Energy saving state"
    ...   is set to reducedEnergySaving. After increased nonGBR traffic gNB should switch beamset back to full 64 TXs
    ...   and cell's "Energy saving state" is set to notEnergySaving.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for NSA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - Time window is set outside of current time, will be set in test procedure
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in NSA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_17318; 5G_RAN_USR_RRM_17320;5G_RAN_USR_RRM_17542;5G_RAN_USR_RRM_17540;5G_RAN_OP_2395;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12195 USCB008133-A#B4: Power reduction via load based massive MIMO power saving with 32TRX path switch off
    ...     -  CB008133-12196 USCB008133-A#B5: Power reduction restore via load based massive MIMO power saving with 32TRX path switch on
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-A_3
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Attach UE16 to simulated eNB1 CELL-1
    Attach UE17 to simulated eNB1 CELL-1
    Attach UE18 to simulated eNB1 CELL-1
    Attach UE19 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE16 with NRCELL_1 on gNB2
    Trigger SgnbAddition procedure for UE17 with NRCELL_1 on gNB2
    Trigger SgnbAddition procedure for UE18 with NRCELL_2 on gNB2
    Trigger SgnbAddition procedure for UE19 with NRCELL_2 on gNB2
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Configure NRPGRP CB008133-A_3
    Wait 50s for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]

    Run 100Mbps DL traffic on split bearer for UE16 and wait 0 seconds
    Run 100Mbps DL traffic on split bearer for UE17 and wait 0 seconds
    Run 100Mbps DL traffic on split bearer for UE18 and wait 0 seconds
    Run 100Mbps DL traffic on split bearer for UE19 and wait 0 seconds
    Wait for 40s to trigger TX path switch on
    Wait 40s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 30 - 70
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is equal 0

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test A_3


# In regression covered in CB008133-A_4_5 Switch on-off cells TX path after lbpsSuspended modification and feature deactivation
CB008133-A_4 Feature deactivation when cell is in reducedEnergySaving state
    [Tags]    A_4    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when cell is in reducedEnergySaving state and feature flag will be deactivated, gNB shall switch on
    ...   all TX paths on that cell and change energySavingState to NotEnergySaving
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_17319;5G_RAN_OP_2395;5G_RAN_OP_2399;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12193 USCB008133-A#B2: Deactivate Load-Based Reduced TX Path Power Saving
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-A_4

    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Run 20Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds
    Verify 20Mbps DL traffic on UE1 PDU1 QFI1
    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  False  bts_id=1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Verify 20Mbps DL traffic on UE1 PDU1 QFI1

    [Teardown]  Cleanup after test A_4


# In regression covered in CB008133-A_4_5 Switch on-off cells TX path after lbpsSuspended modification and feature deactivation
CB008133-A_5 Switch on-off cells TX path after lbpsSuspended modification
    [Tags]    A_5    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when in Power Saving Group energy saving is suspended, then all cells with "Energy saving state" set to
    ...   reducedEnergySaving are set to notEnergySaving state immediately. When energy saving is unsuspended, cells can be again set to
    ...   reducedEnergySaving state.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - Time window is set outside of current time, will be set in test procedure
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:    5G_RAN_OP_2395;5G_RAN_USR_RRM_17542
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     Alternative scenarios from USCB008133-A#B4 and USCB008133-A#B5:
    ...     -  CB008392-7327 USCB008392-A#B18: Suspend Load-Based Reduced TX Paths Power Saving
    ...     -  CB008392-7328 USCB008392-A#B19: Un-suspend Load-Based Reduced TX Paths Power Saving
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-A_5
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Configure NRPGRP CB008133-A_5
    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]
    ## Check again energySavingState to verify that PSG is suspended
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  notSuspended  bts_id=1
    Wait for 30s to trigger TX path switch off
    Wait 10s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 40 - 70
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 40 - 70

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test A_5


CB008133-A_6 Interaction with emergency call
    [Tags]    A_6
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that cell with ongoing emergency call can not be set into reducedEnergySaving state.
    ...   Test verifies, that when all cells are configured with lbpsCellSOOrder = 100, then only cells without emergency call are set to
    ...   reducedEnergySaving. Rest of the cells are set to reducedEnergySaving when emergency call is ended.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRCELL-2.actEmergencyCall = True
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...
    ...  == Postconditions ==
    ...   - All mMIMO cells NRCELL.energySavingState is set to notEnergySaving, emergency call is ended.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:    5G_RAN_OP_2395;CB_FIM_31472;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-A_6

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 10 seconds
    Wait 50s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Start UE3 emergency call in NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    ## Wait longer to verify, that NRCELL-2 will be still in notEnergySaving state
    Wait for 100s to trigger TX path switch off
    Check for cells [1,2] if energySavingState equals [reducedEnergySaving,notEnergySaving]

    Stop UE3 emergency call in NRCELL-2
    Wait for 40s to trigger TX path switch off
    Wait 30s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Set lbpsCellSOOrder in NRPGRP-1 to [100, 100] for cells [1,2]
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Start UE3 emergency call in NRCELL-2
    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 30s for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]

    Stop UE3 emergency call in NRCELL-2
    Wait for 40s to trigger TX path switch off
    Wait 10s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 170 - 230
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 60 - 120

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test A_6


CB008133-A_7 Cell failed due to cell level alarm
    [Tags]    A_7
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when one of the cells in power group becomes failed, the rest of cells in the same power group
    ...   with energy saving state set to reducedEnergy should switch on TX paths and change state to notEnergySaving.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - Time window is set outside of current time, will be set in test procedure
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_17540;5G_RAN_USR_RRM_17542;5G_RAN_USR_COM_16104
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     Alternative scenarios from USCB008133-A#B4 and USCB008133-A#B5:
    ...     -  CB008392-13004 USCB008392-A#B17: Handle Cell or TX Path Outage Impact on Capacity
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-A_7
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Configure NRPGRP CB008133-A_7
    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRCELL-1.gscnOrSsPbchArfcn  11  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]
    ## Check again energySavingState to verify that cell-2 cannot enter reducedEnergySavingState
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Change eNB parameter value  NRCELL-1.gscnOrSsPbchArfcn  7880  bts_id=1
    Lock NRCELL-1  # needed to clear alarm on NRCELL-1
    Wait 40s for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]
    Unlock NRCELL-1
    Wait for 20s to trigger TX path switch off
    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 100
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 110 - 180

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test A_7


# Optimization of tests:
# CB008133-A_4 Feature deactivation when cell is in reducedEnergySaving state
#CB008133-A_5 Switch on-off cells TX path after lbpsSuspended modification
CB008133-A_4_5 Switch on-off cells TX path after lbpsSuspended modification and feature deactivation
    [Tags]    A_4_5
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that when in Power Saving Group energy saving is suspended, then all cells with "Energy saving state" set to
    ...   reducedEnergySaving are set to notEnergySaving state immediately. When energy saving is unsuspended, cells can be again set to
    ...   reducedEnergySaving state. Then feature flag is deactivated and gNB shall switch on TX paths on reducedEnergySaving cells
    ...   and change energySavingState to NotEnergySaving.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - Time window is set outside of current time, will be set in test procedure
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:    5G_RAN_OP_2395;5G_RAN_USR_RRM_17542;5G_RAN_USR_RRM_17319;5G_RAN_OP_2399;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12193 USCB008133-A#B2: Deactivate Load-Based Reduced TX Path Power Saving
    ...     Alternative scenarios from USCB008133-A#B4 and USCB008133-A#B5:
    ...     -  CB008392-7327 USCB008392-A#B18: Suspend Load-Based Reduced TX Paths Power Saving
    ...     -  CB008392-7328 USCB008392-A#B19: Un-suspend Load-Based Reduced TX Paths Power Saving
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-A_5
    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Configure NRPGRP CB008133-A_5
    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]
    ## Check again energySavingState to verify that PSG is suspended
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  notSuspended  bts_id=1
    Wait for 30s to trigger TX path switch off
    Wait 10s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Run 20Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds
    Verify 20Mbps DL traffic on UE1 PDU1 QFI1
    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  False  bts_id=1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Verify 20Mbps DL traffic on UE1 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 40 - 110
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 40 - 110

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test A_4


