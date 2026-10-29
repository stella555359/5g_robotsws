*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.ru.GnbRu    WITH NAME      gnbru
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.combined.CombinedGnbKeywords    WITH NAME    gnbcombined


*** Keywords ***
Unlock Radio Unit on gNB
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=1    ${du_id}=${0}
    [Documentation]    Unlock radio unit on gNB.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param radio_unit_id:      radio unit id
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.unlock_radio_unit    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Lock Radio Unit on gNB
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=1    ${du_id}=${0}
    [Documentation]    Lock radio unit on gNB.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param radio_unit_id:      radio unit id
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.lock_radio_unit    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Unlock All Radio Units on gNB
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Unlock radio unit on gNB.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.unlock_all_radio_unit    bts_id=${gnb_id}    du_id=${du_id}

Unlock Radio Unit on gNB from GUI
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=1    ${du_id}=0
    [Documentation]    Unlock radio unit on gNB from GUI.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param radio_unit_id:      radio unit id
    gnbru.unlock_radio_unit_from_GUI    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Lock Radio Unit on gNB from GUI
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=1    ${du_id}=0
    [Documentation]    Lock radio unit on gNB from GUI.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param radio_unit_id:      radio unit id
    gnbru.lock_radio_unit_from_GUI    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Lock All Radio Units on gNB
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Lock radio unit on gNB.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.lock_all_radio_unit    bts_id=${gnb_id}    du_id=${du_id}

Reset gNB Radio Unit
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=1    ${du_id}=${0}
    [Documentation]    Reset radio unit with specified number from gNB side.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param radio_unit_id:      number of radio unit
    gnbru.reset_radio_unit    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Reset All Radio Units on gNB
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Reset all radio units from gNB side.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.reset_all_radio_unit    bts_id=${gnb_id}    du_id=${du_id}

Verify All Radio Module Status
    [Arguments]   ${gnb_id}=0   ${bts_state}=online    ${du_id}=${0}
    [Documentation]   Verify is rmod status correct.
    ...     :param gnb_id:             GNB id - ID related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param bts_state           Status of BTS, default is online.
    gnbru.verify_all_radio_module_status   bts_id=${gnb_id}  bts_state=${bts_state}    du_id=${du_id}

Reset gNB Radio Unit from GUI
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=1    ${du_id}=${0}
    [Documentation]    Reset radio unit with specified number from gNB side.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param radio_unit_id:      number of radio unit, default value is 1
    gnbru.reset_radio_unit_from_GUI    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Reset All gNB Radio Units from GUI
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Reset all radio unit available on gNB from gNB side.
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.reset_all_radio_unit_from_GUI    bts_id=${gnb_id}    du_id=${du_id}

Power Reset gNB Radio Unit
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=0    ${du_id}=${0}
    [Documentation]   Power reset Radio Unit with given radio_unit_id. Configured PDU is requiered.
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param radio_unit_id:    position of RU in rus table from Test Line configuration. Default: 0
    gnbru.power_reset_radio_unit    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}

Power Reset All gNB Radio Units
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]   Power reset all Radio Unit available on gNB. Configured PDU is requiered.
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.power_reset_radio_unit    bts_id=${gnb_id}    du_id=${du_id}

Get DHCP Config For All Radio Units
    [Arguments]     ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Get configuration from DHCP for all available radio units
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ${return_value}      gnbru.get_valid_dhcp_leases     bts_id=${gnb_id}    du_id=${du_id}
    [Return]   ${return_value}

Verify RAC and RAU are Online
    [Arguments]   ${gnb_id}=0    ${du_id}=${0}
    [Documentation]   Verify if RAC and RAU are online
    ...     :param gnb_id:             GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.verify_if_rau_and_rac_are_online   bts_id=${gnb_id}    du_id=${du_id}

Verify Connection to All Radio Units
    [Arguments]   ${dhcp_dict}   ${gnb_id}=0    ${du_id}=${0}
    [Documentation]     Connect via ssh with all radio units connected to BTS
    ...   :param dhcp_dict:    dictionary with dhcp config
    ...   :param gnb_id:       GNB id - related to Test Line configuration.
    ...   :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.verify_connection_with_all_ru   dhcp_dict=${dhcp_dict}   bts_id=${gnb_id}    du_id=${du_id}

