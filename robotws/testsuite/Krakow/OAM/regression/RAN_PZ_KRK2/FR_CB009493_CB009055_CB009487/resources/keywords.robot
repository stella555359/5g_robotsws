*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:

Library        DateTime
Library        taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    GnbCommissioningOp
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbAsir    WITH NAME
...            GnbAsirOp
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbCellCustom    WITH NAME
...            GnbCellOp
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbCustomDu    WITH NAME
...            GnbDuOp
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium    WITH NAME
...            AsirWebEM
Library        testsuite/Krakow/resources/RAN_PZ_KRK2/FR_CB009493_CB009055_CB009487/sbts_methods.py    WITH NAME
...            sbts_methods

Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${BTS_ID}                     ${tl.gnbs[0].global_bts_id}
${VIRTUAL_DISPLAY}            ${True}
&{EXPECTED_ASIRMOD_STATUS}    availabilityStatus=Online    administrativeState=Unlocked    operationalState=Enabled

*** Keywords ***
Set Allowed Alarms
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled
    ...                                         LMP access via port 443
    ...                                         LMP connectivity detected
    ...                                         CBRS Vendor Certificate is about to expire or expired
    ...                                         CRL Update Failure

Set Allowed Alarms For ASiR
    Set Test Variable    @{allowed_alarms_asir}    ${61648}

Set Allowed Alarms With Diagnostic Files
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled
    ...                                         Radio Diagnostic Files collected

Test Teardown For Cell Block TC02
    Run Keyword If Test Failed    Unblock Selected Cells For TC02
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For Cell Block TC16
    Run Keyword If Test Failed    Unblock Selected Cells For TC16
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For Cell Block TC04
    Run Keyword If Test Failed    Unblock Selected Cells For TC04
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For BBMOD Block
    Run Keyword If Test Failed    Unlock BBMODs And Verify Online Status
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For Cell Block
    Run Keyword If Test Failed    Unblock All NR Cells
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For Antenna Block
    Run Keyword If Test Failed    Unblock All BTS Antennas
    Verify ASiR Alarms
    Common Postconditions

Log Current Time
    ${saved_time}    DateTime.Get Current Date    result_format=epoch    exclude_millis=True
    Set Test Variable    ${START_TIME}    ${saved_time}

Verify ASiR Alarms
    Wait Until Keyword Succeeds    1 min    15 sec    GnbAsirOp.verify_only_allowed_alarms_are_active    allowed_alarms=@{allowed_alarms_asir}

Verify All Cells Are Operating Correctly
    GnbCellOp.verify_all_cells_are_onair

Wait For All Cells To Be Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    Verify All Cells Are Operating Correctly

Verify All Cells Dependency Status
    GnbCellOp.verify_setup_of_all_cells    verify_bts_status=${False}
    ...                                    availability_status=Dependency
    ...                                    operational_state=Disabled
    ...                                    administrative_state=Unlocked
    ...                                    blocking_state=Unblocked

Wait For All Cells Dependency Status
    Wait Until Keyword Succeeds    5 min    10 sec    Verify All Cells Dependency Status

Prepare ASiR WebEM Browser
    AsirWebEM.clean_browser
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}
    Wait Until Keyword Succeeds    1 min    15 sec    AsirWebEM.login

Close ASiR WebEM Browser
    Run Keyword And Continue On Failure    AsirWebEM.logout
    Run Keyword And Continue On Failure    AsirWebEM.clean_browser

Verify Cell Status On ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.check_asir_cell_status    cell_type=ALL    expected_status=Green
    [Teardown]    Close ASiR WebEM Browser

Verify Faulty BTS Cell Status On ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.check_asir_cell_status    cell_type=BTS    expected_status=Red
    [Teardown]    Close ASiR WebEM Browser

Verify Expected Number Of Faulty BTS Cell Status On ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.check_asir_cell_status    cell_type=BTS
    ...                                 expected_status=Red
    ...                                 expected_cell_count=${NUMBER_OF_CELLS_BLOCKED}
    [Teardown]    Close ASiR WebEM Browser

