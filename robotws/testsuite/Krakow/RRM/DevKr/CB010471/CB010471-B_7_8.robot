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
...         This Test Plan is covering feature part CB010471-B Feature interworking.
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
...         [20.04.2023] - Created TC
...         [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
...         [08.05.2023] - Review closed

Resource    resources/CB010471-common_keywords.robot
Resource    resources/CB010471_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB010471/1AQQA_1AEQQ_2AEQE.yaml

Suite Setup     Run setup
Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010471/scf_1AQQA_1AEQQ_2AEQE_SANSA.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010471/iphy_1AQQA_1AEQQ_2AEQE_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}

*** Test Cases ***
CB010471-B_7 Interworking with CB008133 - 64TX cell and 32TX cell in the same PSG
    [Tags]    B_7
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  Test verifies that when operator activates both CB010471 and CB008133 at the same gNB and when both features are activated,
    ...  massive MIMO cell with 64TRX and massive MIMO cell with 32TRX is configured in the same PSG. Power saving at massive MIMO cells
    ...  with 64TRX are controlled by CB008133 while power saving at massive MIMO cells with 32TRX are controlled by CB010471.
    ...  Both CB010471 and CB008133 works simultaneously muting both massive MIMO cells with 64TRX and with 32TRX in the same PSG.
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
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving = True
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
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100, 100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  == POSTCONDITION ==
    ...  - All mMIMO cells NRCELL.energySavingState are set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19967;CB_FIM_37256;
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
    ...  - CB010471-3557 USCB010471-B#B12: interworking with CB008133
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-B_7

    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds

    Set lbpsCellSOOrder in NRPGRP-1 to [1,3,2,4] for cells [1,2,3,4]
    Wait 10s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,notEnergySaving,reducedEnergySaving,notEnergySaving]

    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,notEnergySaving]

    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL3 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds

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

    [Teardown]  Cleanup after test CB010471-B_7


CB010471-B_8 Interworking with CB008133 - 64TX cell and 32TX cell in the different PSGs
    [Tags]    B_8
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  Test verifies that when operator activates both CB010471 and CB008133 at the same gNB and both features are activated,
    ...  massive MIMO cell with 64TRX and massive MIMO cell with 32TRX is configured in the different PSGs. Power saving at 32TRX massive MIMO cells
    ...  within a power group are controlled by CB010471 while power saving at 64TRX massive MIMO cells within another power group are controlled
    ...  by CB008133. Both CB010471 and CB008133 works simultaneously muting both massive MIMO cells with 64TRX and with 32TRX in the different PSGs.
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
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1, 2]
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDayOfWeek = current day of the week
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeHour = current hour
    ...  - NRPGRP-1.lbpsPeriodList.lbpsStartTimeMinute = current minute
    ...  - NRPGRP-1.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-1.lbpsRTXSOffTime = 30
    ...  - NRPGRP-1.lbpsRTXSOnTime = 30
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-1.lbpsRTXMinLoad = 5
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [3, 4]
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDayOfWeek = current day of the week
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeHour = current hour
    ...  - NRPGRP-2.lbpsPeriodList.lbpsStartTimeMinute = current minute
    ...  - NRPGRP-2.lbpsPeriodList.lbpsDuration = 1440
    ...  - NRPGRP-2.lbpsRTXSOffTime = 30
    ...  - NRPGRP-2.lbpsRTXSOnTime = 30
    ...  - NRPGRP-2.lbpsRTXMaxLoad = 10
    ...  - NRPGRP-2.lbpsRTXMinLoad = 5
    ...  - NRPGRP-2.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-2.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-2.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [100, 100]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  == POSTCONDITION ==
    ...  The gNB shall switch on all TX paths of all cells in PSG that is updated which energySavingState = reducedEnergySaving
    ...  and change the energySavingState = NotEnergySaving.
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19968;CB_FIM_37256;
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
    ...  - CB010471-3558 USCB010471-B#B13: interworking with CB008133
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-B_8

    # Wait until configuration is finished due to adding cells NRCELL-3 and NRCELL-4 to new power group NRPGRP-2 with TX Switch Off method
    Wait 20s for cells [1,2,3,4] operationalState change to [enabled,enabled,enabled,enabled]

    Attach UEs[1,2] to gNB2 CELL1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Attach UEs[3,4] to gNB2 CELL3 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds
    Wait 60s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Stop 150Mbps DL traffic on UEs[1,2] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]
    # Wait longer to check that NRPGRP-2 is not affected
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2,3,4] if energySavingState equals [reducedEnergySaving,reducedEnergySaving,notEnergySaving,notEnergySaving]

    Stop 150Mbps DL traffic on UEs[3,4] PDU1 QFI1
    Wait for 40s to trigger TX path switch off
    Wait 20s for cells [1,2,3,4] energySavingState change to [reducedEnergySaving,reducedEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 0 seconds
    Wait for 40s to trigger TX path switch on
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,reducedEnergySaving,reducedEnergySaving]

    Run 150Mbps DL traffic on UEs[3,4] PDU1 QFI1 and wait 0 seconds
    Wait for 40s to trigger TX path switch on
    Wait 20s for cells [1,2,3,4] energySavingState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

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

    [Teardown]  Cleanup after test CB010471-B_8
