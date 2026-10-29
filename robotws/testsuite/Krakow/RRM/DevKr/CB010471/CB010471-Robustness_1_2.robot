*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010471
...         When using 32T32R massive MIMO radio units, half of DL TXs can be dynamically muted/unmuted to save energy in low load conditions.
...         CB010471 is applicable only for beam forming configurations in NR TDD FR1 where the cell is served by a 32T32R massive MIMO radio unit.
...         It provides energy savings by muting half of the TXs (16 TXs) in low load conditions. All 32 RXs are still used for uplink.
...         The load is measured for power saving group (PSGRP) of cells with same/overlapping coverage similarly as with the
...         feature CB008133 Massive MIMO muting, which supports the 64T64R mMIMO radio units.
...         Muting is done when the PSGRP load as measured by gNB goes below a configurable threshold. When the load increases above a
...         configurable threshold the muted TXs are switched on again.
...         Muting and unmuting is done dynamically and automatically without cell down time.
...         The muting is done by a horizontal cut in order to keep the horizontal beam forming capabilities as without muting.
...         The feature can be used with 5GC000534 Digital Beamforming for eCPRI based RUs, 5GC002200 Support 4 x 8 port CSI-RS codebook for SU-MIMO,
...         5GC001086 SRS based beamforming in UL and CB008247 SRS based downlink beamforming.
...         This feature can be configured to be active only on wanted time/times of day and duration. In case there are emergency, ETWS/CMAS or
...         High Priority Access (CB008232) calls in the cell the muting is not performed. NOTE: The interaction with High Priority Access is handled
...         by a specific feature "CB010638 Power saving avoidance during priority access calls".
...         The feature can be enabled/disabled per gNB. There are two other features by which half of the TXs can be muted in low load conditions
...         to save energy: CB008392 Load based MIMO muting is for non mMIMO RUs (4T4R, 6T6R and 8T8R RUs), CB008133 Massive MIMO muting (FR1) is
...         for mMIMO RUs with 64T64R. This feature brings the support for 32T32R mMIMO RUs. All three features utilize the power saving groups for
...         gNB configuration. Power saving groups define groups of cells which have overlapping coverage and which share the traffic load.
...         During the low load, when the half of the TXs have been muted the DL user throughput may be reduced as well.
...         Also DL coverage may be reduced so that the cell edge users may change/handover to neighbor cells.
...         For such 32T32R radio units which do not have built-in VET (variable electrical tilt) the feature can be used only with
...         zero electrical downtilt.
...
...         The feature is applicable to SSB beamsets of 1-row of SSB beams only.
...         This feature is applicable for ASIB, ASIL, ASIK, ABIL, ABIN, ABIO, ASOE, ASIM and NR 32T32R radio unit.
...         This feature is applicable for Classical BTS only.
...         This feature is applicable for eCPRI only.
...         This feature is only applied to TDD FR1.
...         This feature can be enabled/disabled by existing O&M parameter.
...
...      == TEST SET NAME ==
...         CB010471-A Massive MIMO muting for FR1 TDD 32T32R radio units
...
...      == TESTING SPLIT ==
...         CB010471-A Basic Massive MIMO muting alogrithms
...         CB010471-B Feature interworking
...
...      == TESTING SCOPE ==
...         This Test Plan is covering robustness testing for feature CB010471.
...
...      == CONTACTS ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...
...      == MAINTAINER ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...
...      == REFERENCES ==
...         CB010471 CFAM - https://gates.nsn-net.net/view/00026c38#o=0
...
...      == HISTORY ==
...         [11.07.2023] - Created TC

Resource    resources/CB010471-common_keywords.robot
Resource    resources/CB010471_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB010471/2AQQA_2AEQQ.yaml

Suite Setup     Run setup
Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010471/scf_2AQQA_2AEQQ_SANSA.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010471/iphy_2AQQA_2AEQQ_4CELLS.xml
${SKIP_COUNTERS}=         ${TRUE}
${rtpm}=                  ${FALSE}

