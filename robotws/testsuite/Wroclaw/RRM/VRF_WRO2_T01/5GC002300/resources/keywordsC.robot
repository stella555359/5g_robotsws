*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords for 5GC002300
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.py
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.collectors.pmcounters  WITH NAME  pm
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.ue
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
Resource        testsuite/Wroclaw/RRM/resources/connections.robot
Library         taf.hw.rf_attenuator    WITH NAME    att
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot


*** Variables ***
@{lines_cell2_5G}       5    6    7    8
@{lines_cell3_5G}       9    10   11   12


*** Keywords ***
Perform commissioning 5GC002300C for 21B/trunk
    [Arguments]         ${actEirpControl}
    ...                 ${pMax}
    ...                 ${ssPbchBlockPower}
    ...                 ${chBwDl}
    ...                 ${chBwUl}
    ...                 ${type0CoresetConfigurationIndex}
    ...                 ${miNrEirp}
    ...                 ${ssBurstSetPeriod}
    ...                 ${csirsTrackingPeriod}
    ...                 ${eirpControlTimeAveragingWindow}
    ...                 ${eirpControlPowerReductionFactorList}
    ...                 ${eirpControlTimeAveragingWindowStepSize}
    ...                 ${externalAntennaGain}
    ...                 ${minGuaranteedBudgetRatio}=50
    ...                 ${antennaMechanicalDowntilt}=0
    ...                 ${startRB}=0
    ...                 ${scramblingIdStep}=3
    ...                 ${csiReportPeriodicity}=slots160

    Log to console      __Perform commissioning with given parameters.
    &{csirsForTracking}  Create dictionary  csirsTrackingPeriod=${csirsTrackingPeriod}   rbAllocation=BWP
    ...                                     startRB=${startRB}
    &{periodicCsiAcquisition}    create dictionary    csiReportPeriodicity=${csiReportPeriodicity}
    ...                                               scramblingIdStep=${scramblingIdStep}

    &{eirpControl}       Create dictionary  minSignificantNormalizedBeamGain=-20
    ...                                     numOfSegmentAzimuthEdges=0
    ...                                     numOfSegmentElevationEdges=0
    ...                                     minGuaranteedBudgetRatio=${minGuaranteedBudgetRatio}
    ...                                     minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...                                     schedulWeightFactorEnabled=true
    ${eirpControlPowerReductionFactorList}    Create list    ${eirpControlPowerReductionFactorList}
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    ${first_cell_id}    Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    remove values from list    ${cell_dists}    ${cell_dists[1]}
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists[:3]}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}      type0CoresetConfigurationIndex    value=${type0CoresetConfigurationIndex}
        Add list parameters to delta   ${cell_path}        periodicCsiAcquisition        &{periodicCsiAcquisition}
    END

    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindow
    ...                                                           value=${eirpControlTimeAveragingWindow}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    actEirpControl        value=${actEirpControl}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    pMax                  value=${pMax}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindowStepSize
    ...                                                           value=${eirpControlTimeAveragingWindowStepSize}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    externalAntennaGain   value=${externalAntennaGain}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    ssPbchBlockPower      value=${ssPbchBlockPower}
    Add param to delta  ${object_path}/NRPMRNL-1                  miNrEirp              value=${miNrEirp}
    Add param to delta  ${object_path}/NRCELLGRP-0                ssBurstSetPeriod      value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    antennaMechanicalDowntilt   value=${antennaMechanicalDowntilt}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlPowerReductionFactorList
    ...                                                           ${eirpControlPowerReductionFactorList}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      csirsForTracking      &{csirsForTracking}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      eirpControl           &{eirpControl}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    600 sec    15 sec    Verify all cells are onair with admin

