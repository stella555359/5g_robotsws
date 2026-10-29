*** Settings ***
Documentation
...   author:     Dawid Dabrowski, Jakub Matuszczyk
...   contact:    dawid.dabrowski@nokia.com,  jakub.matuszczyk@nokia.com
...   maintainer: jakub.matuszczyk@nokia.com

Library   DateTime                                                                                       WITH NAME    dt
Library   OperatingSystem                                                                                WITH NAME    os
Library   SSHLibrary                                                                                     WITH NAME    ssh
Library   taf.sbts.oam.coam.admin                                                                        WITH NAME    coam
Library   taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                                          WITH NAME    gnbbbu
Library   taf.rfrl.ue.ute_ue_config.UteUeConfig                                                          WITH NAME    uteueconfig
Library   taf.rfrl.utilities.logger.custom_logger                                                        WITH NAME    logger
Library   ute_ue                                                                                         WITH NAME    ue
Library    ./suite_specific_keywords.py
Resource  taf/rfrl/bts/robot/gnb.robot
Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables         taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Suite Setup
    logger.Log Banner to Console    Suite Setup
    logger.Log Info to Console    Perform Common Suite Setup
    Common Suite Setup

Suite Setup UUF
    logger.Log Banner to Console    Suite Setup for UUF tests
    logger.Log Info to Console    Perform Common Suite Setup
    Common Suite Setup
    Prepare for UUF Execution

Test Setup
    logger.Log Banner to Console    Test Setup
    logger.Log Info to Console    Perform Common Preconditions
    Common Preconditions    collect_syslog=${False}
    logger.Log Banner to Console    Test Procedure

Test Setup UUF
    logger.Log Banner to Console    Test Setup for UUF tests
    logger.Log Info to Console    Perform Common Preconditions
    Common Preconditions    collect_syslog=${False}
    logger.Log Info to Console    Require UE
    ue.Require Ue    UE_1  capabilities=REAL_ANDROID_UE
    logger.Log Banner to Console    Test Procedure

Test Teardown
    logger.Log Banner to Console    Test Teardown
    logger.Log Info to Console    Perform Common Postconditions
    Common Postconditions   collect_syslog=${False}

Prepare for UUF Execution
    [Documentation]    Prepare variables and environment for UUF test execution
    IF    '${SOURCE_SW}'=='${None}'
        ${source_sw_for_test} =    Get Source SW
        Set Suite Variable    ${SOURCE_SW}    ${source_sw_for_test}
    END
    IF    '${TARGET_SW}'=='${None}'
        ${target_sw_for_test}    ${release} =    Get Target SW
        Set Suite Variable    ${TARGET_SW}    ${target_sw_for_test}
    ELSE
        ${target_sw_for_test}    ${release} =    Adjust Sw Release    ${TARGET_SW}
        Set Suite Variable    ${TARGET_SW}    ${target_sw_for_test}
    END

    IF    '${release}' == 'SBTS25R3'
        Set Global Variable    ${TEST_QC_ID}    ${TEST_QC_ID_SBTS25R3}
    ELSE
        Set Global Variable    ${TEST_QC_ID}    ${TEST_QC_ID_TRUNK}
    END

    Set To Dictionary    ${GNB}    source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}
    logger.Log Info to Console    Source SW for test: ${SOURCE_SW}
    logger.Log Info to Console    Target SW for test: ${TARGET_SW}
    logger.Log Info to Console    Target Release: ${release}, QC Test ID for test based on SW release: ${TEST_QC_ID}

Attach UE
    [Documentation]    The keyword perform attach
    logger.Log Info to Console    Attach UEs
    ue.Attach UE   UE_1    timeout=30
    Sleep  5s

Detach UE
    [Documentation]    This keyword perform detach
    logger.Log Info to Console    Detach UEs
    ue.Detach Ue    UE_1
    Sleep  3s

Start DL and UL data transmission for specified time
    [Arguments]    ${data_transfer_time}    ${tput_ul}    ${tput_dl}
    [Documentation]    Keyword starts UDP traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    logger.Log Info to Console    Start DL and UL data transmission for specified time
    ue.Start Data Transfer    dt_name=DT_UL    ue_alias=UE_1
    ...                       direction=ul    duration=${data_transfer_time}s    protocol=tcp
    ...                       throughput=${tput_ul}    max_segment_size=1350B    parallel_streams=2
    Sleep    2s
    ue.Start Data Transfer    dt_name=DT_DL    ue_alias=UE_1
    ...                       direction=dl    duration=${data_transfer_time}s    protocol=tcp
    ...                       throughput=${tput_dl}    max_segment_size=1350B    parallel_streams=2
    Sleep    2s

