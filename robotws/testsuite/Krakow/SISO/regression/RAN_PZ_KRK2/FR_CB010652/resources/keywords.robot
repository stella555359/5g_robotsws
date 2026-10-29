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
Library        testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.FR_CB010652.resources.GnbCustomRu    WITH NAME
...            GnbRuOp
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.SMAWave.SMAWaveTput   WITH NAME    SMAWave

Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource       ./UE_keywords.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables      ./cell_mapping.py

*** Variables ***
${BTS_ID}                     ${tl.gnbs[0].global_bts_id}
${VIRTUAL_DISPLAY}            ${True}
${CELL_ADD_DEL_ID}            ${1}
&{EXPECTED_ASIRMOD_STATUS}    availabilityStatus=Online    administrativeState=Unlocked    operationalState=Enabled

*** Keywords ***
Setup Attenuators
    Attenuator.initialise_attenuators
    Attenuator.set_max_attenuation_on_all_attenuators

Set Allowed Alarms For ASiR
    Set Test Variable    @{allowed_alarms_asir}    ${61648}    ${4481}    ${4459}

Set Allowed Alarms With Diagnostic Files
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled
    ...                                         Radio Diagnostic Files collected

Log Current Time
    ${saved_time}    DateTime.Get Current Date    result_format=epoch    exclude_millis=True
    Set Test Variable    ${START_TIME}    ${saved_time}

Verify ASiR Alarms
    Wait Until Keyword Succeeds    1 min    15 sec    GnbAsirOp.verify_only_allowed_alarms_are_active    allowed_alarms=@{allowed_alarms_asir}

Verify All Cells Are Operating Correctly
    GnbCellOp.verify_setup_of_all_cells

Wait For All Cells To Be Operating Correctly
    Wait Until Keyword Succeeds    8 min    15 sec    Verify All Cells Are Operating Correctly

Prepare ASiR WebEM Browser
    AsirWebEM.clean_browser
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}
    AsirWebEM.login

Close ASiR WebEM Browser
    Run Keyword And Continue On Failure    AsirWebEM.logout
    Run Keyword And Continue On Failure    AsirWebEM.clean_browser

Verify Cell Status On ASiR WebEM
    Prepare ASiR WebEM Browser
    AsirWebEM.check_asir_cell_status    cell_type=ALL    expected_status=Green
    [Teardown]    Close ASiR WebEM Browser

Reset ANTMOD On ASiR WebEM
    [Arguments]    ${antmod_id}
    Prepare ASiR WebEM Browser
    AsirWebEM.reset_antmod    ant_mod_id=${antmod_id}    timeout=${400}
    [Teardown]    Close ASiR WebEM Browser

Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Wait Until Keyword Succeeds    5 min    30 sec    Verify Cell Status On ASiR WebEM

Wait Until All BTS Antennas Are Available
    Wait Until Keyword Succeeds    5 min    30 sec    GnbAsirOp.verify_all_antennas_status

Reset All ANTMODs On ASiR WebEM
    ${antennas}    GnbAsirOp.get_all_antenna_ids
    FOR    ${ant}    IN    @{antennas}
        Reset ANTMOD On ASiR WebEM    antmod_id=${ant}
    END

Block And Unblock All ANTMODs One By One On ASiR WebEM
    ${antennas}    GnbAsirOp.get_all_antenna_ids
    FOR    ${ant}    IN    @{antennas}
        Run Keyword And Continue On Failure    Block And Unblock Single ANTMOD On ASiR WebEM    antmod_id=${ant}
    END


Block And Unblock Single ANTMOD On ASiR WebEM
    [Arguments]    ${antmod_id}
    Prepare ASiR WebEM Browser
    AsirWebEM.block_antmod    ant_mod_id=${antmod_id}
    Wait Until Keyword Succeeds    1 min    30 sec    GnbAsirOp.check_asir_active_alarm
    ...                                               required_fault_id_list=4348
    AsirWebEM.unblock_antmod    ant_mod_id=${antmod_id}
    Wait Until Keyword Succeeds    1 min    30 sec    GnbAsirOp.check_asir_active_alarm
    ...                                               forbidden_fault_id_list=4348
    [Teardown]    Close ASiR WebEM Browser

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

