*** Settings ***
Documentation
...   Common keywords for test suite for regression testing of feature CB010969
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      Collections
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations            WITH NAME   GnbRadio
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations       WITH NAME    asir
Library     ./resources.py                                                        WITH NAME    local_resources
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                WITH NAME    gnb_du
Library      taf.sbts.oam.coam.admin                                                    WITH NAME    admin
Variables    ./common_variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Common Suite Setup With OnAir Test Line Preparation
    [Arguments]    ${prefix_tag}=${None}
    ...            ${scfs_path}=${False}
    ...            ${swconfig_from_path}=commissionings/Krakow/swconfig/default_swconfig.txt
    ...            ${upload_swconfig_to_neighbour}=${False}
    ...            ${should_LTE_neighbour_be_changed}=${False}
    ...            ${should_5G_neighbour_be_changed}=${False}
    ...            ${incompatible_error_timer}=${False}
    ...            ${increase_timeout_for_update_sw}=${False}
    ...            ${increase_time_for_checking_bbmod}=${False}
    ...            ${increase_time_for_checking_radios}=${False}
    ...            ${increase_time_for_checking_cells}=${False}
    ...            ${increase_time_for_checking_X2link}=${False}
    ...            ${neighbour_incompatible_error_timer}=${False}
    ...            ${neighbour_increase_timeout_for_update_sw}=${False}
    ...            ${increase_time_for_checking_neighbour_bbmod}=${False}
    ...            ${increase_time_for_checking_neighbour_radios}=${False}
    ...            ${increase_time_for_checking_neighbour_cells}=${False}
    ...            ${list_of_additional_allowed_alarms}=${False}
    ...            ${check_truck_roll}=${True}
    ...            ${wait_for_on_air}=${True}
    ...            ${wtd_sfp_wa_support}=${False}
    tl_prep.Power On All PDU Ports

    Run Keyword If    '${prefix_tag}' != 'None'               Set Global Variable    ${current_config}    ${prefix_tag}
    Add to Allowed Alarms During TL Preparation    additional_allowed_alarms=${list_of_additional_allowed_alarms}
    gnb_alarm.Start watching alarms     allowed_alarms=${ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                                 interface=lmp
    ...                                 log_dir=${LOG_PATH}/preparation

    tl_prep.prepare_testline    scfs_path=${scfs_path}
    ...                         scf_prefix_tag=${prefix_tag}
    ...                         swconfig_from_path=${swconfig_from_path}
    ...                         upload_swconfig_to_neighbour=${upload_swconfig_to_neighbour}
    ...                         wait_for_on_air=${wait_for_on_air}
    ...                         should_LTE_neighbour_be_changed=${should_LTE_neighbour_be_changed}
    ...                         should_5G_neighbour_be_changed=${should_5G_neighbour_be_changed}
    ...                         incompatible_error_timer=${incompatible_error_timer}
    ...                         increase_timeout_for_update_sw=${increase_timeout_for_update_sw}
    ...                         increase_time_for_checking_bbmod=${increase_time_for_checking_bbmod}
    ...                         increase_time_for_checking_radios=${increase_time_for_checking_radios}
    ...                         increase_time_for_checking_cells=${increase_time_for_checking_cells}
    ...                         increase_time_for_checking_X2link=${increase_time_for_checking_X2link}
    ...                         neighbour_incompatible_error_timer=${neighbour_incompatible_error_timer}
    ...                         neighbour_increase_timeout_for_update_sw=${neighbour_increase_timeout_for_update_sw}
    ...                         increase_time_for_checking_neighbour_bbmod=${increase_time_for_checking_neighbour_bbmod}
    ...                         increase_time_for_checking_neighbour_radios=${increase_time_for_checking_neighbour_radios}
    ...                         increase_time_for_checking_neighbour_cells=${increase_time_for_checking_neighbour_cells}
    ...                         wtd_sfp_wa_support=${wtd_sfp_wa_support}

    Common Suite Setup    check_truck_roll=${False}

    ${connection}    admin.Connect To
    admin.set_certificate_automatic_management
    ...     reference_number=${ref_num}
    ...     preshared_key=${pre_key}
    ...     connection=${connection}
    admin.cmp_initialize_certificate
    ...     connection=${connection}
    logger.Log Info To Console      CMP Cert initialized
    [Teardown]    Common Suite Setup With OnAir Test Line Preparation Teardown    check_truck_roll=${check_truck_roll}

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

SISO reset all pRRHs
    [Arguments]    ${prrh_to_reset}=${None}
    local_resources.action_with_prrhs    action=Reset    prrh_id=${prrh_to_reset}
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair


Configuration Reset Of The AsirWebEM
    [Arguments]    ${file_path}=/tmp        ${asir_file_name}=initial_configuration_asir.xml
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${file_path}    file_name=${asir_file_name}
    asir.Reset Configuration
    Verify Disabled Status
    Verify RU Status After Asir Configuration Reset
    asir.perform_asir_commissioning    scf_path=${asir_path}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair

Verify Disabled Status
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRadio.wait_for_all_radio_unit_statuses    radio_type=asirmod
    ...                            operational_state=disabled

Verify RU Status After Asir Configuration Reset
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRadio.verify_all_radio_units_are_online    radio_type=asirmod




