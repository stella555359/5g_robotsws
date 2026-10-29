*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com, Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    Maintainer: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    CB014634


Library    BuiltIn
Library    SSHLibrary
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    RuOp
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    CellOp
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    CommOp
Library    taf.rfrl.procedures.resources.python.LogCollection    WITH NAME    logs
Library    testsuite.Krakow.SISO.resources.RAN_PZ_KRK2.Blackbox.RmodOpCustom    WITH NAME    RMod
Library    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/Blackbox/blackbox.py
Library    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/Blackbox/verification_methods/power_sequencer.py
Library    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/Blackbox/verification_methods/voltage_current.py
Library    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/Blackbox/verification_methods/ipsec.py
Library    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/Blackbox/verification_methods/firmware_version.py
Library    ./python_keywords.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./delta_ipsec.py


*** Variables ***
@{RU_IDS_TO_VERIFY_POWERSEQUENCER}=    ${0}
@{RU_IDS_TO_VERIFY_VOLTAGE_AND_CURRENT}=    ${0}
@{RU_IDS_TO_VERIFY_IPSEC}=    ${0}
@{RU_IDS_TO_VERIFY_FIRMWARE}=    ${2}

*** Keywords ***
Wait For All Cells To Be Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    CellOp.verify_all_cells_are_onair

Reset All RUs
    RuOp.reset_all_radio_unit    timeout=${600}
    Wait For All Cells To Be Operating Correctly

Prepare Env
    Prepare Log Directories
    RMod.get_all_rus_credentials

Enable IPSec
    CommOp.perform_bts_delta_commissioning    delta=${delta_ipsec}
    BuiltIn.Sleep    30 sec    reason=Waiting for commissioning to be applied and reboot started
    Wait Until Keyword Succeeds    25 min    30 sec    CellOp.verify_all_cells_are_onair

Save Current Timestamp
    ${date}    get_current_date_in_utc_format
    Set Test Variable    ${SAVED_TIMESTAMP}    ${date}

Prepare Log Directories
    Set Test Variable    ${blackbox_file_path}    ${OUTPUT_DIR}/${TEST_NAME}/blackbox_files
    logs.create_dir_if_doesnt_exist    dir_path=${blackbox_file_path}

Validate PowerSequencer Before RU Reboots
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_POWERSEQUENCER}
        Run Keyword And Continue On Failure    Download And Validate Blackbox PowerSequencer
        ...                                    suffix=_initial
        ...                                    ru_id=${ru_id}
    END

Validate PowerSequencer After RU Reboots
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_POWERSEQUENCER}
        Run Keyword And Continue On Failure    Download And Validate Blackbox PowerSequencer
        ...                                    suffix=_reboot
        ...                                    ru_id=${ru_id}
    END

Download And Validate Blackbox PowerSequencer
    [Arguments]    ${suffix}    ${ru_id}=${1}
    ${blackbox_file}    RMod.download_blackbox_file_from_ru    download_path=${blackbox_file_path}
    ...                                                        ru_id=${ru_id}
    ...                                                        suffix=${suffix}
    ${status}    ${fields}    validate_blackbox    ${blackbox_file}
    ...                       validate_power_sequencer_first_and_last_entries
    ...                       validate_power_sequencer_fields
    ...                       get_power_sequencer_fields
    Set Test Variable    ${${ru_id}_power_sequencer_fields_${suffix}}    ${fields}

Validate PowerSequencer On RU
    [Arguments]    ${ru_id}
    Run Keyword If    ${ru_id} in @{RU_IDS_TO_VERIFY_POWERSEQUENCER}
    ...               Download And Validate Blackbox PowerSequencer    ru_id=${ru_id}

Compare Last Entries For Changes
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_POWERSEQUENCER}
        ${last_entry_activation}=    Set Variable    ${${ru_id}_power_sequencer_fields_initial}[get_power_sequencer_fields][Last 5 entries]
        ${last_entry_reset}=    Set Variable    ${${ru_id}_power_sequencer_fields_reboot}[get_power_sequencer_fields][Last 5 entries]
        Should Not Be Equal    ${last_entry_activation}    ${last_entry_reset}
    END

Download Blackbox And Validate Voltage And Current Fields
    [Arguments]    ${ru_id}    ${destination_path}
    logs.create_dir_if_doesnt_exist    dir_path=${destination_path}
    ${blackbox_file}    RMod.download_blackbox_file_from_ru    download_path=${destination_path}    ru_id=${ru_id}
    ${status}    ${fields}    validate_blackbox    ${blackbox_file}
    ...                       validate_voltage_fields
    ...                       validate_current_fields
    ...                       validate_first_write_last_write_and_isti_for_voltage_and_current
    ...                       get_voltage_histograms
    ...                       get_current_histograms
    [Return]    ${fields['get_voltage_histograms']}    ${fields['get_current_histograms']}


Validate IPSec Is Disabled In Blackbox
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_IPSEC}
        Run Keyword And Continue On Failure    Download And Validate Blackbox IPSec
        ...                                    suffix=_ipsec_disabled
        ...                                    ipsec_expected_activationStatus=disabled
        ...                                    ipsec_expected_isSecured=false
        ...                                    ipsec_expected_ports=Port<0-3>
        ...                                    ru_id=${ru_id}
    END

Validate IPSec Is Enabled In Blackbox
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_IPSEC}
        Run Keyword And Continue On Failure    Download And Validate Blackbox IPSec
        ...                                    suffix=_ipsec_enabled
        ...                                    ipsec_expected_activationStatus=enabled
        ...                                    ipsec_expected_isSecured=true
        ...                                    ipsec_expected_ports=Port0
        ...                                    ipsec_timestamp_before_change=${SAVED_TIMESTAMP}
        ...                                    ru_id=${ru_id}
    END

Download And Validate Blackbox IPSec
    [Arguments]    ${suffix}
    ...            ${ipsec_expected_activationStatus}
    ...            ${ipsec_expected_isSecured}
    ...            ${ipsec_expected_ports}
    ...            ${ru_id}=${1}
    ...            ${ipsec_timestamp_before_change}=${None}
    ${blackbox_file}    RMod.download_blackbox_file_from_ru    download_path=${blackbox_file_path}
    ...                                                        ru_id=${ru_id}
    ...                                                        suffix=${suffix}
    validate_blackbox    ${blackbox_file}
    ...                  validate_ipsec_status
    ...                  ipsec_expected_activationStatus=${ipsec_expected_activationStatus}
    ...                  ipsec_expected_isSecured=${ipsec_expected_isSecured}
    ...                  ipsec_expected_ports=${ipsec_expected_ports}
    ...                  ipsec_timestamp_before_change=${ipsec_timestamp_before_change}

Download Blackbox And Validate Firmware Version
    [Arguments]    ${ru_id}    ${destination_path}
    logs.create_dir_if_doesnt_exist    dir_path=${destination_path}
    ${blackbox_file}    RMod.download_blackbox_file_from_ru    download_path=${destination_path}    ru_id=${ru_id}
    ${parse_success_result}    ${elements_found_list}=  validate_blackbox    ${blackbox_file}
    ...                  validate_firmware_version
    ...                  full_validation_firmware_version


