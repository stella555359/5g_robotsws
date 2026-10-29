*** Settings ***
Documentation
...  author:
...  contact:

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.py
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.collectors.pmcounters  WITH NAME  pm
Library         testsuite.Wroclaw.RRM.resources.webui.WebuiInterface  WITH NAME  WebUI
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.ue
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
Resource        testsuite/Wroclaw/RRM/resources/connections.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_1329.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot


*** Keywords ***
Perform commissioning 5GC002052
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
    ...                 ${aggregationLevel}

    Log to console      __Perform commissioning with given parameters.
    ${sw_version}    Get sw version
    &{csirsForTracking}  Create dictionary  csirsTrackingPeriod=${csirsTrackingPeriod}
        &{eirpControl}       Create dictionary  eirpControlTimeAveragingWindow=${eirpControlTimeAveragingWindow}
    ...                                     minSignificantNormalizedBeamGain=-20
    ...                                     numOfSegmentAzimuthEdges=0
    ...                                     numOfSegmentElevationEdges=0
    ...                                     minGuaranteedBudgetRatio=5
    ...                                     minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...                                     schedulWeightFactorEnabled=false
    ${eirpControlPowerReductionFactorList}    Create list    ${eirpControlPowerReductionFactorList}
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    ${cell_dists}       Get cells distname list
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}          type0CoresetConfigurationIndex       value=${type0CoresetConfigurationIndex}
    END
    Add param to delta  ${object_path}/NRCELL-1                actEirpControl                       value=${actEirpControl}
    Add param to delta  ${object_path}/NRCELL-1                pMax                                 value=${pMax}
    Add param to delta  ${object_path}/NRCELL-1                ssPbchBlockPower                     value=${ssPbchBlockPower}
    Add param to delta  ${object_path}/NRPMRNL-1               miNrEirp                             value=${miNrEirp}
    Add param to delta  ${object_path}/NRCELLGRP-0             ssBurstSetPeriod                     value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}/NRCELL-1                eirpControlPowerReductionFactorList  ${eirpControlPowerReductionFactorList}
    Add list parameters to delta  ${object_path}/NRCELL-1      csirsForTracking                     &{csirsForTracking}
    Add list parameters to delta  ${object_path}/NRCELL-1      eirpControl                          &{eirpControl}
    Add param to delta  ${object_path}/NRCELL-1                aggregationLevel                     value=${aggregationLevel}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    600 sec    30 sec    Verify all cells are onair with admin

Get sw version
    Connect with runtime release    coam
    ${version}    coam.Get sw version    connection=coam
    ${version}    Get substring    ${version}    2    4
    [Return]    ${version}
    [Teardown]    coam.Teardown    connection=coam

Require cell and ue
    [Arguments]  ${ue_alias}=UE_1
    Require ue   ${ue_alias}   capabilities=REAL_QUALCOMM_UE
    Require cell    ENB_1_CELL_1    40050   1

Data transfer
    [Arguments]   ${ue_alias}=UE_1
    ...           ${direction}=DL
    ...           ${duration}=20s
    ...           ${throughput}=300Mbits/sec
    ...           ${protocol}=udp
    ...           ${data_alias}=DT_1
    Start Data Transfer
    ...     dt_name=${data_alias}
    ...     ue_alias=${ue_alias}
    ...     direction=${direction}
    ...     duration=${duration}
    ...     throughput=${throughput}
    ...     protocol=${protocol}
    Sleep  30sec
    Stop Data Transfer    ${data_alias}


Check power with actEirpControl
    [Arguments]    ${value1}     ${margin_of_error}  ${actEirpControl}
        ${result} =   Evaluate    abs(${pmax}-${actEirpControl}-${value1})
        ${bool} =   Set variable if    ${result} >= ${margin_of_error}    ${TRUE}    ${FALSE}
        Run keyword if      ${bool}
        ...                 Log to console  __Test passed: Power values are in the margin of ${margin_of_error} dB error.
        ...                 ELSE  Fail  msg=Power values are out of the margin of ${margin_of_error} dB error.