Verify gNB Radio Unit Certificate Integrity
    [Arguments]    ${certificate_file_name}    ${gnb_id}=0    ${radio_unit_id}=0    ${certificate_dir}=/etc/ssl/certs/
    ...            ${du_id}=${0}
    [Documentation]    Verify that radio unit certificate file is present and verify it's integrity.
    ...    :param certificate_file_name:    name of certificate file.
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param radio_unit_id:    radio unit id - related to Test Line configuration. Default: 0
    ...    :param certificate_dir:    directory where certificate file is located. Default: /etc/ssl/certs/
    gnbru.verify_ru_certificate_integrity    gnb_id=${gnb_id}   radio_unit_id=${radio_unit_id}
    ...    certificate_dir=${certificate_dir}    certificate_file_name=${certificate_file_name}    du_id=${du_id}

Verify All gNB Radio Units Certificate Integrity
    [Arguments]    ${certificate_file_name}    ${gnb_id}=0    ${certificate_dir}=/etc/ssl/certs/    ${du_id}=${0}
    [Documentation]    Verify that on all radio units certificate file is present and verify it's integrity.
    ...    :param certificate_file_name:    name of certificate file.
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param certificate_dir:    directory where certificate file is located. Default: /etc/ssl/certs/
    gnbru.verify_ru_certificate_integrity    gnb_id=${gnb_id}    certificate_dir=${certificate_dir}
    ...    certificate_file_name=${certificate_file_name}    du_id=${du_id}

Verify Configuration Parameter in gNB Soap Logs
    [Arguments]    ${rx_tx_parameters}=None    ${parameters}=None   ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Verify if rx and tx parameters have the same values and if other parameter is equal given value
    ...     :param rx_tx_parameters: list of parameters to find in soap logs in rx and tx
    ...     :param parameters: list of parameters to check in soap logs if they values are between 0 and 255
    ...     :param gnb_id: gNB id - related to Test Line configuration. Default: 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.verify_configuration_parameters_in_soap_logs   rx_tx_parameters=${rx_tx_parameters}   parameters=${parameters}
    ...                                    bts_id=${gnb_id}    du_id=${du_id}

Radio Unit Power Off on gNB
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=0    ${du_id}=${0}    ${confirm}=${True}
    [Documentation]    Power off radio unit using pdu
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param radio_unit_id:    position of RU in rus table from Test Line configuration. Default: 0
    ...    :param confirm: if true set value will be checked afterwards and if it is not set the exception is raised
    gnbru.radio_unit_power_off    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}    confirm=${confirm}

All Radio Units Power Off on gNB
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}    ${confirm}=${True}
    [Documentation]    Power off all radio units on given gNB using pdu. Configured PDU is required.
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param confirm: if true set value will be checked afterwards and if it is not set the exception is raised
    gnbru.radio_unit_power_off    bts_id=${gnb_id}    du_id=${du_id}    confirm=${confirm}

Radio Unit Power On on gNB
    [Arguments]    ${gnb_id}=0    ${radio_unit_id}=0    ${du_id}=${0}    ${confirm}=${True}
    [Documentation]    Power on radio unit using pdu
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param radio_unit_id:    position of RU in rus table from Test Line configuration. Default: 0
    ...    :param confirm: if true set value will be checked afterwards and if it is not set the exception is raised
    gnbru.radio_unit_power_on    bts_id=${gnb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}    confirm=${confirm}

All Radio Units Power On on gNB
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}    ${confirm}=${True}
    [Documentation]    Power on all radio units on given gNB using pdu. Configured PDU is required.
    ...    :param gnb_id:    gNB id - related to Test Line configuration. Default: 0
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param confirm: if true set value will be checked afterwards and if it is not set the exception is raised
    gnbru.radio_unit_power_on    bts_id=${gnb_id}    du_id=${du_id}    confirm=${confirm}

Verify RU Restart Occured
    [Arguments]    ${gnb_id}=0      ${time}=120        ${ru_id}=0    ${du_id}=${0}
    [Documentation]        Verifies if RU uptime is shorter that given time, indicating that Ru restart occurred.
    ...    :param bts_id:          BTS id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param time:            Time in seconds, that will be compared to uptime
    ...    :param ru_id:           Radio Unit id - related to Test Line configuration
    gnbru.verify_ru_restart_occured    bts_id=${gnb_id}     time=${time}    ru_id=${ru_id}    du_id=${du_id}

