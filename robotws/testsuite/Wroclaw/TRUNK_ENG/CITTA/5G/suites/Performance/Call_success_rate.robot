*** Settings ***
Documentation
...    The purpose of this test case is to verify if procedure of adding and removing bearer
...    multiple times performed successfully.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot
# -- extra resources --
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal
Variables    ${RESOURCES}/messages_definition.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Call_success_rate.resources

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${REPETITIONS}    50
${PASS_COUNTER}    0
${FILES_MAX_SIZE}    200000000
${UE_ID}    101
${BEARER_ID}    2

*** Test Cases ***
CNI62781_Call_success_rate_-_add_remove_bearer_multiple_times
    [Documentation]
    ...    The purpose of this test case is to verify if procedure of adding and removing bearer
    ...    multiple times performed successfully.
    [Setup]    [PRE]CNI62781_Call_success_rate_-_add_remove_bearer_multiple_times
    [Teardown]    [POST]CNI62781_Call_success_rate_-_add_remove_bearer_multiple_times
    FOR    ${id}    IN RANGE    1    ${REPETITIONS}+1
        Add Bearer    ${id}
        Verify Packet Flow of Bearer Addition   ${id}
        Remove Bearer    ${id}
        Verify Packet Flow of Bearer Removal    ${id}
        Increment Pass Counter    ${id}
        Remove Tshark Files If Exceed Max Volume    ${id}
    END

*** Keywords ***
[PRE]CNI62781_Call_success_rate_-_add_remove_bearer_multiple_times
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir
    NSA LTE Attach UE"${UE_ID}" To The CELL"1"
    Create Ditectories For Tshark Logs

[POST]CNI62781_Call_success_rate_-_add_remove_bearer_multiple_times
    Report miscellaneous KPIs
    Send Add Remove Bearer KPI
    Stop WTS

# -- test steps --
Add Bearer
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    ute_tshark.setup_tshark
    ...    interface=eth3 lo
    ...    alias=bearer_addition_${id}
    ...    log_dir=${BEARER_ADDITION}
    ...    log_name=bearer_addition_${id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=bearer_addition_${id}
    SLEEP    2    # << ensure all essential packets has been captured
    Perform Bearer Addition
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=bearer_addition_${id}

Verify Packet Flow of Bearer Addition
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    [Teardown]    ute_tshark.teardown_tshark    alias=bearer_addition_${id}
    FOR    ${message}    IN    @{SgNB_ADDITION}
        ${packets_count}=    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=bearer_addition_${id}
        SHOULD BE TRUE    ${packets_count}>=${1}
        ...    msg=Amount of ${message['name']} (${packets_count}) is not equal to expected amount (1)
    END

Remove Bearer
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    ute_tshark.setup_tshark
    ...    interface=eth3 lo
    ...    alias=bearer_removal_${id}
    ...    log_dir=${BEARER_REMOVAL}
    ...    log_name=bearer_removal_${id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=bearer_removal_${id}
    SLEEP    2    # << ensure all essential packets has been captured
    Perform Bearer Removal
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=bearer_removal_${id}

Verify Packet Flow of Bearer Removal
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    [Teardown]    ute_tshark.teardown_tshark    alias=bearer_removal_${id}
    FOR    ${message}    IN    @{SgNB_RELEASE}
        ${packets_count}=    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=bearer_removal_${id}
        SHOULD BE TRUE    ${packets_count}==${1}
        ...    msg=Amount of ${message['name']} (${packets_count}) is not equal to expected amount (1)
    END

Increment Pass Counter
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    SET SUITE VARIABLE    ${PASS_COUNTER}    ${id}

Remove Tshark Files If Exceed Max Volume
    [Tags]    DESIGNSTEP
    [Arguments]    ${id}
    ${logs_size}    Return size of SUBDIRECTORY "tshark" in bytes
    ${remove_logs}    EVALUATE    ${id} > ${1} and ${logs_size} > ${FILES_MAX_SIZE}
    RUN KEYWORD IF    ${remove_logs}
    ...    Remove FILES "bearer_addition_${id}" from SUBDIRECTORY "tshark/bearer_addition"
    RUN KEYWORD IF    ${remove_logs}
    ...    Remove FILES "bearer_removal_${id}" from SUBDIRECTORY "tshark/bearer_removal"

# -- internals --
Create Ditectories For Tshark Logs
    ${tshark_bearer_addition}    Prepare Logs Directory Path    tshark/bearer_addition    with_timestamp=${FALSE}
    ${tshark_bearer_removal}    Prepare Logs Directory Path    tshark/bearer_removal    with_timestamp=${FALSE}
    SET SUITE VARIABLE    ${BEARER_ADDITION}    ${tshark_bearer_addition}
    SET SUITE VARIABLE    ${BEARER_REMOVAL}    ${tshark_bearer_removal}

Perform Bearer Addition
    LOG TO CONSOLE    \n------- 5g bearer addition -------
    ${pass_regexp}    SET VARIABLE    UE${UE_ID}: Proxy \\(eNB 2 cell 1\\) reported successful RA
    ${command}    SET VARIABLE    enb_ue_dc_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=${BEARER_ID} type=split_scg
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=20s

Perform Bearer Removal
    LOG TO CONSOLE    \n------- 5g bearer release -------
    ${pass_regexp}    SET VARIABLE    Bearer-type change from SCG-split to MCG
    ${command}    SET VARIABLE    enb_ue_dc_release ue=${UE_ID} bearer=${BEARER_ID} by=enb cause=off
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

Send Add Remove Bearer KPI
    ${description}    SET VARIABLE    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, TDD, 1xAEQE
    ${passed_executions}    CONVERT TO STRING    ${PASS_COUNTER}
    taf_reporting_portal.report_kpi_results
    ...    target=${REPETITIONS}
    ...    name=5G Call success rate: establish/remove bearer
    ...    visible_to_db=True
    ...    value=${passed_executions}
    ...    kpi_type=int
    ...    description=${description}
    ...    category=Performance
    ...    unit=n/a
