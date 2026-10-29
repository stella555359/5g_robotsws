*** Settings ***
Documentation
...    The purpose of this test case is to verify that locking/unlocking cell multiple times was performed successfully.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Cell_lock_unlock.resources

# -- test scenario variables --
${REPETITION_NUMBER}    30
${RADIO_NAME}    AEQE
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg

*** Test Cases ***
CNI62781_Cell_availability_-_lock_and_unlock_cell_multiple_times
    [Documentation]
    ...    The purpose of this test case is to verify that locking/unlocking cell multiple times
    ...    was performed successfully.
    [Setup]    [PRE]CNI62781_Cell_availability_-_lock_and_unlock_cell_multiple_times
    [Teardown]    [POST]CNI62781_Cell_availability_-_lock_and_unlock_cell_multiple_times
    FOR    ${item}    IN RANGE    1    ${REPETITION_NUMBER}+1
        Start Measuring Time
        Lock Cell 1 And Ensure It Is Locked
        Unlock Cell 1 And Ensure It Is Unlocked
        Ensure Cell 1 Is OnAir
        Stop Measuring Time
        Send KPI    id=${item}
    END

*** Keywords ***
[PRE]CNI62781_Cell_availability_-_lock_and_unlock_cell_multiple_times
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

[POST]CNI62781_Cell_availability_-_lock_and_unlock_cell_multiple_times
    Report miscellaneous KPIs
    Stop WTS

# -- test steps --
Lock Cell 1 And Ensure It Is Locked
    [Tags]    DESIGNSTEP
    Lock Cell

Unlock Cell 1 And Ensure It Is Unlocked
    [Tags]    DESIGNSTEP
    Unlock Cell

Ensure Cell 1 Is OnAir
    [Tags]    DESIGNSTEP
    Verify If First Cell Is Onair

Start Measuring Time
    [Tags]    DESIGNSTEP
    ${time}    Get Current Date
    SET SUITE VARIABLE    ${START_TIME}    ${time}

Stop Measuring Time
    [Tags]    DESIGNSTEP
    ${end_time}    Get Current Date
    ${lock_unlock_to_onAir_time}    Subtract Date From Date    ${end_time}    ${START_TIME}
    SET SUITE VARIABLE    ${LOCK_UNLOCK_TO_ONAIR_TIME}    ${lock_unlock_to_onAir_time}

Send KPI
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    ${result}    Round Value And Convert To String    ${LOCK_UNLOCK_TO_ONAIR_TIME}
    ${TL_NAME}    Run    echo $(hostname | tr - _ )
    ${description}    SET VARIABLE    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, TDD, 1xCell, 1x${RADIO_NAME}, id=${id}
    taf_reporting_portal.report_kpi_results
    ...    target=100
    ...    name=5G Cell availability: cell lock/unlock to OnAir
    ...    visible_to_db=True
    ...    value=${result}
    ...    kpi_type=int
    ...    description=${description}
    ...    category=Performance
    ...    unit=s

# -- internals --
Lock Cell
    [Teardown]    admin.Teardown    connection=lock_cell

    ${log_path}=    Prepare Logs Directory Path    admin_logs/lock_cell
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=lock_cell
    admin.Lock    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    timeout=60    connection=lock_cell
    ${required_state_reached}=    Verify Administrative State    required_state=Locked    admin_alias=lock_cell
    Run Keyword If    not $required_state_reached
    ...    Fail
    ...    msg=Cell lock procedure failed. Cell administrative state is not Locked.

Unlock Cell
    [Teardown]    admin.Teardown    connection=unlock_cell

    ${log_path}=    Prepare Logs Directory Path    admin_logs/unlock_cell
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=unlock_cell
    admin.Unlock    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    timeout=60    connection=unlock_cell
    ${required_state_reached}=    Verify Administrative State    required_state=Unlocked    admin_alias=unlock_cell
    Run Keyword If    not $required_state_reached
    ...    Fail
    ...    msg=Cell unlock procedure failed. Cell administrative state is not Unlocked.

Verify Administrative State
    [Arguments]    ${required_state}    ${admin_alias}

    FOR    ${attempt}    IN RANGE    10
        ${cell_status}=    admin.Get Cell Specific Info
        ...    cell_id=MRBTS-1/NRBTS-1/NRCELL-1
        ...    timeout=30
        ...    connection=${admin_alias}
        ${administrative_state}=    Set Variable    ${cell_status}[status][administrativeState]
        IF    '${administrative_state}' == '${required_state}'    RETURN    ${True}
        Sleep    10 seconds    reason=Wait before next administrative state verification.
    END
    RETURN    ${False}

Verify If First Cell Is Onair
    [Teardown]    admin.Teardown    connection=verify_first_cell_onair

    ${log_path}=    Prepare Logs Directory Path    admin_logs/verify_first_cell_onair
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=verify_first_cell_onair

    FOR    ${attempt}    IN RANGE    10
        ${cell_status}=    admin.Get Cell Specific Info
        ...    cell_id=MRBTS-1/NRBTS-1/NRCELL-1
        ...    timeout=30
        ...    connection=verify_first_cell_onair
        ${searched_cell_states}=    Catenate
        ...    configured
        ...    enabled
        ...    Active
        ...    unbarred
        ${current_cell_states}=    Catenate
        ...    ${cell_status}[status][proceduralStatus]
        ...    ${cell_status}[status][operationalState]
        ...    ${cell_status}[status][usageState]
        ...    ${cell_status}[status][barringStatus]

        IF    '${current_cell_states}' == '${searched_cell_states}'    RETURN    ${True}
        Sleep    10 seconds    reason=Wait before next administrative state verification.
    END
    RETURN    ${False}