Stop DL and UL data transmission
    [Documentation]    Stop DL and UL data transmission
    logger.Log Info to Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_UL
    ue.Stop Data Transfer    dt_name=DT_DL
    Sleep    2s

Await DL and UL data transmission finish
    [Documentation]    Await DL and UL data transmission finish
    logger.Log Info to Console    Await DL and UL data transmission finish
    ue.Await Data Transfer Finish    DT_UL
    ue.Await Data Transfer Finish    DT_DL

Verify DL and UL data transmission loss
    [Arguments]    ${tput_ul}    ${tput_dl}    ${deviation}=10
    [Documentation]    Keyword checks if throughput datagram loss is below max_allowed_datagram_loss.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param max_allowed_data_loss:   max allowed data loss value in percentage
    logger.Log Info to Console    Verify DL and UL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=DT_UL    tput=${tput_ul}    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL    tput=${tput_dl}    deviation=${deviation}

Verify L3 call
    [Arguments]    ${data_transfer_time}    ${tput_ul}=${none}    ${tput_dl}=${none}    ${deviation}=${none}
    [Documentation]   This keyword verify if tcp data transmission reach desired target
    ...    :param data_transfer_time: Time of data transfer
    ...    :param tput_ul: Desired uplink throughput
    ...    :param tput_dl: Desired downlink throughput
    ...    :param deviation: Allowed deviation of uplink and downlink throuhgput
    logger.Log Info to Console    Verify L3 call
    Attach UE
    Start DL and UL data transmission for specified time           data_transfer_time=${data_transfer_time}
    ...                                                            tput_ul=${tput_ul}
    ...                                                            tput_dl=${tput_dl}
    Await DL and UL data transmission finish
    Stop DL and UL data transmission
    Verify DL and UL data transmission Loss                        tput_ul=${tput_ul}
    ...                                                            tput_dl=${tput_dl}
    ...                                                            deviation=${deviation}
    Detach UE

Configure Power Meter
    logger.Log Info to Console    Configuring power meter
    Perform Configuration Parameter Recommissioning On gNB
    ...     dist_name=MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1
    ...     param_name=actPowerMeter
    ...     param_value=true

Get Power Usage On RUs
    logger.Log Info to Console    Collecting RU power usage
    ${result}=   Get RUs Power Usage
    logger.Log Info to Console    Power usage: ${result}
    [Return]  ${result}

Enable Deep Sleep
    [Arguments]     ${rmod_dist_name}
    logger.Log Info to Console    Enabling Deep Sleep on ${rmod_dist_name}
    Perform Configuration Parameter Recommissioning On gNB
    ...     dist_name=${rmod_dist_name}
    ...     param_name=energySavingMode
    ...     param_value=DEEPSLEEP

Lock Cells And Wait For SLEEP State On RMODs
    logger.Log Info to Console    Locking all cells
    Lock All Cells
    logger.Log Info to Console    Waiting for radio sleep
    gnbru.Wait for all radio unit statuses
    ...     power_state=SLEEP
    ...     timeout=600

Unlock Cells And Wait For AWAKE State On RMODs
    logger.Log Info to Console    Unlocking all cells
    Unlock All Cells
    logger.Log Info to Console    Waiting for radio awake
    gnbru.Wait for all radio unit statuses
    ...     availability_status=online
    ...     operational_state=enabled
    ...     administrative_state=unlocked
    ...     power_state=AWAKE
    ...     timeout=600
    logger.Log Info to Console    Waiting for cells onAir
    gnbcell.Wait for all cells to be OnAir

Validate Power Usage Change
    [Arguments]     ${start_power_usage}    ${end_power_usage}    ${expected_change_type}   ${expected_change_percent}   ${rmod_id}=${None}
    [Documentation]    Validates the change in radio power usage.
    ...    :param start_power_usage: dict[str, float], Power usage before the change for each RMOD
    ...    :param end_power_usage: dict[str, float], Power usage after the change for each RMOD
    ...    :param expected_change_type: str, Type of expected change (increase/decrease)
    ...    :param expected_change_percent: float|int, Expected percent change
    ...    :param rmod_id: str|None, (Optional) RMOD identifier
    ...    :returns: None
    logger.Log Info to Console    Validating radio power usage change
    validate_power_change
    ...     start_power_usage=${start_power_usage}
    ...     end_power_usage=${end_power_usage}
    ...     rmod_id=${rmod_id}
    ...     expected_change_type=${expected_change_type}
    ...     expected_change_percent=${expected_change_percent}