Reset HUBMOD On ASiR WebEM
    [Arguments]    ${hubmod_id}
    Prepare ASiR WebEM Browser
    AsirWebEM.reset_hubmod    hub_mod_id=${hubmod_id}    timeout=${400}
    [Teardown]    Close ASiR WebEM Browser

Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Wait Until Keyword Succeeds    5 min    30 sec    Verify Cell Status On ASiR WebEM

Wait For All BTS Cells To Not Be Operating Correctly On ASiR WebEM
    Wait Until Keyword Succeeds    5 min    30 sec    Verify Faulty BTS Cell Status On ASiR WebEM

Wait For Gnb And Hub To Be OnAir
    GnbAsirOp.wait_for_asir_to_be_onair
    GnbDuOp.wait_for_site_to_be_onair
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.verify_status_of_asir_cells
    ...                                               expected_asir_cell_status=operational

Block All NR Cells
    GnbCellOp.block_all_cells    cell_type=nr
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_blocked    cell_type=nr

Block All NR Cells And Save Blocked Cell Count
    ${number_of_cells}    GnbCellOp.block_all_cells_and_return_blocked_cell_count    cell_type=nr
    Set Test Variable    ${NUMBER_OF_CELLS_BLOCKED}    ${number_of_cells}
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_blocked    cell_type=nr

Block All NR Cells On All ASiRHubs And Save Blocked Cell Count
    ${number_of_cells}    GnbCellOp.block_all_cells_on_all_asirhubs_and_return_blocked_cell_count    cell_type=nr
    Set Test Variable    ${NUMBER_OF_CELLS_BLOCKED}    ${number_of_cells}
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_blocked    cell_type=nr

Unblock All NR Cells
    GnbCellOp.unblock_all_cells    cell_type=nr
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Block Selected Cells For TC02
    ${nr_cell_id}    Create List    15
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC02
    ${nr_cell_id}    Create List    15
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Block Selected Cells For TC16
    ${nr_cell_id}    Create List    15
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.block_cell    cell_id=${cell}
        Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_cell_is_blocked    cell_id=${cell}
    END

Unblock Selected Cells For TC16
    ${nr_cell_id}    Create List    15
    FOR    ${cell}    IN    @{nr_cell_id}
        GnbCellOp.unblock_cell    cell_id=${cell}
    END
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellOp.verify_all_cells_are_unblocked    cell_type=nr
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly

Reset BBMODs And Wait For All Cells To Be OnAir
    @{bbmod_list}    GnbDuOp.get_all_bbmod_ids
    FOR    ${bbmod}    IN    @{bbmod_list}
        GnbDuOp.reset_bbmod    bbmod_id=${bbmod}
        Wait Until Keyword Succeeds    7 min    15 sec    Verify All Cells Are Operating Correctly
    END

Lock BBMODs And Verify Locked Status
    GnbDuOp.lock_all_bbmod_units
    Wait Until Keyword Succeeds    1 min    15 sec    GnbDuOp.verify_all_bbmods_locked_status

Unlock BBMODs And Verify Online Status
    GnbDuOp.unlock_all_bbmod_units
    GnbDuOp.wait_until_all_bbmods_are_online

Reset All BTS Antennas
    GnbAsirOp.reset_all_antennas

Wait Until All BTS Antennas Are Available
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.verify_all_antennas_status

Block All BTS Antennas
    GnbAsirOp.block_all_antennas

Unblock All BTS Antennas
    GnbAsirOp.unblock_all_antennas

Wait Until All Antennas Are Blocked
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.verify_all_antennas_are_blocked

Reset All HUBMODs On ASiR WebEM
    ${hubs}    GnbAsirOp.get_all_hub_ids
    FOR    ${hub}    IN    @{hubs}
        Reset HUBMOD On ASiR WebEM    hubmod_id=${hub}
    END

Wait Until All HUBs Are Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    GnbAsirOp.verify_all_hubs_status

