*** Settings ***
Documentation
...             Contact Person: Paweł Wiśniewsi
...             Editor: Wiktor Jarosiński
...             Edit Reason: RobotFramework5.0 Migration
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.py
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.collectors.pmcounters  WITH NAME  pm
Library         testsuite.Wroclaw.RRM.resources.webui.WebuiInterface  WITH NAME  WebUI
Library         taf.collectors.btslog  WITH NAME   btslog
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Resource        testsuite/Wroclaw/RRM/resources/connections.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.robot


*** Keywords ***
Perform commissioning 1329
    [Arguments]         ${cells_on_air_verification}=${TRUE}
    ...                 ${actEirpControl}=false
    ...                 ${pMax}=370
    ...                 ${ssPbchBlockPower}=7
    ...                 ${chBwDl}=15MHz
    ...                 ${chBwUl}=15MHz
    ...                 ${type0CoresetConfigurationIndex}=6
    ...                 ${ssBurstSetPeriod}=10
    ...                 ${csirsTrackingPeriod}=20ms
    ...                 ${rbAllocation}=BWP
    ...                 ${startRB}=0
    ...                 ${targetTotalLoad}=0
    ...                 ${aggregationLevel}=1CCE
    Log to console      __Perform commissioning with given parameters.
    &{csirsForTracking}  Create dictionary  csirsTrackingPeriod=${csirsTrackingPeriod}  rbAllocation=${rbAllocation}
    ...   startRB=${startRB}
    ${first_cell_id}    Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}        type0CoresetConfigurationIndex         value=${type0CoresetConfigurationIndex}
    END
    Add param to delta  ${object_path}GRP-0               ssBurstSetPeriod              value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}-${first_cell_id}   actEirpControl                value=${actEirpControl}
    Add param to delta  ${object_path}-${first_cell_id}   pMax                          value=${pMax}
    Add param to delta  ${object_path}-${first_cell_id}   ssPbchBlockPower              value=${ssPbchBlockPower}
    Add list parameters to delta  ${object_path}-${first_cell_id}  csirsForTracking     &{csirsForTracking}
    Add param to delta  ${object_path}-${first_cell_id}   targetTotalLoad               value=${targetTotalLoad}
    Add param to delta  ${object_path}-${first_cell_id}   aggregationLevel              value=${aggregationLevel}
    Run keyword if      '${actEirpControl}'=='true'   Run keywords
    ...  Add param to delta  ${object_path}-${first_cell_id}        externalAntennaGain             value=0     AND
    ...  Add param to delta  ${object_path}-${first_cell_id}        antennaMechanicalDowntilt       value=0
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Run keyword if      ${cells_on_air_verification}    Verify if all cells are onair


Perform commissioning 1329 Trunk
    [Arguments]         ${cells_on_air_verification}=${TRUE}
    ...                 ${actEirpControl}=false
    ...                 ${pMax}=370
    ...                 ${ssPbchBlockPower}=7
    ...                 ${chBwDl}=15MHz
    ...                 ${chBwUl}=15MHz
    ...                 ${type0CoresetConfigurationIndex}=6
    ...                 ${ssBurstSetPeriod}=10
    ...                 ${csirsTrackingPeriod}=20ms
    ...                 ${rbAllocation}=BWP
    ...                 ${startRB}=0
    ...                 ${targetTotalLoad}=0
    ...                 ${aggregationLevel}=1CCE
    ...                 ${actPdschAtSsbSlots}=true
    ...                 ${reqMinNumPuschPrb}=15
    Log to console      __Perform commissioning with given parameters.
    &{csirsForTracking}  Create dictionary  csirsTrackingPeriod=${csirsTrackingPeriod}  rbAllocation=${rbAllocation}
    ...   startRB=${startRB}
    ${first_cell_id}    Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists}
        ${cell_path}     Set variable     MRBTS-${bts_id}/NRBTS-${bts_id}/${cell_dist}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwDl                         value=${chBwDl}
        Add param to delta  ${cell_path}/NRCELL_FDD-1   chBwUl                         value=${chBwUl}
        Add param to delta  ${cell_path}        type0CoresetConfigurationIndex         value=${type0CoresetConfigurationIndex}
        Add param to delta  ${cell_path}                actPdschAtSsbSlots               value=${actPdschAtSsbSlots}
        Add param to delta  ${cell_path}                reqMinNumPuschPrb                value=${reqMinNumPuschPrb}
    END

    Add param to delta  ${object_path}GRP-0               ssBurstSetPeriod              value=${ssBurstSetPeriod}
    Add param to delta  ${object_path}-${first_cell_id}   actEirpControl                value=${actEirpControl}
    Add param to delta  ${object_path}-${first_cell_id}   pMax                          value=${pMax}
    Add param to delta  ${object_path}-${first_cell_id}   ssPbchBlockPower              value=${ssPbchBlockPower}
    Add list parameters to delta  ${object_path}-${first_cell_id}  csirsForTracking     &{csirsForTracking}
    Add param to delta  ${object_path}-${first_cell_id}   targetTotalLoad               value=${targetTotalLoad}
    Add param to delta  ${object_path}-${first_cell_id}   aggregationLevel              value=${aggregationLevel}
    Run keyword if      '${actEirpControl}'=='true'   Run keywords
    ...  Add param to delta  ${object_path}-${first_cell_id}        externalAntennaGain             value=0     AND
    ...  Add param to delta  ${object_path}-${first_cell_id}        antennaMechanicalDowntilt       value=0
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Run keyword if      ${cells_on_air_verification}    Verify if all cells are onair


Check if pm counter EIRP cell power has incremented
    [Arguments]         @{counters}
    ${pmcounter_cell_power_dbm}     Get cell power from pm counters  @{counters}
    ${outcome_is_cell_power_grater_than_zero}  Is greater than zero  ${pmcounter_cell_power_dbm}
    run keyword if  ${outcome_is_cell_power_grater_than_zero}  log to console  __Success Test has Passed__
    ...  ELSE  log to console  __Test Failed__
