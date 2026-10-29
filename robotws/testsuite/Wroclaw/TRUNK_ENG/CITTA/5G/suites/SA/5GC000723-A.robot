*** Settings ***
Documentation
...    This test suite verifies if changing UE RRC State from IDLE to CONNECTED is handled correctly

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot
# -- extra resources --
Variables    ${RESOURCES}/pm_counters_definitions.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Stop WTS    AND
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC000723-A.resources

# -- test scenario variables --
${DELTA_SCFC_PATH}    ${RESOURCES}/pm_delta.json
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
@{CAUSES}    mo-Signalling    mo-VoiceCall    mt-Access    emergency    highPriorityAccess    mo-Data
${RMODS_NUMBER}    4

*** Test Cases ***
5GC000723-A_-_RRC_Idle_to_Connected_-_packet_flow
    [Documentation]    This test case verifies packet flow for change UE RRC State from IDLE to CONNECTED
    [Setup]    [PRE]5GC000723-A_-_RRC_Idle_to_Connected_-_packet_flow
    [Teardown]    [POST]5GC000723-A_-_RRC_Idle_to_Connected_-_packet_flow
    Attach Single UE To 5G And Verify State Transition From IDLE To CONNECTED

5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_UPLN
    [Documentation]    This test case verifies if UPLN PM Counters are incremented correctly
    ...    after IDLE to CONNECTED flow is finished
    [Setup]    [PRE]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_UPLN
    [Teardown]    [POST]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_UPLN
    Get PM Counter Start Time
    Change State From IDLE To CONNECTED For Single UE By Attach To 5G
    Get PM Counter Collection Range Time
    Wait "120"s Untill PM Counters Are Available
    Verify Idle To Connect UPLN PM Counters

5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_CPLN
    [Documentation]    This test case verifies if CPLN PM Counters are incremented correctly
    ...    after IDLE to CONNECTED flow is finished
    [Setup]    [PRE]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_CPLN
    [Teardown]    [POST]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_CPLN
    Set RRC Establishment Causes
    Get PM Counter Start Time
    Change State From IDLE To CONNECTED For Multiple UEs By Attach To 5G
    Get PM Counter Collection Range Time
    Wait "120"s Untill PM Counters Are Available
    Verify Idle To Connect CPLN PM Counters

*** Keywords ***
Test suite preconditions
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Reboot BTS    rmods_number=${RMODS_NUMBER}
    Commission eNB To SA Mode
    Delta Commissisoning    ${DELTA_SCFC_PATH}
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[PRE]5GC000723-A_-_RRC_Idle_to_Connected_-_packet_flow
    No operation

[POST]5GC000723-A_-_RRC_Idle_to_Connected_-_packet_flow
    Report miscellaneous KPIs
    SA 5G Detach UE"1"

[PRE]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_UPLN
    Wait For BSTAT Is Ready To Start Collection Of PM Counters

[POST]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_UPLN
    Report miscellaneous KPIs
    SA 5G Detach UE"1"

[PRE]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_CPLN
    Wait For BSTAT Is Ready To Start Collection Of PM Counters

[POST]5GC000723-A_-_RRC_Idle_to_Connected_-_PM_Counters_CPLN
    Report miscellaneous KPIs
    FOR    ${id}    IN RANGE    1    7
        RUN KEYWORD AND CONTINUE ON FAILURE    SA 5G Detach UE"${id}"
    END
    No operation

# -- test steps --
Attach Single UE To 5G And Verify State Transition From IDLE To CONNECTED
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"1"

Change State From IDLE To CONNECTED For Single UE By Attach To 5G
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"1"

Get PM Counter Start Time
    [Tags]    DESIGNSTEP
    ${result}   pm_counter.get_current_pm_counter_time    round_direction=down
    SET TEST VARIABLE    ${START}    ${result}

