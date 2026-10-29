*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Resource     taf/rfrl/bts/robot/common/enb_cell.robot
Resource     taf/rfrl/bts/robot/common/enb_alarm.robot
Library      ./resources/keywords.py    WITH NAME    keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords

Suite Setup      Run Keywords    Run Keyword And Ignore Error    tl_prep.prepare_testline    should_LTE_neighbour_be_changed=${False}
...                                                              should_5G_neighbour_be_changed=${False}
...                                                              wait_for_on_air=${False}
...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                       AND    Common Suite Setup With OnAir Test Line Preparation
...                                                          should_LTE_neighbour_be_changed=${True}
...                                                          swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                          list_of_additional_allowed_alarms=${PREPARATION_ALARMS}
Suite Teardown    Common Suite Teardown
Test Setup       Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}
...                       AND    Common Preconditions With Watching Alarms
Test Teardown    Run Keywords    gnb_rus.Reset Radio Unit    radio_unit_id=3
...                       AND    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair
...                       AND    Custom Postconditions With Watching Alarms
...                       AND    Run Keyword If Test Failed    tl_prep.Prepare Testline
...                                                                should_LTE_neighbour_be_changed=${True}
...                                                                should_5G_neighbour_be_changed=${False}
...                                                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                       AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report

*** Variables ***
@{PREPARATION_ALARMS}       No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Cell Activation timeout at gNB-DU
...                         Cell problem due to unavailability of associated links

@{CUSTOM_ALLOWED_ALARMS}    TX out of order
...                         Radio autonomous reset as recovery action
...                         RF module gain adjusting failure
...                         Transmission path failure
...                         No feedback signal
...                         Cell blocked
...                         Radio unit reset triggered by peer BTS
...                         Not able to synchronize baseband bus
...                         Radio slave has taken temporary radio master role

@{ENB_ALLOWED_ALARMS}       Service account root access is enabled
...                         Ethernet port security is disabled
...                         SSH enabled
...                         R&D Service Port enabled
...                         LMP access via port 443
...                         TX out of order
...                         Transmission path failure
...                         Cell blocked
...                         Radio unit reset triggered by peer BTS
...                         Not able to synchronize baseband bus
...                         Radio slave has taken temporary radio master role
...                         No feedback signal

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
${DEFAULT_TPUT_UL}                   110Mbits/sec
${DEFAULT_DEVIATION_UL}              30%
${DEFAULT_TPUT_DL}                   200Mbits/sec
${DEFAULT_DEVIATION_DL}              30%
${UE_TYPE}                           quectel

${TC01_ITERATIONS}                   1
${TC10_ITERATIONS}                   1
${TC16_ITERATIONS}                   1
${TC17_ITERATIONS}                   1
${TC21_ITERATIONS}                   1

