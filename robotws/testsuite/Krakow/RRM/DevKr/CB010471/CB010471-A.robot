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
...         This Test Suite is covering feature part CB010471-A Basic Massive MIMO muting alogrithms.
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
    ...    CONFIGS_Krakow/CB010471/1AQQA_1AEQQ_2AZQU.yaml

Suite Setup     Run Keywords
...             Run setup
...     AND     Enable internal mirroring for alias  gNB2

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_2n78_2n77_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010471/scf_1AQQA_1AEQQ_2AZQU_SANSA.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010471/iphy_1AQQA_1AEQQ_2AZQU_4CELLS.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}

*** Test Cases ***
CB010471-A_1 Activate Load-Based Reduced TX Path Power Saving
    [Tags]    A_1    MANUAL    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  CB010471 is an optional feature whose usage will be controlled by the SW Monitoring function on a per Cell basis.
    ...  This test verifies that after proper configuration of all related parameters and activating feature flag, gNB will reset and
    ...  after that reach onAir state without alarms.
    ...
    ...  TEST DESCRIPTION
    ...  1. Configure NRGRP-0
    ...  - Configure NRPGRP-1 with NRCELL-1 and NRCELL-2
    ...  - Configure NRPGRP-1.lbpsSOMethod to TX Switch Off
    ...  - Configure NRPGRP-1.lbpsCellList.nrCellId to NRCELL-1 and NRCELL-2
    ...
    ...  2. Activate feature CB010471
    ...  - Set NIDD parameter NRBTS-1.actNrLBmMimoRTXPowerSaving is set to True
    ...
    ...  3. Verify activation and gNB behavior
    ...  - Verify that gNB was restarted
    ...  - Verify that all NR cells are on air - ENABLED and UNLOCKED
    ...  - Verify that there are no unexpected alarms
    ...  - Verify that NIDD parameter NRBTS-1.actNrLBmMimoRTXPowerSaving is set to True
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving = False
    ...
    ...  == POSTCONDITION ==
    ...  After gNB restart all cells should reach onAir
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19942;5G_RAN_USR_RRM_19944;5G_RAN_OP_2395;5G_RAN_OP_2399;
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
    ...   - CB010471-3536 USCB010471-A#B1: Activate Load-Based Reduced TX Path Power Saving
    ...   - CB010471-3538 USCB010471-A#B3: Configure Load-Based Reduced TX Path Power Saving Controls
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    # Manual Test Description above
    No operation