Get Count Of Radio Extension Modules
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${None}
    [Documentation]    Get count of radio extension modules from testline configuration
    ...    :param bts_id:          BTS id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param ru_id: Radio unit id
    ...    :return: count of radio extension modules
    ${return_value}      gnbru.get_count_of_radio_extension_modules   bts_id=${gnb_id}  du_id=${du_id}    ru_id=${ru_id}
    [Return]   ${return_value}

Get Count Of Radios
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Get count of radios in Test Line configuration
    ...    :param bts_id:          BTS id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :return: count of radios
    ${return_value}      gnbru.get_count_of_radios   bts_id=${gnb_id}  du_id=${du_id}
    [Return]   ${return_value}

Verify Restart Occured On All RU
    [Arguments]    ${gnb_id}=0      ${time}=120    ${du_id}=${0}
    [Documentation]        Verifies if RU uptime is shorter that given time, indicating that Ru restart occurred.
    ...    :param bts_id:          BTS id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param time:            Time in seconds, that will be compared to uptime
    ...    :param ru_id:           Radio Unit id - related to Test Line configuration
    gnbru.verify_restart_occured_on_all_ru    bts_id=${gnb_id}     time=${time}    du_id=${du_id}

Verify gNB Radio Unit Configuration via GUI
    [Arguments]    ${gnb_id}=0    ${ru_id}=0      ${du_id}=${0}
    [Documentation]    Verify if Radio unit GUI config is correct
    ...    :param bts_id:          BTS id - related to Test Line configuration.
    ...    :param ru_id: Radio unit id
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.verify_ru_configuration_via_gui    bts_id=${gnb_id}     ru_id=${ru_id}    du_id=${du_id}

Add New RMOD Based On Existing RMOD To Configuration via GUI
    [Arguments]    ${prodCodePlanned}    ${rmod_id_to_copy_from}    ${rmod_id}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]        Adds a new RMOD object to configuration based on an existing RMOD object
    ...    :param prodCodePlanned:          value of prodCodePlanned parameter of new RMOD
    ...    :param rmod_id_to_copy_from:     id of RMOD that new RMOD will be based on
    ...    :param rmod_id:                  id of the new RMOD
    ...    :param gnb_id:                   gNB id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.add_new_rmod_based_on_existing_rmod_to_configuration_via_gui    prodCodePlanned=${prodCodePlanned}
    ...    rmod_id_to_copy_from=${rmod_id_to_copy_from}    rmod_id=${rmod_id}    bts_id=${gnb_id}    du_id=${du_id}

Add New LOGLINK via GUI
    [Arguments]    ${loglinkId}    ${loglinkName}    ${first_rmod_id}    ${second_rmod_id}    ${gnb_id}=${0}
    ...            ${du_id}=${0}
    [Documentation]        Adds a new RMOD object to configuration based on an existing RMOD object
    ...    :param loglink_id:                id of the new loglink
    ...    :param loglinkName:               name of the new loglink
    ...    :param first_rmod_id:             first endpoint RMOD id
    ...    :param second_rmod_id:            second endpoint RMOD id
    ...    :param gnb_id:                    gNB id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.add_new_loglink_via_gui    ${loglinkId}    ${loglinkName}    ${first_rmod_id}    ${second_rmod_id}
    ...    bts_id=${gnb_id}    du_id=${du_id}

Set LOGLINK Name via GUI
    [Arguments]    ${loglinkId}    ${loglinkName}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]         Change name of existing loglink to incorrect and verify validation error
    ...    :param loglinkId:               id of the existing loglink
    ...    :param loglinkName:             name of the loglink
    ...    :param gnb_id:                  bts id - related to Test Line configuration.
    ...    :param du_id:                   DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.set_loglink_name_via_gui    ${loglinkId}    ${loglinkName}    bts_id=${gnb_id}    du_id=${du_id}