Perform commissioning 5GC002300C __23r3
    [Arguments]         ${actEirpControl}
    ...                 ${pMax}
    ...                 ${ssPbchBlockPower}
    ...                 ${chBwDl}
    ...                 ${chBwUl}
    ...                 ${type0CoresetConfigurationIndex}
    ...                 ${miNrEirp}
    ...                 ${ssBurstSetPeriod}
    ...                 ${csirsTrackingPeriod}
    ...                 ${eirpControlTimeAveragingWindow}
    ...                 ${eirpControlPowerReductionFactorList}
    ...                 ${eirpControlTimeAveragingWindowStepSize}
    ...                 ${externalAntennaGain}
    ...                 ${minGuaranteedBudgetRatio}=50
    ...                 ${antennaMechanicalDowntilt}=0
    Log to console      __Perform commissioning with given parameters.
    &{csirsForTracking}  Create dictionary
    ...    csirsTrackingPeriod=${csirsTrackingPeriod}
    ...    rbAllocation=BWP
    ...    startRB=0
    &{eirpControl}       Create dictionary  minSignificantNormalizedBeamGain=-20
    ...                                     numOfSegmentAzimuthEdges=0
    ...                                     numOfSegmentElevationEdges=0
    ...                                     minGuaranteedBudgetRatio=${minGuaranteedBudgetRatio}
    ...                                     minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...                                     schedulWeightFactorEnabled=false
    ${eirpControlPowerReductionFactorList}    Create list    ${eirpControlPowerReductionFactorList}
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    ${first_cell_id}    Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}      type0CoresetConfigurationIndex    value=${type0CoresetConfigurationIndex}
    END

    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindow
    ...                                                           value=${eirpControlTimeAveragingWindow}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    actEirpControl        value=${actEirpControl}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    pMax                  value=${pMax}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindowStepSize
    ...                                                           value=${eirpControlTimeAveragingWindowStepSize}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    externalAntennaGain   value=${externalAntennaGain}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    ssPbchBlockPower      value=${ssPbchBlockPower}
    Add param to delta  ${object_path}/NRPMRNL-1                  miNrEirp              value=${miNrEirp}
    Add param to delta  ${object_path}/NRCELLGRP-0                ssBurstSetPeriod      value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    antennaMechanicalDowntilt   value=${antennaMechanicalDowntilt}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlPowerReductionFactorList
    ...                                                           ${eirpControlPowerReductionFactorList}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      csirsForTracking      &{csirsForTracking}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      eirpControl           &{eirpControl}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    600 sec    15 sec    Verify all cells are onair with admin


Check power with actEirpControl
    [Arguments]    ${value}   ${actEirpControl}   ${pmax}
    ${res} =   Evaluate    abs(${pmax}-${actEirpControl})
    Should Be Equal As Numbers   ${res}   ${value}   precision=0

RU cell power
    [Arguments]   ${ant1}   ${ant2}
    ${ant2_tx_power_mw}     Convert dbm To mW  ${ant1}
    ${ant4_tx_power_mw}     Convert dbm To mW  ${ant2}
    ${cell_power_mw}    Evaluate  ${ant2_tx_power_mw}+${ant4_tx_power_mw}
    ${ru_cell_power_dbm}    Convert mw to dbm  ${cell_power_mw}
    [Return]   ${ru_cell_power_dbm}

Turn attenuation on cell 2 and 3
    Set attenuation and check    lines=${lines_cell2_5G}    value=90
    Set attenuation and check    lines=${lines_cell3_5G}    value=90

Check if power values are in range
    [Arguments]         ${first}
    ...                 ${second}
    ...                 ${margin_of_error}
    Check if values are within the margin of error
    ...                 ${first}
    ...                 ${second}
    ...                 ${margin_of_error}

Check M55324C00301/3000=32
    [Arguments]     ${bottom}   ${top}
    ${pmcounter}      Count power value from given samples  3000  ${M55324C00301}
    ${is_in_range}    Is in interval   ${pmcounter}   ${bottom}   ${top}
    Run keyword if      ${is_in_range}
    ...                 Log to console  __Test passed: Power values of EIRP_CONTROL_SEGMENT are betwnen ${bottom} ${top} range.
    ...                 ELSE  Fail  msg=Power values of EIRP_CONTROL_SEGMENT are not in margin error.

