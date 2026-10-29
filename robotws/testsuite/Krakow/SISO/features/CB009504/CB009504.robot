*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library      ./resources/keywords.py    WITH NAME    keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords

Suite Setup      Common Suite Setup
Test Setup    Custom Test Setup
Test Teardown    Run keywords    gnb_rus.Reset Radio Unit    radio_unit_id=3
...                       AND    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair
...                       AND    Custom Test Teardown
Suite Teardown    Common Suite Teardown

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    TX out of order
...                         Radio autonomous reset as recovery action
...                         RF module gain adjusting failure
...                         Transmission path failure
...                         No feedback signal
...                         Cell blocked
...                         Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
...                         No X2 link available for a specific LTEENB

${FID1907}                  TX out of order
${FID1920}                  No feedback signal
${FID1908}                  RF module gain adjusting failure
${FID4003}                  Transmission path failure
${FID49}                    Cell blocked
${FID1907_RESET}            Radio autonomous reset as recovery action
${FID1920_RESET}            Radio autonomous reset as recovery action

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_TPUT_UL}                   110Mbits/sec
${DEFAULT_DEVIATION_UL}              20%
${DEFAULT_TPUT_DL}                   220Mbits/sec
${DEFAULT_DEVIATION_DL}              20%
${UE_TYPE}                           quectel

${TC01_ITERATIONS}                   5
${TC02_ITERATIONS}                   5
${TC04_ITERATIONS}                   5
${TC05_ITERATIONS}                   5
${TC09_ITERATIONS}                   5
${TC10_ITERATIONS}                   5
${TC11_ITERATIONS}                   5
${TC13_ITERATIONS}                   5
${TC15_ITERATIONS}                   5
${TC17_ITERATIONS}                   5
${TC21_ITERATIONS}                   5
${TC22_ITERATIONS}                   5

*** Test Cases ***
CB009504_TC01
    [Tags]    tc01
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE   ${TC01_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC01_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC01 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC02
    [Tags]    tc02
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in startup    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC02_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC02_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC02 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC04
    [Tags]    tc04
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in startup    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC04_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC04_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC04 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC05
    [Tags]    tc05
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in startup    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC05_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC05_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC05 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC09
    [Tags]    tc09
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${TC09_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC09_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC09 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC10
    [Tags]    tc10
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${TC10_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC10_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC10 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC11
    [Tags]    tc11
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in startup    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC11_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC11_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC11 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC13
    [Tags]    tc13
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC11_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC11_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC13 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC15
    [Tags]    tc15
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=145
    FOR    ${i}    IN RANGE    ${TC15_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC15_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}

        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC15 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC17
    [Tags]    tc17
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245
        ...    tput_dl=110Mbits/sec
        ...    tput_ul=110Mbits/sec

    FOR    ${i}    IN RANGE    ${TC17_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC17_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC17 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC21
    [Tags]    tc21
    keywords.Set Act Force Unit Auto Reset    expected_value=false
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${TC21_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC21_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC21 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC22
    [Tags]    tc22
    keywords.Set Act Force Unit Auto Reset    expected_value=false
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${TC22_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC22_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}

        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC22 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

*** Keywords ***
Custom Test Setup
    Modify Moler Logging Directory      mode=test case
    Collect Logs During Test            collect_syslog=${True}
    ...                                 raise_exception_when_setup_ru_console_fail=${True}
    gnbbbu.Connect    force=${True}
    Add Custom Allowed Alarms If Defined
    Verify Default Allowed Alarms on gNB
    keywords.verify_all_bbmods_online_status
#    Verify Mandatory Configuration Params Enabled
    gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
    gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

Custom Test Teardown
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    keywords.verify_all_bbmods_online_status
#    Verify gNB is onAir
    Verify Default Allowed Alarms on gNB
#    Run Keyword And Ignore Error    Refresh Scout SCF ID
#    Run Keyword And Ignore Error    Add BTS environment info to report
    interface.Common step trigger
    gnbbbu.Teardown All Browsers
    [Teardown]    Run Keywords
    ...           Collect Logs After Test Finished              collect_syslog=${True}
    ...                                                         collect_snapshot_from_ru=${True}
    ...           AND
    ...           Compress moler syslogs
    ...           AND
    ...           Restore Origin TAF Testline Configuration
    ...           AND
    ...           gnb_alarm.Stop watching alarms
    ...           AND
    ...           Remove Custom Allowed Alarms If Defined


Verify statuses and alarms
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    keywords.verify_all_bbmods_online_status
#    Verify gNB is onAir
    Verify Default Allowed Alarms on gNB


Preparation RU with simulated TX broken and preconfigured maintenance window
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}

    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                                 rmod_id=${rmod_id}
    ...                                                                                 status=configured

    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}


Preparation RU with TX broken
    [Arguments]    ${impacted_cell}

    keywords.Reset Site
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    10min    5s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed


    Wait Until Keyword Succeeds    10min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded

    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}

    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    Wait Until Keyword Succeeds    10min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}


Preparation RU with simulated TX broken in startup
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}

    keywords.Reset Site

    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    15s    keywords.verify_RMOD_procedural_status
    ...                                                                                 rmod_id=${rmod_id}
    ...                                                                                 status=disabled

    keywords.trigger_FID1920_in_startup    rmod_sn=${rmod_sn}

    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1920_RESET}
    Wait Until Keyword Succeeds    10min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed

    Sleep    15sec    Wait for 'RMOD reset' completed
    Wait Until Keyword Succeeds    10min    15s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    keywords.trigger_FID1920_in_startup    rmod_sn=${rmod_sn}

    Wait Until Keyword Succeeds    2min    5s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1920_RESET}

    Wait Until Keyword Succeeds    10min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded

    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1920}

    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}

