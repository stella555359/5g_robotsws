*** Settings ***
Documentation
...    The purpose of this test case is to perform activation of NRPMQAP profiles and to check whether profile level
...    counters (M55163C00001, M55163C00002, M55161C00001, M55161C00002, M55161C00003) are triggered and incremented
...    properly per each of activated profiles.
...    Additionally, two non-profile level counters (M55125C08501 and M55125C08502) are verified.
...
...    PM measurement interval is set to 5 minutes (along with NRPMQAP activation) via commissioning.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot
Library    ../../resources/libraries/overriding.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Override Variables    DELTA
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/CB006898-B-E.resources

${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA}    ${RESOURCES}/delta_6898_B_E.json
&{DELTA_OVERRIDE}    SBTS25R3=${RESOURCES}/SBTS25R3/delta_6898_B_E.json    SBTS25R2=${RESOURCES}/SBTS25R2/delta_6898_B_E.json
${UES_AMOUNT}     ${2}
${INTERVALS}    ${3}

${PROFILE LEVEL COUNTERS}    M55161C00001,M55161C00002,M55161C00003,M55163C00001,M55163C00002
${NON PROFILE LEVEL COUNTERS}    M55125C08501,M55125C08502

*** Test Cases ***
CB006898-B-E_PMQAP_Profiles_for_NR_I_activation_and_counters_verification
    [Documentation]
    ...    The purpose of this test case is to verify if attach and DL throughput for Multi UEs is performed
    ...    successfully and throughput reaches expected level.
    [Setup]    [PRE]CB006898-B-E_PMQAP_Profiles_for_NR_I_activation_and_counters_verification
    [Teardown]    [POST]CB006898-B-E_PMQAP_Profiles_for_NR_I_activation_and_counters_verification
    Activate NRPMQAP profiles
    Attach UE 1 and setup one PDU sessions
    Attach UE 2 and setup two PDU session
    Get PM counters values
    Verify all tested profile counters per profile 1
    Verify all tested profile counters per profile 2
    Verify all tested profile counters per profile 3
    Verify all tested profile counters per profile 4
    Verify non-profile level counters

*** Keywords ***
Test suite preconditions
    Commission eNB To SA Mode

[PRE]CB006898-B-E_PMQAP_Profiles_for_NR_I_activation_and_counters_verification
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]CB006898-B-E_PMQAP_Profiles_for_NR_I_activation_and_counters_verification
    Report miscellaneous KPIs
    Detach All UEs
    Stop WTS

# -- test steps --
Activate NRPMQAP profiles
    Delta Commissisoning    ${DELTA}
    Wait for counters generation to be started

Attach UE 1 and setup one PDU sessions
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"1"
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"

Attach UE 2 and setup two PDU session
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"2"
    SA Setup Primary PDU Session For PDU"1" UE"2" GW"2" NWSLICE"2"
    SA Setup Additional PDU Session For PDU"2" UE"2" GW"3" NWSLICE"2"

