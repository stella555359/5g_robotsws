*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library    ./resources/keywords.py    WITH NAME    keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      cell

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
...                         Radio unit reset triggered by peer BTS

${FID1907}                  TX out of order
${FID1920}                  No feedback signal
${FID1908}                  RF module gain adjusting failure
${FID4003}                  Transmission path failure
${FID49}                    Cell blocked
${FID1907_RESET}            Radio autonomous reset as recovery action
${FID1920_RESET}            Radio autonomous reset as recovery action
${FID4773_RESET}            Radio unit reset triggered by peer BTS

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_TPUT_UL}                   20Mbits/sec
${DEFAULT_DEVIATION_UL}              20%
${DEFAULT_TPUT_DL}                   40Mbits/sec
${DEFAULT_DEVIATION_DL}              20%
${UE_TYPE}                           quectel

${TC03_ITERATIONS}                   5
${TC12_ITERATIONS}                   5
${TC14_ITERATIONS}                   5
${TC16_ITERATIONS}                   5

*** Test Cases ***
CB009504_TC03
    [Tags]    tc03
    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in startup    impacted_cell=225    rmod_id=3   rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC03_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC03_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC03 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC12
    [Tags]    tc12
    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=225    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC12_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC12_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC12 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC14
    [Tags]    tc14
    &{final_results}=    Create Dictionary

    Preparation RU with simulated TX broken in runtime    impacted_cell=225    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC14_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC14_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC14 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_TC16
    [Tags]    tc16
    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=225    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC16_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC16_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Iteration${i+1}

        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC16 operations
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

    Wait Until Keyword Succeeds    10min    10s    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${impacted_cell}


Preparation RU with simulated TX broken in startup
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}

    keywords.Reset Site

    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    15s    keywords.verify_RMOD_procedural_status
    ...                                                                                 rmod_id=${rmod_id}
    ...                                                                                 status=configured

    keywords.trigger_FID1920_in_startup    rmod_sn=${rmod_sn}

    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
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

    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID4773_RESET}

    Wait Until Keyword Succeeds    10min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded

    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1920}

    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${impacted_cell}

Preparation RU with simulated TX broken in runtime
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}

    keywords.Reset Site

    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                                 rmod_id=${rmod_id}
    ...                                                                                 status=configured

    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status
    ...                                                                         rmod_id=${rmod_id}
    ...                                                                         status=configured

    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Repeat Keyword    10min    Verify Alarm is Not Active on gNB    fault_name=${FID4773_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${impacted_cell}

Block Unblock Cell
    [Arguments]    ${cell_id}
    @{CELL_ID_LIST}    Create List    ${cell_id}
    Wait Until Keyword Succeeds    2min    30s    T07_keywords.Block Cells    cell_list=@{CELL_ID_LIST}

    Wait Until Keyword Succeeds    2min    10s    cell.Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=offline
    ...                                                                    blocking_state=Blocked

    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID49}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    Wait Until Keyword Succeeds    2min    30s    T07_keywords.Unblock Cells    cell_list=@{CELL_ID_LIST}

    Wait Until Keyword Succeeds    2min    10s    cell.Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded
    ...                                                                    blocking_state=Unblocked

    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Not Active on gNB    fault_name=${FID49}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Lock Unlock Cell
    [Arguments]    ${cell_id}

    keywords.Lock eNB Cell   cell_id=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=disabled
    ...                                                                    availability_status=offline
    ...                                                                    administrative_state=Locked

    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    keywords.Unlock eNB Cell   cell_id=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded
    ...                                                                    administrative_state=Unlocked

    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Reset LTE Cell
    [Arguments]    ${cell_id}

    keywords.Reset Cell via GUI   cell_id=${cell_id}

    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${cell_id}

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                    operational_state=enabled
    ...                                                                    availability_status=degraded
    ...                                                                    administrative_state=Unlocked

    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Prepare UE PC Connection
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    # wait for complete `ute_ue.Require UE`

L3 CALL
    [Arguments]    ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    12
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
    ...                           parallel_streams=4

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${tput_ul}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

Perform TC03 operations
    Block Unblock Cell    cell_id=225
    L3 CALL    tput_dl=20Mbits/sec    tput_ul=20Mbits/sec
    Verify statuses and alarms

Perform TC12 operations
    Block Unblock Cell    cell_id=225
    L3 CALL    tput_dl=20Mbits/sec    tput_ul=20Mbits/sec
    Verify statuses and alarms

Perform TC14 operations
    Lock Unlock Cell    cell_id=225
    L3 CALL    tput_dl=20Mbits/sec    tput_ul=20Mbits/sec
    Verify statuses and alarms

Perform TC16 operations
    Reset LTE Cell    cell_id=225
    L3 CALL    tput_dl=20Mbits/sec    tput_ul=20Mbits/sec
    Verify statuses and alarms

Collect Failure Data and Restore Environment
    [Arguments]    ${error_message}
    Log To Console    Error message: ${error_message}
    Collect Logs After Test Finished    collect_syslog=${True}    collect_snapshot_from_ru=${True}
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME
