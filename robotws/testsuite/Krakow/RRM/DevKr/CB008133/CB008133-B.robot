*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...			CB008133
...			When using 64T64R massive MIMO radio units, half of DL TXs can be dynamically muted/unmuted to save energy in low load conditions.
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
...         [08.08.2023] - changes in B_5 after PR719047 fix

Resource    ../CB008392/resources/CB008392-common_keywords.robot
Resource    resources/CB008133_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
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
CB008133-B_1 Interworking with 5GC000431
    [Tags]    B_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that operator can configure both features CB008133 and 5GC000431 on gNB. PSG with lbpsSOMethod = TX Switch Off
    ...   is controlled by CB008133 and PSG with lbpsSOMethod = Cell Switch Off is controlled by 5GC000431
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS.actNrLBPowerSaving  = True
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = Cell Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [3, 4]
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [2, 1]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO and non mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_17466
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12207 USCB008133-B#B6: interworking with 5GC000431
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-B-1

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[11,12] to gNB2 cell3 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[11,12] PDU1 QFI1 and wait 0 seconds
#    Change eNB parameter value  NRBTS-1.actNrLBPowerSaving  True  bts_id=1

    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 30s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]

    Stop 150Mbps DL traffic on UEs[11,12] PDU1 QFI1
    Wait for 320s to trigger cell switch off
    Wait 90s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,energySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Wait for 55s to trigger TX path switch on
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,energySaving]

    Run 150Mbps DL traffic on UEs[11,12] PDU1 QFI1 and wait 0 seconds
    Wait for 140s to trigger cell switch on
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 420 - 480
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 420 - 480
    ...                 Check RTPM counter: NRCELL-3 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is equal 0
    ...                 Check RTPM counter: NRCELL-4 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range 170 - 220

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 0
    ...                 Check RTPM counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test B_1

CB008133-B_2 Interworking with CB008392 - mMIMO and non mMIMO in the same PSG
    [Tags]    B_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that operator can configure both features CB008133 and CB008392 on gNB. Non mMIMO and MIMO cells are configured in
    ...   the same PSG - power saving for mMIMO cell is controlled by CB008133 and for non mMIMO cell by CB008392
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS.actNrLBRTXPowerSaving   = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2, 3, 4]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100, 100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO and non mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_17467
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12208 USCB008133-B#B7: interworking with CB008392
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-B_2

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds

    Set lbpsCellSOOrder in NRPGRP-1 to [1, 3, 2, 4] for cells [1,2,3,4]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Wait for 30s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]

    Wait for 30s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]

    Wait for 30s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[11,12] to gNB2 cell3 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[11,12] PDU1 QFI1 and wait 0 seconds

    Wait 65s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 150 - 190
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 70 - 110
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 110 - 150
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 30 - 70

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test B_2


CB008133-B_3 Interworking with CB008392 - mMIMO and non mMIMO in the different PSGs
    [Tags]    B_3
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This test verifies that operator can configure both features CB008133 and CB008392 on gNB. Non mMIMO and MIMO cells are configured in
    ...   different PSGs - PSG with mMIMO cell is controlled by CB008133 and PSG with non mMIMO cell by CB008392
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS.actNrLBRTXPowerSaving  = True
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [3, 4]
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO and non mMIMO cells NRCELL.energySavingState is set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:   5G_RAN_USR_RRM_17468
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12209 USCB008133-B#B8: interworking with CB008392
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-B_3

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[11,12] to gNB2 cell3 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[11,12] PDU1 QFI1 and wait 0 seconds
    Wait 70s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Activate RTPM counters
    ...                 Wait For Rtpm Before Test

    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 30s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    # wait longer to check that PSG-2 is not affected
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]

    Stop 150Mbps DL traffic on UEs[11,12] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 30s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Wait for 40s to trigger TX path switch on
    Wait 30s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[11,12] PDU1 QFI1 and wait 0 seconds
    Wait for 40s to trigger TX path switch on
    Wait 30s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 120 - 160
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 120 - 160
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 120
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 120

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    Omit when SKIP_COUNTERS present
    ...  RTPM deactivate

    [Teardown]  Cleanup after test B_3


