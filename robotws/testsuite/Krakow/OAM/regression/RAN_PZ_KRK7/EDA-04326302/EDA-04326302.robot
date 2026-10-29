*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library     ./resources/keywords.py    WITH NAME    EDA_keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords


Suite Setup      Run Keywords    Run Keyword And Ignore Error    tl_prep.prepare_testline    should_LTE_neighbour_be_changed=${False}
...                                                              should_5G_neighbour_be_changed=${False}
...                                                              wait_for_on_air=${False}
...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                       AND    Common Suite Setup With OnAir Test Line Preparation
...                                                              should_LTE_neighbour_be_changed=${True}
...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                              list_of_additional_allowed_alarms=${PREPARATION_ALARMS}
Test Setup    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}
...                    AND    Common Preconditions With Watching Alarms
Test Teardown    Run Keywords    gnb_rus.Reset Radio Unit    radio_unit_id=3
...                       AND    gnb_rus.Reset Radio Unit    radio_unit_id=2
...                       AND    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair
...                       AND    Custom Postconditions With Watching Alarms
...                       AND    Run Keyword If Test Failed    tl_prep.Prepare Testline
...                                                               should_LTE_neighbour_be_changed=${True}
...                                                                should_5G_neighbour_be_changed=${False}
...                                                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                       AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report
Suite Teardown    Common Suite Teardown

*** Variables ***
@{PREPARATION_ALARMS}       No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Cell Activation timeout at gNB-DU
...                         Cell problem due to unavailability of associated links

@{CUSTOM_ALLOWED_ALARMS}    TX out of order
...                         RF module gain adjusting failure
...                         Transmission path failure
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Cell blocked

${FID1907}      TX out of order
${FID1908}      RF module gain adjusting failure
${FID4003}      Transmission path failure

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_TPUT_UL}                   110Mbits/sec
${DEFAULT_DEVIATION_UL}              20%
${DEFAULT_TPUT_DL}                   110Mbits/sec
${DEFAULT_DEVIATION_DL}              20%
${UE_TYPE}                           quectel
${CELL_ID}                           345
${CELL_PCI}                          345
${RMOD_ID}                           3
${RMOD_SN}                           BL2106G10I6
${ITERATIONS}                        2

*** Test Cases ***
EDA-04326302_delta_commissioning_with_cell_lock_and_l3_call_with_fid1907
    [Tags]    EDA
    FOR    ${i}    IN RANGE    ${ITERATIONS}
        Log To Console    Iteration ${i+1}
        EDA_keywords.trigger_FID1907    rmod_sn=${RMOD_SN}
        Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on gNB    fault_name=${FID1907}
        Verify Cell Statuses    cell_id=345    operational_state=Enabled    availability_status=Degraded
        EDA_keywords.change_pmax    cell_id=${CELL_ID}
        Wait Until Keyword Succeeds    2min    10s
        ...    Verify Cell Statuses    cell_id=345    operational_state=Enabled    availability_status=Degraded
        EDA_keywords.change_expected_cell_size    cell_id=${CELL_ID}
        Wait Until Keyword Succeeds    2min    10s
        ...    Verify Cell Statuses    cell_id=345    operational_state=Enabled    availability_status=Degraded
        L3 CALL    cell_to_block_id=245
        gnb_rus.Reset Radio Unit    radio_unit_id=${RMOD_ID}
        Wait Until Keyword Succeeds    10min    30s    gnbcell.Verify All Cells Are Onair
        Wait Until Keyword Succeeds    1min    10s    Verify Alarm Is Not Active On gNB    fault_name=${FID1907}
        Verify Alarm Is Not Active On gNB    fault_name=${FID1908}
        Verify Alarm Is Not Active On gNB    fault_name=${FID4003}
    END

*** Keywords ***
Prepare UE PC Connection
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    wait for complete `ute_ue.Require UE`

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
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    66
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    NR5G_NSA    71
    Sleep    10sec
    Attach UE
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
    ...                                                                   operational_state=enabled
    ...                                                                   blocking_state=Unblocked
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Not Active on gNB    fault_name=${FID49}

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
