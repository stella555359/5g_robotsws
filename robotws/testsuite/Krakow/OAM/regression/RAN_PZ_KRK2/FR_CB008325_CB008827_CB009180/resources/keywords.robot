*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:

Library        testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB008325_CB008827_CB009180.resources.GnbRuCustom
...            WITH NAME    GnbRuOp
Library        testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB008325_CB008827_CB009180.resources.ScfFilter
...            WITH NAME    ScfOp

Resource       ../../FR_CB009493_CB009055_CB009487/resources/keywords.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${SUPER_CELL_ID}    ${8}

*** Keywords ***
Test Teardown For Super Cell Block
    Run Keyword If Test Failed    Unblock Super Cell
    Verify ASiR Alarms
    Common Postconditions

Reset BTS And Wait For All Cells To Be Operational
    GnbDuOp.reset_bts
    Wait For All Cells To Be Operating Correctly
    Wait For Gnb And Hub To Be OnAir

Reset All BTS ASIRMODs
    GnbRuOp.reset_all_radio_unit    timeout=${180}    radio_type=asirmod

Wait For All BTS ASIRMOD Modules To Be Operational
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRuOp.verify_all_asirmod_radio_module_status

Wait For All Cells To Be In Expected Status During BBMOD Lock
    GnbCellOp.get_all_cell_infos
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_dependency_status
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_nbiot_status_for_locked_bbmod

Block Super Cell
    GnbCellOp.block_cell    cell_id=${SUPER_CELL_ID}
    Wait Until Keyword Succeeds    2 min    10 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${SUPER_CELL_ID}

Unblock Super Cell
    GnbCellOp.unblock_cell    cell_id=${SUPER_CELL_ID}
    Wait Until Keyword Succeeds    2 min    10 sec    GnbCellOp.verify_cell_is_unblocked    cell_id=${SUPER_CELL_ID}

Verify Alarms After ASIRMOD Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_ResetASIRMOD}=7300 7319 61648 61649 4479 7313
    ...            ${allowed_history_asir_ResetASIRMOD}=4480 61648
    ...            ${required_history_asir_ResetASIRMOD}=10
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_ResetASIRMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_asir_ResetASIRMOD}
    ...                                    required_fault_id_list=${required_history_asir_ResetASIRMOD}

Verify Alarms After All BBMOD Lock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 61625 61074 4654 4655 4681 6261 6450
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_normal}=7313 61649
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_normal}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}

Verify Alarms And Historic Alarms After All BBMOD Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_ResetBBMOD}=7300 7319 61649 7312 7313
    ...            ${required_history_asir_ResetBBMOD}=10
    ...            ${allowed_history_asir_ResetBBMOD}=4480 61648
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_ResetBBMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_asir_ResetBBMOD}
    ...                                    allowed_fault_id_list=${allowed_history_asir_ResetBBMOD}

Wait For And Verify Alarms After All Antenna Block
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61625 61074
    ...            ${required_active_gnb_BlockANTMOD}=4479
    ...            ${allowed_faults_asir}=61648
    ...            ${required_active_asir_BlockANTMOD}=4348
    Wait Until Keyword Succeeds    5 min    30 sec    sbts_methods.check_sbts_active_alarm
    ...                                     allowed_fault_id_list=${allowed_faults_sbts}
    ...                                     required_fault_id_list=${required_active_gnb_BlockANTMOD}
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.check_asir_active_alarm
    ...                                     allowed_fault_id_list=${allowed_faults_asir}
    ...                                     required_fault_id_list=${required_active_asir_BlockANTMOD}

Download ASiR Commissioning
    ${asir_commissioning_file}    sbts_methods.collect_asir_commissioning    device_name=GNB0_ASIMGR
    [Return]    ${asir_commissioning_file}

Download ASiR Commissioning Via ASiR WebEM
    Prepare ASiR WebEM Browser
    ${asir_commissioning_file}    AsirWebEM.save_scf
    [Return]    ${asir_commissioning_file}
    [Teardown]    Close ASiR WebEM Browser

Verify Cell And NBIoT Cell Status On ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.check_asir_cell_status    cell_type=ALL
    ...                                 id_list=${tl.enbs[0].global_bts_id}.${cell['nbIotLinkedCellId']}
    ...                                 expected_status=Green
    AsirWebEM.check_asir_cell_status    cell_type=ALL
    ...                                 id_list=${tl.enbs[0].global_bts_id}.${cell['lnCelId']}
    ...                                 expected_status=Green
    [Teardown]    Close ASiR WebEM Browser

Wait For All Cells To Be In Failed Status
    Wait Until Keyword Succeeds    5 min    30 sec    GnbCellOp.verify_all_cells_failed_statuses     availability_status=failed
    ...                                                                                              operational_state=disabled
    ...                                                                                              administrative_state=unlocked

Block Selected Cells For TC07
    ${nr_cell_id}    Create List    1    8    19
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC07
    ${nr_cell_id}    Create List    1    8    19
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Block Selected Cells For TC03
    ${nr_cell_id}    Create List    1    3    19
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC03
    ${nr_cell_id}    Create List    1    3    19
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly
