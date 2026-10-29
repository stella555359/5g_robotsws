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
...         This Test Plan is covering exploratory testing for feature CB010471.
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
...         [19.07.2023] - Created TC


# Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00
# ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# ...    CONFIGS_Krakow/CB010471/1AQQA_1AEQQ_2AEQE.yaml

# Suite Setup     Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_TDD_SANSA.lua
${SKIP_COUNTERS}=         ${TRUE}
${rtpm}=                  ${FALSE}

*** Test Cases ***
CB010471-Exploratory_1 Moving cells for different NRPGRP Power Groups with Tx switch off method
    [Tags]    Exploratory_1    MANUAL    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies behaviour of gNB when removing and adding cells from and to different NRPGRP Power Groups when TX switch off is enabled.
    ...  Ensure that:
    ...  - Configuring or updating lbpsCellList.nrCellId parameter for NRPGRP with TX switch off set as lbpsSOMethod will provoke cell reset
    ...  of the target NRCELL instance, all UEs will be detached.
    ...  - Traffic is ongoing for cells not affected by modifying NRPGRP.lbpsCellList.nrCellId parameter.
    ...  - All cells in NRPGRP Power Groups in which NRPGRP.lbpsCellList is modified set energySavingState to notEnergySaving.
    ...
    ...  TEST DESCRIPTION
    ...  Attach UE1 to simulated eNB2 NRCELL-1
    ...  Attach UE2 to simulated eNB2 NRCELL-2
    ...  Attach UE3 to simulated eNB2 NRCELL-3
    ...  Attach UE4 to simulated eNB2 NRCELL-4
    ...  Run low traffic on all UEs that do not trigger Load Balancing Power Saving
    ...  Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ...
    ...  Configure NRPGRP-1 with active time period
    ...  Wait 150s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on all UEs
    ...
    ...  Try to configure NRPGRP-2 with NRCELL-4, lbpsSOMethod = TX switch off
    ...  - system refuse to create NRPGRP-2 because cell is already in use by NRPGRP-1
    ...
    ...  Remove NRCELL-4 from NRPGRP-1.lbpsCellList.nrCellId
    ...  Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ...  Wait 80s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    ...
    ...  Configure NRPGRP-2 the same as NRPGRP-1, add NRCELL-4 to NRPGRP-2.lbpsCellList.nrCellId
    ...  Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on UEs 1-3
    ...
    ...  Remove NRCELL-3 from NRPGRP-1.lbpsCellList.nrCellId
    ...  Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ...
    ...  Add NRCELL-3 to NRPGRP-2.lbpsCellList.nrCellId
    ...  Wait 50s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on UEs 1-2
    ...
    ...  Remove NRCELL-2 from NRPGRP-1.lbpsCellList.nrCellId
    ...  Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]
    ...
    ...  Add NRCELL-2 to NRPGRP-2.lbpsCellList.nrCellId
    ...  Wait 80s for cells [1,2,3,4] energySavingState change to [notEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on UE 1
    ...
    ...  Set NRPGRP-2 and NRPGRP-2 lbpsLastCellSOEnabled to True
    ...  Wait 150s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]
    ...  Verify that traffic is present on UE 1
    ...
    ...  Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...
    ...  Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 4 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 3 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1 - to be check manually during test execution
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AEQE
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AEQE are massive MIMO cells
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
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2, 3, 4]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == POSTCONDITION ==
    ...  All mMIMO cells NRCELL.energySavingState are set to reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: N/A for Exploratory test
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
    ...  [19.07.2023] - Created TC

    # Manual Test Description above
    No operation


