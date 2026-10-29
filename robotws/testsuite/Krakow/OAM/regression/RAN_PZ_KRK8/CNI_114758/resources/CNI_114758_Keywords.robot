*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Keywords for 7538 feature tests

Library             DateTime
Library             Dialogs
Library             taf.ue
Library             taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Library             taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnbcounter
Library             taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library             taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library             taf.rfrl.bts.devices.ru.ru_serial_logs_collector.GnbRuSerialLogsCollector    WITH NAME    gnb_ru_lmi
Library             on_air_tl_preparation.testline_preparation    WITH NAME    tl_prep
Library             taf.sw.scout    WITH NAME    scout
Library             CNI_114758_Keywords.py
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Resource            taf/rfrl/bts/robot/logs_collecting.robot
Resource            taf/rfrl/procedures/resources/robot/LockUnlock.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${api_key}          17bd6b4f-de6b-4ce8-8ab2-d67aab87cd69

*** Keywords ***
Test Setup
    Log to console    \n--Test Setup started--\n
    IF    ${full_test_setup}
        Run keyword And Restart gNB On ASIR Timeout    Common preconditions With Watching Alarms
    END
    Set Initial NR RTWP Counters State
    Log to console    \n--Test Setup done--\n
    create test log directory
    Log to console    \n--Starting test ${TEST_NAME}--\n

Test Teardown
    Log to console    \n--Finished test ${TEST_NAME}--\n
    Log to console    \n--Test Teardown started--\n
    IF    ${full_test_setup}
        Run keyword And Restart gNB On ASIR Timeout    Common postconditions With Watching Alarms
    END
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    Setup Suite Variables
    ${tl_name}=    taf.rfrl.utilities.tl_config.Get Testline Name
    scout.Setup Scout    scout_testline_name=${tl_name}    api_key=${api_key}
    scout.enable_full_kpi_pm_collection
    Log to console    \n--Performing Full Commissioning--\n
    IF    ${full_test_setup}
        tl_prep.Power On All Pdu Ports
        Upload swconfig
        Run Keyword And Restart gNB On ASIR Timeout
        ...    Perform Full Commissioning and Wait for onAir
        ...    prefix_tag=${None}
        ...    asir_hub=${True}
        Log to console    \n--Full Commissioning Finished--\n
        Wait For cells To Be OnAir
        Log to console    \n--Performing Common Suite Setup--\n
        Run keyword And Restart gNB On ASIR Timeout    Common Suite Setup

    ELSE
        LOG    ================================================================================    console=${True}
        LOG    SKIPPING FULL SETUP IF IT'S NOT EXPECTED CHANGE full_test_setup VARIABLE TO TRUE    console=${True}
        LOG    ================================================================================    console=${True}
    END
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    IF    ${full_test_setup}
        Common Suite Teardown
    END
    Run Keyword and ignore error    taf.ue.Detach UE    UE_1
    Log to console    \n--Suite Teardown done--\n

Run Keyword And Restart gNB On ASIR Timeout
    [Arguments]    ${keyword}    &{args}
    FOR    ${_}    IN RANGE    3
        TRY
            Run Keyword    ${keyword}    &{args}
        EXCEPT    .*AsirConnection.*    type=regexp
            Log    \n--AsirConnection exception occured--\n    console=${True}
            Log    \n--${keyword} timed out, restarting gNB--\n    console=${True}
            Reset gNB
            Wait For cells To Be OnAir
        ELSE
            RETURN
        END
    END

Run Keyword And Retry On Error
    [Arguments]    ${error_regex}    ${keyword}    ${retry_number}=10    &{args}
    ${result}=    Set Variable   ${None}
    FOR    ${_}    IN RANGE    ${retry_number}
        TRY
            ${result}=    Run Keyword    ${keyword}    &{args}
        EXCEPT    ${error_regex}    type=regexp
            Log    \n--${error_regex}--\n    console=${True}
            Log    \n--${keyword} timed out, restarting gNB--\n    console=${True}
            Sleep    30s
        ELSE
            RETURN    ${result}
        END
    END

