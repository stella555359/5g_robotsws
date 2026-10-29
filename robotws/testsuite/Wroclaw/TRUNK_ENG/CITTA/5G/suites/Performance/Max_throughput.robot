*** Settings ***
Documentation
...    The purpose of this test suite is to evaluate 5G max throughput (UL, DL) values.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_WO_TTI    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/Max_throughput.resources

${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${RADIO_NAME}    AEQE
${CELL_ID}    1
${TPUT_INTERVAL_MINUTES}    ${20}
${START_TPUT_MBPS_DL}       ${600}
${EXPECTED_TPUT_MBPS_DL}    ${585}
${START_TPUT_MBPS_UL}       ${140}
${EXPECTED_TPUT_MBPS_UL}    ${120}
${UE_ID}    101
${RMODS_NUMBER}    4

*** Test Cases ***
CNI62781_Max_throughput_DL
    [Setup]    [PRE]CNI62781_Max_throughput_DL
    [Teardown]    [POST]CNI62781_Max_throughput_DL
    NSA Attach 5G UE"${UE_ID}"
    Start "${START_TPUT_MBPS_DL}"mbps "dl" Data Traffic For UE"${UE_ID}" Bearer"2" Size"1200"
    SLEEP    ${TPUT_INTERVAL_MINUTES} minutes
    Verify "dl" Throughput For UE"${UE_ID}"

CNI62781_Max_throughput_UL
    [Setup]    [PRE]CNI62781_Max_throughput_UL
    [Teardown]    [POST]CNI62781_Max_throughput_UL
    NSA Attach 5G UE"${UE_ID}"
    Start "${START_TPUT_MBPS_UL}"mbps "ul" Data Traffic For UE"${UE_ID}" Bearer"2" Size"1200"
    SLEEP    ${TPUT_INTERVAL_MINUTES} minutes
    Verify "ul" Throughput For UE"${UE_ID}"

*** Keywords ***
Test suite preconditions
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Reboot BTS    rmods_number=${RMODS_NUMBER}

[PRE]CNI62781_Max_throughput_DL
    SET TEST VARIABLE    ${DIR_LABEL}    DL
    SET TEST VARIABLE    ${PM_COUNTER}    ${PM_COUNTER_DL_PATH}
    SET TEST VARIABLE    ${EXPECTED_TPUT_MBPS}    ${EXPECTED_TPUT_MBPS_DL}
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

[POST]CNI62781_Max_throughput_DL
    Report miscellaneous KPIs
    Postconditions
    Stop WTS

[PRE]CNI62781_Max_throughput_UL
    SET TEST VARIABLE    ${DIR_LABEL}    UL
    SET TEST VARIABLE    ${PM_COUNTER}    ${PM_COUNTER_UL_PATH}
    SET TEST VARIABLE    ${EXPECTED_TPUT_MBPS}    ${EXPECTED_TPUT_MBPS_UL}
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

[POST]CNI62781_Max_throughput_UL
    Report miscellaneous KPIs
    Postconditions
    Stop WTS

# -- test steps --
Verify "${dir}" Throughput for UE"${ue}"
    [Tags]    DESIGNSTEP
    LOG TO CONSOLE    \n======= Check And Verify "${dir}" Throughput For UE"${ue}" =======
    Run Keyword And Continue On Failure    Verify Throughput Using PM Counter
    Check Throughput Using Egate    ue=${ue}    dir=${dir}

# -- internals --
Postconditions
    ${command}    SET VARIABLE    trf_data_stop ue=${UE_ID}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    NSA Detach 5G UE"${UE_ID}"
    ${reported_tput}=    Get Variable Value    $REAL_TPUT_MBPS_PM_COUNTER
    RUN KEYWORD IF    ${reported_tput}    Send KPI    ${EXPECTED_TPUT_MBPS}    ${reported_tput}    5G Max throughput ${DIR_LABEL}

Verify Throughput Using PM Counter
    [Documentation]    Checks if throughput is greater than "${EXPECTED_TPUT_MBPS}" mbps using
    ...                PM counter "${PM_COUNTER}"
    LOG TO CONSOLE    \n------- Verify Throughput Using PM Counter -------
    ${avg_tput_kilobytes}    Get Average Value Of PM Counter    ${PM_COUNTER}    ${TPUT_INTERVAL_MINUTES}
    ${avg_tput_mbps}    EVALUATE    ${avg_tput_kilobytes} * 8 / 1000 / 60
    SET TEST VARIABLE    ${REAL_TPUT_MBPS_PM_COUNTER}    ${avg_tput_mbps}
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS}
    ...               msg=Throughput less than expected ${EXPECTED_TPUT_MBPS} mbps: ${avg_tput_mbps} mbps

Check Throughput Using Egate
    [Arguments]    ${ue}    ${dir}    ${bearer_id}=2    ${type}=l3
    [Documentation]    Checks if throughput reached expected level using egate command bearer_stats.
    ...    Parameters:
    ...    `ue` - specified UE ID
    ...    `dir` - traffic direction: ul|dl
    ...    `bearer_id` - id of bearer
    LOG TO CONSOLE    \n------- Check Throughput Using Egate -------
    ${throughput}    Get Traffic Statistics From Bearer    bearer_id=${bearer_id}    ue_id=${ue}    traffic_direction=${dir}
    ...                                                    extra_params=type=${type}
    ${avg_tput_mbps}    Evaluate    ${throughput}[average]/1000000
    Should Be True    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS}    msg=Throughput less than expected ${EXPECTED_TPUT_MBPS}Mbps: ${avg_tput_mbps}Mbps

Send KPI
    [Arguments]    ${expected}    ${real}    ${name}
    ${expected}    CONVERT TO STRING    ${expected}
    ${real}    CONVERT TO STRING    ${real}
    ${description}    SET VARIABLE    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, 1xCell, 1x${RADIO NAME}
    taf_reporting_portal.report_kpi_results
    ...    target=${expected}
    ...    name=${name}
    ...    visible_to_db=True
    ...    value=${real}
    ...    kpi_type=int
    ...    description=${description}
    ...    category=Performance
    ...    unit=mbps