Check M55324C00601=M55324C00101/M55324C00000[dBm]=M55324C00701/M55324C00000[dBm]=Pmax
    [Arguments]   ${pmax}
    Log to console      ${pmax}
    ${pmcounter_power_dbm_701}     Get power value from counter   ${M55324C00701}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_701}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_701}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

    ${pmcounter_power_dbm_101}     Get power value from counter   ${M55324C00101}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_101}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_101}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

    ${pmcounter_power_dbm_601}     Convert mW To dbm   ${M55324C00601}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_601}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_601}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

Check M55324C00800=M55324C00501[dBm]  # this is equal to  pmax + 3dBm (for second TX) - PRF = 44,8 + 3 - 3 = 44.8dBm
    [Arguments]   ${pmax}
    Log to console      ${pmax}
    ${pmcounter_power_dbm_800}     Convert mW To dbm   ${M55324C00800}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_800}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_800}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

    ${pmcounter_power_dbm_501}     Convert mW To dbm   ${M55324C00501}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_501}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_501}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

Check M55324C00201[dBm]   # pmax + 3dBm (for second TX) - extrapolation factor (which is ~ 1dB) = 44,8 + 3 - 1 = 46.8dBm
    [Arguments]   ${pmax}  #46.8
    Log to console      ${pmax}
    ${pmcounter_power_dbm_201}     Convert mW To dbm   ${M55324C00201}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_201}   49.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_201}   29.8    3
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

Check M55324C00400/M55324C00000[dBm]=M55324C00464/M55324C00000[dBm]=M55324C00802/M55324C00000[dBm]=M55324C00801
    [Arguments]  ${pmax}   #RU Power TX1 + RU Power TX2 +/- 0,2 dBm = 44,8 [dBm]
    Log to console      ${pmax}
    ${pmcounter_power_dbm_801}     Convert mW To dbm   ${M55324C00801}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_801}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_801}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

    ${pmcounter_power_dbm_400}     Get power value from counter  ${M55324C00400}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_400}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_400}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

    ${pmcounter_power_dbm_464}     Get power value from counter  ${M55324C00464}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_464}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_464}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

    ${pmcounter_power_dbm_802}     Get power value from counter  ${M55324C00802}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_802}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_802}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'