CB008133-B_4 Deactivate CB008133 while interworking with CB008392 - mMIMO and non mMIMO in the different PSGs
    [Tags]    B_4    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test verifies that when massive MIMO cells and non-massive MIMO cells are in the separate PSG, the gNB shall switch on all TX paths
    ...     of all cells in the corresponding PSG which energySavingState = reducedEnergySaving and change the energySavingState = NotEnergySaving.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS.actNrLBRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [3, 4]
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - If massive MIMO cells and non-massive MIMO cells are in the separate PSG, the gNB shall switch on all TX paths of all cells in the
    ...     corresponding PSG which energySavingState = reducedEnergySaving and change the energySavingState = NotEnergySaving.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:   5G_RAN_USR_RRM_17650
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12212 USCB008133-B#B11: Deactivate Load-Based Reduced TX Path Power Saving while interworking with CB008392
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-B_4

    Wait 40s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRBTS-1.actNrLBRTXPowerSaving  False  bts_id=1
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Change eNB parameter value  NRBTS-1.actNrLBRTXPowerSaving  True  bts_id=1
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  False  bts_id=1
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    [Teardown]  Cleanup after test B_4


CB008133-B_5 Deactivate CB008133 while interworking with CB008392 - mMIMO and non mMIMO in the same PSG
    [Tags]    B_5
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test verifies that when massive MIMO cells and non-massive MIMO cells are in the same PSG, after trying to deactivate either
    ...     actNrLBmMimoRTXPowerSaving or actNrLBRTXPowerSaving, PDL rule is not met and validation of plan is not successful. After deleting
    ...     corresponding cell by operator, feature can be deactivated and validation of plan is successful. The gNB shall switch on all TX paths
    ...     of all cells in PSG that is updated which energySavingState = reducedEnergySaving and change the energySavingState = NotEnergySaving.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS.actNrLBRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1,3]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100,100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [4]
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [1]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...     The gNB shall switch on all TX paths of all cells in PSG that is updated which energySavingState = reducedEnergySaving
    ...     and change the energySavingState = NotEnergySaving.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:   5G_RAN_USR_RRM_17650
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12212 USCB008133-B#B11: Deactivate Load-Based Reduced TX Path Power Saving while interworking with CB008392
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)
    ...     [16.02.2023] - Clarify description of TC

    [Setup]  Prepare test environment CB008133-B_5

    Wait 40s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Deactivate CB008392 and remove NRCELL-3 from NRPGRP-1
#    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Configure NRPGRPs to previous state and activate CB008392
#    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Deactivate CB008133 and remove NRCELL-1 from NRPGRP-1
#    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    [Teardown]  Cleanup after test B_5


CB008133-B_6 Deactivate CB008133 and CB008392 simultaneously - mMIMO and non mMIMO in the same PSG
    [Tags]    B_6    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test verifies that when massive MIMO cells and non-massive MIMO cells are in the same PSG, the gNB shall switch on all TX paths
    ...     of all cells in PSGs and change the energySavingState = NotEnergySaving.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...	 - NRCELL-1 and NRCELL-2 are massive MIMO cells
    ...	 - NRCELL-3 and NRCELL-4 are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA+NSA cells
    ...	 - NRCELL-1.actBeamforming = True
    ...	 - NRCELL-2.actBeamforming = True
    ...  - NRBTS.actMicroDTX = True
    ...  - NRBTS.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS.actNrLBRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1,3]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100,100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [4]
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [1]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == Postconditions ==
    ...   - All mMIMO and non mMIMO cells NRCELL.energySavingState is set to notEnergySaving, cells are not removed from NRPGRP-1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE and two simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:   5G_RAN_USR_RRM_17650
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...	  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008133-12212 USCB008133-B#B11: Deactivate Load-Based Reduced TX Path Power Saving while interworking with CB008392
    ...
    ...  == HISTORY ==
    ...     [07.11.2022] - TC Create
    ...     [09.12.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872053)

    [Setup]  Prepare test environment CB008133-B_6

    Wait 40s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Deactivate both CB008392 and CB008133
    Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    [Teardown]  Cleanup after test B_6


*** Keywords ***
Change gNB param ${param} to ${value}
    coam.perform parameter recommissioning
    ...     dist_name=MRBTS-1/NRBTS-1
    ...     parameter=${param}
    ...     value=${value}
    ...     operation=update
    ...     skip_parameter_relation_errors=False
    ...     connection=${ADMIN_CONNECTION}

Deactivate CB008392 and remove NRCELL-3 from NRPGRP-1
    Run Keyword And Expect Error   *'pdl': "Assertion not met*   Change gNB param actNrLBRTXPowerSaving to false
    Configure NRPGRPs with single cells [1,4] and set CB008392 to False and CB008133 to True

Deactivate CB008133 and remove NRCELL-1 from NRPGRP-1
    Run Keyword And Expect Error   *'pdl': "Assertion not met*   Change gNB param actNrLBmMimoRTXPowerSaving to false
    Configure NRPGRPs with single cells [3,4] and set CB008392 to True and CB008133 to False
