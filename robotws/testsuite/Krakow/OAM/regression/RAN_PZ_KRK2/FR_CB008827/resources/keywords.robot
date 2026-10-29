*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:

Library        taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    GnbRuOp
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbCellCustom    WITH NAME
...            GnbCellOp

Resource       ../../FR_CB009493_CB009055_CB009487/resources/keywords.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Test Teardown For BTS Cell Block
    Run Keyword If Test Failed    Unblock All NR Cells
    Common Postconditions

Verify BTS Active Alarms After Cell Block
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 7313 61510 10
    ...            ${required_active_gnb_BlockCell}=49
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    ...                                     required_fault_id_list=${required_active_gnb_BlockCell}

Verify BTS Active Alarms After Radio Units Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 7313 61510 10
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}

Verify BTS Active Alarms After Radio Units Lock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 7313 61510 10
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}

Verify BTS Active Alarms After Radio Units Unlock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 7313 61510 10
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}

Verify BTS Active And Historic Alarms After Cell Unblock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 7313 61510 10
    ...            ${forbidden_active_gnb_BlockCell}=49
    ...            ${required_history_gnb_UnblockCell}=49
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    ...                                     forbidden_fault_id_list=${forbidden_active_gnb_BlockCell}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    required_fault_id_list=${required_history_gnb_UnblockCell}
    ...                                    appeared_time_later_than=${START_TIME}

Block All pRRH Cells
    @{cells_id}    Create List    1    2    3    4    5    6
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.block_cell    cell_id=${cell_id}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    Verify All pRRH Cells Are Blocked

Verify All pRRH Cells Are Blocked
    @{cells_id}    Create List    1    2    3    4    5    6
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.verify_cell_is_blocked    cell_id=${cell_id}
    END

Unblock All pRRH Cells
    @{cells_id}    Create List    1    2    3    4    5    6
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.unblock_cell    cell_id=${cell_id}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    Verify All pRRH Cells Are Unblocked
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Verify All pRRH Cells Are Unblocked
    @{cells_id}    Create List    1    2    3    4    5    6
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.verify_cell_is_unblocked    cell_id=${cell_id}
    END

Reset All pRRH Units
    @{rmod_list}    Create List    2    3    4
    FOR    ${rmod}    IN    @{rmod_list}
        GnbRuOp.reset_radio_unit    radio_unit_id=${rmod}    radio_type=rmod    timeout=${300}
    END

Wait Until All pRRH Units Are Available
    Wait Until Keyword Succeeds    5 min    30 sec    Verify Status on all pRRH

Wait Until BTS Is OnAir
    GnbDuOp.wait_for_site_to_be_onair

Lock All pRRH Units
    @{rmod_list}    Create List    2    3    4
    FOR    ${rmod}    IN    @{rmod_list}
        GnbRuOp.lock_radio_unit    radio_unit_id=${rmod}    radio_type=rmod
    END

Unlock All pRRH Units
    @{rmod_list}    Create List    2    3    4
    FOR    ${rmod}    IN    @{rmod_list}
        GnbRuOp.unlock_radio_unit    radio_unit_id=${rmod}    radio_type=rmod
    END

Verify Locked Status On All pRRH
    @{rmod_list}    Create List    2    3    4
    FOR    ${rmod}    IN    @{rmod_list}
        GnbRuOp.verify_radio_unit_statuses    ru_id=${rmod}
        ...                                   radio_type=rmod
        ...                                   administrative_state=locked
        ...                                   usage_state=idle
    END

Verify Unlocked Status On All pRRH
    @{rmod_list}    Create List    2    3    4
    FOR    ${rmod}    IN    @{rmod_list}
        GnbRuOp.verify_radio_unit_is_online    ru_id=${rmod}
        ...                                    radio_type=rmod
    END

Wait Until All Radio Units Are Available
    Wait Until Keyword Succeeds    5 min    30 sec    Verify Unlocked Status On All pRRH

Wait For All pRRH Units To Be Locked
    Wait Until Keyword Succeeds    5 min    30 sec    Verify Locked Status On All pRRH