Upload swconfig
    Upload Swconfig On Classical Gnb    sw_config_path=${sw_config_path}

Setup UE specific variables
    taf.ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    ${primary_ue_id}=    Get Variable Value    ${primary_ue_id}    ${tl.ues[0].serial_number}
    Set Global Variable    ${primary_ue_id}    ${primary_ue_id}
    Log to console    \n--Set primary ue id: ${primary_ue_id} --\n

Enable mobile data on UE
    Execute ue pc cmd    ue_id=${0}    cmd=cmd.exe /c "adb -s ${primary_ue_id} shell svc data enable"

Attach Ue and check 5G state
    [Arguments]    ${ue_alias}    ${scg_fails}
    FOR    ${i}    IN RANGE    30
        Log To Console    \n\n==== Attach UE to 5G: attempt ${i} (SCG failures:${scg_fails}) ====\n
        Sleep    10s
        taf.ue.Attach Ue    ${ue_alias}
        Sleep    30s
        ${5G_STATE}=    taf.ue.Get Ue Info    ${ue_alias}    NR_STATE
        Log to console    \n--5G_STATE detected: ${5G_STATE}--\n
        sleep    10s
        Enable mobile data on UE
        sleep    10s
        ${ip_addr}=    taf.ue.Get Ue Info    ${ue_alias}    IP
        IF    $ip_addr is None    Log to console    Ue IP is none
        IF    '${5G_STATE}' == '${expected_5g_state}' and $ip_addr is not None
            BREAK
        END
        Log to console    ---- UE Attach to 5G failed. 5G_STATE incorrect ----\n
        Log To Console    ---- Detach and restart UE due to incorrect 5G_STATE ----\n
        taf.ue.Detach UE    ${ue_alias}
        Sleep    40s
    END
    IF    '${5G_STATE}' == '${expected_5g_state}'
        Log to console    \n\n======== UE Attach to 5G succeeds ========\n\n
    ELSE
        Fail    UE cannot attach to 5G
    END
    Sleep    30s

Start DLUL Data Transfer And Verify Throughput Smawave
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Sleep    15s
    ${start_time}=    Get Current Date
    ${expected_end_time}=    Add Time To Date    ${start_time}    ${duration}
    Log    \n--Starting DLUL data transfer (Smawave)--\n    console=${True}
    Log    \n--Start Time: ${start_time}--\n    console=${True}
    Log    \n--Expected end time: ${expected_end_time}--\n    console=${True}
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}
    Sleep    ${duration}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation}    0s
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation}    0s
    ${end_time}=    Get Current Date
    Postconditions_ForUE
    Log    \n--Finished DLUL data transfer (Smawave)--\n    console=${True}
    Log    \n--End Time: ${end_time}--\n    console=${True}

Start DLUL Data Transfer And Verify Throughput Android
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    Setup UE specific variables
    Attach Ue and check 5G state    ue_alias=UE_${ue_index}    scg_fails=0
    Sleep    15s
    ${start_time}=    Get Current Date
    ${expected_end_time}=    Add Time To Date    ${start_time}    ${duration}
    Log    \n--Starting DLUL data transfer (Android UE)--\n    console=${True}
    Log    \n--Start Time: ${start_time}--\n    console=${True}
    Log    \n--Expected end time: ${expected_end_time}--\n    console=${True}
    Start Data Transfer DL&UL and Verify Troughput    duration=${duration}    tput_dl=${dl_throughput}    tput_ul=${ul_throughput}
    ...    deviation=${max_deviation}    alias=UE_${ue_index}    protocol=tcp    parallel_streams_dl=6    parallel_streams_ul=6
    ${end_time}=    Get Current Date
    Log    \n--Finished DLUL data transfer (Android UE)--\n    console=${True}
    Log    \n--End Time: ${end_time}--\n    console=${True}
    taf.ue.Detach UE    UE_${ue_index}

Collect logs early
    Log    \n--Collecting logs early--\n    console=${True}
    Collect Logs After Test Finished

Setup Suite Variables
    Setup build specific variables
    Setup BTS specific variables