Preparation RU with simulated TX broken in runtime
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}

    keywords.Reset Site

    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                                 rmod_id=${rmod_id}
    ...                                                                                 status=configured

    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}

Preparation RU with simulated TX broken in runtime succeessful recovery
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}

    keywords.Reset Site

    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                                 rmod_id=${rmod_id}
    ...                                                                                 status=configured

    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

#    Wait Until Keyword Succeeds    10min    10s    Verify All Cells Are Onair
    Wait Until Keyword Succeeds    10min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=0

    Repeat Keyword    1min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    Repeat Keyword    1min    Verify Alarm is Not Active on gNB    fault_name=${FID1907}


Block Unblock Cell
    [Arguments]    ${cell_id}
    ${FID49}    Set Variable    Cell blocked
    @{CELL_ID_LIST}    Create List    ${cell_id}
    Wait Until Keyword Succeeds    2min    30s    T07_keywords.Block Cells    cell_list=@{CELL_ID_LIST}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=offline
    ...                                                                    blocking_state=Blocked

    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID49}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    Wait Until Keyword Succeeds    2min    30s    T07_keywords.Unblock Cells    cell_list=@{CELL_ID_LIST}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded
    ...                                                                    blocking_state=Unblocked

    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Not Active on gNB    fault_name=${FID49}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Lock Unlock Cell
    [Arguments]    ${cell_id}

    T07_keywords.Lock gNB Cell   cell_id=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=offline
    ...                                                                    administrative_state=Locked

    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    T07_keywords.Unlock gNB Cell   cell_id=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded
    ...                                                                    administrative_state=Unlocked

    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Reset NR Cell
    [Arguments]    ${cell_id}

    keywords.Reset Cell via GUI   cell_id=${cell_id}

    keywords.Verify All Expected Nrcells Are Onair    nrcells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded
    ...                                                                    administrative_state=Unlocked

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Change Parameter with NRCELL Locking
    [Arguments]    ${cell_id}
    keywords.Change Random Parameter with NRCELL Locking    cell_id=${cell_id}

    Wait Until Keyword Succeeds    2min    2s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=offline

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded

    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Prepare UE PC Connection
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    # wait for complete `ute_ue.Require UE`

L3 CALL
    [Arguments]    ${cell_to_block_id}    ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    ${FID49}    Set Variable    Cell blocked
    @{CELL_ID_LIST}    Create List    ${cell_to_block_id}
    Wait Until Keyword Succeeds    2min    30s    T07_keywords.Block Cells    cell_list=@{CELL_ID_LIST}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_to_block_id}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=offline
    ...                                                                    blocking_state=Blocked

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID49}

    Run Keyword And Ignore Error    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE:NR5G    ue_type=${UE_TYPE}
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    66
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    NR5G_NSA    71
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${tput_dl}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=10

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                         tput=${tput_dl}
    ...                                         deviation=${DEFAULT_DEVIATION_DL}

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${tput_ul}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${tput_ul}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

    Wait Until Keyword Succeeds    2min    30s    T07_keywords.Unblock Cells    cell_list=@{CELL_ID_LIST}
    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_to_block_id}
    ...                                                                    operational_state=enabled
    ...                                                                    blocking_state=Unblocked
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Not Active on gNB    fault_name=${FID49}


Perform TC01 operations
    Preparation RU with simulated TX broken in startup    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC02 operations
    Block Unblock Cell    cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC04 operations
    Lock Unlock Cell   cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC05 operations
    Change Parameter with NRCELL Locking    cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC09 operations
    Preparation RU with simulated TX broken in runtime    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC10 operations
    Preparation RU with simulated TX broken in runtime succeessful recovery    impacted_cell=345
    ...                                                                        rmod_id=3
    ...                                                                        rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245    tput_dl=220Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC11 operations
    Block Unblock Cell    cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC13 operations
    Lock Unlock Cell   cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC15 operations
    Reset NR Cell    cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC17 operations
    Change Parameter with NRCELL Locking    cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms


Perform TC21 operations
    keywords.Setup Maintenance Window
    Preparation RU with simulated TX broken and preconfigured maintenance window    impacted_cell=345
    ...                                                                             rmod_id=3
    ...                                                                             rmod_sn=BL2106G10I6
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_operational_state    rmod_id=3
    ...                                                                                      status=disabled
    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair
    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1907}
    keywords.Verify Maintenance Window Result    rmod_id=3
    L3 CALL    cell_to_block_id=245    tput_dl=220Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Perform TC22 operations
    keywords.Setup Maintenance Window
    Preparation RU with simulated TX broken and preconfigured maintenance window    impacted_cell=345
    ...                                                                             rmod_id=3
    ...                                                                             rmod_sn=BL2106G10I6
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_operational_state    rmod_id=3
    ...                                                                                      status=disabled
    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair
    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1907}
    keywords.Verify Maintenance Window Result    rmod_id=3
    Preparation RU with simulated TX broken and preconfigured maintenance window    impacted_cell=345
    ...                                                                             rmod_id=3
    ...                                                                             rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms

Collect Failure Data and Restore Environment
    [Arguments]    ${error_message}
    Log To Console    Error message: ${error_message}
    Collect Logs After Test Finished    collect_syslog=${True}    collect_snapshot_from_ru=${True}
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME
    gnbcell.Unblock Cell    cell_id=245
