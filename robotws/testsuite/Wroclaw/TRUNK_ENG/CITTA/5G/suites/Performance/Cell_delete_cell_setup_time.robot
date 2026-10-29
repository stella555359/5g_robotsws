*** Settings ***
Documentation
...    This suite counts time between cell delete and cell setup, and sends meaurements to RePo as a KPI Report

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot
# -- extra resources --
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Backup BTS Configuration Files    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Cell_delete_cell_setup_time.resources
${REPETITIONS}    10
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${STARTUP_TIME_LIMIT}    1200
${SCF}    ${RESOURCES}/scf.xml
${CELLS_NUMBER_AFTER_DELETION}    3
${CELLS_NUMBER_BEFORE_DELETION}    4
${RMODS_NUMBER}    4

*** Test Cases ***
CNI62781_Cell_availability_-_cell_delete_cell_setup_multiple_times
    [Documentation]
    ...    This suite counts time between cell delete and cell setup, and sends meaurements to RePo as a KPI Report
    [Setup]    [PRE]CNI62781_Cell_availability_-_cell_delete_cell_setup_multiple_times
    [Teardown]    [POST]CNI62781_Cell_availability_-_cell_delete_cell_setup_multiple_times
    FOR    ${id}    IN RANGE    1    ${REPETITIONS}+1
        Start Measuring Time
        Remove Cell From Configuration
        Check If Cell Is Removed
        Wait Until Radio Is Detected
        Wait Until Cell Is Detected
        Add Cell To Configuration
        Check If Cell Is Added
        Wait Until Radio Is Detected
        Wait Until Cells Are Detected
        Setup S1 And X2 Interfaces
        Check If Cells Are OnAir
        Stop Measuring Time
        Send Cell Delete Cell Setup KPIs    ${id}
        Stop WTS
    END

*** Keywords ***
[PRE]CNI62781_Cell_availability_-_cell_delete_cell_setup_multiple_times
    Configure Required IP Addresses

[POST]CNI62781_Cell_availability_-_cell_delete_cell_setup_multiple_times
    Report miscellaneous KPIs
    RUN KEYWORD IF    '${TEST STATUS}' == 'FAIL'    Stop WTS

# -- test steps --
Start Measuring Time
    [Tags]    DESIGNSTEP
    ${time}    Get Current Date
    SET SUITE VARIABLE    ${START_TIME}    ${time}

Remove Cell From Configuration
    [Tags]    DESIGNSTEP
    Perform Commissioning    scfc_path=${SCF}

Check If Cell Is Removed
    [Tags]    DESIGNSTEP
    WAIT UNTIL KEYWORD SUCCEEDS    20x    60s    ute_admin_infomodel.query_infomodel
    ...    count ${__RUNTIME_NRCELL_IM_PATH__} is [proceduralStatus=configured] = ${CELLS_NUMBER_AFTER_DELETION}

Add Cell To Configuration
    [Tags]    DESIGNSTEP
    Perform Commissioning    scfc_path=${__DEFAULT_SCFC__}

Check If Cell Is Added
    [Tags]    DESIGNSTEP
    WAIT UNTIL KEYWORD SUCCEEDS    20x    60s    ute_admin_infomodel.query_infomodel
    ...    count ${__RUNTIME_NRCELL_IM_PATH__} is [proceduralStatus=configured] = ${CELLS_NUMBER_BEFORE_DELETION}

Wait Until Radio Is Detected
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel    count ${__RUNTIME_RMOD_IM_PATH__} is [operationalState=enabled] = ${RMODS_NUMBER}    timeout=900

Wait Until Cell Is Detected
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel    //NRCELL_R-1 is [proceduralStatus=configured]    timeout=600

Wait Until Cells Are Detected
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel
    ...    count ${__RUNTIME_NRCELL_IM_PATH__} is [proceduralStatus=configured] = ${CELLS_NUMBER_BEFORE_DELETION}
    ...    timeout=600

Setup S1 And X2 Interfaces
    [Tags]    DESIGNSTEP
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False

Check If Cells Are OnAir
    [Tags]    DESIGNSTEP
    Check if BTS is OnAir

Stop Measuring Time
    [Tags]    DESIGNSTEP
    ${end_time}    Get Current Date
    ${startup_time}    Subtract Date From Date    ${end_time}    ${START_TIME}
    ${result}    Round Value And Convert To String    ${startup_time}
    SET SUITE VARIABLE    ${CELL_DELETE_CELL_SETUP_TIME}    ${result}

Send Cell Delete Cell Setup KPIs
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    ${description}    SET VARIABLE    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, TDD, 1xAEQA, id=${id}
    taf_reporting_portal.report_kpi_results
    ...    ${STARTUP_TIME_LIMIT}
    ...    5G Cell availability: cell delete/cell setup
    ...    True
    ...    ${CELL_DELETE_CELL_SETUP_TIME}
    ...    int
    ...    ${description}
    ...    Performance
    ...    s