*** Test Cases ***
CB010471-Robustness_1 Resetting X2 Link
    [Tags]    Robustness_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies behaviour of gNB when reseting X2 link when feature is active and some cells
    ...  are in reducedEnergySaving state.
    ...
    ...  This test verifies behaviour of gNB when feature is activated and cell level alarm is present
    ...  Test steps:
    ...  1. Reach on air state
    ...  2. Feature CB010471 is active and NRPGRP is configured
    ...  3. Attach 2 x UEs per every NRCELL and start 10MBps traffic
    ...  Repeat steps 4-10 x10 times
    ...    4. Wait until all cells are in reducedEnergySaving state
    ...    5. Reset X2 link
    ...    6. Verify that all cells are degraded and in notEnergySaving state
    ...    7. Verify that traffic is ongoing on all UEs
    ...    8. Setup X2 link
    ...    9. Wait until all cells are not degraded and in reducedEnergySaving state
    ...    10. Verify that traffic is ongoing on all UEs
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AQQA, 2x AEQQ
    ...  - NRCELL-1 and NRCELL-2 on AQQA, NRCELL-3 and NRCELL-4 on AEQQ are massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRCELL-3.actBeamforming = True
    ...  - NRCELL-4.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2, 3, 4]
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = current day of the week
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = current hour
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = current minute
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 30
    ...  - NRPGRP-1.lbpsRTXMinLoad = 15
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 15
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100, 100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == POSTCONDITION ==
    ...  All mMIMO cells NRCELL.energySavingState are set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 2x AQQA, 2x AEQQ
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_OP_2395;
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...
    ...  == HISTORY ==
    ...  [11.07.2023] - Created TC
    ...  [11.07.2023] - Review closed

    [Setup]  Prepare test environment CB010471-Robustness_1

    Log to console  Resetting X2 Link
    # STEP 3
    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL2 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds
    Attach UEs[5,6] to gNB2 CELL3 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[5,6] PDU1 QFI1 and wait 0 seconds
    Attach UEs[7,8] to gNB2 CELL4 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[7,8] PDU1 QFI1 and wait 0 seconds

    FOR    ${repeat}    IN RANGE    1    11
        Log to console  Reset number ${repeat}
        # STEP 4
        Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

        # STEP 5
        Reset X2 link between gNB2 and simulated eNB1
        # Wait for 65s to timer x2LinkReestabTmr expiry

        # STEP 6
        Wait 30s for cells [1,2,3,4] availabilityStatus change to [degraded,degraded,degraded,degraded]
        Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

        # STEP 7
        Verify 10Mbps DL traffic for UEs from 1 to 8

        # STEP 8
        Setup X2 link between gNB2 and simulated eNB1

        # STEP 9
        Wait 30s for cells [1,2,3,4] availabilityStatus change to [-,-,-,-]
        Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

        # STEP 10
        Verify 10Mbps DL traffic for UEs from 1 to 8

    END

    [Teardown]  Cleanup after test CB010471-Robustness_1


CB010471-Robustness_2 Lock, unlock and reset NRCELL
    [Tags]    Robustness_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies behaviour of gNB when locking and reseting NRCELL when feature is active and some cells
    ...  are in reducedEnergySaving state.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AQQA, 2x AEQQ
    ...  - NRCELL-1 and NRCELL-2 on AQQA, NRCELL-3 and NRCELL-4 on AEQQ are massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRCELL-3.actBeamforming = True
    ...  - NRCELL-4.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 3]
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = current day of the week
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = current hour
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = current minute
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 15
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 15
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [2, 4]
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = current day of the week
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = current hour
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = current minute
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 15
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 15
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == POSTCONDITION ==
    ...  All mMIMO cells NRCELL.energySavingState are set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 2x AQQA, 2x AEQQ
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_OP_2395;
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...
    ...  == HISTORY ==
    ...  [11.07.2023] - Created TC
    ...  [11.07.2023] - Review closed

    [Setup]  Prepare test environment CB010471-Robustness_2

#   Lock - unlock NRCELL, low traffic
    Log to console  Starting Lock/unlock NRCELL - low traffic scenario
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL3 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds

    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Lock NRCELL-2
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Locked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Unlock NRCELL-2
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Verify 10Mbps DL traffic on UE1 PDU1 QFI1
    Verify 10Mbps DL traffic on UE2 PDU1 QFI1
    Verify 10Mbps DL traffic on UE3 PDU1 QFI1
    Verify 10Mbps DL traffic on UE4 PDU1 QFI1

    Lock NRCELL-1
    Wait 60s for cells [1,2,3,4] administrativeState change to [Locked,Unlocked,Unlocked,Unlocked]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Unlock NRCELL-1
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Verify 10Mbps DL traffic on UE3 PDU1 QFI1
    Verify 10Mbps DL traffic on UE4 PDU1 QFI1

    Lock NRCELL-4
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Locked]
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    Unlock NRCELL-4
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Verify 10Mbps DL traffic on UE3 PDU1 QFI1
    Verify 10Mbps DL traffic on UE4 PDU1 QFI1

    Lock NRCELL-3
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Locked,Unlocked]
    #Verify that UE3 state is OFF on Egate
    #Verify that UE4 state is OFF on Egate
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Unlock NRCELL-3
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Detach and kill UEs from 1 to 4