CB010471-A_2 Basic switch on-off cell TX paths in NSA mode
    [Tags]    A_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...   This test verifies that gNB switch off or switch on cell TX paths based on nonGBR traffic in NSA mode.  When all conditions for switch off
    ...   are met new beamset with half TXs is used. Cell energySavingState is set to reducedEnergySaving. After increased nonGBR traffic gNB should
    ...   switch beamset back to full 32 TXs and cell energySavingState is set to notEnergySaving.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
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
    ...  - NRPGRP-1.lbpsRTXMaxLoad = 6
    ...  - NRPGRP-1.lbpsRTXMinLoad = 3
    ...  - NRPGRP-1.lbpsLastCellRTXMinLoad = 0
    ...  - NRPGRP-1.lbpsRTXCellCapOffset = 80
    ...  - NRPGRP-1.lbpsPdcchLoadOffset = 4
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  == POSTCONDITION ==
    ...  All mMIMO cells NRCELL.energySavingState are set to notEnergySaving
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19942;5G_RAN_USR_RRM_19944;5G_RAN_USR_RRM_19945;5G_RAN_USR_RRM_19946;5G_RAN_OP_2395;5G_RAN_OP_2399;
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
    ...  - CB010471-3539 USCB010471-A#B4: Power reduction via load based massive MIMO power saving with 16TX path switch off
    ...  - CB010471-3540 USCB010471-A#B5: Power reduction restore via load based massive MIMO power saving with 16TX path switch on
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-A_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE16 to simulated eNB1 CELL-1
    Attach UE17 to simulated eNB1 CELL-1
    Attach UE18 to simulated eNB1 CELL-1
    Attach UE19 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE16 with NRCELL_1 on gNB2
    Trigger SgnbAddition procedure for UE17 with NRCELL_1 on gNB2
    Trigger SgnbAddition procedure for UE18 with NRCELL_2 on gNB2
    Trigger SgnbAddition procedure for UE19 with NRCELL_2 on gNB2
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Configure NRPGRP-1 for CB010471-A_2
    Wait 50s for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsLastCellSOEnabled  True  bts_id=1
    Wait 50s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsLastCellSOEnabled  False  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [reducedEnergySaving,notEnergySaving]

    Run 20Mbps DL traffic on split bearer for UE16 and wait 0 seconds
    Run 20Mbps DL traffic on split bearer for UE17 and wait 0 seconds
    Run 20Mbps DL traffic on split bearer for UE18 and wait 0 seconds
    Run 20Mbps DL traffic on split bearer for UE19 and wait 0 seconds
    Wait for 40s to start traffic and trigger TX path switch on
    Wait 50s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Verify 20Mbps DL traffic on SCG split bearer for UE16
    Verify 20Mbps DL traffic on SCG split bearer for UE17
    Verify 20Mbps DL traffic on SCG split bearer for UE18
    Verify 20Mbps DL traffic on SCG split bearer for UE19

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 110 - 170
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 20 - 60

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1

    [Teardown]  Cleanup after test CB010471-A_2


# In regression covered in CB010471-A_3_4 Switch on-off cells TX path after lbpsSuspended modification and feature deactivation
CB010471-A_3 Feature deactivation when cell is in reducedEnergySaving state
    [Tags]    A_3    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies that when cell is in reducedEnergySaving state and for load balance power saving switch off method set to
    ...  'cell switch off' or feature flag actNrLBmMimoRTXPowerSaving deactivation, gNB shall switch on all TX paths on that cell and change
    ...  that cell energySavingState to notEnergySaving.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [2]
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
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [2]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19943;5G_RAN_OP_2399;
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
    ...  - CB010471-3537 USCB010471-A#B2: Deactivate Load-Based Reduced TX Path Power Saving
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-A_3

    Wait 90s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Attach UE1 to gNB2 CELL1 with ICS during PDU session setup
    Run 20Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds
    Verify 20Mbps DL traffic on UE1 PDU1 QFI1

    Attach UE2 to gNB2 CELL2 with ICS during PDU session setup
    Run 20Mbps DL traffic on UE2 PDU1 QFI1 and wait 2 seconds
    Verify 20Mbps DL traffic on UE2 PDU1 QFI1

    Change eNB parameter value  NRPGRP-1.lbpsSOMethod  cell switch off  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  False  bts_id=1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Verify 20Mbps DL traffic on UE1 PDU1 QFI1
    Verify 20Mbps DL traffic on UE2 PDU1 QFI1

    [Teardown]  Cleanup after test CB010471-A_3


# In regression covered in CB010471-A_3_4 Switch on-off cells TX path after lbpsSuspended modification and feature deactivation
CB010471-A_4 Switch on-off cells TX path after lbpsSuspended modification
    [Tags]    A_4    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies that when in Power Saving Group energy saving is suspended, then all cells with "Energy saving state" set to
    ...  reducedEnergySaving are set to notEnergySaving state immediately. When energy saving is unsuspended, cells can be again set to
    ...  reducedEnergySaving state.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1,2]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [100,100]
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_OP_2395;5G_RAN_USR_RRM_19945;
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
    ...  Alternative scenarios from USCB010471-A#B4 and USCB010471-A#B5:
    ...  - CB008392-7327 USCB008392-A#B18: Suspend Load-Based Reduced TX Paths Power Saving
    ...  - CB008392-7328 USCB008392-A#B19: Un-suspend Load-Based Reduced TX Paths Power Saving
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-A_4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]
    Configure NRPGRP-1 for CB010471-A_4
    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]
    ## Check again energySavingState to verify that PSG is suspended after cell switch timer 30s expires
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
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 90
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 90

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Cleanup after test CB010471-A_4