#2300H
Perform commissioning 5GC002300H for 21B/trunk
    [Arguments]         ${actEirpControl}
    ...                 ${pMax}
    ...                 ${ssPbchBlockPower}
    ...                 ${chBwDl}
    ...                 ${chBwUl}
    ...                 ${miNrEirp}
    ...                 ${ssBurstSetPeriod}
    ...                 ${csirsTrackingPeriod}
    ...                 ${eirpControlTimeAveragingWindow}
    ...                 ${eirpControlPowerReductionFactorList}
    ...                 ${eirpControlTimeAveragingWindowStepSize}
    ...                 ${actFdmScheduling}
    ...                 ${actFdmEnhancedScheduling}
    ...                 ${targetTotalLoad}
    ...                 ${type0CoresetConfigurationIndex}
    ...                 ${minGuaranteedBudgetRatio}
    ...                 ${externalAntennaGain}=0
    ...                 ${antennaMechanicalDowntilt}=0
    ...                 ${startRB}=0

    Log to console      __Perform commissioning with given parameters.
    &{csirsForTracking}  Create dictionary
    ...    csirsTrackingPeriod=${csirsTrackingPeriod}
    ...    rbAllocation=BWP
    ...    startRB=${startRB}
    &{eirpControl}       Create dictionary  minSignificantNormalizedBeamGain=-20
    ...                                     numOfSegmentAzimuthEdges=0
    ...                                     numOfSegmentElevationEdges=0
    ...                                     minGuaranteedBudgetRatio=${minGuaranteedBudgetRatio}
    ...                                     minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...                                     schedulWeightFactorEnabled=true
    ${eirpControlPowerReductionFactorList}    Create list    ${eirpControlPowerReductionFactorList}
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    ${first_cell_id}    Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    remove values from list    ${cell_dists}    ${cell_dists[1]}
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists[:3]}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}        type0CoresetConfigurationIndex         value=${type0CoresetConfigurationIndex}
    END
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}                actEirpControl                       value=${actEirpControl}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}               pMax                                 value=${pMax}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}             targetTotalLoad                 value=${targetTotalLoad}
    Add param to delta  ${object_path}                         actFdmScheduling                     value=${actFdmScheduling}
    Add param to delta  ${object_path}                         actFdmEnhancedScheduling                  value=${actFdmEnhancedScheduling}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}                ssPbchBlockPower                     value=${ssPbchBlockPower}
    Add param to delta  ${object_path}/NRPMRNL-1               miNrEirp                             value=${miNrEirp}
    Add param to delta  ${object_path}/NRCELLGRP-0             ssBurstSetPeriod                     value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    externalAntennaGain   value=${externalAntennaGain}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    antennaMechanicalDowntilt   value=${antennaMechanicalDowntilt}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}        eirpControlPowerReductionFactorList  ${eirpControlPowerReductionFactorList}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindow
    ...                                                           value=${eirpControlTimeAveragingWindow}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindowStepSize
    ...                                                           value=${eirpControlTimeAveragingWindowStepSize}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      csirsForTracking                     &{csirsForTracking}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      eirpControl                          &{eirpControl}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    600 sec    15 sec    Verify all cells are onair with admin

Perform commissioning 5GC002300H __23r3
    [Arguments]         ${actEirpControl}
    ...                 ${pMax}
    ...                 ${ssPbchBlockPower}
    ...                 ${chBwDl}
    ...                 ${chBwUl}
    ...                 ${miNrEirp}
    ...                 ${ssBurstSetPeriod}
    ...                 ${csirsTrackingPeriod}
    ...                 ${eirpControlTimeAveragingWindow}
    ...                 ${eirpControlPowerReductionFactorList}
    ...                 ${eirpControlTimeAveragingWindowStepSize}
    ...                 ${actFdmScheduling}
    ...                 ${actFdmEnhancedScheduling}
    ...                 ${targetTotalLoad}
    ...                 ${type0CoresetConfigurationIndex}
    ...                 ${minGuaranteedBudgetRatio}
    ...                 ${externalAntennaGain}=0
    ...                 ${antennaMechanicalDowntilt}=0
    Log to console      __Perform commissioning with given parameters.
    &{csirsForTracking}  Create dictionary
    ...    csirsTrackingPeriod=${csirsTrackingPeriod}
    ...    rbAllocation=BWP
    ...    startRB=0
    &{eirpControl}       Create dictionary  minSignificantNormalizedBeamGain=-20
    ...                                     numOfSegmentAzimuthEdges=0
    ...                                     numOfSegmentElevationEdges=0
    ...                                     minGuaranteedBudgetRatio=${minGuaranteedBudgetRatio}
    ...                                     minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...                                     schedulWeightFactorEnabled=false
    ${eirpControlPowerReductionFactorList}    Create list    ${eirpControlPowerReductionFactorList}
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    ${first_cell_id}    Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}        type0CoresetConfigurationIndex         value=${type0CoresetConfigurationIndex}
    END
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}                actEirpControl                       value=${actEirpControl}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}               pMax                                 value=${pMax}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}             targetTotalLoad                 value=${targetTotalLoad}
    Add param to delta  ${object_path}                         actFdmScheduling                     value=${actFdmScheduling}
    Add param to delta  ${object_path}                         actFdmEnhancedScheduling                  value=${actFdmEnhancedScheduling}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}                ssPbchBlockPower                     value=${ssPbchBlockPower}
    Add param to delta  ${object_path}/NRPMRNL-1               miNrEirp                             value=${miNrEirp}
    Add param to delta  ${object_path}/NRCELLGRP-0             ssBurstSetPeriod                     value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    externalAntennaGain   value=${externalAntennaGain}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    antennaMechanicalDowntilt   value=${antennaMechanicalDowntilt}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}        eirpControlPowerReductionFactorList  ${eirpControlPowerReductionFactorList}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindow
    ...                                                           value=${eirpControlTimeAveragingWindow}
    Add param to delta  ${object_path}/NRCELL-${first_cell_id}    eirpControlTimeAveragingWindowStepSize
    ...                                                           value=${eirpControlTimeAveragingWindowStepSize}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      csirsForTracking                     &{csirsForTracking}
    Add list parameters to delta  ${object_path}/NRCELL-${first_cell_id}      eirpControl                          &{eirpControl}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    600 sec    15 sec    Verify all cells are onair with admin