Verify ASIRMOD Status
    sbts_methods.check_asirmod_status    expected_status_dict=${EXPECTED_ASIRMOD_STATUS}

Verify Alarms After Antenna Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_ResetANTMOD}=7313 61649 4003
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
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 61625 61074
    ...            ${allowed_faults_asir}=61648
    ...            ${allowed_history_gnb_BlockANTMOD}=7313 61649 4003
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

Reset BTS Via WebEM
    GnbDuOp.reset_bts_via_gui
    GnbDuOp.wait_for_site_to_be_not_onair
    GnbDuOp.wait_for_site_to_be_onair

Reset All BTS Antennas Via WebEM
    GnbRuOp.reset_all_radio_unit_via_gui

Run Throughputs On Selected Cell
    [Arguments]    ${selected_cell}
    Prepare Call To Selected Cell    selected_cell=${selected_cell}

Run Max Throughput On All Cells One By One
    [Arguments]    ${max_throughput_deviation}=20%
    Set Test Variable    @{selected_cells}    @{mapping}[${CONFIG}]
    FOR    ${cell}    IN     @{selected_cells}
        Log To Console    ${cell}
        Perform Call On Selected Cell    cell=${cell}
        ...                              max_throughput_deviation=${max_throughput_deviation}
    END

Run Throughput On All Cells One By One
    [Arguments]    ${max_throughput_deviation}=20.0%    ${skip_cell}=${None}
    Set Test Variable    @{selected_cells}    @{mapping}[${CONFIG}]
    FOR    ${cell}    IN    @{selected_cells}
        Log To Console    ${cell}
        Run Keyword If    '${CONFIG}' == 'C'    Block All Cells For L3Call    ${cell}[cells_to_block]
        Run Keyword If    '${CONFIG}' == 'C'    Wait Until Keyword Succeeds    1 min    15 sec    Verify All Cells Are Blocked For L3Call
        ...                                                                                       ${cell}[cells_to_block]
        Run Keyword If    ${skip_cell}!=${cell}    Perform Call On Selected Cell
        ...                                        cell=${cell}
        ...                                        max_throughput_deviation=${max_throughput_deviation}
        Run Keyword If    '${CONFIG}' == 'C'    Unblock All Cells For L3Call    ${cell}[cells_to_block]
        Run Keyword If    '${CONFIG}' == 'C'    Wait Until Keyword Succeeds    1 min    15 sec    Verify All Cells Are Unblocked For L3Call
        ...                                                                                       ${cell}[cells_to_block]
    END

Perform Call On Selected Cell
    [Arguments]    ${cell}    ${max_throughput_deviation}=20.0%
    Run Keyword And Continue On Failure    Run Throughputs On Selected Cell
    ...                                    selected_cell=${cell}
    Run Keyword And Continue On Failure    SMAWave.run_bidirectional_traffic
    ...                                    duration_time=120
    ...                                    uepc_ip=PLKR-SG02-154.intra.noklab.net
    ...                                    uepc_username=pzkrk
    ...                                    uepc_passwd=NokiaBts2003
    ...                                    smawave_username=root
    ...                                    key_algorithm=-p 22 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa
    ...                                    smawave_ip=10.253.166.106
    ...                                    smawave_password=Jk4Ms5Lm6Gu7
    ...                                    tput_command_ul=1400
    ...                                    tput_expected_dl=${cell}[throughput_dl]
    ...                                    tput_expected_ul=${cell}[throughput_ul]
    ...                                    deviation=${max_throughput_deviation}
    ...                                    protocol=udp
    [Teardown]    Attenuate RU    attenuators=${cell}[attenuators]