Get PM Counter Collection Range Time
    [Tags]    DESIGNSTEP
    ${stop}    pm_counter.get_current_pm_counter_time    round_direction=up
    @{range}    pm_counter.list_of_unix_minutes_between_dates    ${START}    ${stop}
    SET TEST VARIABLE    @{RANGE_TIME}    @{range}

Wait "${time}"s Untill PM Counters Are Available
    SLEEP    ${time}s

Set RRC Establishment Causes
    [Tags]    DESIGNSTEP
    FOR    ${id}    ${cause}    IN ENUMERATE    @{CAUSES}
        ${command}    SET VARIABLE    ue_nr_rrc_setup_param id=${id + 1} establishment_cause=${cause}
        ute_wtssim.execute_egate_command_and_wait_for_data
        ...    cmd=${command}
        ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
        ...    pass_regexp=
    END

Change State From IDLE To CONNECTED For Multiple UEs By Attach To 5G
    [Tags]    DESIGNSTEP
    FOR    ${id}    IN RANGE    1    7
        RUN KEYWORD AND CONTINUE ON FAILURE    SA 5G Attach UE"${id}"
    END

Verify Idle To Connect UPLN PM Counters
    [Tags]    DESIGNSTEP
    FOR    ${counter}    IN    @{UPLN_COUNTERS}
        ${pm_counter_path}    SET VARIABLE    ${counter['path']}/${counter['id']}
        ${pm_counters}    Get PM Counter "${pm_counter_path}" Measurements Untill Success
        ${result}    RUN KEYWORD AND CONTINUE ON FAILURE    pm_counter.get_sum_of_pm_counter_value_based_on_time
        ...    data=${pm_counters}
        ...    path=${pm_counter_path}
        ...    counter_time=${RANGE_TIME}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${result}" == "${counter['amount']}"
        ...    msg=Amount of counter:${counter['id']} - ${counter['name']} (${result}) is not equal to ${counter['amount']}
    END

Verify Idle To Connect CPLN PM Counters
    [Tags]    DESIGNSTEP
    FOR    ${counter}    IN    @{CPLN_COUNTERS}
        ${pm_counter_path}    SET VARIABLE    ${counter['path']}/${counter['id']}
        ${pm_counters}    Get PM Counter "${pm_counter_path}" Measurements Untill Success
        ${result}    RUN KEYWORD AND CONTINUE ON FAILURE    pm_counter.get_sum_of_pm_counter_value_based_on_time
        ...    data=${pm_counters}
        ...    path=${pm_counter_path}
        ...    counter_time=${RANGE_TIME}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${result}" == "${counter['amount']}"
        ...    msg=Amount of counter:${counter['id']} - ${counter['name']} (${result}) is not equal to ${counter['amount']}
    END

# -- internals --
Wait Until Radio Is Detected
    ute_admin_infomodel.query_infomodel    //RMOD_L-* is [stateInfo.availabilityStatus=Online]    timeout=900

Wait Until Cell Is Detected
    ute_admin_infomodel.query_infomodel    every //CELL_M-* is [stateInfo.proceduralState=Validated]    timeout=600

Wait For BSTAT Is Ready To Start Collection Of PM Counters
    ute_admin_infomodel.query_infomodel
    ...    query=/MRBTS-1/EQM-1/SMOD-*/TIME-1 is [stateInfo.operationalState=Enabled]
    ...    timeout=30
    ute_admin_infomodel.query_infomodel
    ...    query=every /MRBTS-1/EQM-1/BBMOD-*/BBU-1/DSP-*/SYNC-1 is [stateInfo.operationalState=Enabled]
    ...    timeout=30
    ute_admin_infomodel.query_infomodel
    ...    query=every /MRBTS-1/EQM-1/SMOD-*/CCU-1/CPU-*/SYNC-1 is [stateInfo.operationalState=Enabled]
    ...    timeout=30
    sleep    120    # << wait for PMReportingConfigReq is sent to PMAGENT and PMAGENT response with PMReportingConfigResp
