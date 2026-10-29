*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library      ./resources/keywords.py    WITH NAME    keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords

Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup       Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}
...                       AND    Common Preconditions With Watching Alarms
Test Teardown    Run Keywords    gnb_rus.Reset Radio Unit    radio_unit_id=3
...                       AND    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair
...                       AND    Custom Postconditions With Watching Alarms
...                       AND    Run Keyword If Test Failed    tl_prep.Prepare Testline
...                                                                should_LTE_neighbour_be_changed=${False}
...                                                                should_5G_neighbour_be_changed=${False}
...                                                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                       AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    TX out of order
...                         Radio autonomous reset as recovery action
...                         RF module gain adjusting failure
...                         Transmission path failure
...                         No feedback signal
...                         Cell blocked
...                         Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
...                         Radio unit reset triggered by peer BTS
...                         Not able to synchronize baseband bus
...                         No connection to unit
...                         Radio slave has taken temporary radio master role

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

${TC16_ITERATIONS}                   2

*** Test Cases ***
CB009504_B_16_degraded_LTE_Cell_reset_after_failed_RU_recovery
    [Tags]    ITEM_B    tc16
    Delete Maintenance Window    bts_host=10.84.140.145
    Set Act Force Unit Auto Reset    bts_host=10.84.140.145
    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=225    rmod_id=3    rmod_sn=BL2106G10I6
    FOR    ${i}    IN RANGE    ${TC16_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC16_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/TC16/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC16 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

*** Keywords ***
Perform TC16 operations
    Reset LTE Cell    cell_id=225
    L3 CALL    tput_dl=20Mbits/sec    tput_ul=20Mbits/sec
    Verify statuses and alarms    cell_id=225

Collect Failure Data and Restore Environment
    [Arguments]    ${error_message}
    Log To Console    Error message: ${error_message}
    Collect Logs After Test Finished    collect_syslog=${True}    collect_snapshot_from_ru=${True}
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME

Preparation RU with simulated TX broken in runtime
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}
    keywords.Reset Site    bts_host=10.84.140.145
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Repeat Keyword    5min    Verify Alarm is Not Active on gNB    fault_name=${FID4773_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Ltecells Are Onair
    ...                                                                    ltecells_to_skip=${impacted_cell}

Reset LTE Cell
    [Arguments]    ${cell_id}
    keywords.Reset Cell via GUI   cell_id=${cell_id}
    keywords.Verify All Expected Ltecells Are Onair    ltecells_to_skip=${cell_id}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded
    ...                                                                   administrative_state=Unlocked
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}

Verify statuses and alarms
    [Arguments]    ${cell_id}
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    keywords.verify_all_bbmods_online_status
    keywords.Verify All Expected Ltecells Are Onair    ltecells_to_skip=${cell_id}
    Verify Default Allowed Alarms on gNB

Prepare UE PC Connection
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    wait for complete `ute_ue.Require UE`

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
    ...                           parallel_streams=2

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
    ...                           parallel_streams=2

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${tput_ul}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

Custom Postconditions
    [Arguments]     ${collect_syslog}=${True}
    ...             ${collect_snapshot_from_ru}=${True}
    gnbalarm.Wait Until Callback Logs Collection Finished
    gnbcell.Verify All Cells are OnAir
    Verify gNB is onAir
    Verify Default Allowed Alarms on gNB
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs
    interface.Common step trigger
    gnbbbu.Teardown All Browsers
    [Teardown]    Run Keywords
    ...           Collect Logs After Test Finished              collect_syslog=${collect_syslog}
    ...                                                         collect_snapshot_from_ru=${collect_snapshot_from_ru}
    ...           AND
    ...           Compress moler syslogs
    ...           AND
    ...           Restore Origin TAF Testline Configuration

Custom Postconditions With Watching Alarms
    Custom Postconditions
    [Teardown]    Run Keywords
    ...           gnb_alarm.Stop watching alarms
    ...           AND
    ...           Remove Custom Allowed Alarms If Defined