Verify Alarms After BBMOD Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_ResetBBMOD}=7300 7319 61649
    ...            ${required_history_asir_ResetBBMOD}=
    ...            ${allowed_history_asir_ResetBBMOD}=61648 10 4480
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_ResetBBMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_asir_ResetBBMOD}
    ...                                    allowed_fault_id_list=${allowed_history_asir_ResetBBMOD}

Verify Alarms And Historic Alarms After Cell Block
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074 7313
    ...            ${required_active_gnb_BlockCell}=49
    ...            ${allowed_faults_asir}=61648
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    ...                                     required_fault_id_list=${required_active_gnb_BlockCell}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_sbts}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}

Verify Alarms And Historic Alarms After All NR Cells Unblock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61074 61625
    ...            ${forbidden_active_gnb_BlockCell}=49
    ...            ${allowed_faults_asir}=61648
    ...            ${required_history_gnb_UnblockCell}=49
    ...            ${allowed_history_asir_normal}=61648
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    ...                                     forbidden_fault_id_list=${forbidden_active_gnb_BlockCell}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_gnb_UnblockCell}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_asir_normal}

Verify Alarms And Historic Alarms On BTS And ASiR
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_normal}=61649
    ...            ${allowed_history_asir_normal}=61648
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_normal}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_asir_normal}

Verify Alarms And Historic Alarms After PRACH Change With RAT Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_normal}=61649 16
    ...            ${allowed_history_asir_normal}=61648 10 4480
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_normal}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_asir_normal}

Verify Alarms And Historic Alarms After PRACH Change Without RAT Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_normal}=61649
    ...            ${allowed_history_asir_normal}=61648
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_normal}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_asir_normal}

Verify ASIRMOD Status
    sbts_methods.check_asirmod_status    expected_status_dict=${EXPECTED_ASIRMOD_STATUS}

Verify Alarms After Antenna Reset
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

Verify Alarms After Antenna Block
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074 7313
    ...            ${allowed_faults_asir}=61648
    ...            ${required_active_gnb_BlockANTMOD}=4479
    ...            ${required_active_asir_BlockANTMOD}=4348
    Wait Until Keyword Succeeds    5 min    15 sec    sbts_methods.check_sbts_active_alarm
    ...                                               allowed_fault_id_list=${allowed_faults_sbts}
    ...                                               required_fault_id_list=${required_active_gnb_BlockANTMOD}
    Wait Until Keyword Succeeds    5 min    15 sec    GnbAsirOp.check_asir_active_alarm
    ...                                               allowed_fault_id_list=${allowed_faults_asir}
    ...                                               required_fault_id_list=${required_active_asir_BlockANTMOD}

Verify Alarms And Historic Alarms After Antenna Unblock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_BlockANTMOD}=61649
    ...            ${required_history_gnb_BlockANTMOD}=4479
    ...            ${allowed_history_asir_BlockANTMOD}=61648
    ...            ${required_history_asir_BlockANTMOD}=4348
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_BlockANTMOD}
    ...                                    required_fault_id_list=${required_history_gnb_BlockANTMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_asir_BlockANTMOD}
    ...                                    allowed_fault_id_list=${allowed_history_asir_BlockANTMOD}

Verify Active And Historic Alarms After HUBMOD Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 10 61625 61074
    ...            ${allowed_faults_asir}=61648 10 4480
    ...            ${allowed_history_gnb_ResetHUBMOD}=7300 7319 61648 7313
    ...            ${allowed_history_asir_ResetHUBMOD}=4480
    ...            ${required_history_asir_ResetHUBMOD}=10
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_gnb_ResetHUBMOD}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_asir_ResetHUBMOD}
    ...                                    allowed_fault_id_list=${allowed_history_asir_ResetHUBMOD}

Perform Full gNB And ASiR Commissioning
    [Arguments]    ${gnb_commisioning_path}
    ...            ${asir_commissioning_path}
    GnbCommissioningOp.perform_bts_full_commissioning    scf_file=${gnb_commisioning_path}
    ...                                                  timeout=${600}
    GnbAsirOp.perform_asir_commissioning    scf_path=${asir_commissioning_path}
    ...                                     migrate_nidd=${False}
