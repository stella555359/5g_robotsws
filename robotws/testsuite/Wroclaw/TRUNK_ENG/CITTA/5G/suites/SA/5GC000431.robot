*** Settings ***
Documentation
...    The purpose of this test case is to verify whether load-based Power Saving (feature 5GC000431) activation
...    and deactivation works correctly.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot
# -- extra resources --

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC000431.resources

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA_SCFC_PATH}    ${RESOURCES}/delta_5GC000431_activation.json

${RUNTIME_NRCELL_1_IM_PATH}    //NRCELL_R-1
${RUNTIME_NRCELL_2_IM_PATH}    //NRCELL_R-2
${RUNTIME_NRCELL_IM_PATH}    //NRCELL_R-*
${IM_CELL_M_PATH}    //CELL_M-*
${RMODS_NUMBER}    4

*** Test Cases ***
5GC000431_Cell_switch-off_for_Energy_Efficiency_-_load-based_Power_Saving_activation_and_deactivation
    [Documentation]
    ...    This test case verifies whether load-based Power Saving (feature 5GC000431) activation and
    ...    deactivation works correctly.
    [Setup]    [PRE]5GC000431_Cell_switch-off_for_Energy_Efficiency_-_load-based_Power_Saving_activation_and_deactivation
    [Teardown]    [POST]5GC000431_Cell_switch-off_for_Energy_Efficiency_-_load-Based_Power_Saving_activation_and_deactivation
    Activate load-based Power Saving feature
    Wait for switching off procedure to trigger on first cell
    Verify that first cell changed to disabled and energy saving state
    Verify that second cell does not change to energy saving state
    Deactivate load-based Power Saving feature
    Verify that first cell changed to enabled and not energy saving state

*** Keywords ***
[PRE]5GC000431_Cell_switch-off_for_Energy_Efficiency_-_load-based_Power_Saving_activation_and_deactivation
    Check if BTS is correctly configured    rmods_number=${RMODS_NUMBER}
    Set SA configuration
    Check if BTS is correctly configured    rmods_number=${RMODS_NUMBER}
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir
    Ensure both cells are OnAir and not degraded
    Ensure both cells are not energy saving

[POST]5GC000431_Cell_switch-off_for_Energy_Efficiency_-_load-based_Power_Saving_activation_and_deactivation
    Report miscellaneous KPIs
    Ensure both cells are OnAir and not degraded
    Stop WTS

# -- test steps --
Activate load-based Power Saving feature
    [Tags]    DESIGNSTEP
    Set current time values in delta file
    Delta Commissisoning    ${CURRENT_TIME_DELTA}

Wait for switching off procedure to trigger on first cell
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [energySavingState=switchingOff]    timeout=350
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [operationalState=enabled]    timeout=350

Verify that first cell changed to disabled and energy saving state
    [Tags]    DESIGNSTEP
    Check if first cell became energy saving and disabled
    Verify M55601C00502 PM counter

Verify that second cell does not change to energy saving state
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_2_IM_PATH} is [energySavingState=notEnergySaving]
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_2_IM_PATH} is [operationalState=enabled]

Deactivate load-based Power Saving feature
    [Tags]    DESIGNSTEP
    ${connection}=    SET VARIABLE    parameter_recommissioning
    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=${connection}
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1
    ...    parameter=actNrLBPowerSaving
    ...    operation=update
    ...    value=false
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    [Teardown]    admin.teardown    connection=${connection}

Verify that first cell changed to enabled and not energy saving state
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [energySavingState=notEnergySaving]
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [operationalState=enabled]

# -- internals --
Set current time values in delta file
    ${datestring}=    GET CURRENT DATE    time_zone=UTC    result_format=%a %H %M
    @{date}=    SPLIT STRING    ${datestring}
    ${WEEKDAY}    ${HOUR}    ${MINUTE}=    SET VARIABLE    ${date}
    ${HOUR}=    CONVERT TO INTEGER    ${HOUR}
    ${MINUTE}=    CONVERT TO INTEGER    ${MINUTE}
    ${template_delta}=    GET FILE    ${DELTA_SCFC_PATH}
    ${current_time_delta}=    REPLACE VARIABLES    ${template_delta}
    SET SUITE VARIABLE    ${CURRENT_TIME_DELTA}    ${current_time_delta}

Check if first cell became energy saving and disabled
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [energySavingState=energySaving]    timeout=180
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [operationalState=disabled]    timeout=180

Verify M55601C00502 PM counter
    [Documentation]    Fails if M55601C00502 does not change in span of 10 minutes
    ${pm_counter_path}=    SET VARIABLE    ${M55601C00502_PATH}
    FOR    ${i}    IN RANGE    1    5
        ${measurements}    Get PM Counter "${pm_counter_path}" Measurements Untill Success
        ${counter_value}    pm_counter.get_avg_pm_counter_value    ${measurements}    ${pm_counter_path}    ${1}
        EXIT FOR LOOP IF    ${counter_value} == 1
        SLEEP    240s    reason=Wait for next update window of M55601C00502 counter
    END
    SHOULD BE EQUAL AS INTEGERS    ${counter_value}    ${1}
    ...    msg=Counter was not updated despite the change of related states in infomodel

Set SA configuration
    Commission eNB To SA Mode

Ensure both cells are OnAir and not degraded
    ute_admin_infomodel.query_infomodel    every ${IM_CELL_M_PATH} is [stateInfo.proceduralState=OnAirDone]
    ute_admin_infomodel.query_infomodel    every ${IM_CELL_M_PATH} is [stateInfo.availabilityStatus=Online]

Ensure both cells are not energy saving
    ute_admin_infomodel.query_infomodel    every ${RUNTIME_NRCELL_IM_PATH} is [energySavingState=notEnergySaving]
