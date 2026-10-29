*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer:
...    CB009027_CB009028_CB008325 Keywords

Library          testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB009027_CB009028_CB008325.resources.asimgr_methods.AsirHandler    WITH NAME
...              Asimgr

Resource       ../../FR_CB009493_CB009055_CB009487/resources/keywords.robot

Variables        taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Test Teardown For Single NR Cell Block
    Run Keyword If Test Failed    Unblock Single NR Cell
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For Single NR Cell And LTE Cell Block
    Run Keyword If Test Failed    Unblock Selected Cells For TC17 Subcase2
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For Two NR Cells Block
    Run Keyword If Test Failed    Unblock Selected Cells For TC15
    Verify ASiR Alarms
    Common Postconditions

Block Selected Cells For TC15
    ${nr_cell_id}    Create List    11    12    13    14
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC15
    ${nr_cell_id}    Create List    11    12    13    14
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Block Selected Cells For TC17
    ${nr_cell_id}    Create List    2    9    10    11    12    13    14
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC17
    ${nr_cell_id}    Create List    2    9    10    11    12    13    14
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Block Selected Cells For TC17 Subcase2
    ${nr_cell_id}    Create List    10    1
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC17 Subcase2
    ${nr_cell_id}    Create List    10    1
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Wait For All Cells To Be Operating Correctly after PRACH Modification
    Wait Until Keyword Succeeds    10 min    15 sec    Verify All Cells Are Operating Correctly

Verify Historic Alarms After Antenna Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_ResetANTMOD}=7313 61649
    ...            ${required_history_gnb_ResetANTMOD}=4479
    ...            ${allowed_history_asir_ResetANTMOD}=61648
    ...            ${required_history_asir_ResetANTMOD}=4480
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_ResetANTMOD}
    ...                                    required_fault_id_list=${required_history_gnb_ResetANTMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_asir_ResetANTMOD}
    ...                                    allowed_fault_id_list=${allowed_history_asir_ResetANTMOD}

Verify Alarms And Historic Alarms After Cell And NBIoT Cell Unlock
    [Arguments]    ${allowed_history_gnb_BlockANTMOD}=7313 61649 4749
    ...            ${allowed_history_asir_BlockANTMOD}=61648 4348
    ...            ${forbidden_active_gnb_BlockANTMOD}=4479
    ...            ${forbidden_active_asir_BlockANTMOD}=4348
    ...            ${required_history_gnb_BlockANTMOD}=4479
    ...            ${required_history_asir_BlockANTMOD}=4348
    sbts_methods.check_sbts_active_alarm    forbidden_fault_id_list=${forbidden_active_gnb_BlockANTMOD}
    GnbAsirOp.check_asir_active_alarm    forbidden_fault_id_list=${forbidden_active_asir_BlockANTMOD}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_BlockANTMOD}
    ...                                    required_fault_id_list=${required_history_gnb_BlockANTMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${required_history_asir_BlockANTMOD}
    ...                                    allowed_fault_id_list=${allowed_history_asir_BlockANTMOD}

Change PrachIndex For TDLTE 0 Ms
    @{prach_pool}    Create List    92    96    97    102    150    156    158    194    195    198    206
    GnbDuOp.change_parameter_value_to_random_one_excluding_current_value_via_gui
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRCELL-${CELL_ID_FOR_PRACH_CHANGE}
    ...    parameter=PRACH configuration index
    ...    param_abbr=prachConfigurationIndex
    ...    values_list=${prach_pool}

Change PrachIndex For TDLTE 3 Ms
    @{prach_pool}    Create List    87    88    89    93    94    98    100    101    104    145    146    147
    ...                             148    149    151    157    159    160    162    189    190    191    192
    ...                             196    201    202    203    205
    GnbDuOp.change prach and lte frame shift parameter via gui
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRCELL-${CELL_ID_FOR_PRACH_CHANGE}
    ...    parameter_prach=PRACH configuration index
    ...    param_abbr_prach=prachConfigurationIndex
    ...    value_prach=${prach_pool}
    ...    parameter_frame=LTE to NR frame shift
    ...    param_abbr_frame=lteToNrFrameShift
    ...    value_frame=3ms

Change PrachIndex And Frame Shift on Teardown
    [Arguments]    ${prach}=90
    GnbDuOp.change prach and lte frame shift parameter via gui
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRCELL-${CELL_ID_FOR_PRACH_CHANGE}
    ...    parameter_prach=PRACH configuration index
    ...    param_abbr_prach=prachConfigurationIndex
    ...    value_prach=${prach}
    ...    parameter_frame=LTE to NR frame shift
    ...    param_abbr_frame=lteToNrFrameShift
    ...    value_frame=0ms