Block All Cells For L3Call
    [Arguments]    ${cells_id}
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.block_cell    cell_id=${cell_id}
    END
    Sleep    10s

Verify All Cells Are Blocked For L3Call
    [Arguments]    ${cells_id}
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.verify_cell_is_blocked    cell_id=${cell_id}
    END

Unblock All Cells For L3Call
    [Arguments]    ${cells_id}
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.unblock_cell    cell_id=${cell_id}
    END

Verify All Cells Are Unblocked For L3Call
    [Arguments]    ${cells_id}
    FOR    ${cell_id}    IN    @{cells_id}
        GnbCellOp.verify_cell_is_unblocked    cell_id=${cell_id}
    END

Block And Unblock All Cells One By One Via WebEM
    Set Test Variable    @{selected_cells}    @{mapping}[${CONFIG}]
    FOR    ${cell}    IN     @{selected_cells}
        GnbCellOp.block_cell_via_gui    cell_id=${cell}[id]
        ...                             technology=${cell}[technology]
        Wait Until Keyword Succeeds    60 sec    10 sec    GnbCellOp.verify_cell_is_blocked_via_gui
        ...                                                cell_id=${cell}[id]
        ...                                                technology=${cell}[technology]
        GnbCellOp.unblock_cell_via_gui    cell_id=${cell}[id]
        ...                             technology=${cell}[technology]
        Wait Until Keyword Succeeds    60 sec    10 sec    GnbCellOp.verify_cell_is_unblocked_via_gui
        ...                                                cell_id=${cell}[id]
        ...                                                technology=${cell}[technology]
    END

Delete Cell And Run Throughput On All Remaining Cells
    GnbAsirOp.perform_asir_commissioning    scf_path=${CURDIR}/commissioning/Delta_Delete_Cell_ASiR.xml
    GnbCommissioningOp.perform_bts_delta_json_commissioning    delta_file=${CURDIR}/commissioning/Delta_Delete_Cell_BTS.json
    Wait For All Cells To Be Operating Correctly
    Run Throughput On All Cells One By One    skip_cell=${CELL_ADD_DEL_ID}

Add Cell And Run Throughput On All Cells
    GnbCommissioningOp.perform_bts_delta_json_commissioning    delta_file=${CURDIR}/commissioning/Delta_Add_Cell_BTS.json
    GnbAsirOp.perform_asir_commissioning    scf_path=${CURDIR}/commissioning/Delta_Add_Cell_ASiR.xml
    Wait For All Cells To Be Operating Correctly
    Run Throughput On All Cells One By One

Allow Alarms For ANTMOD Operations
    Allow Alarm    Failure detected on assigned antennas
    Allow Alarm    Transmission path failure
    Allow Alarm    Cell blocked

Disallow Alarms For ANTMOD Operations With Common Postconditions
    Common Postconditions With Watching Alarms
    Disallow Alarm    Failure detected on assigned antennas
    Disallow Alarm    Transmission path failure
    Disallow Alarm    Cell blocked

Allow Alarm For Site Reset
    Allow Alarm    BTS Reset Cause

Disallow Alarms For Site Reset With Common Postconditions And Logout From Gui
    Common Postconditions With Watching Alarms
    Disallow Alarm    BTS Reset Cause
    Run Keyword And Ignore Error    GnbDuOp.logout_gui

Common Postconditions And Logout From Gui
    Common Postconditions With Watching Alarms
    Run Keyword And Ignore Error    GnbDuOp.logout_gui

Allow Alarm For Cells Block
    Allow Alarm    Cell blocked

Disallow Alarms For Cells Block With Common Postconditions And Logout From Gui
    Common Postconditions With Watching Alarms
    Disallow Alarm    Cell blocked
    Run Keyword And Ignore Error    GnbDuOp.logout_gui
