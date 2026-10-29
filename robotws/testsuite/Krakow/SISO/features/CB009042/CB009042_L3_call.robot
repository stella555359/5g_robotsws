*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009042 for SA configuration - all L3 call tests
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Library     resources/resources.py
Resource    resources/resources.robot
Resource    resources/L3_call_procedures.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/variables.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords    Common Preconditions With Watching Alarms
...               AND             Prepare Ue for L3 Call    capabilities=${capabilities}    alias=${alias}
...                                                         reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
# ----------------------Common--------------------------------
${ITERATIONS}          ${1}
${RU_startup_time}     ${300}
${RAT_startup_time}    ${300}
${BTS_startup_time}    ${500}
${cell_block_unblock_time}    ${10}
${cell_lock_unlock_time}      ${10}

# ----------------------L3 call-------------------------------
${ENABLE_RACH_OBSERVER}                 ${False}    # don't set to True, the functionality doesn't work
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}    # to debug tput problems set to True
${alias}                   UE
${capabilities}            REAL_UE

${duration}                60s
${protocol}                tcp
${interval}                1
${reboot_ue}               ${False}
${timeout_reboot_ue}       100

${tput_dl}                 4250 Mbits/sec
${deviation_dl}            10%
${size_packet_dl}          1400B
${buffer_client_dl}        8M
${buffer_server_dl}        8M
${parallel_streams_dl}     1

${tput_ul}                 550 Mbits/sec
${deviation_ul}            10%
${size_packet_ul}          1320B
${buffer_client_ul}        2M
${buffer_server_ul}        2M
${parallel_streams_ul}     2

${qci_dl}                  ${None}
${qci_ul}                  ${None}
${linux_congestion_dl}     reno
${linux_congestion_ul}     ${None}

# ----------------------Cell addition deletion-------------------------------
${tput_dl_without_cell}    3718 Mbits/sec
${tput_ul_without_cell}    414 Mbits/sec


*** Test Cases ***
[2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto RF lock unlock with L3call

[1.0] General_SiSo_Auto_RF_module_reset_from_WebUI_with_L3call
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto RF module reset from WebUI with L3call

[1.0] General_SiSo_Auto_RF_module_power_reset_with_L3call
    Set test variable    @{mandatory_alarms}    10
    Set test variable    @{mandatory_alarms_after_power_on}    4589

    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    L3_call_procedures.General SiSo Auto RF module power reset with L3call
    ...                                           mandatory_alarms=@{mandatory_alarms}
    ...                                           mandatory_alarms_after_power_on=${mandatory_alarms_after_power_on}
    ...                                           allowed_alarms=${allowed_alarms_during_ru_power_reset}

General_SiSo_Auto_RAT_reset_with_L3call
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto RAT reset with L3call

[1.0] General_SiSo_Auto_Startup_BTS_power_reset_with_L3call
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto Startup BTS power reset with L3call

[1.0] General_SiSo_Auto_Cell_block_and_unblock_with_L3call
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto Cell block and unblock with L3call

[1.0] Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    Manual SiSo SM NR cell lock unlock administrative state change from GUI

[1.0] General_SiSo_Auto_Online_Cell_Addition_Deletion_with_L3call
    [Setup]    Common Preconditions With Watching Alarms
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto Online Cell Addition Deletion with L3call
