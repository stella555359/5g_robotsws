*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:

Library     DateTime
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    RuOp
Library     testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB010731.resources.GnbCellCustom.GnbCellCustom   WITH NAME    CellOp
Library     testsuite/Krakow/resources/RAN_PZ_KRK2/FR_CB010731/ru_ssh_connection_handler.py   WITH NAME    ssh

Library     testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium    WITH NAME
...         AsirWebEM
Library     testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbAsir    WITH NAME
...         GnbAsirOp
Library     testsuite/Krakow/resources/RAN_PZ_KRK2/FR_CB009493_CB009055_CB009487/sbts_methods.py    WITH NAME
...         sbts_methods

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${RFSW_ACCOUNT}       rfsw
${PLTF_ACCOUNT}       pltf

@{USERS}              hubapp
...                   rfsw
...                   pltf
...                   i2c
...                   leds
...                   mtd
...                   ptp
...                   zynqmpfw
...                   pps
...                   vrha


${CHECK_FILE}         ambient-capab
@{allowed_alarms}     SSH enabled
...                   R&D Service Port enabled
...                   LMP access via port 443
...                   Service account root access is enabled
...                   Ethernet port security is disabled
...                   LMP connectivity detected
...                   Operator Certificate About to Expire or Expired

${VIRTUAL_DISPLAY}    ${True}

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

Verify ASiR Alarms
    Wait Until Keyword Succeeds    1 min    15 sec    GnbAsirOp.verify_only_allowed_alarms_are_active    allowed_alarms=@{allowed_alarms_asir}
    [Teardown]    GnbAsirOp.disconnect

CB010731 Test Teardown
    Run Keyword If Test Failed    CellOp.unblock_all_cells
    Run Keyword If Test Failed    Unblock All ASiR Antennas
    Verify ASiR Alarms
    Common Postconditions

Check New User Accounts And Groups Exist On All Hubs
    ssh.connect_to_gnb    gnb_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${ru_internal_ips}    ssh.get_all_ru_internal_ips
    FOR    ${ru}    IN    @{ru_internal_ips}
        Log To Console    Checking new user accounts and groups for RU: ${ru_internal_ips}[${ru}]:${ru}
        Check New User Accounts And Groups Exist On Hub    ru_ip=${ru}
    END
    [Teardown]    ssh.disconnect_from_gnb

Check New User Accounts And Groups Exist On Hub
      [Arguments]    ${ru_ip}

      ${check_rfsw_user}    ssh.execute_command_on_ru    ru_ip=${ru_ip}    command=cat /etc/passwd | grep ${RFSW_ACCOUNT}
      ${check_pltf_user}    ssh.execute_command_on_ru    ru_ip=${ru_ip}    command=cat /etc/passwd | grep ${PLTF_ACCOUNT}
      ${rfsw_group_users}    ssh.execute_command_on_ru    ru_ip=${ru_ip}    command=cat /etc/group | grep ${RFSW_ACCOUNT}
      ${file_list}    ssh.execute_command_on_ru    ru_ip=${ru_ip}    command=ls /usr/bin | grep ${CHECK_FILE}

      Should Start With    ${check_rfsw_user}      ${RFSW_ACCOUNT}
      Should Start With    ${check_pltf_user}      ${PLTF_ACCOUNT}

      FOR    ${user}    IN    @{USERS}
            Should Contain    ${rfsw_group_users}    ${user}
      END

      Should Not Be Empty    ${file_list}
      [Teardown]    ssh.close_channel_connection

Reset All sHUBs In WebEM
    RuOp.reset_all_radio_unit_from_GUI
    RuOp.wait_for_all_radio_unit_statuses    operational_state=disabled
    RuOp.wait_for_radio_unit_to_be_online    radio_type=asirmod    timeout=300

