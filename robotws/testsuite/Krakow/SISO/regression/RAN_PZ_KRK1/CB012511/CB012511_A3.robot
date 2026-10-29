*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012524
...   author: Radoslaw Serafin, Agnieszka Bylica, Julia Luszcz
...   author/contact: radoslaw.serafin@nokia.com, damian.silkowski@nokia.com, agnieszka.bylica@nokia.com, julia.luszcz@nokia.com


Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/common.robot
Resource    ../resources/robot/tput.robot
Resource    ../resources/rjio_procedures/General_SiSo_RF_module_lock_unlock_from_WebUI_with_L3_call.robot
Resource    ../resources/rjio_procedures/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ../resources/rjio_procedures/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ../resources/rjio_procedures/Manual_SiSo_SM_BTS_Block_Site.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py


Force Tags    CA_VRF_KRK    RF50

Suite Setup       Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                               prefix_tag=${prefix_tag}
...                               increase_timeout_for_update_sw=${1800}
...                               increase_time_for_checking_radios=${1800}
...                               list_of_additional_allowed_alarms=${allowed_alarms_during_tl_prep}
...                               AND
...                               load_ru_matrix    ${prefix_tag_L3_call}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed


*** Variables ***
${CUSTOM_ALLOWED_ALARMS}                [{'fault_id': 61675,'fault_name': 'WiFi Configuration Issue'},
...                                      {'fault_id': 61673, 'fault_name': 'Wifi Enabled Alarm'}]
# ${prefix_tag} requires setting of CONFIGURATION variable e.g.: -v CONFIGURATION:Krakow.7_7_UTE5GCLOUDT8SK134
${prefix_tag}                           CB012511_A3
${prefix_tag_L3_call}                   CB012511_A3_L3_call
${prefix_tag_L3_call_selected_cells}    CB012511_A3_L3_call_selected_cells
# ${current_config} to remove after TL preparation added; to skip commissioning set equal to ${prefix_tag}
${current_config}                       ${None}
${BTS_Site_Reset_iterations}            ${3}
${BTS_startup_time}                     ${600}
${block_site_iterations}                ${3}

#tput
${reboot_ue}                            False
${capabilities}                         REAL_UE
${duration}                             180s
${parallel_streams_dl}                  4
${parallel_streams_ul}                  4
${size_packet}                          1400B
${deviation}                            20%
${size_packet_dl}                       1400B
${size_packet_ul}                       1400B
${interval}                             1
${omit}                                 5
${alias}                                UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}  False
#attach
${timeout_reboot_ue}                    100
#rf switch
${RFS_ALIAS}                            Matrix
${RF_VENDOR}                            RFLIGHT
${RF_IP}                                10.255.27.56
${RF_MODEL}                             NT-4X64NS


*** Test Cases ***
[1][1.0] CB012511_A3_General_SiSo_RF_lock_unlock
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=${prefix_tag_L3_call}
    [Timeout]    20h

    General_SiSo_RF_module_lock_unlock_from_WebUI_with_L3_call

[1][1.0] CB012511_A3_Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=${prefix_tag_L3_call}
    [Timeout]    20h

    Load_ru_matrix    ${prefix_tag_L3_call_selected_cells}
    Manual_SiSo_SM_BTS_Site_Reset    iterations=${BTS_Site_Reset_iterations}

[1][1.0] CB012511_A3_Manual_SiSo_SM_NR_RAT_reset
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=${prefix_tag_L3_call}
    [Timeout]    20h

    Load_ru_matrix    ${prefix_tag_L3_call_selected_cells}
    Manual_SiSo_SM_NR_RAT_reset    rat_startup_time=${BTS_startup_time}
    ...                            is_actRatResetEnhancement_frozen=${is_actRatResetEnhancement_frozen}

[1][1.0] CB012511_A3_Manual_SiSo_SM_BTS_Block_Site
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=${prefix_tag_L3_call}
    [Timeout]    20h

    Load_ru_matrix    ${prefix_tag_L3_call_selected_cells}
    Manual_SiSo_SM_BTS_Block_Site    iterations=${block_site_iterations}