CB010471-A_5 Interaction with emergency call
    [Tags]    A_5
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies that cell with ongoing emergency call can not be set into reducedEnergySaving state.
    ...  Test verifies that when all cells are configured with lbpsCellSOOrder = 100, then only cells without emergency call are set to
    ...  reducedEnergySaving. Rest of the cells are set to reducedEnergySaving when emergency call is ended.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1, 2]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRCELL-2.actEmergencyCall = True
    ...  - NRCELL-1.emergencyAreaIdList = 1
    ...  - NRCELL-2.emergencyAreaIdList = 2
    ...
    ...  == POSTCONDITION ==
    ...  - All mMIMO cells NRCELL.energySavingState are set to notEnergySaving, emergency call is ended.
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA + NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AQQA, 1x AEQQ, 2x AZQU radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_OP_2395;CB_FIM_37245;
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
    ...  - CB010471-3681 CB010471 Interacts with 5GC000784, 5GC000784: Emergency calls handling in SA mode
    ...  CB010471 functionality shall select a cell for power saving TX switch-off it will check if selected cell has an Emergency Session ongoing.
    ...  If that cell has an Emergency Session ongoing CB010471 functionality shall not switch half TXs off for power saving reasons and the
    ...  algorithm of selection will be repeated next time from the starting point.
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-A_5

    Attach UEs[1,2] to gNB2 cell1 with ICS during PDU session setup
    Run 150Mbps DL traffic on UEs[1,2] PDU1 QFI1 and wait 10 seconds
    Wait 60s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

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
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 170 - 240
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 130

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Cleanup after test CB010471-A_5


CB010471-A_6 Interaction with CB008745
    [Tags]    A_6    MANUAL    SKIPRUN
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies that when CB010471 and CB008745 are both enabled at the same time and lbpsSOMethod is set to TX switch off,
    ...  CB008745 takes no effect.
    ...
    ...  TEST DESCRIPTION
    ...  1. UEs are attached to NRCELL-1 and NRCELL-2, start GBR traffic on all UEs
    ...  2. Check that NRCELL-1 uses legacy calculation for GBR traffic load which is set to 0 and non-GBR traffic load which contains both GBR
    ...  and non-GBR traffic load besides adding special handling for Mu MIMO. Check load calculations in syslogs.
    ...  3. Check that NRCELL-2 uses new calculation for GBR traffic load and PRB based non-GBR traffic load separately, and additionally add category
    ...  based normalized non-GBR traffic load. Check load calculations in syslogs.
    ...  4. Set NRPGRP-2.lbpsSOMethod = cell Switch Off and NRPGRP-2.lbpsSOMethod = TX Switch Off (one NRPGRP must be TX switch off)
    ...  5. Check that NRCELL-1 uses new calculation for GBR traffic load and PRB based non-GBR traffic load separately, and additionally add category
    ...  based normalized non-GBR traffic load. Check load calculations in syslogs.
    ...  6. Check that NRCELL-2 uses legacy calculation for GBR traffic load which is set to 0 and non-GBR traffic load which contains both GBR
    ...  and non-GBR traffic load besides adding special handling for Mu MIMO. Check load calculations in syslogs.
    ...  7. Set NRPGRP-2.lbpsSOMethod = TX Switch Off and NRPGRP-2.lbpsSOMethod = cell Switch Off (one NRPGRP must be cell switch off)
    ...  8. Check that NRCELL-1 uses legacy calculation for GBR traffic load which is set to 0 and non-GBR traffic load which contains both GBR
    ...  and non-GBR traffic load besides adding special handling for Mu MIMO. Check load calculations in syslogs.
    ...  9. Check that NRCELL-2 uses new calculation for GBR traffic load and PRB based non-GBR traffic load separately, and additionally add category
    ...  based normalized non-GBR traffic load. Check load calculations in syslogs.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
    ...  - NRBTS-1.actLbpsCtrlLogicEnh = True
    ...  - NRBTS-1.actNrLBPowerSaving = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...  - NRPGRP-1.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-1.lbpsSOnTrRule = MinValueMethod
    ...  - NRPGRP-1.lbpsLoadCalcMethod = Max(G, C, P)
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = cell Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [2]
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
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [2]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = False
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
    ...  - NRPGRP-2.lbpsSOffTrRule = MaxValueMethod
    ...  - NRPGRP-2.lbpsSOnTrRule = MinValueMethod
    ...  - NRPGRP-2.lbpsLoadCalcMethod = Max(G, C, P)
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_OP_2395;CB_FIM_37245;
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
    ...  - CB008745-7492 CB010471 Interacts with CB008745: 4G/5G Cell Switch OFF & 4G MIMO Muting Responsiveness Improvements
    ...  CB010471 reuse legacy calculation for GBR traffic load which is set to 0 and non-GBR traffic load which contains both GBR
    ...  and non-GBR traffic load besides adding special handling for Mu MIMO.
    ...  CB008745 introduce new calculation for GBR traffic load and PRB based non-GBR traffic load separately, and additionally add category
    ...  based normalized non-GBR traffic load.
    ...  When CB010471 and CB008745 are both enabled at the same time and lbpsSOMethod is set to TX switch off, CB008745 takes no effect.
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    # Manual Test Description above
    No Operation