Setup build specific variables
    Set Suite Variable    $build_branch    ${ENB_BUILD.split("_")[0]}
    Log to console    \n--Detected build branch: ${build_branch}--\n

Setup BTS specific variables
    Set Suite Variable    ${dist_name}    MRBTS-78192/NRBTS-78192
    Set Suite Variable    ${expected_5g_state}    5G_NSA

Create test log directory
    Log to console    Test log path: ${LOG_PATH}
    create directory    ${LOG_PATH}

Set Initial NR RTWP Counters State
    Set NR RTWP Counters Interval    disabled
    Set NR RTWP Counters Status    false

Set NR RTWP Counters Status
    [Arguments]    ${status}
    # robocop: disable=0502
    gnbscf.perform_configuration_parameter_recommissioning    operation=update
    ...    dist_name=${dist_name}
    ...    parameter=actRtwpMeasurement
    ...    value=${status}
    ...    timeout=300

    Wait for cells to be OnAir
    Sleep    30s

Wait For Counter Interval To Expire
    [Arguments]    ${wait_time}=310s
    ${start_time}=    Get Current Date
    ${end_time}=    Add Time To Date    ${start_time}    ${wait_time}
    Log to console    \n--Waiting for counter interval to expire--\n
    Log to console    \n--Start time: ${start_time}--\n
    Log to console    \n--Expected end time: ${end_time}--\n
    Sleep    ${wait_time}
    Log to console    \n--Counter interval wait completed--\n

Set NR RTWP Counters Interval
    [Arguments]    ${value}
    # robocop: disable=0502
    gnbscf.perform_configuration_parameter_recommissioning    operation=update
    ...    dist_name=${dist_name}/NRPMRNL-1
    ...    parameter=miNrRtwp
    ...    value=${value}
    ...    timeout=300

    Wait for cells to be OnAir
    Sleep    30s

Wait for cells to be OnAir
    Log to console    \n--Wait for cells to be OnAir--\n
    gnbcell.Wait For All Cells To Be Onair    timeout=600
    Log to console    \n--Cells are OnAir--\n

Extract data from counter GUI
    [Arguments]    ${current_counter}
    ${counter_output}=    gnbcounter.get_pm_counter_info_via_gui    counter_id=${current_counter}    only_latest_value=${False}
    ${output_data}=    convert_gui_counter_values_to_list    ${counter_output}
    RETURN    ${output_data}

Extract data from counter scout
    [Arguments]    ${current_counter}    ${start_time}    ${end_time}
    ${counter_output}=    get_scout_pm_counter    ${current_counter}   start_time=${start_time}    end_time=${end_time}
    ${extracted_counter_output}=    convert_scout_counter_values_to_list    ${counter_output}
    RETURN    ${extracted_counter_output}

Extract data from counter
    [Arguments]    ${current_counter}
    ${counter_output}=    gnbcounter.get_counter    counter_ids=${current_counter}
    ${parsed_output}=    gnbcounter.extract_counter_data_from_response    ${counter_output}    ${current_counter}
    ${extracted_counter_tput}=     convert_counter_values_to_list    ${parsed_output}
    RETURN    ${extracted_counter_tput}

Generate counter list
    ${counter_list}=    Create List
    FOR    ${x}    IN RANGE    0    3
        FOR    ${y}    IN RANGE    0    2
            ${current_counter}=    Set Variable    M55369C00${x}0${y}
            Append To List    ${counter_list}    ${current_counter}
        END
    END
    RETURN    ${counter_list}

Verify Counters Existence
    ${counter_list}=    Generate counter list
    ${merged_counter_list}=    Set Variable    ${{ ','.join($counter_list) }}
    FOR    ${current_counter}    IN    @{counter_list}
        Log    Verifying counter ${current_counter}    console=${True}
        ${counter_data}=    Extract data from counter    current_counter=${current_counter}
        ${stripped_counter_data}=    strip_counter_values_before_date    ${counter_data}    ${test_start_time}
        verify_disabled_nr_rtwp_counter_correctness    ${stripped_counter_data}
    END