Set Incorrect LOGLINK Name And Verify Error via GUI
    [Arguments]    ${loglinkId}    ${loglinkName}    ${error_content}=EXTMOD-1    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]         Change name of existing loglink to incorrect and verify validation error
    ...    :param loglinkId:               id of the existing loglink
    ...    :param loglinkName:             incorrect name of the loglink
    ...    :param error_content            content of validation error message to compare
    ...    :param gnb_id:                  bts id - related to Test Line configuration.
    ...    :param du_id:                   DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.set_incorrect_loglink_name_and_verify_error_via_gui    ${loglinkId}    ${loglinkName}    ${error_content}
    ...    bts_id=${gnb_id}    du_id=${du_id}

Verify RU LED Status Is Online via GUI
    [Arguments]  ${gnb_id}=0    ${du_id}=0  ${ru_id}=0
    [Documentation]     Verifies if Radio Unit LED status icon is in the Online state. Checked from the GUI
    ...     :param bts_id:      BTS id - related to Test Line configuration.
    ...     :param du_id:       Distribution Unit id - related to Test Line configuration
    ...     :param ru_id:       Radio Unit id - related to Test Line configuration
    gnbru.verify_radio_unit_online_led_status   bts_id=${gnb_id}    du_id=${du_id}     ru_id=${ru_id}

Verify RU LED Status Is NotInstalled via GUI
    [Arguments]  ${gnb_id}=0    ${du_id}=0  ${ru_id}=0
    [Documentation]     Verifies if Radio Unit LED status icon is in the Online state. Checked from the GUI
    ...     :param bts_id:      BTS id - related to Test Line configuration.
    ...     :param du_id:       Distribution Unit id - related to Test Line configuration
    ...     :param ru_id:       Radio Unit id - related to Test Line configuration
    gnbru.verify_radio_unit_not_installed_led_status   bts_id=${gnb_id}    du_id=${du_id}     ru_id=${ru_id}

Verify RU LED Status Is Offline via GUI
    [Arguments]  ${gnb_id}=0    ${du_id}=0  ${ru_id}=0
    [Documentation]     Verifies if Radio Unit LED status icon is in the Offline state. Checked from the GUI
    ...     :param bts_id:      BTS id - related to Test Line configuration.
    ...     :param du_id:       Distribution Unit id - related to Test Line configuration
    ...     :param ru_id:       Radio Unit id - related to Test Line configuration
    gnbru.verify_radio_unit_offline_led_status   bts_id=${gnb_id}    du_id=${du_id}     ru_id=${ru_id}

Add Extension Panel And Configure Proper Beamset via GUI
    [Arguments]    ${number_of_extenders}    ${prodCodePlanned}    ${first_rmod_id}    ${second_rmod_id}
    ...            ${loglinkId}    ${basicBeamSet}    ${cell_id}=${None}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]         Configure extension panel or panels and set proper beamset values for given configuration.
    ...    :param number_of_extenders:      number of extenders to configure
    ...    :param prodCodePlanned:          value of prodCodePlanned parameter of extension panel
    ...    :param first_rmod_id:            id of existing RMOD corresponding to radio unit
    ...    :param second_rmod_id:           id of new RMOD corresponding to extension panel
    ...    :param loglink_id:               id of the new loglink
    ...    :param basicBeamSet              dict with beam set and angles e.g.
    ...                                     basicBeamSet = {
    ...                                     "Basic Beam Set": "beamSetFR2_6_6_4_2P",
    ...                                     "Left Cell Edge Angle": "90",
    ...                                     "Lower Cell Edge Angle": "110",
    ...                                     "Right Cell Edge Angle": "90",
    ...                                     "Upper Cell Edge Angle": "90"
    ...                                     }
    ...    :param cell_id                   cell id value - set to None to configure beam sets for all cells
    ...    :param gnb_id:                   gnb id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbcombined.add_extension_panel_and_configure_proper_beamset_via_gui    ${number_of_extenders}
    ...    ${prodCodePlanned}    ${first_rmod_id}    ${second_rmod_id}    ${loglinkId}    ${basicBeamSet}
    ...    cell_id=${cell_id}    bts_id=${gnb_id}    du_id=${du_id}