Block And Unblock All Cells
    CellOp.block_all_lte_cells_via_gui
    CellOp.block_all_nr_cells_via_gui
    Wait Until Keyword Succeeds    10 sec    60 sec    CellOp.verify_all_cells_are_blocked
    CellOp.unblock_all_lte_cells_via_gui
    CellOp.unblock_all_nr_cells_via_gui
    Wait Until Keyword Succeeds    10 sec    180 sec    CellOp.verify_all_cells_are_unblocked
    CellOp.wait_for_all_cells_to_be_onair
    [Teardown]    CellOp.logout_gui

Prepare ASiR WebEM Browser
    [Arguments]    ${width}=${1920}    ${height}=${1280}
    AsirWebEM.clean_browser
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}    width=${width}    height=${height}
    AsirWebEM.login

Close ASiR WebEM Browser
    Run Keyword And Continue On Failure    AsirWebEM.logout
    Run Keyword And Continue On Failure    AsirWebEM.clean_browser

Reset All HUBMODs On ASiR WebEM
    Log Current Time
    ${hubs}    GnbAsirOp.get_all_hub_ids
    GnbAsirOp.disconnect
    FOR    ${hub}    IN    @{hubs}
        Reset HUBMOD On ASiR WebEM    hubmod_id=${hub}
    END

Reset HUBMOD On ASiR WebEM
    [Arguments]    ${hubmod_id}    ${width}=${4000}    ${height}=${2500}
    Prepare ASiR WebEM Browser    width=${width}    height=${height}
    AsirWebEM.reset_hubmod    hub_mod_id=${hubmod_id}    timeout=${400}
    [Teardown]    Close ASiR WebEM Browser

Wait Until All HUBs Are Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    GnbAsirOp.verify_all_hubs_status
    [Teardown]    GnbAsirOp.disconnect

Log Current Time
    ${saved_time}    DateTime.get_current_date    result_format=epoch    exclude_millis=True
    Set Test Variable    ${START_TIME}    ${saved_time}

Verify Active And Historic Alarms After HUBMOD Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 10 61625 61074
    ...            ${allowed_faults_asir}=61648 10 4480
    ...            ${allowed_history_gnb_ResetHUBMOD}=7300 7319 61648 61649 7313
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
    [Teardown]    GnbAsirOp.disconnect

Reset All ANTMODs On ASiR WebEM
    Log Current Time
    ${ants}    GnbAsirOp.get_all_antenna_ids
    GnbAsirOp.disconnect
    FOR    ${ant}    IN    @{ants}
        Reset ANTMOD On ASiR WebEM    antmod_id=${ant}
    END

Reset ANTMOD On ASiR WebEM
    [Arguments]    ${antmod_id}
    Prepare ASiR WebEM Browser
    AsirWebEM.reset_antmod    ant_mod_id=${antmod_id}    timeout=${400}
    [Teardown]    Close ASiR WebEM Browser

Wait Until All BTS Antennas Are Available
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.verify_all_antennas_status
    [Teardown]    GnbAsirOp.disconnect

Verify Active And Historic Alarms After Antenna Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_ResetANTMOD}=7313 61648 61649
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
    [Teardown]    GnbAsirOp.disconnect

Block All Antennas In ASiR WebEM
    Log Current Time
    ${ants}    GnbAsirOp.get_all_antenna_ids
    GnbAsirOp.disconnect
    FOR    ${ant}    IN    @{ants}
        Block ANTMOD On ASiR WebEM    antmod_id=${ant}
    END

Block ANTMOD On ASiR WebEM
    [Arguments]    ${antmod_id}
    Prepare ASiR WebEM Browser
    AsirWebEM.block_antmod    ant_mod_id=${antmod_id}    timeout=${400}
    [Teardown]    Close ASiR WebEM Browser

Wait Until All Antennas Are Blocked
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.verify_all_antennas_are_blocked
    [Teardown]    GnbAsirOp.disconnect

Verify Active Alarms After Antenna Block
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
    [Teardown]    GnbAsirOp.disconnect