Get PM counters values
    [Tags]    DESIGNSTEP
    ${connection}=    Set Variable    get_pm_counters
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    Sleep    10 minutes    reason=Wait for all profile level counters to gain expected value
    ${counter_ids}=    CATENATE     SEPARATOR=,    ${PROFILE LEVEL COUNTERS}    ${NON PROFILE LEVEL COUNTERS}
    ${counters_info}=    admin.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}

    Comment    M55161C00001
    ${M55161C00001_profile_1_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00001_PROFILE_1_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00001_PROFILE_1_VALUE}    ${M55161C00001_profile_1_value}
    ${M55161C00001_profile_2_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00001_PROFILE_2_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00001_PROFILE_2_VALUE}    ${M55161C00001_profile_2_value}
    ${M55161C00001_profile_3_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00001_PROFILE_3_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00001_PROFILE_3_VALUE}    ${M55161C00001_profile_3_value}
    ${M55161C00001_profile_4_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00001_PROFILE_4_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00001_PROFILE_4_VALUE}    ${M55161C00001_profile_4_value}

    Comment    M55161C00002
    ${M55161C00002_profile_1_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00002_PROFILE_1_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00002_PROFILE_1_VALUE}    ${M55161C00002_profile_1_value}
    ${M55161C00002_profile_2_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00002_PROFILE_2_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00002_PROFILE_2_VALUE}    ${M55161C00002_profile_2_value}
    ${M55161C00002_profile_3_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00002_PROFILE_3_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00002_PROFILE_3_VALUE}    ${M55161C00002_profile_3_value}
    ${M55161C00002_profile_4_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00002_PROFILE_4_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00002_PROFILE_4_VALUE}    ${M55161C00002_profile_4_value}

    Comment    M55161C00003
    ${M55161C00003_profile_1_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00003_PROFILE_1_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00003_PROFILE_1_VALUE}    ${M55161C00003_profile_1_value}
    ${M55161C00003_profile_2_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00003_PROFILE_2_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00003_PROFILE_2_VALUE}    ${M55161C00003_profile_2_value}
    ${M55161C00003_profile_3_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00003_PROFILE_3_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00003_PROFILE_3_VALUE}    ${M55161C00003_profile_3_value}
    ${M55161C00003_profile_4_value}    pm_counter.get_avg_pm_counter_value    ${counters_info}    ${M55161C00003_PROFILE_4_PATH}    ${1}
    SET SUITE VARIABLE    ${M55161C00003_PROFILE_4_VALUE}    ${M55161C00003_profile_4_value}

    Comment    M55163C00001
    ${M55163C00001_profile_1_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00001_PROFILE_1_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00001_PROFILE_1_VALUE}    ${M55163C00001_profile_1_value}
    ${M55163C00001_profile_2_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00001_PROFILE_2_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00001_PROFILE_2_VALUE}    ${M55163C00001_profile_2_value}
    ${M55163C00001_profile_3_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00001_PROFILE_3_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00001_PROFILE_3_VALUE}    ${M55163C00001_profile_3_value}
    ${M55163C00001_profile_4_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00001_PROFILE_4_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00001_PROFILE_4_VALUE}    ${M55163C00001_profile_4_value}

    Comment    M55163C00001
    ${M55163C00002_profile_1_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00002_PROFILE_1_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00002_PROFILE_1_VALUE}    ${M55163C00002_profile_1_value}
    ${M55163C00002_profile_2_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00002_PROFILE_2_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00002_PROFILE_2_VALUE}    ${M55163C00002_profile_2_value}
    ${M55163C00002_profile_3_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00002_PROFILE_3_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00002_PROFILE_3_VALUE}    ${M55163C00002_profile_3_value}
    ${M55163C00002_profile_4_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55163C00002_PROFILE_4_PATH}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55163C00002_PROFILE_4_VALUE}    ${M55163C00002_profile_4_value}

    Comment    non-profile counters
    ${M55125C08501_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55125C08501_pm_counter_path}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55125C08501_VALUE}    ${M55125C08501_value}
    ${M55125C08502_value}    pm_counter.get_sum_pm_counter_value    ${counters_info}    ${M55125C08502_pm_counter_path}    ${INTERVALS}
    SET SUITE VARIABLE    ${M55125C08502_VALUE}    ${M55125C08502_value}
    [Teardown]    admin.teardown    connection=${connection}

Verify all tested profile counters per profile 1
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00001_PROFILE_1_VALUE}    ${600}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00002_PROFILE_1_VALUE}    ${300}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00003_PROFILE_1_VALUE}    ${2}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00001_PROFILE_1_VALUE}    ${3}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00002_PROFILE_1_VALUE}    ${3}

Verify all tested profile counters per profile 2
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00001_PROFILE_2_VALUE}    ${0}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00002_PROFILE_2_VALUE}    ${300}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00003_PROFILE_2_VALUE}    ${0}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00001_PROFILE_2_VALUE}    ${0}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00002_PROFILE_2_VALUE}    ${0}

Verify all tested profile counters per profile 3
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00001_PROFILE_3_VALUE}    ${600}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00002_PROFILE_3_VALUE}    ${300}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00003_PROFILE_3_VALUE}    ${2}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00001_PROFILE_3_VALUE}    ${3}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00002_PROFILE_3_VALUE}    ${3}

Verify all tested profile counters per profile 4
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00001_PROFILE_4_VALUE}    ${300}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00002_PROFILE_4_VALUE}    ${300}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55161C00003_PROFILE_4_VALUE}    ${1}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00001_PROFILE_4_VALUE}    ${1}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55163C00002_PROFILE_4_VALUE}    ${1}

Verify non-profile level counters
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55125C08501_VALUE}     ${3}
    ...    msg=Counter was not updated despite the change of related states in infomodel
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE EQUAL AS INTEGERS    ${M55125C08502_VALUE}     ${3}
    ...    msg=Counter was not updated despite the change of related states in infomodel

# -- internals --
Wait for counters generation to be started
    comment    Waiting for distName creation for the counter (BTS/CELLS/NRCELL-1/NRPMQAP-1/ACCSQ/M55161C00002)
    Wait Until Keyword Succeeds    20x    15s    Get PM Counter "${M55161C00002_PROFILE_1_PATH}" Measurements

Detach All UEs
    FOR    ${id}    IN RANGE    1     ${UES_AMOUNT}+1
        SA 5G Detach UE"${id}"
    END
