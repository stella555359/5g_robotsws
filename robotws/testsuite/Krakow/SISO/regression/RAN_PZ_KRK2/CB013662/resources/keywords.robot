*** Settings ***
Documentation
...    Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Maintainer:

Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbCellCustom    WITH NAME
...            GnbCellOp
Library        testsuite/Krakow/resources/random_oam_procedure_runner.py

Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource       ./UE_keywords.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${CAPABILITIES}                         REAL_UE
${REBOOT_UE}                            ${False}
${REBOOT_UE_TIMEOUT}                    100
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

${TOTAL_TIMEOUT}                                ${7200}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${True}
# Sample of ${OPERATIONS}  ['site_reset', 'bts_power_on', 'reset_bbmod', 'reset_rmod', 'power_reset_rmod']
${OPERATIONS}                                   ${None}
# Sample of ${OPERATION_KWARGS}  {'site_reset': {'temp_allowed_alarms': [{'alarm_id': '7115', 'fault_id': '4590',
# 'fault_name': 'Sample fault name'}], 'calculate_kpi': true}, 'reset_rmod': {'calculate_kpi': false}}
${OPERATION_KWARGS}                             {"rat_reset": {"temp_allowed_alarms": [{"alarm_id": "7114", "fault_id": "7107",
...                                             "fault_name": "Cell problem due to associated X2 links and/or NG links
...                                             and/or E1 link unavailability"}, {"alarm_id": "7114", "fault_id": "7107",
...                                             "fault_name": "Cell problem due to unavailability of associated links"}]}}
${RANDOM_SEED}                                  ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${logs_path}                                    ${OUTPUTDIR}

*** Keywords ***
Perform L3Call on 15MHz Cell
    gnb_alarm.Allow alarm    alarm=49
    ${cells_to_block}    Create List    31    32
    Block Selected Cells For L3Call    cells_to_block=${cells_to_block}
    Run Bidirectional TCP Data Transfer 15MHz
    Unblock Selected Cells For L3Call    cells_to_unblock=${cells_to_block}
    gnb_alarm.Disallow alarm    alarm=49

Perform L3Call on 15MHz PCell and 30MHz SCell
    gnb_alarm.Allow alarm    alarm=49
    ${cells_to_block}    Create List    32
    Block Selected Cells For L3Call    cells_to_block=${cells_to_block}
    Run Bidirectional TCP Data Transfer 15MHz PCell 30MHz SCell
    Unblock Selected Cells For L3Call    cells_to_unblock=${cells_to_block}
    gnb_alarm.Disallow alarm    alarm=49

Perform L3Call on 49.5MHz PCell and 15MHz SCell
    gnb_alarm.Allow alarm    alarm=49
    ${cells_to_block}    Create List    30
    Block Selected Cells For L3Call    cells_to_block=${cells_to_block}
    Run Bidirectional TCP Data Transfer 49.5MHz PCell 15MHz SCell
    Unblock Selected Cells For L3Call    cells_to_unblock=${cells_to_block}
    gnb_alarm.Disallow alarm    alarm=49

Perform L3Call with Cell Lock on 49.5MHz
    gnb_alarm.Allow alarm    alarm=49
    ${cells_to_block}    Create List    30    33
    Block Selected Cells For L3Call    cells_to_block=${cells_to_block}
    Run Bidirectional TCP Data Transfer 49.5MHz
    Lock Cell    cell_id=32
    Unlock Cell    cell_id=32
    Sleep    60s    Wait for cell stabilization on FRU6 AWHHJ
    Run Bidirectional TCP Data Transfer 49.5MHz
    Unblock Selected Cells For L3Call    cells_to_unblock=${cells_to_block}
    gnb_alarm.Disallow alarm    alarm=49

Lock Cell
    [Arguments]    ${cell_id}
    GnbCellOp.lock_cell    cell_id=${cell_id}
    GnbCellOp.wait_for_cell_to_be_locked    cell_id=${cell_id}

Unlock Cell
    [Arguments]    ${cell_id}
    GnbCellOp.unlock_cell    cell_id=${cell_id}
    GnbCellOp.wait_for_cell_to_be_onair    cell_id=${cell_id}

Block Selected Cells For L3Call
    [Arguments]    ${cells_to_block}
    FOR    ${cell}    IN    @{cells_to_block}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For L3Call
    [Arguments]    ${cells_to_unblock}
    FOR    ${cell}    IN    @{cells_to_unblock}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Random OAM Operations
    [Timeout]    96h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}

Verify All Cells Are Operating Correctly
    GnbCellOp.verify_all_cells_are_onair