Check M55324C00400/M55324C00000[dBm]
    [Arguments]    ${pmax}
    Log to console      ${pmax}
    ${pmcounter_power_dbm_400}  Get power value from counter  ${M55324C00400}
    ${a}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_400}   47.8    2
    ${b}  run keyword and ignore error    Check if power values are in range     ${pmcounter_power_dbm_400}   29.8    2
    should be true    '${a[0]}' or '${b[0]}'=='PASS'

Check M55308C10001
    ${bool} =   Set variable if    0 < ${M55308C10001}    ${TRUE}    ${FALSE}
    Run keyword if      ${bool}
    ...                 Log to console  __M55308C10001 > 0
    ...                 ELSE  Fail  msg=M55308C10001 = 0

Check M55308C00001=M55308C00007   #+M55324C00301
    ${bool} =   Set variable if    ${M55324C00301} > 0 and ${M55308C00001} > 0 and ${M55308C00007} > 0    ${TRUE}    ${FALSE}
    Run keyword if      ${bool}
    ...                 Log to console  __Counter value is acceptable
    ...                 ELSE  Fail  msg=Counter value is not acceptable

Check if M55324C00301>0 and M55308C00001>0    #counter M55308C00007>0 should be checked also if Artificial Load is ON
    ${bool} =   Set variable if    ${M55324C00301} > 0 and ${M55308C00001} > 0    ${TRUE}    ${FALSE}
    Run keyword if      ${bool}
    ...                 Log to console  __Counter value is acceptable
    ...                 ELSE  Fail  msg=Counter value is not acceptable

#for 5GC002052
Check if M55308C10001 is 0
    ${bool} =   Set variable if    0 = ${M55308C10001}    ${TRUE}    ${FALSE}
    Run keyword if      ${bool}
    ...                 Log to console  __M55308C10001 is equal to 0
    ...                 ELSE  Fail  msg=M55308C10001 is not qual to 0

Start DL data transfer
    [Arguments]    ${throughput}=150 Mbits/sec   ${dt_name}=DT_1   ${ue_alias}=AT_BASED_UE_1   ${min_tput}=80
    ...        ${direction}=dl  ${duration}=60s   ${protocol}=udp   ${packet_size}=1400  ${deviation}=50%
    taf.ue.Start Data Transfer
    ...     dt_name=${dt_name}
    ...     ue_alias=${ue_alias}
    ...     direction=${direction}
    ...     duration=${duration}
    ...     throughput=${throughput}
    ...     protocol=${protocol}
    ...     packet_size=${packet_size}
    Await Data Transfer Finish    ${dt_name}
    Verify Average Throughput With Deviation   ${dt_name}   ${throughput}   ${deviation}
    Verify Average Throughput    ${dt_name}    ${min_tput} Mbits/sec