Verify Active BTS Alarms After RF Diagnostic Test
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074 7313
    ...            ${allowed_faults_asir}=61648
    Wait Until Keyword Succeeds    5 min    15 sec    sbts_methods.check_sbts_active_alarm
    ...                                               allowed_fault_id_list=${allowed_faults_sbts}
    Wait Until Keyword Succeeds    5 min    15 sec    GnbAsirOp.check_asir_active_alarm
    ...                                               allowed_fault_id_list=${allowed_faults_asir}
    [Teardown]    GnbAsirOp.disconnect

Unblock All Antennas In ASiR WebEM
    ${ants}    GnbAsirOp.get_all_antenna_ids
    GnbAsirOp.disconnect
    FOR    ${ant}    IN    @{ants}
        Run Keyword And Continue On Failure    Unblock ANTMOD On ASiR WebEM    antmod_id=${ant}
    END

Unblock All ASiR Antennas
    ${ants}    GnbAsirOp.get_all_antenna_ids
    FOR    ${ant}    IN    @{ants}
        Run Keyword And Continue On Failure    GnbAsirOp.unblock_antenna    ant_id=${ant}
    END
    [Teardown]    GnbAsirOp.disconnect

Unblock ANTMOD On ASiR WebEM
    [Arguments]    ${antmod_id}
    Prepare ASiR WebEM Browser
    AsirWebEM.unblock_antmod    ant_mod_id=${antmod_id}    timeout=${400}
    [Teardown]    Close ASiR WebEM Browser

Verify Alarms And Historic Alarms After Antenna Unblock
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_BlockANTMOD}=61648 61649 4003
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
    [Teardown]    GnbAsirOp.disconnect

Perform RF Diagnostic Test On BTS WebEM
    CellOp.perform_rf_diagnostic_test    output_dir=${OUTPUT DIR}
    ...                                  cells=All NR cells
    CellOp.perform_rf_diagnostic_test    output_dir=${OUTPUT DIR}
    ...                                  cells=All LTE cells
    [Teardown]    CellOp.logout_gui

Get HUB Info
    Prepare ASiR WebEM Browser
    ${shubs}    AsirWebEM.get_all_shubs
    Set Test Variable    ${SHUBS_INFO}    ${shubs}
    [Teardown]    Close ASiR WebEM Browser

Change HUB Load Balancing Energy Saving Mode
    Prepare ASiR WebEM Browser
    AsirWebEm.disable_energy_saving_status_for_hubs    hubs_data=${SHUBS_INFO}
    AsirWebEm.validate_all_hubs_are_not_in_energy_saving_mode    hubs_data=${SHUBS_INFO}
    [Teardown]    Close ASiR WebEM Browser

Get Cell Info
    ${cells}    CellOp.get_bts_cell_info
    Set Test Variable    ${CELLS_INFO}    ${cells}
    [Teardown]    CellOp.logout_gui

Get HUB And Cell Info
    Get HUB Info
    Get Cell Info

Delete All Cells In ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.delete_all_asir_cells    coam_cell_info=${CELLS_INFO}    asir_shubs=${SHUBS_INFO}
    [Teardown]    Close ASiR WebEM Browser

Verify Active BTS Alarms After Cell Deletion
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074 7313
    ...            ${required_active_gnb_ASiRCellDeletion}=4478
    Wait Until Keyword Succeeds    5 min    15 sec    sbts_methods.check_sbts_active_alarm
    ...                                               allowed_fault_id_list=${allowed_faults_sbts}
    ...                                               required_fault_id_list=${required_active_gnb_ASiRCellDeletion}

Add All Cells In ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.add_all_asir_cells    coam_cell_info=${CELLS_INFO}    asir_shubs=${SHUBS_INFO}
    [Teardown]    Close ASiR WebEM Browser

Verify Active BTS Alarms After Cell Addition
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074 7313
    ...            ${forbidden_active_gnb_ASiRCellDeletion}=4478
    Wait Until Keyword Succeeds    5 min    15 sec    sbts_methods.check_sbts_active_alarm
    ...                                               allowed_fault_id_list=${allowed_faults_sbts}
    ...                                               forbidden_fault_id_list=${forbidden_active_gnb_ASiRCellDeletion}

Wait For All Cells To Be Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    CellOp.verify_all_cells_are_onair
