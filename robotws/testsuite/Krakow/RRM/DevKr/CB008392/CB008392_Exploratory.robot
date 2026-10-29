*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008392 provide the RAN level requirements of half of DL TX paths can be dynamically muted / unmuted
...         to save energy in low load conditions.
...         This feature is applied to non-beamforming MIMO configurations with 4T4R, 6T6R or 8T8R radio unit
...         and beamforming MIMO configurations with 8T8R radio unit.
...         This feature can be enabled/disabled by new O&M parameter.
...         This feature is only applied to TDD FR1 and FDD FR1.
...
...      == TEST SET NAME ==
...         CB008392 - Load based MIMO muting for Energy Efficiency
...
...      == TESTING SPLIT ==
...         Subfeature-A MIMO muting for 4T4R, 6T6R radio
...         Subfeature-B MIMO muting for 8T8R radio in non-BF configuration
...         Subfeature-C MIMO muting for 8T8R radio in subsectorization configuration
...         Subfeature-D MIMO muting for 8T8R radio in BF configuration
...         Subfeature-E feature interaction with 5GC00431
...         Subfeature-F feature interaction with EIRP control, uDTX
...
...      == CONTACTS ==
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == REFERENCES ==
...         CB008392 CFAM
...
...      == HISTORY ==
...         [19.07.2022] - TC Create
...         [17.08.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=863796)

Resource    ./resources/CB008392-common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008392/CB008392-A-E.yaml

Suite Setup  Run setup
Suite Teardown  Run teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_TDD_SANSA.lua
${SKIP_COUNTERS}=         ${TRUE}

*** Test Cases ***
CB008392-Exploratory_1 traffic distinction for cells in 5GC000431 and CB008392 power saving groups
    [Tags]    E_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This check, that correct load is calculated separately for power saving group with different lbpsSOMethod.
    ...  Test verification is not fully automated. Syslog was manually checked to verify raported load calculation.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with four SA cells
    ...  - NRCELL-1, NRCELL-2, NRCELL-3, NRCELL-4 are up and connected to AMF1
    ...  - each NRCELL is connected with 4 TX, 4 RX CHANNELs to RMOD with 4 ANTLs
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-1.lbpsSOMethod = 'TX Switch Off'
    ...  - NRPGRP-2.lbpsSOMethod = 'cell Switch off'
    ...
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 2
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 3
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 100
    ...       - nrCellId = 4
    ...       }
    ...    }
    ...  - Time window is set according to current time
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = {current day of the week}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = {current hour - 1}
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = 0
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRBTS.actNrLBRTXPowerSaving = False
    ...  - NRBTS.actNrLBPowerSaving = False
    ...  - NRPMRNL-1.miNrCellAvailability = 5min
    ...
    ...  rdLowLoadSwitchOffDelay = 300s (Switch-off delay time for 5GC000431)
    ...  NRBTS-1.shutdownWindow = 60 (duration of the cell shutdown for 5GC000431)
    ...
    ...  == Postconditions ==
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_CP_ARC_ALG_7430;5G_RAN_USR_COM_16102;5G_RAN_USR_COM_16103;CB_FIM_29800
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008392-7358 USCB008392-E#B15: Handle Power Saving Configuration Change
    ...     -  CB008392-7359 USCB008392-E#B16: Manage Cell TX Path Reduction and Cell Switch Off Power Saving Interaction
    ...
    ...  == HISTORY ==
    ...     [19.07.2022] - TC Create
    ...     [xx.xx.2022] - Review

    [Setup]  Prepare test environment E_1_2

    Activate CB008392 and 5GC000431 feature flags

    start_collecting_syslog  prefix=Robustness_1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    sleep  60

    Wait for 40s to trigger TX path switch on
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Run 75Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    sleep  60

    Attach UEs[3,4] to gNB2 cell3 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds
    sleep  60
    Run 75Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds
    sleep  60

    Stop 75Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait 60s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]

    Stop 75Mbps DL traffic on UEs[3,4] PDU1 QFI1
    sleep  60

    stop_collecting_syslog

    ## in syslog verify maily below prints, to check if load is changeing correctly for both PDG:
    ## DBG/cp_rt/EnergySavingAlgorithm.cpp:xxx [CELL] nrCellIdentity:xxxx collected 4 measurements, average=[0, xx, xx]
    ## DBG/cp_rt/EnergySavingAlgorithm.cpp:xxx PowerGroup1 pgLoad=xx > lbpsMaxLoad/lbpsRTXMaxLoad=xx

    [Teardown]  Basic cleanup

*** Keywords ***
