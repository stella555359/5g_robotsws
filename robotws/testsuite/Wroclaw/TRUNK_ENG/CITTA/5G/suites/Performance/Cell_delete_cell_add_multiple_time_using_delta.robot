*** Settings ***
Documentation
...    This suite counts time between cell deletion and setting a new added cell to onAir
...    and sends meaurements to RePo as a KPI Report

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot
# -- extra resources --
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal
Library    ../../resources/libraries/overriding.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Override Variables    DELTA_ADD
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Backup BTS Configuration Files    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Cell_delete_cell_add_multiple_time_using_delta.resources
${REPETITIONS}    10
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${STARTUP_TIME_LIMIT}    180
${DELTA_DELETE}    ${RESOURCES}/delta_delete_cells.json

${DELTA_ADD}    ${RESOURCES}/delta_add_cells.json
&{DELTA_ADD_OVERRIDE}    SBTS25R3=${RESOURCES}/SBTS25R3/delta_add_cells.json    SBTS25R2=${RESOURCES}/SBTS25R2/delta_add_cells.json
...    SBTS25R1=${RESOURCES}/SBTS25R1/delta_add_cells.json    SBTS26R1=${RESOURCES}/SBTS26R1/delta_add_cells.json

${CELLS_NUMBER_AFTER_DELETION}    2
${CELLS_NUMBER_BEFORE_DELETION}    4
${RMODS_NUMBER}    4
${RUNTIME_CELL_M_IM_PATH}    //CELL_M-*

*** Test Cases ***
CNI62781_Cell_availability_-_cell_delete_cell_add_multiple_times_using_delta
    [Documentation]
    ...    This test case counts time between deleting one TDD cell and one FDD cell and setting the cells to onAir
    ...    (after adding them to gNB configuration) The case also sends measurements to RePo as a KPI Report.
    ...    Test steps are repeated 10 time
    [Setup]    [PRE]CNI62781_Cell_availability_-_cell_delete_cell_add_multiple_times_using_delta
    [Teardown]    [POST]CNI62781_Cell_availability_-_cell_delete_cell_add_multiple_times_using_delta
    FOR    ${iteration}    IN RANGE    1    ${REPETITIONS}+1
        Remove Cells From Configuration
        Check If Cells Are Removed
        Add Cells To Configuration
        Check If Cells Are Added
        Check If All Configured Cells Are OnAir
        Send Cells Delete Cells Setup KPIs    ${iteration}
    END

*** Keywords ***
[PRE]CNI62781_Cell_availability_-_cell_delete_cell_add_multiple_times_using_delta
    Commission eNB To SA Mode
    Check if BTS is correctly configured    ${RMODS_NUMBER}
    Start WTS    ${LUA_CONFIG}    nr_mode=SA    check_version=False
    Check if BTS is OnAir

[POST]CNI62781_Cell_availability_-_cell_delete_cell_add_multiple_times_using_delta
    Report miscellaneous KPIs
    Stop WTS

# -- test steps --

Remove Cells From Configuration
    [Tags]    DESIGNSTEP
    ${time}    Get Current Date
    SET TEST VARIABLE    ${START_TIME}    ${time}
    Delta Commissisoning    ${DELTA_DELETE}

Check If Cells Are Removed
    [Tags]    DESIGNSTEP
    WAIT UNTIL KEYWORD SUCCEEDS    10x    60s    ute_admin_infomodel.query_infomodel
    ...    count ${__RUNTIME_NRCELL_IM_PATH__} is [administrativeState=Unlocked] = ${CELLS_NUMBER_AFTER_DELETION}

Add Cells To Configuration
    [Tags]    DESIGNSTEP
   Delta Commissisoning    ${DELTA_ADD}

Check If Cells Are Added
    [Tags]    DESIGNSTEP
    WAIT UNTIL KEYWORD SUCCEEDS    10x    60s    ute_admin_infomodel.query_infomodel
    ...    count ${__RUNTIME_NRCELL_IM_PATH__} is [administrativeState=Unlocked] = ${CELLS_NUMBER_BEFORE_DELETION}

Check If All Configured Cells Are OnAir
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel
    ...    every ${RUNTIME_CELL_M_IM_PATH} is [stateInfo.proceduralState=OnAirDone]    timeout=300    alias=default
    ${time}    Get Current Date
    SET TEST VARIABLE    ${STOP_TIME}    ${time}

Send Cells Delete Cells Setup KPIs
    [Tags]    DESIGNSTEP
    [Arguments]    ${iteration}
    ${startup_time}    Subtract Date From Date    ${STOP_TIME}    ${START_TIME}
    ${cell_delete_cell_setup_time}    Round Value And Convert To String    ${startup_time}
    ${description}=    CATENATE    CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, TDD, FDD, 2xAEQE, 2xAHLOA,
    ...    iteration=${iteration}
    taf_reporting_portal.report_kpi_results
    ...    ${STARTUP_TIME_LIMIT}
    ...    5G Cell availability: cell delete/cell add
    ...    True
    ...    ${cell_delete_cell_setup_time}
    ...    int
    ...    ${description}
    ...    Performance
    ...    s