*** Test Cases ***
CB009504_A_01_Triggering_fault_to_verify_the_cell_is_set_up_and_operates_with_reduced_performance
    [Tags]    ITEM_A    tc01
    keywords.Set Act Force Unit Auto Reset    expected_value=false
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE   ${TC01_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC01_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/TC01/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC01 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_B_10_successful_RU_recovery_after_FID_trigger
    [Tags]    ITEM_B    t16
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${TC10_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC10_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/TC10/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC10 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_B_16_degraded_LTE_Cell_reset_after_failed_RU_recovery
    [Tags]    ITEM_B    tc16
    Delete Maintenance Window
    Set Act Force Unit Auto Reset
    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=345
    ...                                                   impacted_lte_cell=225
    ...                                                   rmod_id=3
    ...                                                   rmod_sn=BL2106G10I6
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

CB009504_B_17_degraded_NRCell_parameter_changes_after_failed_RU_recovery
    [Tags]    ITEM_B    tc17
    keywords.Set Act Force Unit Auto Reset    expected_value=true
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    Preparation RU with simulated TX broken in runtime    impacted_cell=345
    ...                                                   impacted_lte_cell=225
    ...                                                   rmod_id=3
    ...                                                   rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245
        ...    tput_dl=110Mbits/sec
        ...    tput_ul=110Mbits/sec

    FOR    ${i}    IN RANGE    ${TC17_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC17_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/TC17/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC17 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

CB009504_C_21_successful_RU_recovery_in_maintenance_window
    [Tags]    ITEM_C    tc21
    keywords.Set Act Force Unit Auto Reset    expected_value=false
    keywords.Delete Maintenance Window

    &{final_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${TC21_ITERATIONS}
        Log To Console    Iteration ${i+1}/${TC21_ITERATIONS}
        Set Test Variable    ${LOG_PATH}    ${OUTPUT_DIR}/TC21/Iteration${i+1}
        ${result}    ${error_message} =	Run Keyword And Ignore Error	Perform TC21 operations
        Set To Dictionary    ${final_results}    Iteration ${i+1}    ${result}
        Log To Console    Iteration ${i+1} status: ${result}
        Run Keyword If    "${result}" == "FAIL"    Run Keyword And Ignore Error
        ...               Collect Failure Data and Restore Environment     error_message=${error_message}
    END
    Dictionary Should Not Contain Value    ${final_results}    FAIL

*** Keywords ***
Perform TC01 operations
    Preparation RU with simulated TX broken no recovery    impacted_cell=345    rmod_id=3    rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms    cell_id=345    lte_cell_id=225

Perform TC16 operations
    Reset LTE Cell    cell_id=225
    L3 CALL LTE    tput_dl=20Mbits/sec    tput_ul=20Mbits/sec
    Verify statuses and alarms    cell_id=345    lte_cell_id=225

Perform TC17 operations
    Change Parameter with NRCELL Locking    cell_id=345
    L3 CALL    cell_to_block_id=245    tput_dl=110Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms    cell_id=345    lte_cell_id=225

Perform TC10 operations
    Preparation RU with simulated TX broken in runtime succeessful recovery    impacted_cell=345
    ...                                                                        rmod_id=3
    ...                                                                        rmod_sn=BL2106G10I6
    L3 CALL    cell_to_block_id=245    tput_dl=200Mbits/sec    tput_ul=110Mbits/sec
    Verify statuses and alarms    cell_id=345    lte_cell_id=225

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
    Verify statuses and alarms    cell_id=345    lte_cell_id=225

Verify statuses and alarms
    [Arguments]    ${cell_id}=0    ${lte_cell_id}=0
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    keywords.verify_all_bbmods_online_status
    keywords.Verify All Expected Nrcells Are Onair    nrcells_to_skip=${cell_id}
    keywords.Verify All Expected Ltecells Are Onair    ltecells_to_skip=${lte_cell_id}    bts=enb
    Verify Default Allowed Alarms on gNB
    enbalarm.Verify Allowed Alarms    allowed_alarms=${ENB_ALLOWED_ALARMS}

Collect Failure Data and Restore Environment
    [Arguments]    ${error_message}
    Log To Console    Error message: ${error_message}
    Collect Logs After Test Finished    collect_syslog=${True}    collect_snapshot_from_ru=${True}
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=245

Preparation RU with simulated TX broken no recovery
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}
    keywords.Reset Site
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Wait Until Keyword Succeeds    15min    10s    gnbcell.Verify All Cells Statuses    operational_state=enabled
    ...                                                                        availability_status=online
    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded
    Repeat Keyword    5min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}

Preparation RU with simulated TX broken in runtime
    [Arguments]    ${impacted_cell}    ${impacted_lte_cell}    ${rmod_id}    ${rmod_sn}
    keywords.Reset Site
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on eNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    5min    10s    enbcell.Verify Cell Statuses    cell_id=${impacted_lte_cell}
    ...                                                                           operational_state=disabled
    ...                                                                           availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on eNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    5min    10s    enbcell.Verify Cell Statuses    cell_id=${impacted_lte_cell}
    ...                                                                           operational_state=disabled
    ...                                                                           availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on eNB    fault_name=${FID4773_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    5min    10s    enbcell.Verify Cell Statuses    cell_id=${impacted_lte_cell}
    ...                                                                           operational_state=disabled
    ...                                                                           availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    4min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Repeat Keyword    2min    Run Keywords    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    ...                                AND    Verify Alarm is Not Active on eNB    fault_name=${FID4773_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded
    enbcell.Verify Cell Statuses    cell_id=${impacted_lte_cell}
    ...                             operational_state=enabled
    ...                             availability_status=degraded
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on eNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected ltecells Are Onair
    ...                                                                    ltecells_to_skip=${impacted_lte_cell}
    ...                                                                    bts=enb

Preparation RU with simulated TX broken in runtime succeessful recovery
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}
    keywords.Reset Site
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Sleep    3min    Wait for RMOD in runtime
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907_RESET}
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify All Cells Are Onair
    Repeat Keyword    1min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    Repeat Keyword    1min    Verify Alarm is Not Active on gNB    fault_name=${FID1907}

Preparation RU with simulated TX broken and preconfigured maintenance window
    [Arguments]    ${impacted_cell}    ${rmod_id}    ${rmod_sn}
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_RMOD_procedural_status    rmod_id=${rmod_id}
    ...                                                                                      status=configured
    keywords.trigger_FID1907    rmod_sn=${rmod_sn}
    Repeat Keyword    2min    Verify Alarm is Not Active on gNB    fault_name=${FID1907_RESET}
    Verify Cell Statuses    cell_id=${impacted_cell}
    ...                     operational_state=enabled
    ...                     availability_status=degraded
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    keywords.Verify All Expected Nrcells Are Onair
    ...                                                                    nrcells_to_skip=${impacted_cell}

Reset LTE Cell
    [Arguments]    ${cell_id}
    keywords.Reset ENB Cell   cell_id=${cell_id}
    keywords.Verify All Expected Ltecells Are Onair    ltecells_to_skip=${cell_id}
    ...                                                bts=enb
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on eNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    enbcell.Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                           operational_state=enabled
    ...                                                                           availability_status=degraded
    ...                                                                           administrative_state=Unlocked
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on eNB    fault_name=${FID1907}

Change Parameter with NRCELL Locking
    [Arguments]    ${cell_id}
    keywords.Change Pmax    cell_id=${cell_id}
    Wait Until Keyword Succeeds    2min    2s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                  operational_state=disabled
    ...                                                                  availability_status=offline
    Wait Until Keyword Succeeds    2min    10s    Verify Cell Statuses    cell_id=${cell_id}
    ...                                                                   operational_state=enabled
    ...                                                                   availability_status=degraded
    keywords.Verify All Expected Nrcells Are Onair    nrcells_to_skip=${cell_id}
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
    ...                                                                   operational_state=disabled
    ...                                                                   availability_status=offline
    ...                                                                   blocking_state=Blocked
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID49}
    Run Keyword And Ignore Error    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE:NR5G    ue_type=${UE_TYPE}
    Sleep    5sec    Wait for Change Network Mode complete
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    66
    Sleep    5sec    Wait for Set Active Bands complete
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    NR5G_NSA    71
    Sleep    5sec    Wait for Set Active Bands complete
    Attach UE
    Sleep    5sec    Wait for Attach UE complete
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    Sleep    5sec    Wait for Get UE Info complete
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
    ...                                                                   operational_state=enabled
    ...                                                                   blocking_state=Unblocked
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Not Active on gNB    fault_name=${FID49}

L3 CALL LTE
    [Arguments]    ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    5sec    Wait for Change Network Mode complete
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    12
    Sleep    5sec    Wait for Set Active Bands complete
    Attach UE
    Sleep    5sec    Wait for Attach UEs complete
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    Sleep    5sec    Wait for Get UE Info complete

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

Attach UE
    Log to Console    Attaching UE
    ${status}    Run Keyword And Return Status    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    IF    not ${status}
        Log to Console    UE attach failed, trying to recover UE by rebooting it
        ute_ue.Reboot Ue    ${UE_DEFAULT_ALIAS_NAME}      timeout=${170}
        Sleep    10s    Wait for UE Reboot
        Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}
        Sleep    5sec    # wait for complete `ute_ue.Require UE`
        Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
        Sleep    5sec    # wait for complete `ute_ue.Require UE`
        Log to Console    Attaching UE Again
        ${status}    Run Keyword And Return Status    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    END
    Run Keyword If    not ${status}    Fail    UE attach failed even after recovery

Custom Postconditions
    [Arguments]     ${collect_syslog}=${True}
    ...             ${collect_snapshot_from_ru}=${True}

    gnbalarm.Wait Until Callback Logs Collection Finished
#    Check TRUCK ROLL alarms
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
