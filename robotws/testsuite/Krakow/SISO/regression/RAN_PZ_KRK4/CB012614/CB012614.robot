*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB012614 test cases

Library     BuiltIn
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012614/resources/Keywords.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012614/resources/Delta_generator.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012614/resources/Manual_SiSo_CM_Recommissioning.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/data_transfer_configuration_1.py
Variables   ./resources/data_transfer_configuration_3.py
Variables   ./resources/data_transfer_configuration_4.py
Variables   ./resources/data_transfer_configuration_9.py
Variables   ./resources/data_transfer_configuration_9_lte.py
Variables   ./resources/recommissioning_parameters.py

Suite Setup         Common Suite Setup With Commissioning    prefix_tag=CONF1    asir_hub=${True}
Suite Teardown      Common Suite Teardown

*** Variables ***
#Manual_SiSo_SM_Cell_Block_Unblock
${Cell_Block_Unblock_Additional_alarms}    Cell blocked

#Delete_add_NR_cell_with_L3Call
${scf_path}    ${OUTPUTDIR}/generated_scf/

*** Test Cases ***
Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    Run Keywords
    ...    Perform Full Commissioning and Wait for onAir    prefix_tag=CONF1    asir_hub=${True}
    ...    AND    Common Preconditions With Watching Alarms
#    Perform Bidirectional Data Transfer With Throughput Verification on all cells
#    ...    data_transfer_configuration=${data_transfer_configuration_1}
    log to console   \nBTS Site Reset
    General_SiSo_Auto_BTS_Site_Reset
    Perform Bidirectional Data Transfer With Throughput Verification on all cells
    ...    data_transfer_configuration=${data_transfer_configuration_1}
    [Teardown]    Common Postconditions With Watching Alarms

Manual_SiSo_SM_Cell_Block_Unblock
    [Setup]    Run Keywords
    ...    Perform Full Commissioning and Wait for onAir    prefix_tag=CONF3    asir_hub=${True}
    ...    AND    Common Preconditions With Watching Alarms
    gnb_alarm.Allow Alarm    alarm=${Cell_Block_Unblock_Additional_alarms}
    log to console   \nCell_Block_Unblock
    General SiSo Cell block and unblock
    Perform Bidirectional Data Transfer With Throughput Verification on all cells
    ...    data_transfer_configuration=${data_transfer_configuration_3}
    gnb_alarm.Disallow Alarm    alarm=${Cell_Block_Unblock_Additional_alarms}
    [Teardown]    Common Postconditions With Watching Alarms

Delete_add_NR_cell_with_L3Call
    Generate delta scf
    ...    primary_scf_prefix=CONF4_deleted_cell
    ...    secondary_scf_prefix=CONF4
    ...    scf_path=${scf_path}
    ...    asir_hub=${True}
    Common Preconditions With Watching Alarms
    log to console    \n------START Remove cell via delta configuration plan------
    perform_bts_delta_json_commissioning   ${scf_path}/delta_1.json    timeout=900
    log to console    \n------START Add cell via delta configuration file------
    perform_bts_delta_json_commissioning   ${scf_path}/delta_2.json   timeout=900
    log to console    \n------Wait for cells to be OnAir------
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.verify_all_cells_are_onair
    log to console    \n------Attach and call------
    Perform Bidirectional Data Transfer With Throughput Verification on all cells
    ...    data_transfer_configuration=${data_transfer_configuration_4}
    [Teardown]    Common Postconditions With Watching Alarms

Manual_SiSo_CM_Recommissioning
    [Setup]    Run Keywords
    ...    Perform Full Commissioning and Wait for onAir    prefix_tag=CONF9    asir_hub=${True}
    ...    AND    Common Preconditions With Watching Alarms
    Manual_SiSo_CM_Recommissioning
    ...      parameters_to_change=${parameters_to_change}
    ...      incorrect_parameters=${incorrect_parameters}
    [Teardown]    Common Postconditions With Watching Alarms

Manual_SiSo_CALL_LTE_data_call
    [Setup]    Run Keywords
    ...    Perform Full Commissioning and Wait for onAir    prefix_tag=CONF9    asir_hub=${True}
    ...    AND    Common Preconditions With Watching Alarms
    Perform Bidirectional Data Transfer With Throughput Verification on all cells
    ...    data_transfer_configuration=${data_transfer_configuration_9_lte}
    log to console    ok
    [Teardown]    Common Postconditions With Watching Alarms