#   Lock - unlock NRCELL, high traffic
    Log to console  Starting Lock/unlock NRCELL - high traffic scenario
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 100Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL3 with ICS during PDU session setup
    Run 100Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds

    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]

    Lock NRCELL-2
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Locked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Unlock NRCELL-2
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Verify that UE1 state is ACTIVE on Egate
    Verify that UE2 state is ACTIVE on Egate
    Verify that UE3 state is ACTIVE on Egate
    Verify that UE4 state is ACTIVE on Egate

    Lock NRCELL-1
    Wait 60s for cells [1,2,3,4] administrativeState change to [Locked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Unlock NRCELL-1
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    ##Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Verify that UE3 state is ACTIVE on Egate
    Verify that UE4 state is ACTIVE on Egate

    Lock NRCELL-4
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Locked]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Unlock NRCELL-4
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Verify that UE3 state is ACTIVE on Egate
    Verify that UE4 state is ACTIVE on Egate

    Lock NRCELL-3
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Locked,Unlocked]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Unlock NRCELL-3
    Wait 60s for cells [1,2,3,4] administrativeState change to [Unlocked,Unlocked,Unlocked,Unlocked]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    #Verify that UE3 state is OFF on Egate
    #Verify that UE4 state is OFF on Egate
    Detach and kill UEs from 1 to 4

#   Reset NRCELL, low traffic
    Log to console  Starting Reset NRCELL - low traffic scenario
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL3 with ICS during PDU session setup
    Run 10Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds

    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Reset NRCELL-2
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Verify 10Mbps DL traffic on UE1 PDU1 QFI1
    Verify 10Mbps DL traffic on UE2 PDU1 QFI1
    Verify 10Mbps DL traffic on UE3 PDU1 QFI1
    Verify 10Mbps DL traffic on UE4 PDU1 QFI1

    Reset NRCELL-1
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Verify 10Mbps DL traffic on UE3 PDU1 QFI1
    Verify 10Mbps DL traffic on UE4 PDU1 QFI1

    Reset NRCELL-4
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Verify 10Mbps DL traffic on UE3 PDU1 QFI1
    Verify 10Mbps DL traffic on UE4 PDU1 QFI1

    Reset NRCELL-3
    Wait 10s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    #Verify that UE3 state is OFF on Egate
    #Verify that UE4 state is OFF on Egate
    Detach and kill UEs from 1 to 4

#   Reset NRCELL, high traffic
    Log to console  Starting reset NRCELL - high traffic scenario
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 100Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL3 with ICS during PDU session setup
    Run 100Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds

    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]

    Reset NRCELL-2
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Verify that UE1 state is ACTIVE on Egate
    Verify that UE2 state is ACTIVE on Egate
    Verify that UE3 state is ACTIVE on Egate
    Verify that UE4 state is ACTIVE on Egate

    Reset NRCELL-1
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Verify that UE3 state is ACTIVE on Egate
    Verify that UE4 state is ACTIVE on Egate

    Reset NRCELL-4
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    Verify that UE3 state is ACTIVE on Egate
    Verify that UE4 state is ACTIVE on Egate

    Reset NRCELL-3
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,notEnergySaving,reducedEnergySaving]
    Wait 10s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]
    Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    #Verify that UE1 state is OFF on Egate
    #Verify that UE2 state is OFF on Egate
    #Verify that UE3 state is OFF on Egate
    #Verify that UE4 state is OFF on Egate

    [Teardown]  Cleanup after test CB010471-Robustness_2

*** Keywords ***
Verify 10Mbps DL traffic for UEs from 1 to 8
    FOR    ${ind1}    IN RANGE    1    9
        Verify 10Mbps DL traffic on UE${ind1} PDU1 QFI1
    END