CB010471-Exploratory_2 Moving cells for different NRPGRP Power Groups with Tx switch off and cell switch off method
    [Tags]    Exploratory_2    MANUAL    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies behaviour of gNB when removing and adding cells from and to different NRPGRP Power Groups when TX switch off
    ...  and cell switch off are enabled.
    ...  Ensure that:
    ...  - Configuring or updating lbpsCellList.nrCellId parameter for NRPGRP with lbpsSOMethod set to TX switch off will provoke cell reset
    ...  of the target NRCELL instance, all UEs will be detached, traffic is stopped.
    ...  - Configuring or updating lbpsCellList.nrCellId parameter for NRPGRP with lbpsSOMethod set to cell switch off will not provoke cell reset
    ...  of the target NRCELL instance, all UEs will not be detached, traffic is ongoing.
    ...  - Traffic is ongoing for cells not affected by modifying NRPGRP.lbpsCellList.nrCellId parameter.
    ...  - All cells in NRPGRP Power Groups in which NRPGRP.lbpsCellList is modified set energySavingState to notEnergySaving.
    ...
    ...  TEST DESCRIPTION
    ...  Attach UE1 to simulated eNB2 NRCELL-1
    ...  Attach UE2 to simulated eNB2 NRCELL-2
    ...  Attach UE3 to simulated eNB2 NRCELL-3
    ...  Attach UE4 to simulated eNB2 NRCELL-4
    ...  Run low traffic on all UEs that do not trigger Load Balancing Power Saving
    ...  Check for cells [1,2,3,4] if energySavingState equals [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ...
    ...  Configure NRPGRP-1 with active time period
    ...  Wait 150s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on all UEs
    ...
    ...  Try to configure NRPGRP-2 with NRCELL-4, lbpsSOMethod = cell switch off
    ...  - system refuse to create NRPGRP-2 because cell is already in use by NRPGRP-1
    ...
    ...  Remove NRCELL-4 from NRPGRP-1.lbpsCellList.nrCellId
    ...  Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ...  Wait 80s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on all UEs
    ...
    ...  Configure NRPGRP-2 with parameters
    ...  - NRPGRP-2.lbpsSOMethod = cell Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [4]
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = current day of the week
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = current hour
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = current minute
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-2.lbpsRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsMaxLoad = 20
    ...  - NRPGRP-2.lbpsMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 10
    ...  - NRPGRP-2.lbpsLastCellMinLoad = 10
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [4]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = False
    ...  - set NRBTS-1.actNrLBPowerSaving to True
    ...
    ...  Wait 80s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    ...  Verify that traffic is present on UEs 1-4
    ...
    ...  Remove NRCELL-3 from NRPGRP-1.lbpsCellList.nrCellId
    ...  Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    ...
    ...  Add NRCELL-3 to NRPGRP-2.lbpsCellList.nrCellId
    ...  Verify that traffic is present on UEs 1-4
    ...  Wait 80s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,energySaving,notEnergySaving]
    ...  Verify that traffic is present on UEs 1-2 and 4
    ...
    ...  Remove NRCELL-2 from NRPGRP-1.lbpsCellList.nrCellId
    ...  Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,energySaving,notEnergySaving]
    ...
    ...  Add NRCELL-2 to NRPGRP-2.lbpsCellList.nrCellId
    ...  Verify that traffic is present on UEs 1-2 and 4
    ...  Wait 150s for cells [1,2,3,4] energySavingState change to [notEnergySaving,energySaving,energySaving,notEnergySaving]
    ...  Verify that traffic is present on UEs 1 and 4
    ...
    ...  Set NRPGRP-2 and NRPGRP-2 lbpsLastCellSOEnabled to True
    ...  Wait 220s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,energySaving,energySaving,energySaving]
    ...  Verify that traffic is present on UE 1
    ...
    ...  Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range xxx - to be check manually during test execution
    ...
    ...  Check RTPM counter: NRCELL-2 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-3 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range xxx - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-4 SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) is in range xxx - to be check manually during test execution
    ...
    ...  Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 4 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-3 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-4 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0 - to be check manually during test execution
    ...
    ...  Check RTPM counter: NRCELL-2 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-3 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1 - to be check manually during test execution
    ...  Check RTPM counter: NRCELL-4 CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) is equal 1 - to be check manually during test execution
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AEQE
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AEQE are massive MIMO cells
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
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 20
    ...  - NRPGRP-1.lbpsRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 10
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2, 3, 4]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = False
    ...
    ...  == POSTCONDITION ==
    ...  All mMIMO cells NRCELL.energySavingState are set to reducedEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: N/A for Exploratory test
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
    ...  [20.07.2023] - Created TC

    # Manual Test Description above
    No operation