CB010471-A_7 Cell failed due to cell level alarm
    [Tags]    A_7
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies that when one of the cells in power group becomes failed, the rest of cells in the same power group
    ...  with energy saving state set to reducedEnergy should switch on TX paths and change state to notEnergySaving.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19945;5G_RAN_USR_RRM_19946
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
    ...  Alternative scenarios from USCB008133-A#B4 and USCB008133-A#B5:
    ...  - CB008392-13004 USCB008392-A#B17: Handle Cell or TX Path Outage Impact on Capacity
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-A_7

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Configure NRPGRP-1 for CB010471-A_7
    Wait 60s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRCELL-1.gscnOrSsPbchArfcn  11  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]
    ## Check again energySavingState to verify that NRCELL-2 not enter reducedEnergySavingState
    Wait for 50s to trigger TX path switch off
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Change eNB parameter value  NRCELL-1.gscnOrSsPbchArfcn  7880  bts_id=1
    # needed to clear alarm on NRCELL-1
    Lock NRCELL-1
    Wait 40s for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]

    Unlock NRCELL-1
    Wait for 20s to trigger TX path switch off
    Wait 40s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,notEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 50 - 90
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 110 - 170

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 2

    [Teardown]  Cleanup after test CB010471-A_7


# Optimization of tests for Regression:
#CB010471-A_3 Feature deactivation when cell is in reducedEnergySaving state
#CB010471-A_4 Switch on-off cells TX path after lbpsSuspended modification
CB010471-A_3_4 Switch on-off cells TX path after lbpsSuspended modification and feature deactivation
    [Tags]    A_3_4
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  This test verifies that when in Power Saving Group energy saving is suspended, then all cells with "Energy saving state" set to
    ...  reducedEnergySaving are set to notEnergySaving state immediately. When energy saving is unsuspended, cells can be again set to
    ...  reducedEnergySaving state. Then when cell is in reducedEnergySaving state and for load balance power saving switch off method set to
    ...  'cell switch off' on first cell and feature flag actNrLBmMimoRTXPowerSaving deactivation on second cell, gNB shall switch on all TX paths
    ...  on and change that cells energySavingState to notEnergySaving.
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AQQA, 1x AEQQ, 2x AZQU
    ...  - NRCELL-1 on AQQA and NRCELL-2 on AEQQ are massive MIMO cells
    ...  - NRCELL-3 and NRCELL-4 both on AZQU are non massive MIMO cells
    ...  - eNB1 - simulated
    ...  - NR cells are up and connected to AMF1
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA + NSA mode
    ...  - gNB2 up and running with four SA + NSA cells
    ...  - NRCELL-1.actBeamforming = True
    ...  - NRCELL-2.actBeamforming = True
    ...  - NRBTS-1.actMicroDTX = True
    ...  - NRBTS-1.actNrLBmMimoRTXPowerSaving  = True
    ...
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-1.lbpsCellList.nrCellId = [1]
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
    ...  - NRPGRP-1.lbpsCellList.lbpsCellSOOrder = [1]
    ...  - NRPGRP-1.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-1.lbpsPeriodList.lbpsSuspended = notSuspended
    ...
    ...  - NRPGRP-2 is created
    ...  - NRPGRP-2.lbpsSOMethod = TX Switch Off
    ...  - NRPGRP-2.lbpsCellList.nrCellId = [2]
    ...  - Time window is set according to current time
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
    ...  - NRPGRP-2.lbpsCellList.lbpsCellSOOrder = [2]
    ...  - NRPGRP-2.lbpsLastCellSOEnabled = True
    ...  - NRPGRP-2.lbpsPeriodList.lbpsSuspended = notSuspended
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19943;5G_RAN_OP_2399;5G_RAN_OP_2395;5G_RAN_USR_RRM_19945;
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
    ...  - CB010471-3537 USCB010471-A#B2: Deactivate Load-Based Reduced TX Path Power Saving
    ...  Alternative scenarios from USCB010471-A#B4 and USCB010471-A#B5:
    ...  - CB008392-7327 USCB008392-A#B18: Suspend Load-Based Reduced TX Paths Power Saving
    ...  - CB008392-7328 USCB008392-A#B19: Un-suspend Load-Based Reduced TX Paths Power Saving
    ...
    ...  == HISTORY ==
    ...  [20.04.2023] - Created TC
    ...  [08.05.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=883964)
    ...  [08.05.2023] - Review closed

    [Setup]  Prepare test environment CB010471-A_3

    Wait 90s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  suspended  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]
    ## Check again energySavingState to verify that PSG is suspended after cell switch timer 30s expires
    Wait for 40s to trigger TX path switch off
    Check for cells [1,2] if energySavingState equals [notEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsPeriodList.lbpsSuspended  notSuspended  bts_id=1
    Wait for 40s to trigger TX path switch off
    Wait 10s for cells [1,2] energySavingState change to [reducedEnergySaving,reducedEnergySaving]

    Attach UE1 to gNB2 CELL1 with ICS during PDU session setup
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds
    Verify 10Mbps DL traffic on UE1 PDU1 QFI1

    Attach UE2 to gNB2 CELL2 with ICS during PDU session setup
    Run 10Mbps DL traffic on UE2 PDU1 QFI1 and wait 2 seconds
    Verify 10Mbps DL traffic on UE2 PDU1 QFI1

    Check for cells [1,2] if energySavingState equals [reducedEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRPGRP-1.lbpsSOMethod  cell switch off  bts_id=1
    Wait 10s for cells [1,2] energySavingState change to [notEnergySaving,reducedEnergySaving]

    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  False  bts_id=1
    Check for cells [1,2] if energySavingState equals [notEnergySaving,notEnergySaving]

    Verify 10Mbps DL traffic on UE1 PDU1 QFI1
    Verify 10Mbps DL traffic on UE2 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 80 - 160
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_SAMPLES (M55601C02002) is in range 240 - 320

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Check RTPM counter: NRCELL-1 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 1
    ...                 Check RTPM counter: NRCELL-2 NR_CELL_RTX_PWR_SAVING_CHNG_TO (M55601C02001) is equal 0

    [Teardown]  Cleanup after test CB010471-A_3
