*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009042 for SA configuration
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Library     taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    resources/OAM_procedures.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/variables.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed


*** Variables ***
${ITERATIONS}          ${1}
${logs_path}    ${OUTPUTDIR}    # required by HWPTA test cases

${block_unblock_site_iterations}    ${3}

${BTS_Power_Reset_iterations}    ${3}
&{BTS_Power_Reset_target}        kpi3=${600}    # example values (no defined target)

${RU_startup_time}    300

*** Test Cases ***
[1][2.1] General_SiSo_Cell_block_and_unblock
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Cell block and unblock

[1][1.0] Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    Lock Unlock All gNB Cells via Gui    administrative_state=${True}

[1][3.0] General_SiSo_Auto_RF_lock_unlock
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo Auto RF Lock Unlock

[1][1.0] General_SiSo_RU_module_reset_from_GUI
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    General SiSo RU module reset from GUI

[1][1.0] General SiSo Auto RF module power reset
    Set test variable    @{mandatory_alarms}    10
    Set test variable    @{mandatory_alarms_after_power_on}    4589

    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    OAM_procedures.General SiSo Auto RF module power reset
    ...                                           mandatory_alarms=@{mandatory_alarms}
    ...                                           mandatory_alarms_after_power_on=${mandatory_alarms_after_power_on}
    ...                                           allowed_alarms=${allowed_alarms_during_ru_power_reset}

[1][2.0] Manual_SiSo_SM_BTS_Block_Site
    FOR    ${index}    IN RANGE    ${block_unblock_site_iterations}
        Log to console    Block and unblock site - iteration: ${index+1}
        Block Unblock Site    allowed_alarms=${allowed_alarms_during_bts_blocked}
    END

[1][2.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    Repeat Keyword    ${ITERATIONS}
    ...    Run Keyword And Continue On Failure    OAM_procedures.General SiSo Auto gNB Site Reset From WebUI
    ...                                           allowed_alarms=${allowed_alarms_during_bbu_reset}

[1][1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
    [Setup]    Common Preconditions
    run_bts_power_on_in_loop    iterations=${BTS_Power_Reset_iterations}
    ...                         target=&{BTS_Power_Reset_target}
    ...                         additional_allowed_alarms=${allowed_alarms_during_bts_power_reset}
    [Teardown]    Common Postconditions With Restore Configuration If Test Failed