Verify If All Radio Modules Online
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}
    [Documentation]   Verify if all radio modules availability statuses are online.
    ...     :param gnb_id:             GNB id - ID related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.verify_if_all_radio_modules_online   bts_id=${gnb_id}    du_id=${du_id}

Update Ru IP Address If Neeeded
    [Arguments]  ${gnb_id}=0    ${du_id}=0
    [Documentation]     Update the radio unit the conenction params: contanier id and IP address.
    ...     :param bts_id:      BTS id - related to Test Line configuration.
    ...     :param du_id:       Distribution Unit id - related to Test Line configuration
    gnbru.update_ru_ip_address_if_needed   bts_id=${gnb_id}    du_id=${du_id}

Provoke RU Supervision Failure
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]     Provokes RU supervision failures by blocking communication, using iptables rules.
    ...    :param bts_id:  BTS id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.provoke_ru_supervision_failure  bts_id=${gnb_id}    du_id=${du_id}


Restore RU Supervision
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]     Restores RU supervision by removinf iptables rules.
     ...   :param bts_id:  BTS id - related to Test Line configuration.
     ...   :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbru.restore_ru_supervision  bts_id=${gnb_id}    du_id=${du_id}

Verify statuses on RU
    [Arguments]    ${gnb_id}=${0}   ${DU}=${1}    ${RU_id}=${1}    ${operationalState}=enabled    ${proceduralStatus}=configured
    ...    ${availabilityStatus}=online    ${administrativeState}=unlocked
    [Documentation]   Verify Ru statuses: operationalState, proceduralState, availabilityStatus, administrativeState.
    ...     :param gnb_id:             GNB id - ID related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param ru_id:             RU id - ID related to Test Line configuration.
    gnbru.verify_statuses_on_ru    bts_id=${gnb_id}    du_id=${DU}    ru_id=${RU_id}    operational_state=${operationalState}
    ...    procedural_status=${proceduralStatus}    availability_status=${availabilityStatus}
    ...    administrative_state=${administrativeState}

Collect Css Shell logs from all Radio Units
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}  ${log_dir}=${None}
    [Documentation]     Collects Css Shell logs from all Radio Units.
     ...   :param gnb_id:      gNB id - related to Test Line configuration.
     ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
     ...   :param log_dir:     local directory path where logs will be downloaded.
     ...                       If None - default logs dir will be used: ${OUTPUT DIR}/Logs/<timestamp>
     gnbru.collect_ccs_shell_logs  bts_id=${gnb_id}    du_id=${du_id}  log_dir=${log_dir}

Disable Beams on Main RU
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    [Documentation]    Disable beams on main radio unit.
    ...   :param gnb_id:      gNB id - related to Test Line configuration.
    ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...   :param ru_id:       RU id - ID related to Test Line configuration.
    gnbru.disable_beams    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}

Enable Beams on Main RU
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    [Documentation]    Enable beams on main radio unit.
    ...   :param gnb_id:      gNB id - related to Test Line configuration.
    ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...   :param ru_id:       RU id - ID related to Test Line configuration.
    gnbru.enable_beams    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}

Disable Beams on First Extension Panel
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    [Documentation]    Disable beams on first extension panel.
    ...   :param gnb_id:      gNB id - related to Test Line configuration.
    ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...   :param ru_id:       RU id - ID related to Test Line configuration.
    gnbru.disable_beams    panel_id=${1}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}

Enable Beams on First Extension Panel
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    [Documentation]    Enable beams on first extension panel.
    ...   :param gnb_id:      gNB id - related to Test Line configuration.
    ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...   :param ru_id:       RU id - ID related to Test Line configuration.
    gnbru.enable_beams    panel_id=${1}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}

Disable Beams on Second Extension Panel
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    [Documentation]    Disable beams on second extension panel.
    ...   :param gnb_id:      gNB id - related to Test Line configuration.
    ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...   :param ru_id:       RU id - ID related to Test Line configuration.
    gnbru.disable_beams    panel_id=${2}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}

Enable Beams on Second Extension Panel
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    [Documentation]    Enable beams on second extension panel.
    ...   :param gnb_id:      gNB id - related to Test Line configuration.
    ...   :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...   :param ru_id:       RU id - ID related to Test Line configuration.
    gnbru.enable_beams    panel_id=${2}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
